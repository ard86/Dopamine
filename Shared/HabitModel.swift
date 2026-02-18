import Foundation

// MARK: - App Group identifier for sharing data between app and widget
let appGroupIdentifier = "group.com.annierdudu.dopamine.habits"

// MARK: - Habit Definition

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var emoji: String
    var appURLScheme: String   // e.g. "headspace://" or "https://..."
    var fallbackURL: String    // App Store or web URL if scheme fails
    var sortOrder: Int

    static let defaults: [Habit] = [
        Habit(
            id: UUID(),
            name: "Log Weight",
            emoji: "⚖️",
            appURLScheme: "noom://",
            fallbackURL: "https://apps.apple.com/app/noom/id634598719",
            sortOrder: 0
        ),
        Habit(
            id: UUID(),
            name: "Meditate",
            emoji: "🧘",
            appURLScheme: "headspace://",
            fallbackURL: "https://apps.apple.com/app/headspace/id493145008",
            sortOrder: 1
        ),
        Habit(
            id: UUID(),
            name: "Vision Board",
            emoji: "🎯",
            appURLScheme: "notion://",
            fallbackURL: "https://apps.apple.com/app/notion/id1232780281",
            sortOrder: 2
        ),
        Habit(
            id: UUID(),
            name: "Podcast",
            emoji: "🎧",
            appURLScheme: "spotify://",
            fallbackURL: "https://apps.apple.com/app/spotify/id324684580",
            sortOrder: 3
        ),
    ]
}

// MARK: - Daily completion record

struct DailyLog: Codable {
    var date: String // "yyyy-MM-dd"
    var completedHabitIDs: Set<UUID>
}

// MARK: - Streak Data

struct StreakInfo: Codable {
    var daily: Int
    var weekly: Int
    var monthly: Int
}

// MARK: - Persistence via App Groups (UserDefaults shared suite)

final class HabitStore {
    static let shared = HabitStore()

    private let defaults: UserDefaults

    private let habitsKey = "habits_v1"
    private let logKey = "daily_log_v1"
    private let historyKey = "log_history_v1"

    private let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()

    init() {
        self.defaults = UserDefaults(suiteName: appGroupIdentifier) ?? .standard
        if loadHabits().isEmpty {
            save(habits: Habit.defaults)
        }
    }

    // MARK: Habits CRUD

    func loadHabits() -> [Habit] {
        guard let data = defaults.data(forKey: habitsKey),
              let habits = try? JSONDecoder().decode([Habit].self, from: data)
        else { return [] }
        return habits.sorted { $0.sortOrder < $1.sortOrder }
    }

    func save(habits: [Habit]) {
        if let data = try? JSONEncoder().encode(habits) {
            defaults.set(data, forKey: habitsKey)
        }
    }

    // MARK: Daily Log

    func todayKey() -> String {
        dateFormatter.string(from: Date())
    }

    func loadTodayLog() -> DailyLog {
        let key = todayKey()
        guard let data = defaults.data(forKey: logKey),
              let log = try? JSONDecoder().decode(DailyLog.self, from: data),
              log.date == key
        else {
            return DailyLog(date: key, completedHabitIDs: [])
        }
        return log
    }

    func saveTodayLog(_ log: DailyLog) {
        if let data = try? JSONEncoder().encode(log) {
            defaults.set(data, forKey: logKey)
        }
        // Also archive into history
        archiveLog(log)
    }

    func toggleHabit(_ habitID: UUID) {
        var log = loadTodayLog()
        if log.completedHabitIDs.contains(habitID) {
            log.completedHabitIDs.remove(habitID)
        } else {
            log.completedHabitIDs.insert(habitID)
        }
        log.date = todayKey()
        saveTodayLog(log)
    }

    func isCompleted(_ habitID: UUID) -> Bool {
        loadTodayLog().completedHabitIDs.contains(habitID)
    }

    func completedCount() -> Int {
        let log = loadTodayLog()
        let habits = loadHabits()
        return habits.filter { log.completedHabitIDs.contains($0.id) }.count
    }

    func totalCount() -> Int {
        loadHabits().count
    }

    // MARK: - Wellness Goal Days

    private let wellnessKey = "wellness_days_v1"

    func loadWellnessDays() -> Set<String> {
        guard let data = defaults.data(forKey: wellnessKey),
              let days = try? JSONDecoder().decode(Set<String>.self, from: data)
        else { return [] }
        return days
    }

    func saveWellnessDays(_ days: Set<String>) {
        if let data = try? JSONEncoder().encode(days) {
            defaults.set(data, forKey: wellnessKey)
        }
    }

    func toggleWellnessDay(_ dateString: String) {
        var days = loadWellnessDays()
        if days.contains(dateString) {
            days.remove(dateString)
        } else {
            days.insert(dateString)
        }
        saveWellnessDays(days)
    }

    // MARK: - History & Streaks

    func loadHistory() -> [DailyLog] {
        guard let data = defaults.data(forKey: historyKey),
              let logs = try? JSONDecoder().decode([DailyLog].self, from: data)
        else { return [] }
        return logs
    }

    private func saveHistory(_ logs: [DailyLog]) {
        if let data = try? JSONEncoder().encode(logs) {
            defaults.set(data, forKey: historyKey)
        }
    }

    private func archiveLog(_ log: DailyLog) {
        var history = loadHistory()
        // Replace existing entry for the same date, or append
        if let idx = history.firstIndex(where: { $0.date == log.date }) {
            history[idx] = log
        } else {
            history.append(log)
        }
        // Keep only last 90 days
        if history.count > 90 {
            history = Array(history.suffix(90))
        }
        saveHistory(history)
    }

    /// A day counts as "completed" if ALL habits were done that day.
    private func completedDates() -> Set<String> {
        let habits = loadHabits()
        guard !habits.isEmpty else { return [] }
        let habitIDs = Set(habits.map(\.id))
        var history = loadHistory()
        // Include today
        let today = loadTodayLog()
        if let idx = history.firstIndex(where: { $0.date == today.date }) {
            history[idx] = today
        } else {
            history.append(today)
        }
        var dates = Set<String>()
        for log in history {
            if habitIDs.isSubset(of: log.completedHabitIDs) {
                dates.insert(log.date)
            }
        }
        return dates
    }

    func calculateStreaks() -> StreakInfo {
        let completed = completedDates()
        let calendar = Calendar.current

        // Daily streak: consecutive days ending today (or yesterday)
        let daily = calculateDailyStreak(completedDates: completed, calendar: calendar)

        // Weekly streak: consecutive weeks where every day was completed
        let weekly = calculateWeeklyStreak(completedDates: completed, calendar: calendar)

        // Monthly streak: consecutive months with at least one all-done day
        let monthly = calculateMonthlyStreak(completedDates: completed, calendar: calendar)

        return StreakInfo(daily: daily, weekly: weekly, monthly: monthly)
    }

    private func calculateDailyStreak(completedDates: Set<String>, calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: Date())
        let todayStr = dateFormatter.string(from: today)

        // Start from today, walk backwards
        var streak = 0
        var current = today

        // If today isn't completed yet, check if yesterday starts the streak
        if !completedDates.contains(todayStr) {
            current = calendar.date(byAdding: .day, value: -1, to: today)!
            let yesterdayStr = dateFormatter.string(from: current)
            if !completedDates.contains(yesterdayStr) {
                return 0
            }
        }

        while true {
            let key = dateFormatter.string(from: current)
            if completedDates.contains(key) {
                streak += 1
                current = calendar.date(byAdding: .day, value: -1, to: current)!
            } else {
                break
            }
        }
        return streak
    }

    private func calculateWeeklyStreak(completedDates: Set<String>, calendar: Calendar) -> Int {
        let today = Date()

        // Check each week going backwards
        var streak = 0
        var weekOffset = 0

        while true {
            let refDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: refDate) else { break }

            // Check if all days in this week (up to today) are completed
            var allDone = true
            var day = weekInterval.start
            let endDate = min(weekInterval.end, calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!)

            var dayCount = 0
            while day < endDate {
                let key = dateFormatter.string(from: day)
                if !completedDates.contains(key) {
                    allDone = false
                    break
                }
                day = calendar.date(byAdding: .day, value: 1, to: day)!
                dayCount += 1
            }

            // Current week might be incomplete (not all days passed yet), so be lenient
            if weekOffset == 0 {
                // For current week, only count if at least today or days so far are done
                if dayCount > 0 && allDone {
                    streak += 1
                } else {
                    // Current week not done yet, skip and check prior weeks
                    weekOffset += 1
                    continue
                }
            } else {
                if allDone && dayCount == 7 {
                    streak += 1
                } else {
                    break
                }
            }
            weekOffset += 1
            if weekOffset > 13 { break } // Max 13 weeks back
        }
        return streak
    }

    private func calculateMonthlyStreak(completedDates: Set<String>, calendar: Calendar) -> Int {
        let today = Date()
        var streak = 0
        var monthOffset = 0

        while true {
            guard let refDate = calendar.date(byAdding: .month, value: -monthOffset, to: today),
                  let monthInterval = calendar.dateInterval(of: .month, for: refDate)
            else { break }

            // A month counts if it has at least one all-done day
            var hasCompletedDay = false
            var day = monthInterval.start
            let endDate = min(monthInterval.end, calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!)
            while day < endDate {
                let key = dateFormatter.string(from: day)
                if completedDates.contains(key) {
                    hasCompletedDay = true
                    break
                }
                day = calendar.date(byAdding: .day, value: 1, to: day)!
            }

            if hasCompletedDay {
                streak += 1
            } else {
                break
            }
            monthOffset += 1
            if monthOffset > 12 { break }
        }
        return streak
    }
}

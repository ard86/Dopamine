import Foundation

// MARK: - App Group identifier for sharing data between app and widget
let appGroupIdentifier = "group.com.dopamine.habits"

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

// MARK: - Persistence via App Groups (UserDefaults shared suite)

final class HabitStore {
    static let shared = HabitStore()

    private let defaults: UserDefaults

    private let habitsKey = "habits_v1"
    private let logKey = "daily_log_v1"

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
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
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
}

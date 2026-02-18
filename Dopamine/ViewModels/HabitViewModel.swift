import SwiftUI
import WidgetKit

final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var completedIDs: Set<UUID> = []
    @Published var streaks: StreakInfo = StreakInfo(daily: 0, weekly: 0, monthly: 0)
    @Published var wellnessDays: Set<String> = []

    private let store = HabitStore.shared

    init() {
        reload()
    }

    func reload() {
        habits = store.loadHabits()
        completedIDs = store.loadTodayLog().completedHabitIDs
        streaks = store.calculateStreaks()
        wellnessDays = store.loadWellnessDays()
    }

    func toggleWellnessDay(_ dateString: String) {
        store.toggleWellnessDay(dateString)
        wellnessDays = store.loadWellnessDays()
    }

    var completedCount: Int {
        habits.filter { completedIDs.contains($0.id) }.count
    }

    var totalCount: Int {
        habits.count
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    // MARK: - Actions

    func toggle(_ habit: Habit) {
        store.toggleHabit(habit.id)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func openApp(for habit: Habit) {
        guard let url = URL(string: habit.appURLScheme) else { return }
        UIApplication.shared.open(url) { [weak self] success in
            if !success, let fallback = URL(string: habit.fallbackURL) {
                UIApplication.shared.open(fallback)
            }
            // Mark as completed when user taps to open the app
            if let self = self, !self.completedIDs.contains(habit.id) {
                self.toggle(habit)
            }
        }
    }

    func addHabit(name: String, emoji: String, appScheme: String, fallbackURL: String) {
        let habit = Habit(
            id: UUID(),
            name: name,
            emoji: emoji,
            appURLScheme: appScheme,
            fallbackURL: fallbackURL,
            sortOrder: habits.count
        )
        var all = habits
        all.append(habit)
        store.save(habits: all)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateHabit(_ habit: Habit, name: String, emoji: String, appScheme: String, fallbackURL: String) {
        var all = habits
        guard let idx = all.firstIndex(where: { $0.id == habit.id }) else { return }
        all[idx].name = name
        all[idx].emoji = emoji
        all[idx].appURLScheme = appScheme
        all[idx].fallbackURL = fallbackURL
        store.save(habits: all)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func deleteHabit(_ habit: Habit) {
        var all = habits
        all.removeAll { $0.id == habit.id }
        // Reindex sort orders
        for i in all.indices {
            all[i].sortOrder = i
        }
        store.save(habits: all)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func moveHabit(from source: IndexSet, to destination: Int) {
        var all = habits
        all.move(fromOffsets: source, toOffset: destination)
        for i in all.indices {
            all[i].sortOrder = i
        }
        store.save(habits: all)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

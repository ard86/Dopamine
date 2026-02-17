import AppIntents
import WidgetKit

// MARK: - Toggle a habit from the widget

struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Habit"
    static var description: IntentDescription = "Mark a habit as done or not done"

    @Parameter(title: "Habit ID")
    var habitID: String

    init() {}

    init(habitID: String) {
        self.habitID = habitID
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: habitID) else {
            return .result()
        }
        HabitStore.shared.toggleHabit(uuid)
        // Reload all widget timelines so the checkmark updates
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Open an external app from the widget

struct OpenHabitAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Habit App"
    static var description: IntentDescription = "Opens the associated app for a habit"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "URL Scheme")
    var urlScheme: String

    @Parameter(title: "Fallback URL")
    var fallbackURL: String

    init() {}

    init(urlScheme: String, fallbackURL: String) {
        self.urlScheme = urlScheme
        self.fallbackURL = fallbackURL
    }

    func perform() async throws -> some IntentResult {
        // The actual URL opening is handled by the app when it comes to foreground.
        // We pass data via the deep link: dopamine://open?scheme=<scheme>&fallback=<fallback>
        return .result()
    }
}

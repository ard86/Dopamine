import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Provider

struct HabitTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habits: Habit.defaults, completedIDs: [], streaks: StreakInfo(daily: 0, weekly: 0, monthly: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        let store = HabitStore.shared
        let habits = store.loadHabits()
        let log = store.loadTodayLog()
        let streaks = store.calculateStreaks()
        completion(HabitEntry(date: Date(), habits: habits, completedIDs: log.completedHabitIDs, streaks: streaks))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let store = HabitStore.shared
        let habits = store.loadHabits()
        let log = store.loadTodayLog()
        let streaks = store.calculateStreaks()
        let entry = HabitEntry(date: Date(), habits: habits, completedIDs: log.completedHabitIDs, streaks: streaks)

        // Refresh at midnight so the checklist resets
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
    let completedIDs: Set<UUID>
    let streaks: StreakInfo

    var completedCount: Int {
        habits.filter { completedIDs.contains($0.id) }.count
    }

    var progress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedCount) / Double(habits.count)
    }
}

// MARK: - Small Widget (Lock Screen circular / inline)

struct DopamineWidgetSmallView: View {
    let entry: HabitEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Text("\(entry.completedCount)/\(entry.habits.count)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("habits")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Inline Lock Screen Widget

struct DopamineWidgetInlineView: View {
    let entry: HabitEntry

    var body: some View {
        Text("☀️ \(entry.completedCount)/\(entry.habits.count) habits done")
    }
}

// MARK: - Medium Home Screen Widget (the main interactive one)

struct DopamineWidgetMediumView: View {
    let entry: HabitEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            HStack {
                Text("Morning Routine")
                    .font(.system(size: 17, weight: .heavy, design: .serif))
                    .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
                Spacer()
                Text("\(entry.completedCount)/\(entry.habits.count)")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 1.0, green: 0.369, blue: 0.2))
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.1))
                        .frame(height: 6)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.369, blue: 0.2),
                                    Color(red: 0.718, green: 0.812, blue: 0.31)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * entry.progress, 0), height: 6)
                }
            }
            .frame(height: 6)

            // Habit rows — each is a button that toggles + opens the app
            ForEach(entry.habits.prefix(4)) { habit in
                let isDone = entry.completedIDs.contains(habit.id)
                HStack(spacing: 10) {
                    // Toggle button (interactive via AppIntent)
                    Button(intent: ToggleHabitIntent(habitID: habit.id.uuidString)) {
                        Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isDone ? Color(red: 0.718, green: 0.812, blue: 0.31) : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.25))
                            .font(.body)
                    }
                    .buttonStyle(.plain)

                    Text(habit.emoji)
                        .font(.callout)

                    Text(habit.name)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(isDone ? Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.35) : Color(red: 0.102, green: 0.0, blue: 0.537))
                        .strikethrough(isDone)

                    Spacer()

                    // Open app button
                    Link(destination: URL(string: "dopamine://open?scheme=\(habit.appURLScheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&fallback=\(habit.fallbackURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.callout)
                            .foregroundStyle(Color(red: 1.0, green: 0.369, blue: 0.2).opacity(0.5))
                    }
                }
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(red: 0.937, green: 0.906, blue: 0.827)
        }
    }
}

// MARK: - Large Home Screen Widget

struct DopamineWidgetLargeView: View {
    let entry: HabitEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.45))
                    Text("Morning Routine")
                        .font(.system(size: 22, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
                }
                Spacer()
                // Mini progress ring
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.1), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: entry.progress)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.369, blue: 0.2),
                                    Color(red: 0.718, green: 0.812, blue: 0.31)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 14, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
                }
                .frame(width: 48, height: 48)
            }

            Divider()
                .background(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.1))

            // All habits
            ForEach(entry.habits) { habit in
                let isDone = entry.completedIDs.contains(habit.id)
                HStack(spacing: 12) {
                    Button(intent: ToggleHabitIntent(habitID: habit.id.uuidString)) {
                        Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isDone ? Color(red: 0.718, green: 0.812, blue: 0.31) : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.2))
                            .font(.title3)
                    }
                    .buttonStyle(.plain)

                    Text(habit.emoji)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.name)
                            .font(.system(size: 16, weight: .semibold, design: .serif))
                            .foregroundStyle(isDone ? Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.35) : Color(red: 0.102, green: 0.0, blue: 0.537))
                            .strikethrough(isDone)
                        Text(isDone ? "Done" : "Tap circle to check off")
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundStyle(isDone ? Color(red: 0.718, green: 0.812, blue: 0.31) : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.3))
                    }

                    Spacer()

                    Link(destination: URL(string: "dopamine://open?scheme=\(habit.appURLScheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&fallback=\(habit.fallbackURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!) {
                        HStack(spacing: 4) {
                            Text("Open")
                                .font(.system(size: 12, weight: .semibold, design: .serif))
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                        }
                        .foregroundStyle(Color(red: 1.0, green: 0.369, blue: 0.2))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(Color(red: 1.0, green: 0.369, blue: 0.2).opacity(0.1))
                        )
                    }
                }
                .padding(.vertical, 4)
            }

            if entry.completedCount == entry.habits.count && !entry.habits.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("All done! Great start to your day")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(red: 0.718, green: 0.812, blue: 0.31))
                    Spacer()
                }
            }

            // Streak row
            if entry.streaks.daily > 0 || entry.streaks.weekly > 0 || entry.streaks.monthly > 0 {
                Divider()
                    .background(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.1))
                HStack(spacing: 0) {
                    widgetStreakItem(value: entry.streaks.daily, label: "Day", icon: "flame.fill")
                    widgetStreakItem(value: entry.streaks.weekly, label: "Week", icon: "calendar")
                    widgetStreakItem(value: entry.streaks.monthly, label: "Month", icon: "star.fill")
                }
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(red: 0.937, green: 0.906, blue: 0.827)
        }
    }

    private func widgetStreakItem(value: Int, label: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(value > 0
                    ? Color(red: 1.0, green: 0.369, blue: 0.2)
                    : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.2))
            Text("\(value)")
                .font(.system(size: 13, weight: .heavy, design: .serif))
                .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .serif))
                .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
}

// MARK: - Widget Configuration

struct DopamineWidget: Widget {
    let kind: String = "DopamineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitTimelineProvider()) { entry in
            DopamineWidgetMediumView(entry: entry)
        }
        .configurationDisplayName("Morning Routine")
        .description("Track your daily habits right from the home screen.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Lock Screen Widget

struct DopamineLockScreenWidget: Widget {
    let kind: String = "DopamineLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitTimelineProvider()) { entry in
            if #available(iOSApplicationExtension 16.0, *) {
                DopamineWidgetSmallView(entry: entry)
            }
        }
        .configurationDisplayName("Habits Progress")
        .description("See your habit progress on the lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

// MARK: - Widget Bundle

@main
struct DopamineWidgetBundle: WidgetBundle {
    var body: some Widget {
        DopamineWidget()
        DopamineLockScreenWidget()
    }
}

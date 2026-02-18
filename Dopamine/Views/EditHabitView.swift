import SwiftUI

struct EditHabitView: View {
    @EnvironmentObject var vm: HabitViewModel
    @Environment(\.dismiss) var dismiss

    let habit: Habit

    @State private var name: String
    @State private var emoji: String
    @State private var appScheme: String
    @State private var fallbackURL: String

    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _emoji = State(initialValue: habit.emoji)
        _appScheme = State(initialValue: habit.appURLScheme)
        _fallbackURL = State(initialValue: habit.fallbackURL)
    }

    private let suggestedEmojis = ["✅", "💪", "📖", "🏃", "💧", "🧘", "📝", "🎯", "⚖️", "🎧", "🧠", "☀️"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.937, green: 0.906, blue: 0.827)
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Habit name", text: $name)
                        TextField("App URL or link (e.g. https://youtube.com/...)", text: $appScheme)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("Fallback URL (optional)", text: $fallbackURL)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Details")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                    } footer: {
                        Text("Paste any URL — app schemes (spotify://) or web links (https://youtube.com/...) both work.")
                            .font(.system(size: 12, design: .serif))
                    }

                    Section {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(suggestedEmojis, id: \.self) { e in
                                Text(e)
                                    .font(.title)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(emoji == e ? Color(red: 1.0, green: 0.369, blue: 0.2).opacity(0.2) : Color.clear)
                                    )
                                    .onTapGesture {
                                        emoji = e
                                    }
                            }
                        }
                    } header: {
                        Text("Icon")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                    }

                    Section {
                        presetButton(name: "Headspace", emoji: "🧘", scheme: "headspace://", fallback: "https://apps.apple.com/app/headspace/id493145008")
                        presetButton(name: "YouTube", emoji: "▶️", scheme: "https://youtube.com", fallback: "https://youtube.com")
                        presetButton(name: "Notion", emoji: "🎯", scheme: "notion://", fallback: "https://apps.apple.com/app/notion/id1232780281")
                        presetButton(name: "Spotify", emoji: "🎧", scheme: "spotify://", fallback: "https://apps.apple.com/app/spotify/id324684580")
                    } header: {
                        Text("Quick Presets")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.updateHabit(
                            habit,
                            name: name,
                            emoji: emoji,
                            appScheme: appScheme,
                            fallbackURL: fallbackURL
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func presetButton(name: String, emoji: String, scheme: String, fallback: String) -> some View {
        Button {
            self.name = name
            self.emoji = emoji
            self.appScheme = scheme
            self.fallbackURL = fallback
        } label: {
            HStack {
                Text(emoji)
                Text(name)
                    .foregroundStyle(.primary)
            }
        }
    }
}

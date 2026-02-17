import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var vm: HabitViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var emoji = "✅"
    @State private var appScheme = ""
    @State private var fallbackURL = ""

    private let suggestedEmojis = ["✅", "💪", "📖", "🏃", "💧", "🧘", "📝", "🎯", "⚖️", "🎧", "🧠", "☀️"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.10, blue: 0.17)
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Habit name", text: $name)
                        TextField("App URL scheme (e.g. spotify://)", text: $appScheme)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("Fallback URL (App Store link)", text: $fallbackURL)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Details")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                    }

                    Section {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(suggestedEmojis, id: \.self) { e in
                                Text(e)
                                    .font(.title)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(emoji == e ? Color(red: 0.28, green: 0.79, blue: 0.89).opacity(0.3) : Color.clear)
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
                        presetButton(name: "Noom (Weight)", emoji: "⚖️", scheme: "noom://", fallback: "https://apps.apple.com/app/noom/id634598719")
                        presetButton(name: "Headspace", emoji: "🧘", scheme: "headspace://", fallback: "https://apps.apple.com/app/headspace/id493145008")
                        presetButton(name: "Notion", emoji: "🎯", scheme: "notion://", fallback: "https://apps.apple.com/app/notion/id1232780281")
                        presetButton(name: "Spotify", emoji: "🎧", scheme: "spotify://", fallback: "https://apps.apple.com/app/spotify/id324684580")
                        presetButton(name: "Apple Health", emoji: "❤️", scheme: "x-apple-health://", fallback: "")
                        presetButton(name: "Fitness", emoji: "💪", scheme: "fitnessapp://", fallback: "")
                    } header: {
                        Text("Quick Presets")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addHabit(
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

#Preview {
    AddHabitView()
        .environmentObject(HabitViewModel())
}

import SwiftUI

struct IdentityPillarsSection: View {
    @EnvironmentObject var vm: HabitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Identity Ignition")
                        .font(.system(size: 17, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
                    Text("The four pillars you're becoming")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.4))
                }
                Spacer()
            }

            VStack(spacing: 10) {
                ForEach(vm.pillars) { pillar in
                    IdentityPillarCard(pillar: pillar)
                }
            }
        }
    }
}

struct IdentityPillarCard: View {
    @EnvironmentObject var vm: HabitViewModel
    let pillar: IdentityPillar
    @State private var showingEdit = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Emoji icon
            Text(pillar.emoji)
                .font(.system(size: 26))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.07))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(pillar.name.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .serif))
                    .tracking(1.2)
                    .foregroundStyle(Color(red: 1.0, green: 0.369, blue: 0.2))

                Text(pillar.identitySentence)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.08), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onLongPressGesture {
            showingEdit = true
        }
        .onTapGesture {
            showingEdit = true
        }
        .sheet(isPresented: $showingEdit) {
            EditIdentityPillarView(pillar: pillar)
                .environmentObject(vm)
        }
    }
}

struct EditIdentityPillarView: View {
    @EnvironmentObject var vm: HabitViewModel
    @Environment(\.dismiss) var dismiss

    let pillar: IdentityPillar

    @State private var name: String
    @State private var emoji: String
    @State private var identitySentence: String

    init(pillar: IdentityPillar) {
        self.pillar = pillar
        _name = State(initialValue: pillar.name)
        _emoji = State(initialValue: pillar.emoji)
        _identitySentence = State(initialValue: pillar.identitySentence)
    }

    private let suggestedEmojis = ["✨", "🏃‍♀️", "💻", "🌱", "🔥", "🧠", "💫", "🎯", "🌊", "⚡️", "🌅", "🦋"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.937, green: 0.906, blue: 0.827)
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Pillar name", text: $name)
                    } header: {
                        Text("Pillar")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                    }

                    Section {
                        TextField(
                            "I am …",
                            text: $identitySentence,
                            axis: .vertical
                        )
                        .lineLimit(3...8)
                    } header: {
                        Text("Live Identity Sentence")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                    } footer: {
                        Text("Write it as if it's already true. Start with \"I am …\" and explain why.")
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
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Pillar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.updatePillar(
                            pillar,
                            name: name,
                            emoji: emoji,
                            identitySentence: identitySentence
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || identitySentence.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.937, green: 0.906, blue: 0.827)
            .ignoresSafeArea()
        IdentityPillarsSection()
            .padding()
            .environmentObject(HabitViewModel())
    }
}

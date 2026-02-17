import SwiftUI

struct HabitCardView: View {
    @EnvironmentObject var vm: HabitViewModel
    let habit: Habit

    private var isCompleted: Bool {
        vm.completedIDs.contains(habit.id)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Emoji icon
            Text(habit.emoji)
                .font(.system(size: 32))
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.07))
                )

            // Name and status
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))

                Text(isCompleted ? "Done" : "Tap to open")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(isCompleted ? Color(red: 0.718, green: 0.812, blue: 0.31) : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.35))
            }

            Spacer()

            // Checkmark toggle
            Button {
                withAnimation(.spring(response: 0.3)) {
                    vm.toggle(habit)
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? Color(red: 0.718, green: 0.812, blue: 0.31) : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.2))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isCompleted
                        ? Color(red: 0.718, green: 0.812, blue: 0.31).opacity(0.4)
                        : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.08),
                    lineWidth: 1
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            vm.openApp(for: habit)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.937, green: 0.906, blue: 0.827)
        VStack {
            HabitCardView(habit: Habit.defaults[0])
            HabitCardView(habit: Habit.defaults[1])
        }
        .padding()
        .environmentObject(HabitViewModel())
    }
}

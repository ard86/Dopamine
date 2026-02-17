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
                        .fill(Color.white.opacity(0.08))
                )

            // Name and status
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(isCompleted ? "Done" : "Tap to open")
                    .font(.caption)
                    .foregroundStyle(isCompleted ? .green : .white.opacity(0.4))
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
                    .foregroundStyle(isCompleted ? .green : .white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isCompleted
                        ? Color.green.opacity(0.3)
                        : Color.white.opacity(0.06),
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
        Color.black
        VStack {
            HabitCardView(habit: Habit.defaults[0])
            HabitCardView(habit: Habit.defaults[1])
        }
        .padding()
        .environmentObject(HabitViewModel())
    }
}

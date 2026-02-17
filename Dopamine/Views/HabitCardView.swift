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
                        .fill(Color(red: 0.28, green: 0.79, blue: 0.89).opacity(0.12))
                )

            // Name and status
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 1.0, green: 0.96, blue: 0.90))

                Text(isCompleted ? "Done" : "Tap to open")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(isCompleted ? Color(red: 0.91, green: 0.76, blue: 0.44) : Color(red: 1.0, green: 0.96, blue: 0.90).opacity(0.4))
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
                    .foregroundStyle(isCompleted ? Color(red: 0.91, green: 0.76, blue: 0.44) : Color(red: 1.0, green: 0.96, blue: 0.90).opacity(0.25))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.06, green: 0.16, blue: 0.24).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isCompleted
                        ? Color(red: 0.91, green: 0.76, blue: 0.44).opacity(0.3)
                        : Color(red: 0.28, green: 0.79, blue: 0.89).opacity(0.1),
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

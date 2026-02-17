import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: HabitViewModel
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.07, blue: 0.15),
                        Color(red: 0.12, green: 0.10, blue: 0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        progressSection
                        habitsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView()
                    .environmentObject(vm)
            }
        }
        .onAppear {
            vm.reload()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.7))

            Text("Morning Routine")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
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

    // MARK: - Progress Ring

    private var progressSection: some View {
        VStack(spacing: 12) {
            ProgressRingView(progress: vm.progress)
                .frame(width: 120, height: 120)

            Text("\(vm.completedCount) of \(vm.totalCount) complete")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Habit Cards

    private var habitsSection: some View {
        VStack(spacing: 14) {
            ForEach(vm.habits) { habit in
                HabitCardView(habit: habit)
            }
            .onMove { source, dest in
                vm.moveHabit(from: source, to: dest)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    vm.deleteHabit(vm.habits[index])
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitViewModel())
}

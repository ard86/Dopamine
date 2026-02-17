import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: HabitViewModel
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Beige background
                Color(red: 0.937, green: 0.906, blue: 0.827)
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
                            .foregroundStyle(Color(red: 1.0, green: 0.369, blue: 0.2))
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
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
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.5))

            Text("Morning Routine")
                .font(.system(size: 36, weight: .heavy, design: .serif))
                .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
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
                .font(.system(size: 15, weight: .medium, design: .serif))
                .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.45))
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

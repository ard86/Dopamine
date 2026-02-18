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
                        wellnessCalendarSection
                        progressSection
                        streakSection
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

    // MARK: - Wellness Calendar

    private let wellnessDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()

    private var wellnessCalendarSection: some View {
        let calendar = Calendar.current
        let today = Date()
        let monthName = today.formatted(.dateTime.month(.wide).year())
        let daysInMonth = calendar.range(of: .day, in: .month, for: today)!.count
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let startWeekday = calendar.component(.weekday, from: firstOfMonth) // 1=Sun
        let todayDay = calendar.component(.day, from: today)

        // Count completed days this month
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let completedThisMonth = (1...daysInMonth).filter { day in
            let key = String(format: "%04d-%02d-%02d", year, month, day)
            return vm.wellnessDays.contains(key)
        }.count

        return VStack(alignment: .leading, spacing: 10) {
            // Title row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("2026 Food Goals")
                        .font(.system(size: 17, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))
                    Text(monthName)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.4))
                }
                Spacer()
                Text("\(completedThisMonth)/\(todayDay)")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 1.0, green: 0.369, blue: 0.2))
            }

            // Weekday headers
            let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.3))
                        .frame(maxWidth: .infinity)
                }

                // Empty cells for offset
                ForEach(0..<(startWeekday - 1), id: \.self) { _ in
                    Color.clear
                        .frame(height: 28)
                }

                // Day cells
                ForEach(1...daysInMonth, id: \.self) { day in
                    let key = String(format: "%04d-%02d-%02d", year, month, day)
                    let isFilled = vm.wellnessDays.contains(key)
                    let isToday = day == todayDay
                    let isFuture = day > todayDay

                    Button {
                        if !isFuture {
                            withAnimation(.spring(response: 0.25)) {
                                vm.toggleWellnessDay(key)
                            }
                        }
                    } label: {
                        Text("\(day)")
                            .font(.system(size: 11, weight: isFilled ? .bold : .medium, design: .serif))
                            .foregroundStyle(
                                isFilled
                                    ? Color.white
                                    : isFuture
                                        ? Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.15)
                                        : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.5)
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        isFilled
                                            ? Color(red: 0.718, green: 0.812, blue: 0.31)
                                            : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.04)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        isToday
                                            ? Color(red: 1.0, green: 0.369, blue: 0.2)
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isFuture)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Streaks

    private var streakSection: some View {
        HStack(spacing: 12) {
            streakBadge(value: vm.streaks.daily, label: "Day", icon: "flame.fill")
            streakBadge(value: vm.streaks.weekly, label: "Week", icon: "calendar")
            streakBadge(value: vm.streaks.monthly, label: "Month", icon: "star.fill")
        }
    }

    private func streakBadge(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(value > 0
                    ? Color(red: 1.0, green: 0.369, blue: 0.2)
                    : Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.2))

            Text("\(value)")
                .font(.system(size: 24, weight: .heavy, design: .serif))
                .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537))

            Text("\(label) streak")
                .font(.system(size: 11, weight: .medium, design: .serif))
                .foregroundStyle(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.102, green: 0.0, blue: 0.537).opacity(0.08), lineWidth: 1)
        )
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

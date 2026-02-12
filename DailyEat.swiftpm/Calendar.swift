import SwiftUI

struct CalendarView: View {

    @AppStorage("dailyLogs") private var dailyLogsRaw: String = ""

    @State private var targetCalories = 2000
    @State private var selectedLog: DailyLog?
    @State private var showDetail = false
    @State private var currentMonth: Date = Date()
    @State private var dragOffset: CGFloat = 0

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    // MARK: - Date Formatter (สร้างครั้งเดียว)
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    // MARK: - Load Logs
    var logs: [DailyLog] {
        dailyLogsRaw
            .split(separator: "|")
            .compactMap {
                try? JSONDecoder().decode(
                    DailyLog.self,
                    from: Data($0.utf8)
                )
            }
    }

    // MARK: - Monthly Summary
    var currentMonthLogs: [DailyLog] {
        logs.filter { log in
            guard let date = formatter.date(from: log.date) else { return false }
            return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        }
    }

    var averageCalories: Int {
        guard !currentMonthLogs.isEmpty else { return 0 }
        let total = currentMonthLogs.map { $0.totalCalories }.reduce(0, +)
        return total / currentMonthLogs.count
    }

    var successDays: Int {
        currentMonthLogs.filter { $0.totalCalories >= targetCalories }.count
    }

    // คิด % จากจำนวนวันทั้งเดือน
    var successRate: Int {
        guard daysInMonth > 0 else { return 0 }
        return Int((Double(successDays) / Double(daysInMonth)) * 100)
    }

    // MARK: - Month Info

    var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
    }

    var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        return calendar.date(from: components) ?? Date()
    }

    // ทำให้ Mon = 0
    var startingSpaces: Int {
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekday + 5) % 7
    }

    // MARK: - Body
    var body: some View {

        ScrollView {
            VStack(spacing: 24) {

                // MARK: Month Navigation
                HStack {

                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.yellow)
                            .padding()
                            .background(Color(.darkGray))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(monthYearString())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.yellow)

                    Spacer()

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.yellow)
                            .padding()
                            .background(Color(.darkGray))
                            .clipShape(Circle())
                    }

                    Button("Today") {
                        withAnimation(.spring()) {
                            currentMonth = Date()
                        }
                    }
                    .foregroundColor(.yellow)
                }

                // MARK: Monthly Summary
                monthlySummaryCard()

                // MARK: Target
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Target")
                        .foregroundColor(.gray)

                    Stepper(value: $targetCalories,
                            in: 1200...3500,
                            step: 100) {
                        Text("\(targetCalories) kcal")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(.darkGray))
                .cornerRadius(16)

                // MARK: Calendar Grid
                LazyVGrid(columns: columns, spacing: 12) {

                    // Weekday Header
                    ForEach(["Mon","Tue","Wed","Thu","Fri","Sat","Sun"], id:\.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    // Empty Spaces
                    ForEach(0..<startingSpaces, id:\.self) { _ in
                        Color.clear.frame(height: 65)
                    }

                    // Days
                    ForEach(1...daysInMonth, id:\.self) { day in
                        dayCell(day: day)
                    }
                }
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            if value.translation.width < -80 {
                                nextMonth()
                            } else if value.translation.width > 80 {
                                previousMonth()
                            }
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                )

                Spacer()
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showDetail) {
            if let log = selectedLog {
                detailSheet(log: log)
            }
        }
    }

    // MARK: - Day Cell
    func dayCell(day: Int) -> some View {

        let dateString = formattedDate(day: day)
        let log = logs.first { $0.date == dateString }
        let hitTarget = (log?.totalCalories ?? 0) >= targetCalories

        let date = formatter.date(from: dateString) ?? Date()
        let isToday = calendar.isDate(date, inSameDayAs: Date())

        return VStack(spacing: 4) {

            Text("\(day)")
                .font(.headline)
                .foregroundColor(.black)

            if let calories = log?.totalCalories {
                Text("\(calories)")
                    .font(.caption2)
                    .foregroundColor(.black)
            }
        }
        .frame(height: 65)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if isToday {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.yellow, lineWidth: 3)
                }

                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        log == nil
                        ? Color.gray.opacity(0.25)
                        : (hitTarget ? Color.yellow : Color.orange)
                    )
            }
        )
        .cornerRadius(14)
        .onTapGesture {
            if let log = log {
                selectedLog = log
                showDetail = true
            }
        }
    }

    // MARK: - Navigation Logic

    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation(.easeInOut) {
                currentMonth = newDate
            }
        }
    }

    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation(.easeInOut) {
                currentMonth = newDate
            }
        }
    }

    // MARK: - Helpers

    func formattedDate(day: Int) -> String {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        var newComponents = components
        newComponents.day = day
        let date = calendar.date(from: newComponents) ?? Date()
        return formatter.string(from: date)
    }

    func monthYearString() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: currentMonth).uppercased()
    }

    // MARK: - Detail Sheet
    func detailSheet(log: DailyLog) -> some View {
        VStack(spacing: 20) {

            Text(log.date)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)

            Text("\(log.totalCalories) kcal")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(
                    log.totalCalories >= targetCalories
                    ? .yellow
                    : .red
                )

            Divider().background(Color.gray)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(log.foods, id: \.self) { food in
                    Text("• \(food)")
                        .foregroundColor(.white)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Monthly Summary Card

    func monthlySummaryCard() -> some View {
        VStack(spacing: 16) {

            Text("MONTH SUMMARY")
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                summaryItem(title: "AVG", value: "\(averageCalories)", unit: "kcal")
                summaryItem(title: "SUCCESS", value: "\(successDays)", unit: "days")
                summaryItem(title: "RATE", value: "\(successRate)", unit: "%")
            }
        }
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(20)
    }

    func summaryItem(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.yellow)

            Text(unit)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

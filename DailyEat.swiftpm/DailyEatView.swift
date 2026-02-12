import SwiftUI
import UIKit

struct DailyEatView: View {

    @AppStorage("dailyLogs") private var dailyLogsRaw: String = ""

    let mainFoods = foods.filter { $0.type == .main }
    let snackFoods = foods.filter { $0.type == .snack }

    @State private var selectedMeal = "Breakfast"
    @State private var todayFood: Food?
    @State private var eatenFoods: [Food] = []

    @State private var breakfastCal = 0
    @State private var lunchCal = 0
    @State private var dinnerCal = 0
    @State private var snackCal = 0
    @State private var targetCalories = 2000

    var totalCalories: Int {
        breakfastCal + lunchCal + dinnerCal + snackCal
    }

    var remainingCalories: Int {
        max(targetCalories - totalCalories, 0)
    }

    var progress: Double {
        guard targetCalories > 0 else { return 0 }
        return Double(totalCalories) / Double(targetCalories)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    Text("DAILY FOOD")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.yellow)

                    Picker("Meal", selection: $selectedMeal) {
                        Text("Breakfast").tag("Breakfast")
                        Text("Lunch").tag("Lunch")
                        Text("Dinner").tag("Dinner")
                        Text("Snack").tag("Snack")
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(Color(.darkGray))
                    .cornerRadius(12)

                    if let food = todayFood {
                        modernFoodCard(food)
                    }

                    HStack(spacing: 16) {
                        modernButton(title: "Main Dish") {
                            todayFood = mainFoods
                                .filter { $0.category == selectedMeal }
                                .randomElement()
                        }

                        modernButton(title: "Snack") {
                            todayFood = snackFoods
                                .filter { $0.category == selectedMeal }
                                .randomElement()
                        }
                    }

                    // MARK: Progress Ring Dashboard
                    VStack(spacing: 18) {

                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 14)

                            Circle()
                                .trim(from: 0, to: min(progress, 1))
                                .stroke(Color.yellow,
                                        style: StrokeStyle(lineWidth: 14,
                                                           lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: progress)

                            VStack {
                                Text("\(totalCalories)")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.yellow)

                                Text("kcal")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 160, height: 160)

                        Text("Remaining: \(remainingCalories) kcal")
                            .foregroundColor(
                                remainingCalories > 300 ? .green : .red
                            )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkGray))
                    .cornerRadius(20)

                    VStack(alignment: .leading) {
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

                    if let food = todayFood {
                        Button {
                            addCalories(food)
                            eatenFoods.append(food)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } label: {
                            Text("ADD FOOD")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(14)
                        }
                    }

                    Button {
                        saveTodayLog()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Text("SAVE TODAY")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow.opacity(0.9))
                            .foregroundColor(.black)
                            .cornerRadius(14)
                    }

                    Button("RESET TODAY") {
                        resetToday()
                    }
                    .foregroundColor(.red)
                    .font(.caption)

                    NavigationLink(destination: CalendarView()) {
                        Text("VIEW CALENDAR")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .foregroundColor(.yellow)
                            .cornerRadius(14)
                    }

                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }

    // MARK: - Logic

    func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

    func saveTodayLog() {
        let today = todayString()

        // ลบ log ของวันนี้ออกก่อน (กันซ้ำ)
        let filteredLogs = dailyLogsRaw
            .split(separator: "|")
            .filter { !$0.contains(today) }

        let log = DailyLog(
            date: today,
            foods: eatenFoods.map { $0.name },
            totalCalories: totalCalories
        )

        if let data = try? JSONEncoder().encode(log),
           let json = String(data: data, encoding: .utf8) {

            dailyLogsRaw = filteredLogs.joined(separator: "|")
            if !dailyLogsRaw.isEmpty { dailyLogsRaw += "|" }
            dailyLogsRaw += json + "|"
        }
    }

    func addCalories(_ food: Food) {
        switch selectedMeal {
        case "Breakfast": breakfastCal += food.calories
        case "Lunch": lunchCal += food.calories
        case "Dinner": dinnerCal += food.calories
        default: snackCal += food.calories
        }
    }

    func resetToday() {
        breakfastCal = 0
        lunchCal = 0
        dinnerCal = 0
        snackCal = 0
        eatenFoods.removeAll()
    }

    // MARK: - Components

    func modernFoodCard(_ food: Food) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(food.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)

            Text("\(food.type.rawValue) • \(food.category)")
                .foregroundColor(.gray)

            Divider().background(Color.gray)

            Text("🔥 \(food.calories) kcal")
                .foregroundColor(.white)

            Text("🥗 \(food.nutrients)")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.darkGray))
        .cornerRadius(20)
    }

    func modernButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title.uppercased())
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow.opacity(0.85))
                .foregroundColor(.black)
                .cornerRadius(14)
        }
    }
}

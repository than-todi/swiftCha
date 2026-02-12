import SwiftUI

struct DailyEatView: View {

    @AppStorage("dailyLogs") private var dailyLogsRaw: String = ""

    let mainFoods = foods.filter { $0.type == .main }
    let snackFoods = foods.filter { $0.type == .snack }

    @State private var selectedMeal = "Breakfast"
    @State private var todayFood: Food?
    @State private var eatenFoods: [Food] = []

    // Calories per meal
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Header
                    Text("DAILY FOOD")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.yellow)

                    // MARK: Meal Picker
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

                    // MARK: Food Card
                    if let food = todayFood {
                        modernFoodCard(food)
                    }

                    // MARK: Generate Buttons
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

                    // MARK: Dashboard
                    VStack(spacing: 12) {
                        Text("Consumed")
                            .foregroundColor(.gray)

                        Text("\(totalCalories) kcal")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.yellow)

                        Text("Remaining: \(remainingCalories) kcal")
                            .foregroundColor(
                                remainingCalories > 300 ? .green : .red
                            )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkGray))
                    .cornerRadius(20)

                    // MARK: Target Stepper
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

                    // MARK: Add Food
                    if let food = todayFood {
                        Button(action: {
                            addCalories(food)
                            eatenFoods.append(food)
                        }) {
                            Text("ADD FOOD")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(14)
                        }
                    }

                    // MARK: Save
                    Button(action: {
                        saveTodayLog()
                    }) {
                        Text("SAVE TODAY")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow.opacity(0.9))
                            .foregroundColor(.black)
                            .cornerRadius(14)
                    }

                    // MARK: Calendar
                    NavigationLink(destination: CalendarView()) {
                        Text("VIEW CALENDAR")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
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
        let log = DailyLog(
            date: todayString(),
            foods: eatenFoods.map { $0.name },
            totalCalories: totalCalories
        )

        if let data = try? JSONEncoder().encode(log),
           let json = String(data: data, encoding: .utf8) {
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

    // MARK: - Components

    func modernFoodCard(_ food: Food) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(food.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)

            Text("\(food.type.rawValue) • \(food.category)")
                .foregroundColor(.gray)

            Divider()
                .background(Color.gray)

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

import SwiftUI

// MARK: - Food Model
struct Food: Identifiable {
    let id = UUID()
    let name: String
    let category: String     // Breakfast / Lunch / Dinner / Snack
    let type: FoodType       // Main Dish / Snack
    let calories: Int
    let nutrients: String
}

enum FoodType: String {
    case main = "🍽️ Main Dish"
    case snack = "🍪 Snack"
}

// MARK: - Food List
let foods: [Food] = [

    // 🍽️ Main Dishes (Rice-Based)
    Food(name: "Chicken Basil Rice", category: "Lunch", type: .main, calories: 550, nutrients: "Protein 30g | Carbs 60g"),
    Food(name: "Pork Fried Rice", category: "Lunch", type: .main, calories: 600, nutrients: "Protein 25g | Carbs 65g"),
    Food(name: "Omelet with Rice", category: "Lunch", type: .main, calories: 500, nutrients: "Protein 20g | Fat 25g"),
    Food(name: "Pork Rice Soup", category: "Breakfast", type: .main, calories: 300, nutrients: "Protein 25g | Easy to digest"),
    Food(name: "Hainanese Chicken Rice", category: "Lunch", type: .main, calories: 650, nutrients: "Protein 35g | Fat 25g"),
    Food(name: "Red Pork with Rice", category: "Lunch", type: .main, calories: 620, nutrients: "Protein 30g | Carbs 70g"),

    // 🍜 Noodles / Soups
    Food(name: "Boat Noodles", category: "Lunch", type: .main, calories: 450, nutrients: "Protein 25g"),
    Food(name: "Tom Yum Noodles", category: "Lunch", type: .main, calories: 430, nutrients: "Protein 22g"),
    Food(name: "Egg Noodles with BBQ Pork", category: "Lunch", type: .main, calories: 480, nutrients: "Protein 24g"),
    Food(name: "Sukiyaki Soup", category: "Dinner", type: .main, calories: 350, nutrients: "High vegetables | Low fat"),
    Food(name: "Clear Soup with Tofu and Minced Pork", category: "Dinner", type: .main, calories: 180, nutrients: "High protein | Low fat"),

    // 🥦 Vegetables / Healthy Options
    Food(name: "Papaya Salad", category: "Lunch", type: .main, calories: 120, nutrients: "Fiber | Vitamin C"),
    Food(name: "Glass Noodle Salad", category: "Lunch", type: .main, calories: 250, nutrients: "Protein | Low fat"),
    Food(name: "Mixed Vegetable Soup", category: "Dinner", type: .main, calories: 150, nutrients: "High fiber"),
    Food(name: "Stir-Fried Mixed Vegetables", category: "Dinner", type: .main, calories: 220, nutrients: "Vitamins | Minerals"),

    // 🍳 Protein-Based
    Food(name: "Boiled Eggs (2)", category: "Breakfast", type: .main, calories: 140, nutrients: "Protein 12g"),
    Food(name: "Steamed Chicken Breast", category: "Dinner", type: .main, calories: 200, nutrients: "High protein"),
    Food(name: "Grilled Fish", category: "Dinner", type: .main, calories: 250, nutrients: "Omega-3"),
    Food(name: "Garlic Fried Pork", category: "Lunch", type: .main, calories: 480, nutrients: "Protein | Fat"),

    // 🍪 Snacks / Light Foods
    Food(name: "Banana", category: "Snack", type: .snack, calories: 90, nutrients: "Potassium"),
    Food(name: "Apple", category: "Snack", type: .snack, calories: 80, nutrients: "Fiber"),
    Food(name: "Watermelon", category: "Snack", type: .snack, calories: 60, nutrients: "High water content"),
    Food(name: "Mandarin Orange", category: "Snack", type: .snack, calories: 70, nutrients: "Vitamin C"),
    Food(name: "Plain Yogurt", category: "Snack", type: .snack, calories: 120, nutrients: "Probiotics"),

    // ☕ Beverages
    Food(name: "Milk (1 glass)", category: "Breakfast", type: .snack, calories: 130, nutrients: "Calcium"),
    Food(name: "Black Coffee", category: "Breakfast", type: .snack, calories: 5, nutrients: "No sugar"),
    Food(name: "Unsweetened Green Tea", category: "Snack", type: .snack, calories: 10, nutrients: "Antioxidants")
]

import Foundation

struct DailyLog: Identifiable, Codable {
    var id: UUID
    var date: String          // dd/MM/yyyy
    var foods: [String]
    var totalCalories: Int

    init(id: UUID = UUID(),
         date: String,
         foods: [String],
         totalCalories: Int) {

        self.id = id
        self.date = date
        self.foods = foods
        self.totalCalories = totalCalories
    }
}

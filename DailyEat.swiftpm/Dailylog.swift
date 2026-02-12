//
//  Dailylog.swift
//  DailyEat
//
//  Created by USER922-22 on 7/2/2569 BE.
//

import Foundation

struct DailyLog: Identifiable, Codable {
    let id: UUID
    let date: String          // dd/MM/yyyy
    let foods: [String]
    let totalCalories: Int

    init(date: String, foods: [String], totalCalories: Int) {
        self.id = UUID()
        self.date = date
        self.foods = foods
        self.totalCalories = totalCalories
    }
}

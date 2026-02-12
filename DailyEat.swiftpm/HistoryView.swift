import SwiftUI

struct HistoryView: View {
    let history: [String]

    var body: some View {
        List {
            ForEach(history, id: \.self) { item in
                Text(item)
            }
        }
        .navigationTitle("📖 Eating History")
    }
}

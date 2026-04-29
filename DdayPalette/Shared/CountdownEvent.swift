import Foundation
import SwiftUI

struct CountdownEvent: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var targetDate: Date
    var colorHex: String
    var icon: String
    var notes: String
    var isFavorite: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        targetDate: Date,
        colorHex: String = CountdownPalette.colors[0].hex,
        icon: String = "heart.fill",
        notes: String = "",
        isFavorite: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.colorHex = colorHex
        self.icon = icon
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    var color: Color {
        Color(hex: colorHex)
    }

    func daysRemaining(from date: Date = .now, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let end = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    func relativeText(from date: Date = .now) -> String {
        let days = daysRemaining(from: date)
        if days == 0 { return "D-Day" }
        if days > 0 { return "\(days)일 후" }
        return "\(abs(days))일 지남"
    }
}

extension Array where Element == CountdownEvent {
    func sortedForDisplay() -> [CountdownEvent] {
        sorted {
            if $0.isFavorite != $1.isFavorite { return $0.isFavorite && !$1.isFavorite }
            let left = $0.daysRemaining()
            let right = $1.daysRemaining()
            if left >= 0 && right < 0 { return true }
            if left < 0 && right >= 0 { return false }
            return abs(left) < abs(right)
        }
    }
}

import SwiftUI

enum CountdownPalette {
    static let appGroupIdentifier = "group.com.jungyeons.DdayPalette"
    static let storageKey = "countdown.events.v1"

    static let colors: [(name: String, hex: String)] = [
        ("Coral", "#FF3B45"),
        ("Orange", "#FF8A1C"),
        ("Amber", "#FFB703"),
        ("Mint", "#1DB954"),
        ("Teal", "#00A7A5"),
        ("Sky", "#279AF1"),
        ("Blue", "#2F6BFF"),
        ("Violet", "#7C3AED"),
        ("Pink", "#F2388F"),
        ("Graphite", "#3D4451")
    ]

    static let symbols = [
        "heart.fill",
        "graduationcap.fill",
        "book.closed.fill",
        "pencil.and.list.clipboard",
        "star.fill",
        "flag.fill",
        "rosette",
        "checkmark.seal.fill"
    ]
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red: Double
        let green: Double
        let blue: Double

        switch cleaned.count {
        case 6:
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
        default:
            red = 1
            green = 0.23
            blue = 0.27
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

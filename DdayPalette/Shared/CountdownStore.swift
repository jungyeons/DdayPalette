import Foundation

final class CountdownStore: ObservableObject {
    @Published private(set) var events: [CountdownEvent] = []

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = UserDefaults(suiteName: CountdownPalette.appGroupIdentifier) ?? .standard) {
        self.defaults = defaults
        load()
    }

    func upsert(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            events.append(event)
        }
        save()
    }

    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        save()
    }

    func toggleFavorite(_ event: CountdownEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index].isFavorite.toggle()
        save()
    }

    func load() {
        guard let data = defaults.data(forKey: CountdownPalette.storageKey),
              let decoded = try? decoder.decode([CountdownEvent].self, from: data) else {
            events = Self.sampleEvents()
            save()
            return
        }
        events = decoded
    }

    private func save() {
        guard let data = try? encoder.encode(events) else { return }
        defaults.set(data, forKey: CountdownPalette.storageKey)
    }

    static func loadForWidget() -> [CountdownEvent] {
        let defaults = UserDefaults(suiteName: CountdownPalette.appGroupIdentifier) ?? .standard
        guard let data = defaults.data(forKey: CountdownPalette.storageKey),
              let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) else {
            return sampleEvents()
        }
        return decoded.sortedForDisplay()
    }

    private static func sampleEvents() -> [CountdownEvent] {
        let calendar = Calendar.current
        return [
            CountdownEvent(
                title: "한능검",
                targetDate: calendar.date(byAdding: .day, value: 24, to: .now) ?? .now,
                colorHex: "#FF3B45",
                icon: "heart.fill",
                notes: "기본 샘플입니다. 편집하거나 삭제하세요.",
                isFavorite: true
            )
        ]
    }
}

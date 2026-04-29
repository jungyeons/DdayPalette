import SwiftUI

@main
struct DdayPaletteApp: App {
    @StateObject private var store = CountdownStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 980, minHeight: 640)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

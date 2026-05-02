import SwiftUI

struct DesktopWidgetView: View {
    @StateObject private var store = CountdownStore()
    let close: () -> Void

    private var event: CountdownEvent? {
        store.events.sortedForDisplay().first
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let event {
                event.color
                Circle()
                    .fill(.white)
                    .frame(width: 76, height: 76)
                    .overlay {
                        Image(systemName: event.icon)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(event.color)
                    }
                    .padding(20)

                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text(event.title)
                        .font(.system(size: 31, weight: .black))
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                    Text(event.relativeText())
                        .font(.system(size: 31, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            } else {
                Color(hex: CountdownPalette.colors[0].hex)
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text("D-day")
                        .font(.system(size: 31, weight: .black))
                    Text("기록 없음")
                        .font(.system(size: 27, weight: .black))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }

            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(.black.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 34))
        .onReceive(NotificationCenter.default.publisher(for: .countdownStoreDidChange)) { _ in
            store.load()
        }
    }
}

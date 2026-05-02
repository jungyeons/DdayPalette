import SwiftUI

struct DesktopWidgetView: View {
    @StateObject private var store = CountdownStore()
    let size: DesktopWidgetSize
    let changeSize: (DesktopWidgetSize) -> Void
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
                    .frame(width: iconCircleSize, height: iconCircleSize)
                    .overlay {
                        Image(systemName: event.icon)
                            .font(.system(size: iconSize, weight: .bold))
                            .foregroundStyle(event.color)
                    }
                    .padding(edgePadding)

                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text(event.title)
                        .font(.system(size: titleSize, weight: .black))
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                    Text(event.relativeText())
                        .font(.system(size: titleSize, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(edgePadding)
            } else {
                Color(hex: CountdownPalette.colors[0].hex)
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text("D-day")
                        .font(.system(size: titleSize, weight: .black))
                    Text("기록 없음")
                        .font(.system(size: titleSize - 4, weight: .black))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(edgePadding)
            }

            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: closeSize, height: closeSize)
                    .background(Circle().fill(.black.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .padding(size == .compact ? 7 : 10)

            sizeControls
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(size == .compact ? 8 : 11)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onReceive(NotificationCenter.default.publisher(for: .countdownStoreDidChange)) { _ in
            store.load()
        }
    }

    private var sizeControls: some View {
        HStack(spacing: 5) {
            ForEach(DesktopWidgetSize.allCases) { option in
                Button {
                    changeSize(option)
                } label: {
                    Text(option.shortTitle)
                        .font(.system(size: size == .compact ? 9 : 10, weight: .bold))
                        .foregroundStyle(option == size ? .black : .white)
                        .frame(width: size == .compact ? 22 : 25, height: size == .compact ? 18 : 20)
                        .background(
                            Capsule()
                                .fill(option == size ? .white : .black.opacity(0.18))
                        )
                }
                .buttonStyle(.plain)
                .help(option.title)
            }
        }
    }

    private var titleSize: CGFloat {
        switch size {
        case .compact: 21
        case .small: 25
        case .large: 31
        }
    }

    private var iconCircleSize: CGFloat {
        switch size {
        case .compact: 44
        case .small: 56
        case .large: 76
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .compact: 21
        case .small: 26
        case .large: 34
        }
    }

    private var edgePadding: CGFloat {
        switch size {
        case .compact: 18
        case .small: 22
        case .large: 28
        }
    }

    private var closeSize: CGFloat {
        size == .compact ? 22 : 26
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .compact: 24
        case .small: 28
        case .large: 34
        }
    }
}

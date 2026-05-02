import SwiftUI

struct DesktopWidgetView: View {
    @StateObject private var store = CountdownStore()
    let eventID: UUID?
    let size: DesktopWidgetSize
    let isEditing: Bool
    let close: () -> Void
    let finishEditing: () -> Void

    private var event: CountdownEvent? {
        if let eventID, let event = store.events.first(where: { $0.id == eventID }) {
            return event
        }
        if eventID != nil {
            return nil
        }
        return store.events.sortedForDisplay().first
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
                    Text(eventID == nil ? "D-day" : "삭제됨")
                        .font(.system(size: titleSize, weight: .black))
                    Text(eventID == nil ? "기록 없음" : "위젯 닫기")
                        .font(.system(size: titleSize - 4, weight: .black))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(edgePadding)
            }

            if isEditing {
                editControls
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onReceive(NotificationCenter.default.publisher(for: .countdownStoreDidChange)) { _ in
            store.load()
        }
    }

    private var editControls: some View {
        ZStack {
            Button(action: close) {
                Image(systemName: "minus")
                    .font(.system(size: size == .compact ? 11 : 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: closeSize, height: closeSize)
                    .background(Circle().fill(.regularMaterial))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: -closeSize / 2, y: -closeSize / 2)

            Button(action: finishEditing) {
                Text("완료")
                    .font(.system(size: size == .compact ? 10 : 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, size == .compact ? 8 : 10)
                    .padding(.vertical, size == .compact ? 5 : 6)
                    .background(Capsule().fill(.black.opacity(0.32)))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(size == .compact ? 8 : 10)
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

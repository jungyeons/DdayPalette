import AppKit
import SwiftUI

@MainActor
final class DesktopWidgetController {
    static let shared = DesktopWidgetController()

    private var panel: NSPanel?
    private var size: DesktopWidgetSize = .small

    private init() {}

    func show(size: DesktopWidgetSize = .small) {
        self.size = size
        if let panel {
            panel.contentView = NSHostingView(rootView: DesktopWidgetView(size: size) {
                self.hide()
            })
            panel.setContentSize(size.dimensions)
            position(panel)
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let rootView = DesktopWidgetView(size: size) {
            self.hide()
        }

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size.dimensions),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.contentView = NSHostingView(rootView: rootView)

        if let screen = NSScreen.main {
            let frame = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: frame.minX + 28, y: frame.maxY - 310))
        }

        self.panel = panel
        position(panel)
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }
        let frame = screen.visibleFrame
        let margin: CGFloat = 28
        panel.setFrameOrigin(NSPoint(x: frame.minX + margin, y: frame.maxY - size.dimensions.height - margin))
    }
}

enum DesktopWidgetSize: String, CaseIterable, Identifiable {
    case compact
    case small
    case large

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compact: "작게"
        case .small: "보통"
        case .large: "크게"
        }
    }

    var shortTitle: String {
        switch self {
        case .compact: "S"
        case .small: "M"
        case .large: "L"
        }
    }

    var dimensions: NSSize {
        switch self {
        case .compact: NSSize(width: 180, height: 150)
        case .small: NSSize(width: 210, height: 180)
        case .large: NSSize(width: 270, height: 270)
        }
    }
}

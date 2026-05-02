import AppKit
import SwiftUI

@MainActor
final class DesktopWidgetController {
    static let shared = DesktopWidgetController()

    private var panel: NSPanel?

    private init() {}

    func show() {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let rootView = DesktopWidgetView {
            self.hide()
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 120, y: 120, width: 270, height: 270),
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
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }
}

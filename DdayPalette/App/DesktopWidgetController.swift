import AppKit
import SwiftUI

@MainActor
final class DesktopWidgetController: NSObject, NSWindowDelegate {
    static let shared = DesktopWidgetController()

    private var panel: NSPanel?
    private var size: DesktopWidgetSize
    private var placement: DesktopWidgetPlacement
    private var isEditingPlacement = false
    private var isProgrammaticMove = false
    private let defaults = UserDefaults.standard

    private override init() {
        size = DesktopWidgetSize(rawValue: UserDefaults.standard.string(forKey: "desktopWidget.size") ?? "") ?? .small
        placement = DesktopWidgetPlacement(rawValue: UserDefaults.standard.string(forKey: "desktopWidget.placement") ?? "") ?? .topRight
        super.init()
    }

    func show(size newSize: DesktopWidgetSize? = nil, placement newPlacement: DesktopWidgetPlacement? = nil) {
        if let newSize {
            size = newSize
            defaults.set(newSize.rawValue, forKey: "desktopWidget.size")
        }
        if let newPlacement {
            placement = newPlacement
            defaults.set(newPlacement.rawValue, forKey: "desktopWidget.placement")
            defaults.removeObject(forKey: "desktopWidget.customX")
            defaults.removeObject(forKey: "desktopWidget.customY")
        }

        if let panel {
            panel.contentView = NSHostingView(rootView: makeWidgetView())
            panel.setContentSize(size.dimensions)
            position(panel)
            applyPanelLevel(panel)
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size.dimensions),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.delegate = self
        applyPanelLevel(panel)
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.contentView = NSHostingView(rootView: makeWidgetView())

        self.panel = panel
        position(panel)
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func beginPlacementMode() {
        isEditingPlacement = true
        show()
        if let panel {
            applyPanelLevel(panel)
            panel.contentView = NSHostingView(rootView: makeWidgetView())
            panel.orderFrontRegardless()
        }
    }

    func endPlacementMode() {
        isEditingPlacement = false
        if let panel {
            applyPanelLevel(panel)
            panel.contentView = NSHostingView(rootView: makeWidgetView())
            panel.orderFrontRegardless()
        }
    }

    private func makeWidgetView() -> some View {
        DesktopWidgetView(size: size, isEditing: isEditingPlacement) {
            self.hide()
        } finishEditing: {
            self.endPlacementMode()
        }
    }

    private func applyPanelLevel(_ panel: NSPanel) {
        if isEditingPlacement {
            panel.level = .floating
        } else {
            panel.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
        }
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }
        isProgrammaticMove = true
        defer { isProgrammaticMove = false }

        if defaults.object(forKey: "desktopWidget.customX") != nil,
           defaults.object(forKey: "desktopWidget.customY") != nil {
            let x = defaults.double(forKey: "desktopWidget.customX")
            let y = defaults.double(forKey: "desktopWidget.customY")
            panel.setFrameOrigin(NSPoint(x: x, y: y))
            return
        }

        let frame = screen.visibleFrame
        let margin: CGFloat = 28
        let origin: NSPoint
        switch placement {
        case .topLeft:
            origin = NSPoint(x: frame.minX + margin, y: frame.maxY - size.dimensions.height - margin)
        case .topRight:
            origin = NSPoint(x: frame.maxX - size.dimensions.width - margin, y: frame.maxY - size.dimensions.height - margin)
        case .bottomLeft:
            origin = NSPoint(x: frame.minX + margin, y: frame.minY + margin)
        case .bottomRight:
            origin = NSPoint(x: frame.maxX - size.dimensions.width - margin, y: frame.minY + margin)
        case .center:
            origin = NSPoint(x: frame.midX - size.dimensions.width / 2, y: frame.midY - size.dimensions.height / 2)
        }
        panel.setFrameOrigin(origin)
    }

    nonisolated func windowDidMove(_ notification: Notification) {
        Task { @MainActor in
            guard !isProgrammaticMove, let panel else { return }
            defaults.set(panel.frame.origin.x, forKey: "desktopWidget.customX")
            defaults.set(panel.frame.origin.y, forKey: "desktopWidget.customY")
        }
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

    var dimensions: NSSize {
        switch self {
        case .compact: NSSize(width: 180, height: 150)
        case .small: NSSize(width: 210, height: 180)
        case .large: NSSize(width: 270, height: 270)
        }
    }
}

enum DesktopWidgetPlacement: String, CaseIterable, Identifiable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case center

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topLeft: "왼쪽 위"
        case .topRight: "오른쪽 위"
        case .bottomLeft: "왼쪽 아래"
        case .bottomRight: "오른쪽 아래"
        case .center: "가운데"
        }
    }
}

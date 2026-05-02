import AppKit
import SwiftUI

@MainActor
final class DesktopWidgetController: NSObject, NSWindowDelegate {
    static let shared = DesktopWidgetController()

    private var panels: [UUID: NSPanel] = [:]
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

        show(eventID: nil, size: newSize, placement: newPlacement)
    }

    func show(eventID: UUID?, size newSize: DesktopWidgetSize? = nil, placement newPlacement: DesktopWidgetPlacement? = nil) {
        let widgetID = eventID ?? Self.defaultWidgetID
        if let newSize {
            size = newSize
            defaults.set(newSize.rawValue, forKey: sizeKey(widgetID))
            defaults.set(newSize.rawValue, forKey: "desktopWidget.size")
        } else {
            size = DesktopWidgetSize(rawValue: defaults.string(forKey: sizeKey(widgetID)) ?? "") ?? size
        }
        if let newPlacement {
            placement = newPlacement
            defaults.set(newPlacement.rawValue, forKey: placementKey(widgetID))
            defaults.set(newPlacement.rawValue, forKey: "desktopWidget.placement")
            clearCustomPosition(widgetID)
        } else {
            placement = DesktopWidgetPlacement(rawValue: defaults.string(forKey: placementKey(widgetID)) ?? "") ?? placement
        }

        if let panel = panels[widgetID] {
            panel.contentView = NSHostingView(rootView: makeWidgetView(eventID: eventID, widgetID: widgetID))
            panel.setContentSize(size.dimensions)
            position(panel, widgetID: widgetID)
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
        panel.identifier = NSUserInterfaceItemIdentifier(widgetID.uuidString)
        panel.isReleasedWhenClosed = false
        panel.delegate = self
        applyPanelLevel(panel)
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.contentView = NSHostingView(rootView: makeWidgetView(eventID: eventID, widgetID: widgetID))

        panels[widgetID] = panel
        position(panel, widgetID: widgetID)
        panel.orderFrontRegardless()
    }

    func hide() {
        panels.values.forEach { $0.orderOut(nil) }
    }

    func hide(eventID: UUID?) {
        let widgetID = eventID ?? Self.defaultWidgetID
        panels[widgetID]?.orderOut(nil)
    }

    func beginPlacementMode() {
        isEditingPlacement = true
        show()
        for panel in panels.values {
            applyPanelLevel(panel)
            let eventID = eventID(for: panel)
            let widgetID = eventID ?? Self.defaultWidgetID
            panel.contentView = NSHostingView(rootView: makeWidgetView(eventID: eventID, widgetID: widgetID))
            panel.orderFrontRegardless()
        }
    }

    func endPlacementMode() {
        isEditingPlacement = false
        for panel in panels.values {
            applyPanelLevel(panel)
            let eventID = eventID(for: panel)
            let widgetID = eventID ?? Self.defaultWidgetID
            panel.contentView = NSHostingView(rootView: makeWidgetView(eventID: eventID, widgetID: widgetID))
            panel.orderFrontRegardless()
        }
    }

    private func makeWidgetView(eventID: UUID?, widgetID: UUID) -> some View {
        let widgetSize = DesktopWidgetSize(rawValue: defaults.string(forKey: sizeKey(widgetID)) ?? "") ?? size
        return DesktopWidgetView(eventID: eventID, size: widgetSize, isEditing: isEditingPlacement) {
            self.hide(eventID: eventID)
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

    private func position(_ panel: NSPanel, widgetID: UUID) {
        guard let screen = NSScreen.main else { return }
        isProgrammaticMove = true
        defer { isProgrammaticMove = false }

        if defaults.object(forKey: customXKey(widgetID)) != nil,
           defaults.object(forKey: customYKey(widgetID)) != nil {
            let x = defaults.double(forKey: customXKey(widgetID))
            let y = defaults.double(forKey: customYKey(widgetID))
            panel.setFrameOrigin(NSPoint(x: x, y: y))
            return
        }

        let frame = screen.visibleFrame
        let margin: CGFloat = 28
        let panelSize = panel.frame.size
        let origin: NSPoint
        switch placement {
        case .topLeft:
            origin = NSPoint(x: frame.minX + margin, y: frame.maxY - panelSize.height - margin)
        case .topRight:
            origin = NSPoint(x: frame.maxX - panelSize.width - margin, y: frame.maxY - panelSize.height - margin)
        case .bottomLeft:
            origin = NSPoint(x: frame.minX + margin, y: frame.minY + margin)
        case .bottomRight:
            origin = NSPoint(x: frame.maxX - panelSize.width - margin, y: frame.minY + margin)
        case .center:
            origin = NSPoint(x: frame.midX - panelSize.width / 2, y: frame.midY - panelSize.height / 2)
        }
        panel.setFrameOrigin(origin)
    }

    nonisolated func windowDidMove(_ notification: Notification) {
        Task { @MainActor in
            guard !isProgrammaticMove,
                  let panel = notification.object as? NSPanel,
                  let rawID = panel.identifier?.rawValue,
                  let widgetID = UUID(uuidString: rawID) else { return }
            defaults.set(panel.frame.origin.x, forKey: customXKey(widgetID))
            defaults.set(panel.frame.origin.y, forKey: customYKey(widgetID))
        }
    }

    private static let defaultWidgetID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    private func eventID(for panel: NSPanel) -> UUID? {
        guard let rawID = panel.identifier?.rawValue,
              let widgetID = UUID(uuidString: rawID),
              widgetID != Self.defaultWidgetID else { return nil }
        return widgetID
    }

    private func sizeKey(_ widgetID: UUID) -> String { "desktopWidget.\(widgetID.uuidString).size" }
    private func placementKey(_ widgetID: UUID) -> String { "desktopWidget.\(widgetID.uuidString).placement" }
    private func customXKey(_ widgetID: UUID) -> String { "desktopWidget.\(widgetID.uuidString).customX" }
    private func customYKey(_ widgetID: UUID) -> String { "desktopWidget.\(widgetID.uuidString).customY" }

    private func clearCustomPosition(_ widgetID: UUID) {
        defaults.removeObject(forKey: customXKey(widgetID))
        defaults.removeObject(forKey: customYKey(widgetID))
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

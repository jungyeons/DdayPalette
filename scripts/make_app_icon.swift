import AppKit

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconSet = root
    .appendingPathComponent("DdayPalette")
    .appendingPathComponent("Assets.xcassets")
    .appendingPathComponent("AppIcon.appiconset")

try FileManager.default.createDirectory(at: iconSet, withIntermediateDirectories: true)

struct IconImage {
    let filename: String
    let idiom: String
    let size: String
    let scale: String
    let pixels: Int
}

let images: [IconImage] = [
    .init(filename: "icon_16.png", idiom: "mac", size: "16x16", scale: "1x", pixels: 16),
    .init(filename: "icon_16@2x.png", idiom: "mac", size: "16x16", scale: "2x", pixels: 32),
    .init(filename: "icon_32.png", idiom: "mac", size: "32x32", scale: "1x", pixels: 32),
    .init(filename: "icon_32@2x.png", idiom: "mac", size: "32x32", scale: "2x", pixels: 64),
    .init(filename: "icon_128.png", idiom: "mac", size: "128x128", scale: "1x", pixels: 128),
    .init(filename: "icon_128@2x.png", idiom: "mac", size: "128x128", scale: "2x", pixels: 256),
    .init(filename: "icon_256.png", idiom: "mac", size: "256x256", scale: "1x", pixels: 256),
    .init(filename: "icon_256@2x.png", idiom: "mac", size: "256x256", scale: "2x", pixels: 512),
    .init(filename: "icon_512.png", idiom: "mac", size: "512x512", scale: "1x", pixels: 512),
    .init(filename: "icon_512@2x.png", idiom: "mac", size: "512x512", scale: "2x", pixels: 1024)
]

func color(_ hex: UInt32) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: 1
    )
}

func drawIcon(size: Int) -> Data {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fatalError("Could not create bitmap context")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    defer { NSGraphicsContext.restoreGraphicsState() }

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor.clear.setFill()
    bounds.fill()

    let s = CGFloat(size)
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    shadow.shadowBlurRadius = s * 0.06
    shadow.shadowOffset = NSSize(width: 0, height: -s * 0.025)

    let bg = NSBezierPath(roundedRect: bounds.insetBy(dx: s * 0.055, dy: s * 0.055), xRadius: s * 0.22, yRadius: s * 0.22)
    shadow.set()
    color(0xFF3B45).setFill()
    bg.fill()
    NSShadow().set()

    let highlight = NSBezierPath(roundedRect: NSRect(x: s * 0.13, y: s * 0.68, width: s * 0.74, height: s * 0.19), xRadius: s * 0.09, yRadius: s * 0.09)
    NSColor.white.withAlphaComponent(0.20).setFill()
    highlight.fill()

    let tab = NSBezierPath(roundedRect: NSRect(x: s * 0.18, y: s * 0.72, width: s * 0.18, height: s * 0.11), xRadius: s * 0.035, yRadius: s * 0.035)
    NSColor.white.withAlphaComponent(0.92).setFill()
    tab.fill()
    let tab2 = NSBezierPath(roundedRect: NSRect(x: s * 0.41, y: s * 0.72, width: s * 0.18, height: s * 0.11), xRadius: s * 0.035, yRadius: s * 0.035)
    tab2.fill()

    let badgeRect = NSRect(x: s * 0.57, y: s * 0.55, width: s * 0.28, height: s * 0.28)
    NSColor.white.setFill()
    NSBezierPath(ovalIn: badgeRect).fill()

    NSColor(calibratedRed: 1, green: 0.05, blue: 0.12, alpha: 1).setFill()
    let heart = NSBezierPath()
    let cx = badgeRect.midX
    let cy = badgeRect.midY - s * 0.012
    let h = badgeRect.height * 0.42
    heart.move(to: NSPoint(x: cx, y: cy - h * 0.7))
    heart.curve(to: NSPoint(x: cx - h, y: cy + h * 0.08), controlPoint1: NSPoint(x: cx - h * 0.7, y: cy - h * 0.22), controlPoint2: NSPoint(x: cx - h, y: cy - h * 0.46))
    heart.curve(to: NSPoint(x: cx, y: cy + h * 0.46), controlPoint1: NSPoint(x: cx - h, y: cy + h * 0.5), controlPoint2: NSPoint(x: cx - h * 0.35, y: cy + h * 0.56))
    heart.curve(to: NSPoint(x: cx + h, y: cy + h * 0.08), controlPoint1: NSPoint(x: cx + h * 0.35, y: cy + h * 0.56), controlPoint2: NSPoint(x: cx + h, y: cy + h * 0.5))
    heart.curve(to: NSPoint(x: cx, y: cy - h * 0.7), controlPoint1: NSPoint(x: cx + h, y: cy - h * 0.46), controlPoint2: NSPoint(x: cx + h * 0.7, y: cy - h * 0.22))
    heart.fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    let textAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: s * 0.19, weight: .black),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph
    ]
    "D".draw(in: NSRect(x: s * 0.19, y: s * 0.32, width: s * 0.3, height: s * 0.22), withAttributes: textAttributes)

    let smallAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: s * 0.135, weight: .heavy),
        .foregroundColor: NSColor.white.withAlphaComponent(0.95)
    ]
    "-24".draw(in: NSRect(x: s * 0.19, y: s * 0.19, width: s * 0.45, height: s * 0.17), withAttributes: smallAttributes)

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not export PNG")
    }
    return png
}

for item in images {
    let png = drawIcon(size: item.pixels)
    try png.write(to: iconSet.appendingPathComponent(item.filename))
}

let contents: [String: Any] = [
    "images": images.map {
        [
            "filename": $0.filename,
            "idiom": $0.idiom,
            "scale": $0.scale,
            "size": $0.size
        ]
    },
    "info": [
        "author": "xcode",
        "version": 1
    ]
]

let json = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try json.write(to: iconSet.appendingPathComponent("Contents.json"))

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
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.16)
    shadow.shadowBlurRadius = s * 0.055
    shadow.shadowOffset = NSSize(width: 0, height: -s * 0.02)

    let cardRect = bounds.insetBy(dx: s * 0.075, dy: s * 0.075)
    let bg = NSBezierPath(roundedRect: cardRect, xRadius: s * 0.19, yRadius: s * 0.19)
    shadow.set()
    color(0xFFFFFF).setFill()
    bg.fill()
    NSShadow().set()

    NSColor(calibratedWhite: 0, alpha: 0.04).setStroke()
    bg.lineWidth = max(1, s * 0.006)
    bg.stroke()

    let top = NSBezierPath(roundedRect: NSRect(x: cardRect.minX, y: s * 0.69, width: cardRect.width, height: s * 0.235), xRadius: s * 0.19, yRadius: s * 0.19)
    color(0xFF3B45).setFill()
    top.fill()

    let cover = NSRect(x: cardRect.minX, y: s * 0.69, width: cardRect.width, height: s * 0.12)
    color(0xFF3B45).setFill()
    cover.fill()

    let check = NSBezierPath()
    check.move(to: NSPoint(x: s * 0.34, y: s * 0.43))
    check.line(to: NSPoint(x: s * 0.46, y: s * 0.31))
    check.line(to: NSPoint(x: s * 0.68, y: s * 0.55))
    check.lineWidth = s * 0.095
    check.lineCapStyle = .round
    check.lineJoinStyle = .round
    color(0xFF5A64).setStroke()
    check.stroke()

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

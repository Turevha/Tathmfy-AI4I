#!/usr/bin/env swift
import AppKit
import CoreGraphics

// Generates Tathmfy app icon PNGs (espresso ground + score arc mark).
// Run: swift Scripts/GenerateAppIcons.swift

let outputDir = CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : "Tathmfy/Resources/Assets.xcassets/AppIcon.appiconset"

let sizes: [Int] = [40, 60, 58, 87, 80, 120, 180, 152, 167, 1024]

func hex(_ value: UInt32) -> NSColor {
  let r = CGFloat((value >> 16) & 0xFF) / 255
  let g = CGFloat((value >> 8) & 0xFF) / 255
  let b = CGFloat(value & 0xFF) / 255
  return NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
}

func drawIcon(size: Int) -> NSImage {
  let image = NSImage(size: NSSize(width: size, height: size))
  image.lockFocus()

  guard let context = NSGraphicsContext.current?.cgContext else {
    image.unlockFocus()
    return image
  }

  let rect = CGRect(x: 0, y: 0, width: size, height: size)
  let corner = CGFloat(size) * 0.224

  let path = CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
  context.addPath(path)
  context.clip()

  let colors = [hex(0x33251C).cgColor, hex(0x221911).cgColor] as CFArray
  let gradient = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: colors,
    locations: [0, 1]
  )!
  context.drawLinearGradient(
    gradient,
    start: CGPoint(x: 0, y: size),
    end: CGPoint(x: size, y: 0),
    options: []
  )

  let center = CGPoint(x: CGFloat(size) / 2, y: CGFloat(size) / 2)
  let radius = CGFloat(size) * 0.31
  let stroke = max(2, CGFloat(size) * 0.052)
  let startAngle = CGFloat(160 * Double.pi / 180)
  let sweep = CGFloat(220 * Double.pi / 180)

  context.setLineWidth(stroke)
  context.setLineCap(.round)

  let arcColors = [
    hex(0xC8553A).cgColor,
    hex(0xD99A33).cgColor,
    hex(0xC9A23A).cgColor,
    hex(0x1C6E60).cgColor,
  ] as CFArray
  let arcGradient = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: arcColors,
    locations: [0, 0.42, 0.72, 1]
  )!

  context.saveGState()
  context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: startAngle + sweep, clockwise: false)
  context.replacePathWithStrokedPath()
  context.clip()
  context.drawLinearGradient(
    arcGradient,
    start: CGPoint(x: center.x - radius, y: center.y),
    end: CGPoint(x: center.x + radius, y: center.y),
    options: []
  )
  context.restoreGState()

  let knobAngle = startAngle + sweep * 0.72
  let knobPoint = CGPoint(
    x: center.x + radius * cos(knobAngle),
    y: center.y + radius * sin(knobAngle)
  )
  let knobRadius = stroke * 0.6
  context.setFillColor(NSColor.white.cgColor)
  context.fillEllipse(in: CGRect(
    x: knobPoint.x - knobRadius,
    y: knobPoint.y - knobRadius,
    width: knobRadius * 2,
    height: knobRadius * 2
  ))
  context.setStrokeColor(hex(0x1C6E60).cgColor)
  context.setLineWidth(max(1, stroke * 0.18))
  context.strokeEllipse(in: CGRect(
    x: knobPoint.x - knobRadius,
    y: knobPoint.y - knobRadius,
    width: knobRadius * 2,
    height: knobRadius * 2
  ))

  image.unlockFocus()
  return image
}

func savePNG(_ image: NSImage, to url: URL) {
  guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let data = bitmap.representation(using: .png, properties: [:])
  else { return }

  try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
  try? data.write(to: url)
}

let fm = FileManager.default
let base = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(outputDir)
try? fm.createDirectory(at: base, withIntermediateDirectories: true)

for size in sizes {
  let image = drawIcon(size: size)
  savePNG(image, to: base.appendingPathComponent("icon-\(size).png"))
  print("Wrote icon-\(size).png")
}

let contents: [String: Any] = [
  "images": [
    ["size": "20x20", "idiom": "iphone", "filename": "icon-40.png", "scale": "2x"],
    ["size": "20x20", "idiom": "iphone", "filename": "icon-60.png", "scale": "3x"],
    ["size": "29x29", "idiom": "iphone", "filename": "icon-58.png", "scale": "2x"],
    ["size": "29x29", "idiom": "iphone", "filename": "icon-87.png", "scale": "3x"],
    ["size": "40x40", "idiom": "iphone", "filename": "icon-80.png", "scale": "2x"],
    ["size": "40x40", "idiom": "iphone", "filename": "icon-120.png", "scale": "3x"],
    ["size": "60x60", "idiom": "iphone", "filename": "icon-120.png", "scale": "2x"],
    ["size": "60x60", "idiom": "iphone", "filename": "icon-180.png", "scale": "3x"],
    ["size": "76x76", "idiom": "ipad", "filename": "icon-152.png", "scale": "2x"],
    ["size": "83.5x83.5", "idiom": "ipad", "filename": "icon-167.png", "scale": "2x"],
    ["size": "1024x1024", "idiom": "ios-marketing", "filename": "icon-1024.png", "scale": "1x"],
  ],
  "info": ["version": 1, "author": "xcode"],
]

let jsonData = try! JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted])
try! jsonData.write(to: base.appendingPathComponent("Contents.json"))
print("Done → \(base.path)")

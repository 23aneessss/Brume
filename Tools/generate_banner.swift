#!/usr/bin/env swift
//
// generate_banner.swift — renders the Brume README banner (2400×800 PNG).
//
//   swift Tools/generate_banner.swift
//
import Foundation
import CoreGraphics
import ImageIO
import CoreText
import UniformTypeIdentifiers

let W = 2400, H = 800
let cs = CGColorSpace(name: CGColorSpace.sRGB)!

guard let ctx = CGContext(
    data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
    space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { fatalError("no ctx") }

func color(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) -> CGColor {
    CGColor(colorSpace: cs, components: [r, g, b, a])!
}

let fw = CGFloat(W), fh = CGFloat(H)

// MARK: - Dreamy gradient
ctx.saveGState()
ctx.addRect(CGRect(x: 0, y: 0, width: fw, height: fh))
ctx.clip()
let grad = CGGradient(colorsSpace: cs, colors: [
    color(0.85, 0.62, 0.44),
    color(0.93, 0.81, 0.67),
    color(0.96, 0.91, 0.83),
    color(0.72, 0.81, 0.73)
] as CFArray, locations: [0, 0.4, 0.7, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: fh), end: CGPoint(x: fw, y: 0), options: [])

// Mist blobs
func mist(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ a: Double) {
    let g = CGGradient(colorsSpace: cs, colors: [color(1,1,1,a), color(1,1,1,0)] as CFArray, locations: [0,1])!
    ctx.drawRadialGradient(g, startCenter: CGPoint(x: x, y: y), startRadius: 0,
                           endCenter: CGPoint(x: x, y: y), endRadius: r, options: [])
}
mist(fw * 0.2, fh * 0.7, 380, 0.4)
mist(fw * 0.8, fh * 0.35, 420, 0.35)
mist(fw * 0.5, fh * 0.85, 300, 0.3)
ctx.restoreGState()

// MARK: - Helper to draw centered CoreText
func drawText(_ string: String, font: CTFont, color c: CGColor, x: CGFloat, y: CGFloat, centered: Bool = false) {
    let attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): c
    ]
    let attr = NSAttributedString(string: string, attributes: attrs)
    let line = CTLineCreateWithAttributedString(attr)
    var startX = x
    if centered {
        let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
        startX = x - bounds.width / 2
    }
    ctx.textPosition = CGPoint(x: startX, y: y)
    CTLineDraw(line, ctx)
}

// MARK: - Wordmark "Brume"
let titleFont = CTFontCreateWithName("Noteworthy-Bold" as CFString, 220, nil)
// Shadow
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 20, color: color(0.4, 0.34, 0.3, 0.3))
drawText("Brume", font: titleFont, color: color(0.42, 0.36, 0.30), x: fw / 2, y: fh / 2 - 30, centered: true)
ctx.restoreGState()

// MARK: - Tagline
let tagFont = CTFontCreateWithName("Noteworthy-Light" as CFString, 64, nil)
drawText("breathe · write · draw", font: tagFont, color: color(0.55, 0.47, 0.40), x: fw / 2, y: fh / 2 - 150, centered: true)

// MARK: - Write out
guard let image = ctx.makeImage() else { fatalError("no image") }
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Docs/banner.png"
try? FileManager.default.createDirectory(atPath: "Docs", withIntermediateDirectories: true)
let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("no dest")
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("write failed") }
print("✓ Wrote banner to \(outPath)")

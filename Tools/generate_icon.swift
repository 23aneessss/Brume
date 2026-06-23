#!/usr/bin/env swift
//
// generate_icon.swift — renders the Brume app icon (1024×1024 PNG) from code
// with CoreGraphics. Full-bleed (iOS applies its own rounded mask).
//
//   swift Tools/generate_icon.swift
//
// Writes the icon straight into the asset catalog as AppIcon-1024.png.
//
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let S = 1024
let cs = CGColorSpace(name: CGColorSpace.sRGB)!

guard let ctx = CGContext(
    data: nil, width: S, height: S, bitsPerComponent: 8, bytesPerRow: 0,
    space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { fatalError("Could not create context") }

func color(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) -> CGColor {
    CGColor(colorSpace: cs, components: [r, g, b, a])!
}

let W = CGFloat(S)
let full = CGRect(x: 0, y: 0, width: W, height: W)

// MARK: - Soft dreamy gradient background (terracotta → cream → sage)
ctx.saveGState()
ctx.addRect(full)
ctx.clip()
let bgGrad = CGGradient(colorsSpace: cs, colors: [
    color(0.85, 0.62, 0.44),   // terracotta top
    color(0.93, 0.80, 0.66),   // warm clay
    color(0.96, 0.91, 0.83),   // cream
    color(0.70, 0.80, 0.72)    // sage bottom
] as CFArray, locations: [0, 0.34, 0.64, 1])!
ctx.drawLinearGradient(
    bgGrad,
    start: CGPoint(x: 0, y: W),
    end: CGPoint(x: W, y: 0),
    options: []
)

// MARK: - Drifting mist blobs (soft translucent clouds)
func mistBlob(center: CGPoint, radius: CGFloat, alpha: Double) {
    let blobGrad = CGGradient(colorsSpace: cs, colors: [
        color(1, 1, 1, alpha),
        color(1, 1, 1, 0)
    ] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(
        blobGrad,
        startCenter: center, startRadius: 0,
        endCenter: center, endRadius: radius,
        options: []
    )
}
mistBlob(center: CGPoint(x: W * 0.30, y: W * 0.70), radius: 340, alpha: 0.45)
mistBlob(center: CGPoint(x: W * 0.72, y: W * 0.40), radius: 300, alpha: 0.40)
mistBlob(center: CGPoint(x: W * 0.55, y: W * 0.80), radius: 240, alpha: 0.30)
ctx.restoreGState()

// MARK: - Hand-drawn "B" mark
// Stroked with a soft warm-brown, two bowls + a spine, rounded caps.
ctx.saveGState()
ctx.setLineCap(.round)
ctx.setLineJoin(.round)

let cx = W * 0.50
let topY = W * 0.30
let botY = W * 0.74
let spineX = W * 0.40
let lineW: CGFloat = 64

// Subtle shadow for depth
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: color(0.42, 0.36, 0.30, 0.35))

// Build the B path
let b = CGMutablePath()
// Spine
b.move(to: CGPoint(x: spineX, y: W - topY))
b.addLine(to: CGPoint(x: spineX, y: W - botY))
// Upper bowl
b.move(to: CGPoint(x: spineX, y: W - topY))
b.addCurve(
    to: CGPoint(x: spineX, y: W - (topY + botY) / 2),
    control1: CGPoint(x: cx + W * 0.20, y: W - topY + 30),
    control2: CGPoint(x: cx + W * 0.20, y: W - (topY + botY) / 2 - 10)
)
// Lower bowl
b.move(to: CGPoint(x: spineX, y: W - (topY + botY) / 2))
b.addCurve(
    to: CGPoint(x: spineX, y: W - botY),
    control1: CGPoint(x: cx + W * 0.24, y: W - (topY + botY) / 2 + 10),
    control2: CGPoint(x: cx + W * 0.24, y: W - botY - 30)
)

ctx.addPath(b)
ctx.setStrokeColor(color(0.42, 0.36, 0.30))   // warm brown
ctx.setLineWidth(lineW)
ctx.strokePath()
ctx.restoreGState()

// MARK: - A small sprout growing from the top of the B's spine (life, calm)
ctx.saveGState()
ctx.setLineCap(.round)
ctx.setLineJoin(.round)

// Short stem rising from the spine top
let stem = CGMutablePath()
let stemBase = CGPoint(x: spineX, y: W - topY)
let stemTop = CGPoint(x: spineX - 26, y: W - topY + 84)
stem.move(to: stemBase)
stem.addQuadCurve(to: stemTop, control: CGPoint(x: spineX - 30, y: W - topY + 40))
ctx.addPath(stem)
ctx.setStrokeColor(color(0.55, 0.66, 0.53))
ctx.setLineWidth(14)
ctx.strokePath()

// A single leaf at the tip of the stem
let leaf = CGMutablePath()
let lx = stemTop.x
let ly = stemTop.y
leaf.move(to: CGPoint(x: lx, y: ly))
leaf.addQuadCurve(
    to: CGPoint(x: lx - 78, y: ly + 30),
    control: CGPoint(x: lx - 64, y: ly + 64)
)
leaf.addQuadCurve(
    to: CGPoint(x: lx, y: ly),
    control: CGPoint(x: lx - 40, y: ly - 14)
)
ctx.addPath(leaf)
ctx.setFillColor(color(0.55, 0.66, 0.53))   // sage
ctx.fillPath()
ctx.restoreGState()

// MARK: - Write out
guard let image = ctx.makeImage() else { fatalError("Could not render image") }

let outPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Brume/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(
    url as CFURL, UTType.png.identifier as CFString, 1, nil
) else { fatalError("Could not create destination") }
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("Could not write PNG") }

print("✓ Wrote icon to \(outPath)")

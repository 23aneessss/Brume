import SwiftUI

struct OnboardingIllustration: View {
    let kind: OnboardingPage.Illustration
    let accent: Color

    var body: some View {
        switch kind {
        case .write: WriteIllustration(accent: accent)
        case .draw:  DrawIllustration(accent: accent)
        case .calm:  CalmIllustration(accent: accent)
        }
    }
}

// MARK: - Page 1: a sheet of paper with handwritten lines + a pen
private struct WriteIllustration: View {
    let accent: Color
    @State private var penOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Soft halo
            Circle()
                .fill(accent.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 8)

            // Paper
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.brumeSurface)
                .frame(width: 150, height: 190)
                .rotationEffect(.degrees(-6))
                .overlay(
                    SketchyRoundedRectangle(cornerRadius: 14, roughness: 1.0, seed: 7)
                        .stroke(accent.opacity(0.5), lineWidth: 1.6)
                        .frame(width: 150, height: 190)
                        .rotationEffect(.degrees(-6))
                )
                .shadow(color: .black.opacity(0.08), radius: 14, y: 8)

            // Handwritten squiggle lines
            VStack(alignment: .leading, spacing: 16) {
                ForEach(0..<5, id: \.self) { i in
                    SquiggleLine(seed: UInt64(i + 1))
                        .stroke(BrumeTheme.Colors.inkLight.opacity(0.7),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: i == 4 ? 70 : 110, height: 6)
                }
            }
            .rotationEffect(.degrees(-6))

            // Pen
            Image(systemName: "pencil")
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(accent)
                .rotationEffect(.degrees(45))
                .offset(x: 70, y: 70 + penOffset)
                .shadow(color: accent.opacity(0.3), radius: 6, y: 3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                penOffset = -8
            }
        }
    }
}

// MARK: - Page 2: paper with a drawn heart + sun doodle
private struct DrawIllustration: View {
    let accent: Color
    @State private var draw: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 8)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.brumeSurface)
                .frame(width: 170, height: 180)
                .rotationEffect(.degrees(4))
                .overlay(
                    SketchyRoundedRectangle(cornerRadius: 14, roughness: 1.0, seed: 21)
                        .stroke(accent.opacity(0.5), lineWidth: 1.6)
                        .frame(width: 170, height: 180)
                        .rotationEffect(.degrees(4))
                )
                .shadow(color: .black.opacity(0.08), radius: 14, y: 8)

            // Hand-drawn sun
            SunDoodle()
                .trim(from: 0, to: draw)
                .stroke(BrumeTheme.Colors.moodHappy,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 64, height: 64)
                .offset(x: -34, y: -28)

            // Hand-drawn heart
            HeartDoodle()
                .trim(from: 0, to: draw)
                .stroke(accent,
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                .frame(width: 60, height: 56)
                .offset(x: 36, y: 30)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6)) { draw = 1 }
        }
    }
}

// MARK: - Page 3: a calm moon + stars, breathing
private struct CalmIllustration: View {
    let accent: Color
    @State private var breathe = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.25), accent.opacity(0.05)],
                        center: .center, startRadius: 10, endRadius: 130
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(breathe ? 1.08 : 0.94)

            // Crescent moon
            MoonDoodle()
                .fill(
                    LinearGradient(
                        colors: [BrumeTheme.Colors.lavenderLight, accent],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .shadow(color: accent.opacity(0.3), radius: 12, y: 4)
                .scaleEffect(breathe ? 1.05 : 0.96)

            // Little stars
            ForEach(0..<4, id: \.self) { i in
                let positions: [CGPoint] = [
                    CGPoint(x: -80, y: -60),
                    CGPoint(x: 78, y: -40),
                    CGPoint(x: 70, y: 70),
                    CGPoint(x: -64, y: 78)
                ]
                StarDoodle()
                    .fill(BrumeTheme.Colors.moodHappy.opacity(0.8))
                    .frame(width: 18, height: 18)
                    .offset(x: positions[i].x, y: positions[i].y)
                    .opacity(breathe ? 1 : 0.4)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.3),
                        value: breathe
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

// MARK: - Doodle shapes
struct SquiggleLine: Shape {
    var seed: UInt64 = 1
    func path(in rect: CGRect) -> Path {
        var rng = SeededRNG(seed: seed)
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        let segments = 6
        for i in 1...segments {
            let x = rect.width * CGFloat(i) / CGFloat(segments)
            let y = rect.midY + CGFloat(rng.nextDouble() * 2 - 1) * rect.height
            path.addQuadCurve(
                to: CGPoint(x: x, y: y),
                control: CGPoint(x: x - rect.width / CGFloat(segments) / 2,
                                 y: rect.midY + CGFloat(rng.nextDouble() * 2 - 1) * rect.height)
            )
        }
        return path
    }
}

struct HeartDoodle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.95))
        path.addCurve(
            to: CGPoint(x: w * 0.02, y: h * 0.32),
            control1: CGPoint(x: w * 0.2, y: h * 0.75),
            control2: CGPoint(x: w * 0.02, y: h * 0.55)
        )
        path.addArc(
            center: CGPoint(x: w * 0.26, y: h * 0.30),
            radius: w * 0.24,
            startAngle: .degrees(165), endAngle: .degrees(-15), clockwise: false
        )
        path.addArc(
            center: CGPoint(x: w * 0.74, y: h * 0.30),
            radius: w * 0.24,
            startAngle: .degrees(165), endAngle: .degrees(-15), clockwise: false
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.95),
            control1: CGPoint(x: w * 0.98, y: h * 0.55),
            control2: CGPoint(x: w * 0.8, y: h * 0.75)
        )
        return path
    }
}

struct SunDoodle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.width * 0.28
        path.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let inner = CGPoint(x: c.x + cos(angle) * r * 1.4, y: c.y + sin(angle) * r * 1.4)
            let outer = CGPoint(x: c.x + cos(angle) * r * 1.9, y: c.y + sin(angle) * r * 1.9)
            path.move(to: inner)
            path.addLine(to: outer)
        }
        return path
    }
}

struct StarDoodle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.width / 2
        for i in 0..<5 {
            let angle = CGFloat(i) * 4 * .pi / 5 - .pi / 2
            let p = CGPoint(x: c.x + cos(angle) * r, y: c.y + sin(angle) * r)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        return path
    }
}

struct MoonDoodle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = rect.width / 2
        let c = CGPoint(x: rect.midX, y: rect.midY)
        path.addArc(center: c, radius: r, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
        path.addArc(
            center: CGPoint(x: c.x - r * 0.4, y: c.y),
            radius: r * 0.95,
            startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        OnboardingIllustration(kind: .write, accent: BrumeTheme.Colors.lavender)
        OnboardingIllustration(kind: .draw, accent: BrumeTheme.Colors.sage)
        OnboardingIllustration(kind: .calm, accent: BrumeTheme.Colors.softBrown)
    }
    .padding()
    .background(BrumeTheme.Colors.background)
}

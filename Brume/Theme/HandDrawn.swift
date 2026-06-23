import SwiftUI

// MARK: - Sketchy, slightly-imperfect rounded rectangle border
struct SketchyRoundedRectangle: Shape {
    var cornerRadius: CGFloat = 16
    var roughness: CGFloat = 1.5
    var seed: UInt64 = 42

    func path(in rect: CGRect) -> Path {
        var rng = SeededRNG(seed: seed)
        var path = Path()

        func jitter() -> CGFloat {
            CGFloat(rng.nextDouble() * 2 - 1) * roughness
        }

        let r = cornerRadius
        let minX = rect.minX, minY = rect.minY
        let maxX = rect.maxX, maxY = rect.maxY

        // Start top-left after the corner
        path.move(to: CGPoint(x: minX + r + jitter(), y: minY + jitter()))
        // Top edge
        path.addLine(to: CGPoint(x: maxX - r + jitter(), y: minY + jitter()))
        // Top-right corner
        path.addQuadCurve(
            to: CGPoint(x: maxX + jitter(), y: minY + r + jitter()),
            control: CGPoint(x: maxX, y: minY)
        )
        // Right edge
        path.addLine(to: CGPoint(x: maxX + jitter(), y: maxY - r + jitter()))
        // Bottom-right corner
        path.addQuadCurve(
            to: CGPoint(x: maxX - r + jitter(), y: maxY + jitter()),
            control: CGPoint(x: maxX, y: maxY)
        )
        // Bottom edge
        path.addLine(to: CGPoint(x: minX + r + jitter(), y: maxY + jitter()))
        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: minX + jitter(), y: maxY - r + jitter()),
            control: CGPoint(x: minX, y: maxY)
        )
        // Left edge
        path.addLine(to: CGPoint(x: minX + jitter(), y: minY + r + jitter()))
        // Top-left corner
        path.addQuadCurve(
            to: CGPoint(x: minX + r + jitter(), y: minY + jitter()),
            control: CGPoint(x: minX, y: minY)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Deterministic RNG so sketchy shapes don't flicker on redraw
struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0xdeadbeef : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
    mutating func nextDouble() -> Double {
        Double(next() % 10_000) / 10_000.0
    }
}

// MARK: - Soft paper card with sketchy border
struct PaperCard<Content: View>: View {
    var seed: UInt64 = 42
    var tint: Color = BrumeTheme.Colors.cardBorder
    @ViewBuilder var content: () -> Content
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: BrumeTheme.Radius.md, style: .continuous)
                    .fill(Color.brumeSurface)
            )
            .overlay(
                SketchyRoundedRectangle(cornerRadius: BrumeTheme.Radius.md, roughness: 1.2, seed: seed)
                    .stroke(tint.opacity(scheme == .dark ? 0.4 : 0.7), style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
            )
            .shadow(
                color: BrumeTheme.Shadow.soft.color,
                radius: BrumeTheme.Shadow.soft.radius,
                x: BrumeTheme.Shadow.soft.x,
                y: BrumeTheme.Shadow.soft.y
            )
    }
}

// MARK: - Lined / dotted paper background
struct PaperBackground: View {
    enum Style { case lines, dots, plain }
    var style: Style = .dots
    var spacing: CGFloat = 28
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Color.brumeBackground.ignoresSafeArea()

            Canvas { context, size in
                let lineColor = (scheme == .dark
                    ? Color.white.opacity(0.05)
                    : BrumeTheme.Colors.paperLine)

                switch style {
                case .lines:
                    var y: CGFloat = spacing
                    while y < size.height {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(lineColor), lineWidth: 1)
                        y += spacing
                    }
                case .dots:
                    var y: CGFloat = spacing
                    while y < size.height {
                        var x: CGFloat = spacing
                        while x < size.width {
                            let dot = Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                            context.fill(dot, with: .color(lineColor))
                            x += spacing
                        }
                        y += spacing
                    }
                case .plain:
                    break
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Soft pill button
struct SoftButton: View {
    var title: String
    var icon: String? = nil
    var filled: Bool = true
    var action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: {
            let gen = UIImpactFeedbackGenerator(style: .soft)
            gen.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(BrumeTheme.Fonts.heading(18))
            }
            .foregroundStyle(filled ? Color.white : BrumeTheme.Colors.clay)
            .padding(.horizontal, BrumeTheme.Spacing.lg)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if filled {
                        LinearGradient(
                            colors: [BrumeTheme.Colors.clay, BrumeTheme.Colors.clayLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: BrumeTheme.Radius.pill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BrumeTheme.Radius.pill, style: .continuous)
                    .stroke(BrumeTheme.Colors.clay.opacity(filled ? 0 : 0.6), lineWidth: 1.5)
            )
            .shadow(color: filled ? BrumeTheme.Colors.clay.opacity(0.3) : .clear, radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }
}

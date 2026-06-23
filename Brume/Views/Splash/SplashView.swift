import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var mistOffset: CGFloat = -40
    @State private var taglineOpacity: Double = 0
    @State private var strokeProgress: CGFloat = 0

    var body: some View {
        ZStack {
            // Soft gradient backdrop
            LinearGradient(
                colors: [
                    BrumeTheme.Colors.clayLight.opacity(0.35),
                    BrumeTheme.Colors.background,
                    BrumeTheme.Colors.sageLight.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Drifting mist layers
            ForEach(0..<3, id: \.self) { i in
                MistBlob()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 320, height: 320)
                    .blur(radius: 40)
                    .offset(
                        x: mistOffset + CGFloat(i * 30),
                        y: CGFloat(i * 80 - 80)
                    )
                    .animation(
                        .easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: mistOffset
                    )
            }

            VStack(spacing: BrumeTheme.Spacing.md) {
                // Hand-drawn "B" mark
                BrumeMarkView(progress: strokeProgress)
                    .frame(width: 110, height: 110)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Text("Brume")
                    .font(.custom("Noteworthy-Bold", size: 52))
                    .foregroundStyle(BrumeTheme.Colors.warmBrown)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)

                Text("breathe · write · draw")
                    .font(.custom("Noteworthy-Light", size: 18))
                    .foregroundStyle(BrumeTheme.Colors.softBrown)
                    .opacity(taglineOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                logoOpacity = 1
                logoScale = 1.0
            }
            withAnimation(.easeInOut(duration: 1.6)) {
                strokeProgress = 1.0
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.9)) {
                taglineOpacity = 1
            }
            mistOffset = 40
        }
    }
}

// MARK: - Hand-drawn B mark that "draws itself"
struct BrumeMark: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var full = Path()
        let w = rect.width, h = rect.height
        // Vertical spine
        full.move(to: CGPoint(x: w * 0.28, y: h * 0.15))
        full.addLine(to: CGPoint(x: w * 0.28, y: h * 0.85))
        // Upper bowl
        full.move(to: CGPoint(x: w * 0.28, y: h * 0.15))
        full.addCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.50),
            control1: CGPoint(x: w * 0.80, y: h * 0.08),
            control2: CGPoint(x: w * 0.80, y: h * 0.55)
        )
        // Lower bowl
        full.move(to: CGPoint(x: w * 0.28, y: h * 0.50))
        full.addCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.85),
            control1: CGPoint(x: w * 0.88, y: h * 0.48),
            control2: CGPoint(x: w * 0.88, y: h * 0.92)
        )
        return full.trimmedPath(from: 0, to: progress)
    }
}

// Wrapper that strokes the self-drawing B mark with the brand gradient.
struct BrumeMarkView: View {
    var progress: CGFloat

    var body: some View {
        BrumeMark(progress: progress)
            .stroke(
                LinearGradient(
                    colors: [BrumeTheme.Colors.clay, BrumeTheme.Colors.sage],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
            )
    }
}

// MARK: - Organic blob for mist
struct MistBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.5),
            control1: CGPoint(x: w * 0.85, y: h * 0.05),
            control2: CGPoint(x: w * 0.95, y: h * 0.25)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 1.05, y: h * 0.75),
            control2: CGPoint(x: w * 0.75, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.5),
            control1: CGPoint(x: w * 0.25, y: h),
            control2: CGPoint(x: -0.05 * w, y: h * 0.75)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.05, y: h * 0.25),
            control2: CGPoint(x: w * 0.15, y: h * 0.05)
        )
        return path
    }
}

#Preview {
    SplashView()
}

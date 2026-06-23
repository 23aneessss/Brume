import SwiftUI

/// First-time guide shown over the canvas, explaining the unified write/draw space.
struct CoachOverlay: View {
    var onDismiss: () -> Void
    @State private var step = 0

    private let tips: [CoachTip] = [
        CoachTip(
            icon: "hand.tap",
            title: "Tap anywhere to write",
            body: "In Write mode, tap any empty spot on the page and start typing. Drag a note to move it.",
            arrow: .top
        ),
        CoachTip(
            icon: "scribble.variable",
            title: "Switch to Draw to sketch",
            body: "Flip to Draw mode and your finger or Apple Pencil becomes a pen. Doodle freely over your words.",
            arrow: .bottom
        ),
        CoachTip(
            icon: "heart.fill",
            title: "It's all yours",
            body: "Set a mood, export to PDF, and know that everything stays private on your device.",
            arrow: .none
        )
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { next() }

            VStack {
                if tips[step].arrow == .bottom { Spacer() }

                PaperCard(seed: 99) {
                    VStack(spacing: BrumeTheme.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(BrumeTheme.Colors.clay.opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: tips[step].icon)
                                .font(.system(size: 28, weight: .light))
                                .foregroundStyle(BrumeTheme.Colors.clay)
                        }

                        Text(tips[step].title)
                            .font(BrumeTheme.Fonts.title(24))
                            .foregroundStyle(BrumeTheme.Colors.warmBrown)
                            .multilineTextAlignment(.center)

                        Text(tips[step].body)
                            .font(BrumeTheme.Fonts.body(16))
                            .foregroundStyle(BrumeTheme.Colors.inkMedium)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        HStack(spacing: 8) {
                            ForEach(tips.indices, id: \.self) { i in
                                Circle()
                                    .fill(i == step ? BrumeTheme.Colors.clay : BrumeTheme.Colors.cardBorder)
                                    .frame(width: 7, height: 7)
                            }
                        }
                        .padding(.top, 4)

                        SoftButton(
                            title: step == tips.count - 1 ? "Start writing" : "Next",
                            icon: step == tips.count - 1 ? "checkmark" : "arrow.right"
                        ) { next() }
                    }
                    .padding(BrumeTheme.Spacing.lg)
                }
                .frame(maxWidth: 340)
                .padding(.horizontal, BrumeTheme.Spacing.xl)

                if tips[step].arrow == .top { Spacer() }
            }
            .padding(.vertical, BrumeTheme.Spacing.xxl)
        }
    }

    private func next() {
        if step < tips.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { step += 1 }
        } else {
            onDismiss()
        }
    }
}

struct CoachTip {
    enum Arrow { case top, bottom, none }
    let icon: String
    let title: String
    let body: String
    let arrow: Arrow
}

#Preview {
    ZStack {
        PaperBackground()
        CoachOverlay {}
    }
}

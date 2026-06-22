import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            illustration: .write,
            title: "A quiet place to think",
            body: "Pour your thoughts onto the page. No rules, no pressure — just you and a soft, endless sheet of paper.",
            accent: BrumeTheme.Colors.lavender
        ),
        OnboardingPage(
            illustration: .draw,
            title: "Words and drawings, together",
            body: "Switch between writing and sketching anytime. Doodle in the margins, circle a feeling, let your hand wander.",
            accent: BrumeTheme.Colors.sage
        ),
        OnboardingPage(
            illustration: .calm,
            title: "Yours alone",
            body: "Everything stays on your device. Lock it with Face ID, and gentle reminders help you return whenever you need to breathe.",
            accent: BrumeTheme.Colors.softBrown
        )
    ]

    var body: some View {
        ZStack {
            PaperBackground(style: .dots)

            VStack(spacing: 0) {
                // Skip
                HStack {
                    Spacer()
                    if page < pages.count - 1 {
                        Button("Skip") { finish() }
                            .font(BrumeTheme.Fonts.label(16))
                            .foregroundStyle(BrumeTheme.Colors.inkLight)
                            .padding(BrumeTheme.Spacing.md)
                    }
                }

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { i in
                        OnboardingPageView(page: pages[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                // Custom dots
                HStack(spacing: 10) {
                    ForEach(pages.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? BrumeTheme.Colors.lavender : BrumeTheme.Colors.cardBorder)
                            .frame(width: i == page ? 26 : 9, height: 9)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: page)
                    }
                }
                .padding(.vertical, BrumeTheme.Spacing.lg)

                // CTA
                SoftButton(
                    title: page == pages.count - 1 ? "Begin" : "Next",
                    icon: page == pages.count - 1 ? "sparkles" : "arrow.right"
                ) {
                    if page == pages.count - 1 {
                        finish()
                    } else {
                        withAnimation { page += 1 }
                    }
                }
                .padding(.horizontal, BrumeTheme.Spacing.xl)
                .padding(.bottom, BrumeTheme.Spacing.xl)
            }
        }
    }

    private func finish() {
        withAnimation(.easeInOut(duration: 0.5)) {
            settings.hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    enum Illustration { case write, draw, calm }
    let illustration: Illustration
    let title: String
    let body: String
    let accent: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appear = false

    var body: some View {
        VStack(spacing: BrumeTheme.Spacing.xl) {
            Spacer()

            OnboardingIllustration(kind: page.illustration, accent: page.accent)
                .frame(height: 240)
                .scaleEffect(appear ? 1 : 0.85)
                .opacity(appear ? 1 : 0)

            VStack(spacing: BrumeTheme.Spacing.md) {
                Text(page.title)
                    .font(BrumeTheme.Fonts.title(30))
                    .foregroundStyle(BrumeTheme.Colors.warmBrown)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, BrumeTheme.Spacing.md)

                Text(page.body)
                    .font(BrumeTheme.Fonts.body(17))
                    .foregroundStyle(BrumeTheme.Colors.inkMedium)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, BrumeTheme.Spacing.xl)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 14)

            Spacer()
            Spacer()
        }
        .padding(BrumeTheme.Spacing.lg)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                appear = true
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppSettings.shared)
}

import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject var lockManager: LockManager
    @State private var breathe = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    BrumeTheme.Colors.lavenderLight.opacity(0.4),
                    BrumeTheme.Colors.background
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: BrumeTheme.Spacing.xl) {
                ZStack {
                    Circle()
                        .fill(BrumeTheme.Colors.lavender.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .scaleEffect(breathe ? 1.1 : 0.95)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(BrumeTheme.Colors.lavender)
                }

                VStack(spacing: BrumeTheme.Spacing.sm) {
                    Text("Brume is locked")
                        .font(BrumeTheme.Fonts.title(28))
                        .foregroundStyle(BrumeTheme.Colors.warmBrown)
                    Text("Your thoughts are safe and private.")
                        .font(BrumeTheme.Fonts.body(16))
                        .foregroundStyle(BrumeTheme.Colors.inkMedium)
                }

                SoftButton(title: "Unlock", icon: "faceid") {
                    lockManager.authenticate()
                }
                .padding(.horizontal, BrumeTheme.Spacing.xxl)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

#Preview {
    LockScreenView()
        .environmentObject(LockManager())
}

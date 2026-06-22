import SwiftUI
import SwiftData

@main
struct BrumeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = AppSettings.shared
    @StateObject private var lockManager = LockManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash = true

    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([Entry.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else if !settings.hasCompletedOnboarding {
                    OnboardingView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .opacity
                        ))
                } else if settings.isAppLocked && !lockManager.isUnlocked {
                    LockScreenView()
                        .environmentObject(lockManager)
                } else {
                    HomeView()
                        .transition(.opacity)
                }
            }
            .environmentObject(settings)
            .environmentObject(lockManager)
            .preferredColorScheme(settings.preferredColorScheme)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showSplash = false
                    }
                    if settings.isAppLocked {
                        lockManager.authenticate()
                    }
                }
            }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                // Re-lock when the app leaves the foreground.
                if settings.isAppLocked { lockManager.lock() }
            case .active:
                if settings.isAppLocked && !lockManager.isUnlocked && !showSplash {
                    lockManager.authenticate()
                }
            default:
                break
            }
        }
    }
}

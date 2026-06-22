import Foundation
import LocalAuthentication
import SwiftUI

@MainActor
final class LockManager: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var authError: String?

    func authenticate() {
        let context = LAContext()
        context.localizedFallbackTitle = "Enter Passcode"
        var error: NSError?

        let reason = "Unlock your private journal"

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, evalError in
                Task { @MainActor in
                    if success {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            self?.isUnlocked = true
                        }
                        self?.authError = nil
                    } else {
                        self?.authError = evalError?.localizedDescription ?? "Authentication failed"
                    }
                }
            }
        } else {
            // No biometrics / passcode available — fail open so the user is never locked out.
            isUnlocked = true
        }
    }

    func lock() {
        isUnlocked = false
    }
}

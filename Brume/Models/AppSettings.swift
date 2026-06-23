import Foundation
import SwiftUI
import UIKit

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("isAppLocked")            var isAppLocked: Bool = false
    @AppStorage("notificationsEnabled")   var notificationsEnabled: Bool = false
    @AppStorage("notificationHour")       var notificationHour: Int = 20
    @AppStorage("notificationMinute")     var notificationMinute: Int = 0
    @AppStorage("colorSchemePreference")  var colorSchemePreference: String = "system"

    var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    /// The app's effective appearance as a UIKit style. Reliable inside a
    /// full-screen cover (which doesn't inherit the forced colour scheme):
    /// honour an explicit choice, otherwise read the real system appearance.
    var effectiveInterfaceStyle: UIUserInterfaceStyle {
        switch colorSchemePreference {
        case "light": return .light
        case "dark":  return .dark
        default:      return UIScreen.main.traitCollection.userInterfaceStyle
        }
    }

    private init() {}
}

import Foundation
import SwiftUI

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

    private init() {}
}

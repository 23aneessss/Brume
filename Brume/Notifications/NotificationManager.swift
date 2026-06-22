import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let reminderID = "brume.daily.reminder"

    // Soft, non-pressuring messages rotated daily.
    private let messages: [(title: String, body: String)] = [
        ("A quiet moment 🌙", "Your page is here whenever you'd like to breathe and write."),
        ("How are you, really? 🌿", "Take a minute for yourself. A few words or a small doodle is enough."),
        ("Pause with Brume 🌫", "Let your thoughts settle onto the page. No rush, no rules."),
        ("Gentle check-in 🍃", "Whatever today held, there's space for it here."),
        ("Time to unwind ✨", "Open Brume, take a slow breath, and let your hand wander.")
    ]

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])

        let settings = AppSettings.shared
        let message = messages.randomElement() ?? messages[0]

        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = settings.notificationHour
        dateComponents.minute = settings.notificationMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminderID])
    }

    func refreshIfNeeded() {
        let settings = AppSettings.shared
        guard settings.notificationsEnabled else { return }
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            if setting.authorizationStatus == .authorized {
                self.scheduleDailyReminder()
            }
        }
    }
}

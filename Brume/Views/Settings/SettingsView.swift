import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var entries: [Entry]

    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(style: .dots)

                ScrollView {
                    VStack(spacing: BrumeTheme.Spacing.lg) {
                        appearanceSection
                        privacySection
                        notificationsSection
                        aboutSection
                    }
                    .padding(BrumeTheme.Spacing.lg)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(BrumeTheme.Colors.warmBrown)
                    }
                }
            }
        }
        .tint(BrumeTheme.Colors.clay)
    }

    // MARK: - Appearance
    private var appearanceSection: some View {
        SettingsCard(title: "Appearance", icon: "paintbrush.pointed") {
            VStack(spacing: BrumeTheme.Spacing.md) {
                HStack {
                    Text("Theme")
                        .font(BrumeTheme.Fonts.body(16))
                        .foregroundStyle(BrumeTheme.Colors.inkDark)
                    Spacer()
                    Picker("Theme", selection: $settings.colorSchemePreference) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
        }
    }

    // MARK: - Privacy
    private var privacySection: some View {
        SettingsCard(title: "Privacy", icon: "lock.shield") {
            VStack(spacing: BrumeTheme.Spacing.md) {
                Toggle(isOn: $settings.isAppLocked) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lock with Face ID")
                            .font(BrumeTheme.Fonts.body(16))
                            .foregroundStyle(BrumeTheme.Colors.inkDark)
                        Text("Require authentication to open Brume")
                            .font(BrumeTheme.Fonts.caption(12))
                            .foregroundStyle(BrumeTheme.Colors.inkLight)
                    }
                }
                .tint(BrumeTheme.Colors.sage)
            }
        }
    }

    // MARK: - Notifications
    private var notificationsSection: some View {
        SettingsCard(title: "Gentle reminders", icon: "bell.badge") {
            VStack(spacing: BrumeTheme.Spacing.md) {
                Toggle(isOn: Binding(
                    get: { settings.notificationsEnabled },
                    set: { newValue in
                        if newValue {
                            NotificationManager.shared.requestAuthorization { granted in
                                settings.notificationsEnabled = granted
                                if granted { NotificationManager.shared.scheduleDailyReminder() }
                            }
                        } else {
                            settings.notificationsEnabled = false
                            NotificationManager.shared.cancelReminders()
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily nudge")
                            .font(BrumeTheme.Fonts.body(16))
                            .foregroundStyle(BrumeTheme.Colors.inkDark)
                        Text("A soft reminder to take a moment for yourself")
                            .font(BrumeTheme.Fonts.caption(12))
                            .foregroundStyle(BrumeTheme.Colors.inkLight)
                    }
                }
                .tint(BrumeTheme.Colors.sage)

                if settings.notificationsEnabled {
                    Divider()
                    DatePicker(
                        "Remind me at",
                        selection: Binding(
                            get: {
                                Calendar.current.date(
                                    from: DateComponents(
                                        hour: settings.notificationHour,
                                        minute: settings.notificationMinute
                                    )
                                ) ?? Date()
                            },
                            set: { date in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                                settings.notificationHour = comps.hour ?? 20
                                settings.notificationMinute = comps.minute ?? 0
                                NotificationManager.shared.scheduleDailyReminder()
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .font(BrumeTheme.Fonts.body(16))
                    .foregroundStyle(BrumeTheme.Colors.inkDark)
                }
            }
        }
    }

    // MARK: - About
    private var aboutSection: some View {
        SettingsCard(title: "About", icon: "heart.text.square") {
            VStack(alignment: .leading, spacing: BrumeTheme.Spacing.md) {
                infoRow("Entries", value: "\(entries.count)")
                Divider()
                infoRow("Version", value: appVersion)
                Divider()
                Text("Brume keeps everything on your device. Nothing is ever uploaded.")
                    .font(BrumeTheme.Fonts.caption(13))
                    .foregroundStyle(BrumeTheme.Colors.inkLight)
                    .lineSpacing(3)

                Text("breathe · write · draw")
                    .font(BrumeTheme.Fonts.label(15))
                    .foregroundStyle(BrumeTheme.Colors.clay)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
        }
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(BrumeTheme.Fonts.body(16))
                .foregroundStyle(BrumeTheme.Colors.inkDark)
            Spacer()
            Text(value)
                .font(BrumeTheme.Fonts.body(16))
                .foregroundStyle(BrumeTheme.Colors.inkLight)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return version
    }
}

// MARK: - Reusable settings card
struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: BrumeTheme.Spacing.md) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(BrumeTheme.Colors.clay)
                Text(title)
                    .font(BrumeTheme.Fonts.heading(18))
                    .foregroundStyle(BrumeTheme.Colors.warmBrown)
            }
            content()
        }
        .padding(BrumeTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: BrumeTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BrumeTheme.Radius.lg, style: .continuous)
                .stroke(BrumeTheme.Colors.cardBorder, lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings.shared)
        .modelContainer(for: Entry.self, inMemory: true)
}

import SwiftUI

enum Mood: String, CaseIterable, Identifiable {
    case happy
    case calm
    case sad
    case energetic
    case grateful

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .happy:     return "🌻"
        case .calm:      return "🌙"
        case .sad:       return "🌧"
        case .energetic: return "⚡️"
        case .grateful:  return "🍃"
        }
    }

    var label: String {
        switch self {
        case .happy:     return "Happy"
        case .calm:      return "Calm"
        case .sad:       return "Tender"
        case .energetic: return "Alive"
        case .grateful:  return "Grateful"
        }
    }

    var color: Color {
        switch self {
        case .happy:     return BrumeTheme.Colors.moodHappy
        case .calm:      return BrumeTheme.Colors.moodCalm
        case .sad:       return BrumeTheme.Colors.moodSad
        case .energetic: return BrumeTheme.Colors.moodEnergetic
        case .grateful:  return BrumeTheme.Colors.moodGrateful
        }
    }

    static func from(_ raw: String?) -> Mood? {
        guard let raw else { return nil }
        return Mood(rawValue: raw)
    }
}

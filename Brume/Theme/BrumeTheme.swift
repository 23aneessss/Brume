import SwiftUI

enum BrumeTheme {
    // MARK: - Colors
    struct Colors {
        // Light mode
        static let background     = Color(hex: "#F7F3EC")
        static let surface        = Color(hex: "#FDF9F3")
        static let lavender       = Color(hex: "#9B8EC4")
        static let lavenderLight  = Color(hex: "#C8B8E8")
        static let sage           = Color(hex: "#8BA888")
        static let sageLight      = Color(hex: "#B5CEB3")
        static let warmBrown      = Color(hex: "#6B5B4E")
        static let softBrown      = Color(hex: "#A08070")
        static let inkDark        = Color(hex: "#3D3530")
        static let inkMedium      = Color(hex: "#6B5B4E")
        static let inkLight       = Color(hex: "#9A8880")
        static let paperLine      = Color(hex: "#E8DDD0").opacity(0.6)
        static let cardBorder     = Color(hex: "#E2D8CC")

        // Mood colors
        static let moodHappy      = Color(hex: "#F4C542")
        static let moodCalm       = Color(hex: "#9B8EC4")
        static let moodSad        = Color(hex: "#7BAFD4")
        static let moodEnergetic  = Color(hex: "#E88B5A")
        static let moodGrateful   = Color(hex: "#8BA888")
    }

    // MARK: - Fonts
    struct Fonts {
        static func title(_ size: CGFloat = 28) -> Font {
            .custom("Noteworthy-Bold", size: size)
        }
        static func heading(_ size: CGFloat = 20) -> Font {
            .custom("Noteworthy-Light", size: size)
        }
        static func label(_ size: CGFloat = 15) -> Font {
            .custom("Noteworthy-Light", size: size)
        }
        static func body(_ size: CGFloat = 16) -> Font {
            .custom("Noteworthy-Light", size: size)
        }
        static func caption(_ size: CGFloat = 12) -> Font {
            .custom("Noteworthy-Light", size: size)
        }
        // For main text entry (readability first)
        static func journalBody(_ size: CGFloat = 17) -> Font {
            Font.system(size: size, weight: .regular, design: .serif)
        }
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat   = 4
        static let sm: CGFloat   = 8
        static let md: CGFloat   = 16
        static let lg: CGFloat   = 24
        static let xl: CGFloat   = 32
        static let xxl: CGFloat  = 48
    }

    // MARK: - Corner Radius
    struct Radius {
        static let sm: CGFloat   = 8
        static let md: CGFloat   = 16
        static let lg: CGFloat   = 24
        static let pill: CGFloat = 100
    }

    // MARK: - Shadows
    struct Shadow {
        static let soft = (color: Color.black.opacity(0.06), radius: 12.0, x: 0.0, y: 4.0)
        static let card = (color: Color.black.opacity(0.08), radius: 20.0, x: 0.0, y: 6.0)
    }
}

// MARK: - Color hex init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Adaptive colors for dark mode
extension ShapeStyle where Self == Color {
    static var brumeBackground: Color {
        Color("BrumeBackground")
    }
    static var brumeSurface: Color {
        Color("BrumeSurface")
    }
    static var brumeLavender: Color {
        Color("BrumeLavender")
    }
    static var brumeInk: Color {
        Color("BrumeInk")
    }
}

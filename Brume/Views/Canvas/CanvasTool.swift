import SwiftUI
import PencilKit

enum CanvasMode: String {
    case write
    case draw
}

enum PenKind: String, CaseIterable, Identifiable {
    case pen
    case pencil
    case marker
    case eraser

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pen:    return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }

    var label: String {
        switch self {
        case .pen:    return "Pen"
        case .pencil: return "Pencil"
        case .marker: return "Marker"
        case .eraser: return "Eraser"
        }
    }
}

// Soothing palette for both ink and text.
enum InkColor: String, CaseIterable, Identifiable {
    case ink
    case clay
    case sage
    case rose
    case sky
    case amber

    var id: String { rawValue }

    var hex: String {
        switch self {
        case .ink:   return "#3D3530"
        case .clay:  return "#B97B4D"
        case .sage:  return "#8BA888"
        case .rose:  return "#C98BA8"
        case .sky:   return "#7BAFD4"
        case .amber: return "#E0A458"
        }
    }

    /// Display color. The neutral "ink" adapts to light/dark so notes stay
    /// legible in both; the accent colors read well on either scheme as-is.
    var color: Color {
        self == .ink ? BrumeTheme.Colors.inkDark : Color(hex: hex)
    }

    static func from(hex: String) -> InkColor {
        allCases.first { $0.hex.lowercased() == hex.lowercased() } ?? .ink
    }

    /// Concrete UIColor for PencilKit. The neutral "ink" flips to a light cream
    /// in dark mode so strokes are visible on dark paper; accents are constant.
    /// (Resolved from hex directly — round-tripping a dynamic SwiftUI Color
    /// through UIColor flattens it to one appearance.)
    func uiColor(for scheme: ColorScheme) -> UIColor {
        switch self {
        case .ink: return UIColor(Color(hex: scheme == .dark ? "#F1EBE2" : "#3D3530"))
        default:   return UIColor(Color(hex: hex))
        }
    }
}

struct CanvasToolState {
    var mode: CanvasMode = .write
    var pen: PenKind = .pen
    var color: InkColor = .ink
    var lineWidth: CGFloat = 5

    /// Builds the PencilKit tool, resolving the (possibly adaptive) ink colour
    /// against the active appearance so e.g. the neutral "ink" draws light in
    /// dark mode instead of baking in the light-mode brown.
    func pkTool(for scheme: ColorScheme) -> PKTool {
        let uiColor = color.uiColor(for: scheme)
        switch pen {
        case .pen:
            return PKInkingTool(.pen, color: uiColor, width: lineWidth)
        case .pencil:
            return PKInkingTool(.pencil, color: uiColor, width: lineWidth)
        case .marker:
            return PKInkingTool(.marker, color: uiColor.withAlphaComponent(0.5), width: lineWidth * 3)
        case .eraser:
            return PKEraserTool(.vector)
        }
    }
}

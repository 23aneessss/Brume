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

    /// A genuinely dynamic UIColor for PencilKit. The neutral "ink" flips to a
    /// light cream in dark mode so strokes stay visible on dark paper; accents
    /// are constant. Built with the UIColor trait closure (NOT by converting a
    /// SwiftUI Color, which flattens to a single appearance) so the canvas
    /// resolves it against its own — correct — interface style.
    var dynamicUIColor: UIColor {
        switch self {
        case .ink:
            return UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 0.945, green: 0.922, blue: 0.886, alpha: 1)  // #F1EBE2
                    : UIColor(red: 0.239, green: 0.208, blue: 0.188, alpha: 1)  // #3D3530
            }
        default:
            return UIColor(Color(hex: hex))
        }
    }
}

struct CanvasToolState {
    var mode: CanvasMode = .write
    var pen: PenKind = .pen
    var color: InkColor = .ink
    var lineWidth: CGFloat = 5

    /// Builds the PencilKit tool, resolving the ink colour against an explicit
    /// interface style (the canvas is forced to the same style) so light "ink"
    /// draws as cream in dark mode instead of the baked-in light-mode brown.
    func pkTool(for style: UIUserInterfaceStyle) -> PKTool {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let uiColor = color.dynamicUIColor.resolvedColor(with: traits)
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

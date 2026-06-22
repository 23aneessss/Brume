import Foundation
import CoreGraphics

struct TextAnnotation: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var text: String = ""
    var x: CGFloat
    var y: CGFloat
    var fontSize: CGFloat
    var colorHex: String
    var width: CGFloat

    init(
        text: String = "",
        x: CGFloat,
        y: CGFloat,
        fontSize: CGFloat = 17,
        colorHex: String = "#3D3530",
        width: CGFloat = 280
    ) {
        self.text = text
        self.x = x
        self.y = y
        self.fontSize = fontSize
        self.colorHex = colorHex
        self.width = width
    }

    var position: CGPoint {
        get { CGPoint(x: x, y: y) }
        set { x = newValue.x; y = newValue.y }
    }
}

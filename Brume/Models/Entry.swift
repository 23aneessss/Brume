import Foundation
import SwiftData
import PencilKit

@Model
final class Entry {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var mood: String?
    var drawingData: Data?
    var textAnnotationsData: Data?
    var isLocked: Bool

    init(
        title: String = "",
        mood: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.mood = mood
        self.drawingData = nil
        self.textAnnotationsData = nil
        self.isLocked = false
    }

    var textAnnotations: [TextAnnotation] {
        get {
            guard let data = textAnnotationsData else { return [] }
            return (try? JSONDecoder().decode([TextAnnotation].self, from: data)) ?? []
        }
        set {
            textAnnotationsData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    var preview: String {
        textAnnotations.first?.text.prefix(80).description ?? ""
    }

    var drawing: PKDrawing {
        get {
            guard let data = drawingData else { return PKDrawing() }
            return (try? PKDrawing(data: data)) ?? PKDrawing()
        }
        set {
            drawingData = try? newValue.dataRepresentation()
            updatedAt = Date()
        }
    }

    var isEmpty: Bool {
        drawing.strokes.isEmpty && textAnnotations.allSatisfy { $0.text.isEmpty }
    }
}

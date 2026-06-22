import SwiftUI
import PencilKit

/// UIKit bridge around `PKCanvasView`. The drawing lives in a fixed-size,
/// non-scrolling canvas so the SwiftUI text overlay can share the exact same
/// coordinate space.
struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: PKTool
    var isDrawingEnabled: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.tool = tool
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isScrollEnabled = false
        canvas.alwaysBounceVertical = false
        canvas.drawingPolicy = .anyInput          // finger + Apple Pencil
        canvas.delegate = context.coordinator
        canvas.isUserInteractionEnabled = isDrawingEnabled
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
        canvas.tool = tool
        canvas.isUserInteractionEnabled = isDrawingEnabled
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: PencilCanvasView

        init(_ parent: PencilCanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Avoid feedback loops by only writing real changes.
            if parent.drawing != canvasView.drawing {
                DispatchQueue.main.async {
                    self.parent.drawing = canvasView.drawing
                }
            }
        }
    }
}

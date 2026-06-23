import SwiftUI
import PencilKit

/// UIKit bridge around `PKCanvasView`, used as the scrollable "page".
///
/// The canvas is a tall, vertically-scrolling surface:
/// - **Write mode**: one finger scrolls the page, a tap drops a text note,
///   the pen is disabled.
/// - **Draw mode**: one finger draws, two fingers scroll the page.
///
/// The SwiftUI text overlay is positioned in *content* coordinates and shifted
/// by `contentOffset`, so notes scroll in lock-step with the drawing.
struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var contentOffset: CGPoint
    var tool: PKTool
    var mode: CanvasMode
    var pageHeight: CGFloat
    var interfaceStyle: UIUserInterfaceStyle
    var onTap: (CGPoint) -> Void   // tap location in content coordinates

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.tool = tool
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput          // finger + Apple Pencil
        canvas.delegate = context.coordinator
        canvas.isScrollEnabled = true
        canvas.alwaysBounceVertical = true
        canvas.alwaysBounceHorizontal = false
        canvas.showsHorizontalScrollIndicator = false
        canvas.showsVerticalScrollIndicator = true
        canvas.overrideUserInterfaceStyle = interfaceStyle

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        canvas.addGestureRecognizer(tap)
        context.coordinator.tapRecognizer = tap

        apply(mode: mode, to: canvas)
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        context.coordinator.parent = self
        if canvas.drawing != drawing { canvas.drawing = drawing }
        canvas.tool = tool
        canvas.overrideUserInterfaceStyle = interfaceStyle
        canvas.contentSize = CGSize(width: canvas.bounds.width, height: pageHeight)
        apply(mode: mode, to: canvas)
    }

    private func apply(mode: CanvasMode, to canvas: PKCanvasView) {
        let drawingOn = (mode == .draw)
        canvas.drawingGestureRecognizer.isEnabled = drawingOn
        // One finger draws in Draw mode (so two fingers are free to scroll);
        // one finger scrolls in Write mode.
        canvas.panGestureRecognizer.minimumNumberOfTouches = drawingOn ? 2 : 1
        // Only add notes by tapping while writing.
        canvas.gestureRecognizers?
            .compactMap { $0 as? UITapGestureRecognizer }
            .forEach { $0.isEnabled = !drawingOn }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvasView
        weak var tapRecognizer: UITapGestureRecognizer?

        init(_ parent: PencilCanvasView) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view else { return }
            // location(in: scrollView) is already in content coordinates.
            parent.onTap(gesture.location(in: view))
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if parent.drawing != canvasView.drawing {
                DispatchQueue.main.async {
                    self.parent.drawing = canvasView.drawing
                }
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset
            DispatchQueue.main.async {
                if self.parent.contentOffset != offset {
                    self.parent.contentOffset = offset
                }
            }
        }
    }
}

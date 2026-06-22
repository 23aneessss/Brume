import UIKit
import SwiftUI
import PencilKit

enum PDFExporter {
    /// Renders an entry (text annotations + drawing + header) into a single-page
    /// A4-ish PDF and returns a temporary file URL.
    static func export(entry: Entry) -> URL? {
        let pageWidth: CGFloat = 612   // 8.5"
        let pageHeight: CGFloat = 792  // 11"
        let margin: CGFloat = 48
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let fileName = sanitizedFileName(for: entry)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                let cg = ctx.cgContext

                // Background
                UIColor(BrumeTheme.Colors.surface).setFill()
                cg.fill(pageRect)

                // Header
                drawHeader(entry: entry, in: pageRect, margin: margin)

                // Content area below header
                let contentTop = margin + 70
                let contentRect = CGRect(
                    x: margin,
                    y: contentTop,
                    width: pageWidth - margin * 2,
                    height: pageHeight - contentTop - margin
                )

                // Drawing — scaled to fit the content area, preserving aspect.
                let drawing = entry.drawing
                if !drawing.strokes.isEmpty {
                    let bounds = drawing.bounds
                    if !bounds.isEmpty {
                        let scale = min(
                            contentRect.width / bounds.width,
                            contentRect.height / bounds.height,
                            2.0
                        )
                        let image = drawing.image(from: bounds, scale: scale)
                        let drawW = bounds.width * scale
                        let drawH = bounds.height * scale
                        let drawRect = CGRect(
                            x: contentRect.midX - drawW / 2,
                            y: contentRect.minY,
                            width: drawW,
                            height: drawH
                        )
                        image.draw(in: drawRect)
                    }
                }

                // Text annotations — laid out in reading order beneath any drawing.
                let sortedText = entry.textAnnotations
                    .filter { !$0.text.isEmpty }
                    .sorted { $0.y < $1.y }

                var textY = contentRect.minY
                if !drawing.strokes.isEmpty {
                    textY = contentRect.minY + min(contentRect.height * 0.45, contentRect.height)
                }

                for annotation in sortedText {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.lineSpacing = 4
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont(name: "Georgia", size: 14) ?? UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor(Color(hex: annotation.colorHex)),
                        .paragraphStyle: paragraph
                    ]
                    let textRect = CGRect(
                        x: contentRect.minX,
                        y: textY,
                        width: contentRect.width,
                        height: contentRect.maxY - textY
                    )
                    let attributed = NSAttributedString(string: annotation.text, attributes: attrs)
                    attributed.draw(in: textRect)
                    let measured = attributed.boundingRect(
                        with: CGSize(width: contentRect.width, height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        context: nil
                    )
                    textY += measured.height + 12
                    if textY > contentRect.maxY { break }
                }

                // Footer
                drawFooter(in: pageRect, margin: margin)
            }
            return url
        } catch {
            print("PDF export failed: \(error)")
            return nil
        }
    }

    private static func drawHeader(entry: Entry, in pageRect: CGRect, margin: CGFloat) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateString = formatter.string(from: entry.createdAt)

        let title = entry.title.isEmpty ? "Brume entry" : entry.title
        let moodEmoji = Mood.from(entry.mood)?.emoji ?? ""

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Noteworthy-Bold", size: 26) ?? UIFont.boldSystemFont(ofSize: 26),
            .foregroundColor: UIColor(BrumeTheme.Colors.warmBrown)
        ]
        let titleString = "\(moodEmoji) \(title)".trimmingCharacters(in: .whitespaces)
        titleString.draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttrs)

        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Noteworthy-Light", size: 13) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor(BrumeTheme.Colors.inkLight)
        ]
        dateString.draw(at: CGPoint(x: margin, y: margin + 36), withAttributes: dateAttrs)

        // Divider
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: margin + 60))
        path.addLine(to: CGPoint(x: pageRect.width - margin, y: margin + 60))
        UIColor(BrumeTheme.Colors.cardBorder).setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    private static func drawFooter(in pageRect: CGRect, margin: CGFloat) {
        let footer = "Made with Brume · breathe · write · draw"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Noteworthy-Light", size: 11) ?? UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor(BrumeTheme.Colors.inkLight)
        ]
        let size = footer.size(withAttributes: attrs)
        footer.draw(
            at: CGPoint(x: pageRect.midX - size.width / 2, y: pageRect.height - margin + 10),
            withAttributes: attrs
        )
    }

    private static func sanitizedFileName(for entry: Entry) -> String {
        let base = entry.title.isEmpty ? "Brume-entry" : entry.title
        let safe = base.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "-")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(safe.isEmpty ? "Brume" : safe)-\(formatter.string(from: entry.createdAt)).pdf"
    }
}

import SwiftUI
import PencilKit

struct EntryCard: View {
    let entry: Entry
    var seed: UInt64 = 42
    @Environment(\.colorScheme) private var scheme

    private var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(entry.updatedAt) {
            formatter.dateFormat = "'Today,' h:mm a"
        } else if Calendar.current.isDateInYesterday(entry.updatedAt) {
            formatter.dateFormat = "'Yesterday,' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: entry.updatedAt)
    }

    private var displayTitle: String {
        if !entry.title.isEmpty { return entry.title }
        if !entry.preview.isEmpty { return entry.preview }
        return "Untitled page"
    }

    var body: some View {
        PaperCard(seed: seed) {
            HStack(spacing: BrumeTheme.Spacing.md) {
                // Mood / drawing thumbnail
                thumbnail

                VStack(alignment: .leading, spacing: 6) {
                    Text(displayTitle)
                        .font(BrumeTheme.Fonts.heading(19))
                        .foregroundStyle(BrumeTheme.Colors.warmBrown)
                        .lineLimit(1)

                    if !entry.preview.isEmpty {
                        Text(entry.preview)
                            .font(BrumeTheme.Fonts.body(14))
                            .foregroundStyle(BrumeTheme.Colors.inkMedium)
                            .lineLimit(2)
                    }

                    HStack(spacing: 6) {
                        if let mood = Mood.from(entry.mood) {
                            Text(mood.emoji)
                                .font(.system(size: 13))
                            Text(mood.label)
                                .font(BrumeTheme.Fonts.caption(12))
                                .foregroundStyle(mood.color)
                            Text("·")
                                .foregroundStyle(BrumeTheme.Colors.inkLight)
                        }
                        Text(dateString)
                            .font(BrumeTheme.Fonts.caption(12))
                            .foregroundStyle(BrumeTheme.Colors.inkLight)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(BrumeTheme.Spacing.md)
        }
    }

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BrumeTheme.Radius.sm, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            (Mood.from(entry.mood)?.color ?? BrumeTheme.Colors.lavender).opacity(0.18),
                            (Mood.from(entry.mood)?.color ?? BrumeTheme.Colors.sage).opacity(0.08)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)

            if !entry.drawing.strokes.isEmpty {
                DrawingThumbnail(drawing: entry.drawing)
                    .frame(width: 52, height: 52)
            } else if let mood = Mood.from(entry.mood) {
                Text(mood.emoji)
                    .font(.system(size: 26))
            } else {
                Image(systemName: "doc.text")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(BrumeTheme.Colors.lavender.opacity(0.6))
            }
        }
    }
}

// Renders a PKDrawing into a small static image.
struct DrawingThumbnail: View {
    let drawing: PKDrawing

    var body: some View {
        GeometryReader { geo in
            if let image = renderImage(size: geo.size) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }

    private func renderImage(size: CGSize) -> UIImage? {
        let bounds = drawing.bounds
        guard !bounds.isEmpty else { return nil }
        let scale = min(size.width / bounds.width, size.height / bounds.height)
        return drawing.image(from: bounds, scale: max(scale, 0.1))
    }
}

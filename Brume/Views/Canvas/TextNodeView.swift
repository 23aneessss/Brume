import SwiftUI

struct TextNodeView: View {
    @Binding var annotation: TextAnnotation
    let isInteractive: Bool
    let isFocused: Bool
    var onTapToFocus: () -> Void
    var onDelete: () -> Void
    var onCommit: () -> Void

    @FocusState private var fieldFocused: Bool
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TextField("", text: $annotation.text, axis: .vertical)
                .focused($fieldFocused)
                .font(.system(size: annotation.fontSize, weight: .regular, design: .serif))
                .foregroundStyle(InkColor.from(hex: annotation.colorHex).color)
                .tint(BrumeTheme.Colors.clay)
                .multilineTextAlignment(.leading)
                .frame(width: annotation.width, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isFocused ? BrumeTheme.Colors.clay.opacity(0.06) : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            isFocused ? BrumeTheme.Colors.clay.opacity(0.5) : .clear,
                            style: StrokeStyle(lineWidth: 1.2, dash: [4, 3])
                        )
                )
                .disabled(!isInteractive)

            // Delete handle when focused
            if isFocused && isInteractive {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(BrumeTheme.Colors.softBrown)
                        .background(Circle().fill(Color.brumeSurface))
                }
                .offset(x: 8, y: -8)
            }
        }
        .position(
            x: annotation.x + dragOffset.width,
            y: annotation.y + dragOffset.height
        )
        .gesture(dragGesture, including: isInteractive ? .all : .none)
        .onChange(of: fieldFocused) { _, newValue in
            if !newValue { onCommit() }
        }
        .onChange(of: isFocused) { _, focused in
            fieldFocused = focused
        }
        .onAppear {
            // @FocusState.onChange doesn't fire for the initial value, so a
            // freshly-created (already-focused) note needs an explicit nudge.
            if isFocused {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    fieldFocused = true
                }
            }
        }
        .onTapGesture {
            if isInteractive {
                onTapToFocus()
                fieldFocused = true
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                // Only drag when not actively editing text, to avoid fighting the cursor.
                if !fieldFocused {
                    dragOffset = value.translation
                }
            }
            .onEnded { value in
                if !fieldFocused {
                    annotation.x += value.translation.width
                    annotation.y += value.translation.height
                    dragOffset = .zero
                    onCommit()
                }
            }
    }
}

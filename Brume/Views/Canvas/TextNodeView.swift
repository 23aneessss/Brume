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
            .overlay(alignment: .topTrailing) {
                if isFocused && isInteractive { deleteHandle.offset(x: 10, y: -10) }
            }
            .overlay(alignment: .topLeading) {
                if isFocused && isInteractive { moveHandle.offset(x: -10, y: -10) }
            }
            // Anchored by its top-left corner at the tap point (canvas is
            // top-leading aligned), so text appears exactly where you tapped.
            .offset(
                x: annotation.x + dragOffset.width,
                y: annotation.y + dragOffset.height
            )
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

    // MARK: - Delete handle
    private var deleteHandle: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(BrumeTheme.Colors.softBrown)
                .background(Circle().fill(Color.brumeSurface))
        }
    }

    // MARK: - Move handle (drag to reposition the note)
    private var moveHandle: some View {
        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(Circle().fill(BrumeTheme.Colors.clay))
            .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in dragOffset = value.translation }
                    .onEnded { value in
                        annotation.x += value.translation.width
                        annotation.y += value.translation.height
                        dragOffset = .zero
                        onCommit()
                    }
            )
    }
}

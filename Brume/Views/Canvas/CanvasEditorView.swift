import SwiftUI
import SwiftData
import PencilKit

struct CanvasEditorView: View {
    @Bindable var entry: Entry
    var isNew: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @AppStorage("hasSeenCanvasCoach") private var hasSeenCoach = false

    @State private var tool = CanvasToolState()
    @State private var drawing = PKDrawing()
    @State private var annotations: [TextAnnotation] = []
    @State private var focusedNodeID: UUID?
    @State private var showMoodPicker = false
    @State private var showCoach = false
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    @State private var didLoad = false

    var body: some View {
        ZStack {
            PaperBackground(style: tool.mode == .draw ? .plain : .lines)

            canvasStack

            VStack {
                topBar
                Spacer()
                bottomToolbar
            }

            if showMoodPicker {
                moodPickerOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            if showCoach {
                CoachOverlay { dismissCoach() }
                    .transition(.opacity)
            }
        }
        .onAppear(perform: load)
        .onChange(of: drawing) { _, newValue in
            entry.drawing = newValue
        }
        .onDisappear(perform: persistAndCleanup)
        .sheet(isPresented: $showShareSheet) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
        .statusBarHidden(true)
    }

    // MARK: - Canvas + text layers
    private var canvasStack: some View {
        // Top-leading alignment so a text note's top-left sits exactly where
        // the user tapped (its offset is measured from the canvas corner).
        ZStack(alignment: .topLeading) {
            // Drawing layer (interactive only in draw mode)
            PencilCanvasView(
                drawing: $drawing,
                tool: tool.pkTool(for: AppSettings.shared.effectiveInterfaceStyle),
                isDrawingEnabled: tool.mode == .draw,
                interfaceStyle: AppSettings.shared.effectiveInterfaceStyle
            )

            // Empty-space tap catcher (write mode only)
            if tool.mode == .write {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(coordinateSpace: .local) { location in
                        handleCanvasTap(at: location)
                    }
            }

            // Text nodes
            ForEach($annotations) { $annotation in
                TextNodeView(
                    annotation: $annotation,
                    isInteractive: tool.mode == .write,
                    isFocused: focusedNodeID == annotation.id,
                    onTapToFocus: { focusedNodeID = annotation.id },
                    onDelete: { deleteNode(annotation) },
                    onCommit: { persist() }
                )
                .allowsHitTesting(tool.mode == .write)
            }
        }
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack(spacing: BrumeTheme.Spacing.sm) {
            glassButton(icon: "chevron.left") { saveAndDismiss() }

            Spacer()

            // Mood
            glassButton(icon: nil, label: Mood.from(entry.mood)?.emoji ?? "🌫") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showMoodPicker.toggle()
                }
            }

            glassButton(icon: "square.and.arrow.up") { exportPDF() }
        }
        .padding(.horizontal, BrumeTheme.Spacing.md)
        .padding(.top, BrumeTheme.Spacing.sm)
    }

    // MARK: - Bottom toolbar
    private var bottomToolbar: some View {
        VStack(spacing: BrumeTheme.Spacing.sm) {
            // Tool options row (only in draw mode)
            if tool.mode == .draw {
                drawOptions
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                writeOptions
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Mode switcher
            HStack(spacing: 0) {
                modeTab(.write, icon: "pencil.line", label: "Write")
                modeTab(.draw, icon: "scribble.variable", label: "Draw")
            }
            .padding(4)
            .background(Color.brumeSurface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(BrumeTheme.Colors.cardBorder, lineWidth: 1.2))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
        .padding(.horizontal, BrumeTheme.Spacing.md)
        .padding(.bottom, BrumeTheme.Spacing.md)
    }

    private func modeTab(_ mode: CanvasMode, icon: String, label: String) -> some View {
        let isSelected = tool.mode == mode
        return Button {
            let gen = UIImpactFeedbackGenerator(style: .soft)
            gen.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                tool.mode = mode
                focusedNodeID = nil
                hideKeyboard()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                Text(label)
                    .font(BrumeTheme.Fonts.label(15))
            }
            .foregroundStyle(isSelected ? .white : BrumeTheme.Colors.inkMedium)
            .padding(.horizontal, BrumeTheme.Spacing.lg)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(isSelected ? BrumeTheme.Colors.clay : .clear)
            )
        }
    }

    // MARK: - Draw options (pens + colors + width)
    private var drawOptions: some View {
        VStack(spacing: BrumeTheme.Spacing.sm) {
            HStack(spacing: BrumeTheme.Spacing.md) {
                ForEach(PenKind.allCases) { pen in
                    Button {
                        tool.pen = pen
                    } label: {
                        Image(systemName: pen.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(tool.pen == pen ? .white : BrumeTheme.Colors.inkMedium)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(tool.pen == pen ? BrumeTheme.Colors.sage : Color.clear)
                            )
                    }
                }
            }

            if tool.pen != .eraser {
                HStack(spacing: BrumeTheme.Spacing.md) {
                    ForEach(InkColor.allCases) { ink in
                        colorDot(ink)
                    }
                }
            }
        }
        .padding(BrumeTheme.Spacing.md)
        .background(Color.brumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: BrumeTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BrumeTheme.Radius.lg, style: .continuous)
                .stroke(BrumeTheme.Colors.cardBorder, lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Write options (text colors + add)
    private var writeOptions: some View {
        HStack(spacing: BrumeTheme.Spacing.md) {
            ForEach(InkColor.allCases) { ink in
                colorDot(ink)
            }
            Divider().frame(height: 24)
            Button {
                addNode(at: CGPoint(x: 180, y: 220))
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(BrumeTheme.Colors.clay)
            }
        }
        .padding(BrumeTheme.Spacing.md)
        .background(Color.brumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: BrumeTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BrumeTheme.Radius.lg, style: .continuous)
                .stroke(BrumeTheme.Colors.cardBorder, lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private func colorDot(_ ink: InkColor) -> some View {
        Button {
            tool.color = ink
            // Apply to focused text node if any
            if let id = focusedNodeID,
               let idx = annotations.firstIndex(where: { $0.id == id }) {
                annotations[idx].colorHex = ink.hex
                persist()
            }
        } label: {
            Circle()
                .fill(ink.color)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle().stroke(.white, lineWidth: tool.color == ink ? 2.5 : 0)
                )
                .overlay(
                    Circle().stroke(ink.color.opacity(0.5), lineWidth: tool.color == ink ? 1 : 0)
                        .scaleEffect(1.25)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        }
    }

    // MARK: - Mood picker
    private var moodPickerOverlay: some View {
        VStack {
            Spacer().frame(height: 70)
            HStack(spacing: BrumeTheme.Spacing.sm) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        entry.mood = (entry.mood == mood.rawValue) ? nil : mood.rawValue
                        withAnimation { showMoodPicker = false }
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.emoji).font(.system(size: 26))
                            Text(mood.label)
                                .font(BrumeTheme.Fonts.caption(11))
                                .foregroundStyle(BrumeTheme.Colors.inkMedium)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(entry.mood == mood.rawValue ? mood.color.opacity(0.2) : .clear)
                        )
                    }
                }
            }
            .padding(BrumeTheme.Spacing.md)
            .background(Color.brumeSurface)
            .clipShape(RoundedRectangle(cornerRadius: BrumeTheme.Radius.lg, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
            .padding(.horizontal, BrumeTheme.Spacing.md)
            Spacer()
        }
        .background(
            Color.black.opacity(0.001)
                .onTapGesture { withAnimation { showMoodPicker = false } }
        )
    }

    // MARK: - Reusable glass button
    private func glassButton(icon: String?, label: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(BrumeTheme.Colors.warmBrown)
                } else if let label {
                    Text(label).font(.system(size: 20))
                }
            }
            .frame(width: 44, height: 44)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .overlay(Circle().stroke(BrumeTheme.Colors.cardBorder.opacity(0.5), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
    }

    // MARK: - Actions
    private func load() {
        guard !didLoad else { return }
        didLoad = true
        drawing = entry.drawing
        annotations = entry.textAnnotations
        if !hasSeenCoach {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showCoach = true }
            }
        }
    }

    private func handleCanvasTap(at location: CGPoint) {
        // If a node is focused, an empty tap just dismisses it.
        if focusedNodeID != nil {
            focusedNodeID = nil
            hideKeyboard()
            return
        }
        addNode(at: location)
    }

    private func addNode(at location: CGPoint) {
        // Notes anchor by their top-left corner, so clamp the start point to
        // keep the whole box on-screen (and clear of the top toolbar).
        let screenW = UIScreen.main.bounds.width
        let width = min(300, screenW - 48)
        let x = min(max(16, location.x), screenW - width - 16)
        let y = max(72, location.y)

        var node = TextAnnotation(
            text: "",
            x: x,
            y: y,
            fontSize: 18,
            colorHex: tool.color.hex
        )
        node.width = width
        annotations.append(node)
        focusedNodeID = node.id
        persist()
    }

    private func deleteNode(_ annotation: TextAnnotation) {
        annotations.removeAll { $0.id == annotation.id }
        focusedNodeID = nil
        persist()
    }

    private func persist() {
        // Strip empty, unfocused nodes so the canvas stays tidy.
        annotations.removeAll { $0.text.isEmpty && $0.id != focusedNodeID }
        entry.textAnnotations = annotations
        entry.drawing = drawing
    }

    private func persistAndCleanup() {
        annotations.removeAll { $0.text.isEmpty }
        entry.textAnnotations = annotations
        entry.drawing = drawing

        if isNew && entry.isEmpty {
            context.delete(entry)
        }
    }

    private func saveAndDismiss() {
        hideKeyboard()
        persist()
        dismiss()
    }

    private func exportPDF() {
        persist()
        let url = PDFExporter.export(entry: entry)
        exportURL = url
        if url != nil { showShareSheet = true }
    }

    private func dismissCoach() {
        hasSeenCoach = true
        withAnimation { showCoach = false }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

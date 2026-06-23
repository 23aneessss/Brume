import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.updatedAt, order: .reverse) private var entries: [Entry]

    @State private var searchText = ""
    @State private var showSearch = false
    @State private var newEntry: Entry?
    @State private var openEntry: Entry?
    @State private var showSettings = false
    @State private var entryToDelete: Entry?

    private var filteredEntries: [Entry] {
        guard !searchText.isEmpty else { return entries }
        return entries.filter { entry in
            entry.title.localizedCaseInsensitiveContains(searchText) ||
            entry.textAnnotations.contains { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Late night thoughts"
        }
    }

    var body: some View {
        ZStack {
            PaperBackground(style: .dots)

            VStack(spacing: 0) {
                header

                if showSearch {
                    searchBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }

            // Floating compose button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    composeButton
                        .padding(.trailing, BrumeTheme.Spacing.lg)
                        .padding(.bottom, BrumeTheme.Spacing.lg)
                }
            }
        }
        .fullScreenCover(item: $newEntry) { entry in
            CanvasEditorView(entry: entry, isNew: true)
        }
        .fullScreenCover(item: $openEntry) { entry in
            CanvasEditorView(entry: entry, isNew: false)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .confirmationDialog(
            "Delete this entry?",
            isPresented: Binding(
                get: { entryToDelete != nil },
                set: { if !$0 { entryToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    withAnimation { context.delete(entry) }
                }
                entryToDelete = nil
            }
            Button("Keep", role: .cancel) { entryToDelete = nil }
        } message: {
            Text("This page and its drawing will be gone for good.")
        }
        .onAppear(perform: sweepEmptyEntries)
    }

    /// Removes any fully-empty entries that may have been orphaned (e.g. the app
    /// was killed before an untouched new page could be cleaned up on dismiss).
    private func sweepEmptyEntries() {
        for entry in entries where entry.isEmpty {
            context.delete(entry)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(BrumeTheme.Fonts.label(16))
                    .foregroundStyle(BrumeTheme.Colors.inkLight)
                Text("Your journal")
                    .font(BrumeTheme.Fonts.title(32))
                    .foregroundStyle(BrumeTheme.Colors.warmBrown)
            }
            Spacer()
            HStack(spacing: BrumeTheme.Spacing.sm) {
                circleButton(icon: "magnifyingglass") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showSearch.toggle()
                        if !showSearch { searchText = "" }
                    }
                }
                circleButton(icon: "slider.horizontal.3") {
                    showSettings = true
                }
            }
        }
        .padding(.horizontal, BrumeTheme.Spacing.lg)
        .padding(.top, BrumeTheme.Spacing.sm)
        .padding(.bottom, BrumeTheme.Spacing.md)
    }

    private func circleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(BrumeTheme.Colors.warmBrown)
                .frame(width: 44, height: 44)
                .background(Color.brumeSurface)
                .clipShape(Circle())
                .overlay(Circle().stroke(BrumeTheme.Colors.cardBorder, lineWidth: 1.2))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
    }

    // MARK: - Search
    private var searchBar: some View {
        HStack(spacing: BrumeTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(BrumeTheme.Colors.inkLight)
            TextField("Search your thoughts…", text: $searchText)
                .font(BrumeTheme.Fonts.body(16))
                .tint(BrumeTheme.Colors.clay)
        }
        .padding(.horizontal, BrumeTheme.Spacing.md)
        .padding(.vertical, 12)
        .background(Color.brumeSurface)
        .clipShape(RoundedRectangle(cornerRadius: BrumeTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BrumeTheme.Radius.md, style: .continuous)
                .stroke(BrumeTheme.Colors.cardBorder, lineWidth: 1.2)
        )
        .padding(.horizontal, BrumeTheme.Spacing.lg)
        .padding(.bottom, BrumeTheme.Spacing.md)
    }

    // MARK: - List
    private var entryList: some View {
        ScrollView {
            LazyVStack(spacing: BrumeTheme.Spacing.md) {
                ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                    EntryCard(entry: entry, seed: UInt64(index + 3))
                        .onTapGesture { openEntry = entry }
                        .contextMenu {
                            Button(role: .destructive) {
                                entryToDelete = entry
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .padding(.horizontal, BrumeTheme.Spacing.lg)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: BrumeTheme.Spacing.lg) {
            Spacer()
            OnboardingIllustration(kind: .write, accent: BrumeTheme.Colors.clay)
                .frame(height: 180)
            VStack(spacing: BrumeTheme.Spacing.sm) {
                Text(searchText.isEmpty ? "Your page awaits" : "Nothing found")
                    .font(BrumeTheme.Fonts.title(26))
                    .foregroundStyle(BrumeTheme.Colors.warmBrown)
                Text(searchText.isEmpty
                     ? "Tap the pencil to begin your first entry."
                     : "Try a different word.")
                    .font(BrumeTheme.Fonts.body(16))
                    .foregroundStyle(BrumeTheme.Colors.inkMedium)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Spacer()
        }
        .padding(BrumeTheme.Spacing.xl)
    }

    // MARK: - Compose
    private var composeButton: some View {
        Button {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
            let entry = Entry()
            context.insert(entry)
            newEntry = entry
        } label: {
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        colors: [BrumeTheme.Colors.clay, BrumeTheme.Colors.clayLight],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: BrumeTheme.Colors.clay.opacity(0.4), radius: 16, y: 6)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Entry.self, inMemory: true)
        .environmentObject(AppSettings.shared)
}

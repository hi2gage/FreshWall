import SwiftUI

// MARK: - EnhancedNotesView

/// Comprehensive notes editing view with structured sections for different work stages
struct EnhancedNotesView: View {
    @Binding var notes: IncidentNotes?
    @Environment(\.dismiss) private var dismiss
    @State private var workingNotes: IncidentNotes
    @State private var selectedTab: IncidentNotes.Stage = .beforeWork

    init(notes: Binding<IncidentNotes?>) {
        self._notes = notes
        self._workingNotes = State(initialValue: notes.wrappedValue ?? IncidentNotes())
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector

                // Notes Content
                TabView(selection: $selectedTab) {
                    ForEach(IncidentNotes.Stage.allCases, id: \.self) { stage in
                        NotesStageView(
                            stage: stage,
                            text: bindingForStage(stage),
                            notes: $workingNotes
                        )
                        .tag(stage)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        notes = workingNotes.hasAnyNotes ? workingNotes : nil
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(IncidentNotes.Stage.allCases, id: \.self) { stage in
                    Button(action: { selectedTab = stage }) {
                        VStack(spacing: 4) {
                            Image(systemName: stage.iconName)
                                .font(.title3)

                            Text(stage.displayName)
                                .font(.caption2)
                                .multilineTextAlignment(.center)

                            // Progress indicator
                            if hasContentForStage(stage) {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 6, height: 6)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTab == stage ? Color.accentColor.opacity(0.2) : Color.clear)
                        )
                        .foregroundColor(selectedTab == stage ? .accentColor : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGroupedBackground))
    }

    private func bindingForStage(_ stage: IncidentNotes.Stage) -> Binding<String> {
        switch stage {
        case .beforeWork:
            Binding(
                get: { workingNotes.beforeWork ?? "" },
                set: { workingNotes.beforeWork = $0.isEmpty ? nil : $0 }
            )
        case .duringWork:
            Binding(
                get: { workingNotes.duringWork ?? "" },
                set: { workingNotes.duringWork = $0.isEmpty ? nil : $0 }
            )
        case .completion:
            Binding(
                get: { workingNotes.completion ?? "" },
                set: { workingNotes.completion = $0.isEmpty ? nil : $0 }
            )
        case .general:
            Binding(
                get: { workingNotes.general ?? "" },
                set: { workingNotes.general = $0.isEmpty ? nil : $0 }
            )
        }
    }

    private func hasContentForStage(_ stage: IncidentNotes.Stage) -> Bool {
        switch stage {
        case .beforeWork:
            !(workingNotes.beforeWork?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        case .duringWork:
            !(workingNotes.duringWork?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        case .completion:
            !(workingNotes.completion?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        case .general:
            !(workingNotes.general?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        }
    }
}

// MARK: - NotesStageView

struct NotesStageView: View {
    let stage: IncidentNotes.Stage
    @Binding var text: String
    @Binding var notes: IncidentNotes
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Stage Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: stage.iconName)
                            .font(.title2)
                            .foregroundColor(.accentColor)

                        Text(stage.displayName)
                            .font(.headline)

                        Spacer()
                    }

                    Text(stage.placeholder)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Text Editor
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $text)
                        .focused($isTextEditorFocused)
                        .frame(minHeight: 200)
                        .padding(12)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )

                    // Character count
                    HStack {
                        Spacer()
                        Text("\(text.count) characters")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Quick Actions (if applicable)
                if stage == .beforeWork {
                    quickActionsSection
                }

                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                QuickActionButton(title: "Surface Assessment", icon: "eye.fill") {
                    appendToText("Surface condition: ")
                }

                QuickActionButton(title: "Tools Needed", icon: "wrench.and.screwdriver.fill") {
                    appendToText("Tools required: ")
                }

                QuickActionButton(title: "Material Check", icon: "cube.box.fill") {
                    appendToText("Materials available: ")
                }

                QuickActionButton(title: "Safety Notes", icon: "shield.fill") {
                    appendToText("Safety considerations: ")
                }
            }
            .padding(.horizontal)
        }
    }

    private func appendToText(_ addition: String) {
        if text.isEmpty {
            text = addition
        } else {
            text += text.hasSuffix("\n") ? addition : "\n\(addition)"
        }
        isTextEditorFocused = true
    }
}

// MARK: - QuickActionButton

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}

// MARK: - EnhancedNotesRow

/// Compact row for displaying notes summary in forms
struct EnhancedNotesRow: View {
    let notes: IncidentNotes?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.accentColor)
                        .frame(width: 24)

                    if let notes, notes.hasAnyNotes {
                        Text("Notes (\(notes.filledSectionsCount) sections)")
                            .foregroundColor(.primary)
                    } else {
                        Text("Add Notes")
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                if let notes, let summary = notes.summaryNote {
                    Text(summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.leading, 32)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    @State var notes: IncidentNotes? = IncidentNotes(
        beforeWork: "Surface shows heavy graffiti damage",
        completion: "Work completed successfully"
    )

    FreshWallPreview {
        NavigationStack {
            EnhancedNotesView(notes: $notes)
        }
    }
}

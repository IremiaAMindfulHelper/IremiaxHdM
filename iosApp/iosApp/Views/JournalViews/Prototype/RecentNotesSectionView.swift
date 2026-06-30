import SwiftUI
import Shared

// =============================================================================
// "Letzte Notizen" section — 1:1 translation of RecentNotesSection.kt.
// =============================================================================

/// Recent journal notes section with header and add button.
struct RecentNotesSectionView: View {
    let notes: [NoteUI]
    let onAdd: () -> Void
    let onNoteClick: (NoteUI) -> Void
    let onDelete: (Int64) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(PS.recent_notes_title)
                    .font(IremiaText.h2)
                    .foregroundColor(IremiaColors.ink)
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(IremiaColors.teal700)
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(PS.recent_notes_add)
            }

            Spacer().frame(height: 12)

            // Prominent labeled add button so the affordance matches Android, not
            // only the small plus icon in the header.
            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text(PS.recent_notes_add)
                        .font(IremiaText.cardTitle)
                }
                .foregroundColor(IremiaColors.teal700)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    RoundedRectangle(cornerRadius: IremiaShapes.field, style: .continuous)
                        .stroke(IremiaColors.teal700, lineWidth: 1.5)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer().frame(height: 12)

            ForEach(notes) { note in
                NoteCardView(
                    note: note,
                    onClick: { onNoteClick(note) },
                    onDelete: { onDelete(note.id) }
                )
                Spacer().frame(height: 10)
            }
        }
    }
}

// MARK: - Note Card

private struct NoteCardView: View {
    let note: NoteUI
    let onClick: () -> Void
    let onDelete: () -> Void

    var body: some View {
        IremiaCard(cornerRadius: IremiaShapes.cardSm) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "note.text")
                            .font(.system(size: 16))
                            .foregroundColor(IremiaColors.gray400)
                        Text("\(formattedDate(note.createdAt)) · \(formattedTime(note.createdAt))")
                            .font(IremiaText.caption)
                            .foregroundColor(IremiaColors.gray500)
                    }
                    Spacer()

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(IremiaColors.gray400)
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Löschen")

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(IremiaColors.gray400)
                }

                Spacer().frame(height: 6)

                let title = titleOf(note.content)
                let preview = previewOf(note.content)

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(IremiaText.cardTitle)
                            .foregroundColor(IremiaColors.ink)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        if !preview.isEmpty {
                            Text(preview)
                                .font(IremiaText.body)
                                .foregroundColor(IremiaColors.gray500)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    Spacer()
                    // Mood emoji from the "after" mood, if captured.
                    if let mood = note.moodAfter, mood >= 0, mood < moodFaces.count {
                        Text(moodFaces[mood]).font(IremiaText.cardTitle)
                    }
                }

                // Intensity indicator bar.
                if let strength = note.strength {
                    Spacer().frame(height: 8)
                    IntensityBar(strength: strength)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onClick)
    }

    private func formattedDate(_ ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "de_DE")
        fmt.dateFormat = "d. MMM"
        return fmt.string(from: date)
    }

    private func formattedTime(_ ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }

    private func titleOf(_ content: String) -> String {
        let first = content.components(separatedBy: .newlines).first ?? ""
        return first.isEmpty ? "—" : first
    }

    private func previewOf(_ content: String) -> String {
        // ~50-character preview of the body text.
        let flat = content.replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
        if flat.count <= 50 { return flat }
        return String(flat.prefix(50)) + "…"
    }
}

/// Compact bar visualising episode intensity (1...10) with a matching color.
private struct IntensityBar: View {
    let strength: Int

    private var color: Color {
        switch strength {
        case ...3: return IremiaColors.garden500
        case 4...6: return IremiaColors.warning
        default: return IremiaColors.danger
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(IremiaColors.gray200)
                    Capsule().fill(color)
                        .frame(width: geo.size.width * CGFloat(min(max(strength, 1), 10)) / 10)
                }
            }
            .frame(height: 6)
            Text("\(strength)/10")
                .font(IremiaText.caption)
                .foregroundColor(IremiaColors.gray500)
        }
    }
}

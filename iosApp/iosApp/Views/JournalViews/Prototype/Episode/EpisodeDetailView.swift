import SwiftUI

// =============================================================================
// Episode detail + inline edit — shows everything captured for one episode and
// lets the user edit text, intensity and "after" mood, then save.
// Mirrors the Android EpisodeDetailScreen.
// =============================================================================

struct EpisodeDetailView: View {
    let note: NoteUI
    let onClose: () -> Void
    let onSave: (EpisodeDraftData) -> Void

    @State private var editing = false
    @State private var content: String
    @State private var strength: Double
    @State private var moodAfter: Int

    init(note: NoteUI, onClose: @escaping () -> Void, onSave: @escaping (EpisodeDraftData) -> Void) {
        self.note = note
        self.onClose = onClose
        self.onSave = onSave
        _content = State(initialValue: note.content)
        _strength = State(initialValue: Double(note.strength ?? 5))
        _moodAfter = State(initialValue: note.moodAfter ?? -1)
    }

    private var dateText: String {
        let date = Date(timeIntervalSince1970: Double(note.createdAt) / 1000.0)
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "de_DE")
        fmt.dateFormat = "d. MMM yyyy · HH:mm"
        return fmt.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(PS.episode_detail_title)
                    .font(IremiaText.h2)
                    .foregroundColor(IremiaColors.ink)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(IremiaColors.ink900)
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Text(dateText)
                .font(IremiaText.caption)
                .foregroundColor(IremiaColors.gray500)

            Spacer().frame(height: IremiaSpacing.s4)

            ScrollView {
                VStack(alignment: .leading, spacing: IremiaSpacing.s3) {
                    // Reflection text
                    IremiaCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(PS.episode_reflection_title)
                                .font(IremiaText.eyebrow)
                                .foregroundColor(IremiaColors.teal700)
                            Spacer().frame(height: IremiaSpacing.s2)
                            if editing {
                                TextEditor(text: $content)
                                    .font(IremiaText.body)
                                    .foregroundColor(IremiaColors.ink900)
                                    .frame(height: 120)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .background(IremiaColors.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: IremiaShapes.field)
                                            .stroke(IremiaColors.gray300, lineWidth: 1)
                                    )
                            } else {
                                Text(content.isEmpty ? PS.garden_entry_sheet_empty : content)
                                    .font(IremiaText.body)
                                    .foregroundColor(IremiaColors.ink700)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }

                    // Intensity
                    IremiaCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(PS.episode_strength_label)
                                .font(IremiaText.eyebrow)
                                .foregroundColor(IremiaColors.teal700)
                            Spacer().frame(height: IremiaSpacing.s2)
                            if editing {
                                Slider(value: $strength, in: 1...10, step: 1)
                                    .tint(IremiaColors.teal700)
                            }
                            Text("\(Int(strength))/10")
                                .font(IremiaText.cardTitle)
                                .foregroundColor(IremiaColors.ink)
                        }
                    }

                    // Mood
                    IremiaCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(PS.episode_mood_after)
                                .font(IremiaText.eyebrow)
                                .foregroundColor(IremiaColors.teal700)
                            Spacer().frame(height: IremiaSpacing.s2)
                            HStack(spacing: 8) {
                                ForEach(Array(moodFaces.enumerated()), id: \.offset) { idx, face in
                                    Text(face)
                                        .font(IremiaText.cardTitle)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Capsule().fill(idx == moodAfter ? IremiaColors.teal100 : IremiaColors.gray100)
                                        )
                                        .onTapGesture { if editing { moodAfter = idx } }
                                }
                            }
                        }
                    }

                    // Context (read-only)
                    let contextItems = note.places + note.activities + note.bodySignals
                    if !contextItems.isEmpty {
                        IremiaCard {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(PS.episode_context_title)
                                    .font(IremiaText.eyebrow)
                                    .foregroundColor(IremiaColors.teal700)
                                Spacer().frame(height: IremiaSpacing.s2)
                                Text(contextItems.joined(separator: " · "))
                                    .font(IremiaText.body)
                                    .foregroundColor(IremiaColors.ink700)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }

            Spacer().frame(height: IremiaSpacing.s3)

            if editing {
                PrimaryButton(text: PS.episode_reflection_save) {
                    onSave(
                        EpisodeDraftData(
                            content: content,
                            strength: Int(strength),
                            places: note.places,
                            activities: note.activities,
                            bodySignals: note.bodySignals,
                            moodBefore: note.moodBefore,
                            moodAfter: moodAfter >= 0 ? moodAfter : nil
                        )
                    )
                    editing = false
                }
            } else {
                PrimaryButton(text: PS.episode_detail_edit) { editing = true }
            }

            Spacer().frame(height: IremiaSpacing.s1)

            SecondaryTextButton(text: PS.nav_close, action: onClose)
        }
        .padding(.horizontal, IremiaSpacing.screenGutter)
        .padding(.vertical, IremiaSpacing.s3)
        .background(IremiaColors.gray100.ignoresSafeArea())
    }
}

import SwiftUI
import shared

// =============================================================================
// Block 1: entry-type chooser + journal entry (guided + free) — iOS parity with
// JournalEntryScreens.kt. All strings via the shared moko-resources (Strings).
// =============================================================================

// MARK: - Entry type chooser

/// First step of the capture flow: choose panic vs journal entry. Neutral,
/// autonomy-preserving copy; no default is pre-selected.
struct EntryTypeChooserView: View {
    let onBack: () -> Void
    let onPickPanic: () -> Void
    let onPickJournal: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(IremiaColors.ink900)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Strings.nav_back)
                Spacer()
            }

            Spacer().frame(height: IremiaSpacing.s5)
            Text(Strings.entry_type_title)
                .font(IremiaText.h1)
                .foregroundColor(IremiaColors.ink)
            Spacer().frame(height: IremiaSpacing.s2)
            Text(Strings.entry_type_subtitle)
                .font(IremiaText.body)
                .foregroundColor(IremiaColors.gray500)

            Spacer().frame(height: IremiaSpacing.s6)
            EntryTypeCard(
                systemIcon: "heart.fill",
                iconTint: IremiaColors.teal700,
                iconBackground: IremiaColors.teal50,
                title: Strings.entry_type_panic_title,
                description: Strings.entry_type_panic_desc,
                action: onPickPanic
            )
            Spacer().frame(height: IremiaSpacing.s3)
            EntryTypeCard(
                systemIcon: "leaf.fill",
                iconTint: IremiaColors.garden700,
                iconBackground: IremiaColors.garden100,
                title: Strings.entry_type_journal_title,
                description: Strings.entry_type_journal_desc,
                action: onPickJournal
            )

            Spacer()
        }
        .padding(.horizontal, IremiaSpacing.screenGutter)
        .padding(.top, IremiaSpacing.s2)
        .padding(.bottom, IremiaSpacing.s5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// A large, tappable choice card for one entry type.
private struct EntryTypeCard: View {
    let systemIcon: String
    let iconTint: Color
    let iconBackground: Color
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(iconBackground).frame(width: 52, height: 52)
                    Image(systemName: systemIcon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(iconTint)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(IremiaText.cardTitle)
                        .foregroundColor(IremiaColors.ink)
                    Text(description)
                        .font(IremiaText.caption)
                        .foregroundColor(IremiaColors.gray500)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(IremiaColors.gray400)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(IremiaColors.gray200, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Journal entry (guided + free)

/// The journal entry screen. Starts guided (optional reflection prompts), with an
/// always-visible button to switch to a single big free-text field. A journal
/// entry only requires *some* text; the title is optional and auto-derived when
/// left blank.
struct JournalCaptureEntryView: View {
    /// Emits (title, content). Content is non-empty when this fires.
    let onBack: () -> Void
    let onSave: (String, String) -> Void

    @State private var answers: [String: String] = [:]
    @State private var freeMode = false
    @State private var freeText = ""
    @State private var title = ""

    /// Stable prompt keys in plan order, paired with their question strings.
    private let promptKeys = [
        "annoyed", "pleased", "stressed", "relaxed", "hard",
        "welldone", "worried", "lookforward", "burdened", "grateful",
    ]

    private func question(for key: String) -> String {
        // Explicit mapping (the shared Strings proxy is KeyPath-based, so it can't
        // take a runtime-built key like the old prototype dictionary could).
        switch key {
        case "annoyed": return Strings.journal_q_annoyed
        case "pleased": return Strings.journal_q_pleased
        case "stressed": return Strings.journal_q_stressed
        case "relaxed": return Strings.journal_q_relaxed
        case "hard": return Strings.journal_q_hard
        case "welldone": return Strings.journal_q_welldone
        case "worried": return Strings.journal_q_worried
        case "lookforward": return Strings.journal_q_lookforward
        case "burdened": return Strings.journal_q_burdened
        case "grateful": return Strings.journal_q_grateful
        default: return ""
        }
    }

    /// Builds the entry text from answered prompts, "Question\nAnswer" per pair.
    private var guidedContent: String {
        promptKeys.compactMap { key -> String? in
            let answer = (answers[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return answer.isEmpty ? nil : "\(question(for: key))\n\(answer)"
        }.joined(separator: "\n\n")
    }

    private var content: String { freeMode ? freeText : guidedContent }
    private var canSave: Bool { !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        IremiaActionScaffold {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(IremiaColors.ink900)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Strings.nav_back)
                Spacer()
            }
            .padding(.top, IremiaSpacing.s2)
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                // Title and subtitle scroll away: at large Dynamic Type sizes the h1
                // alone eats most of a small screen.
                Spacer().frame(height: IremiaSpacing.s4)
                Text(Strings.journal_title)
                    .font(IremiaText.h1)
                    .foregroundColor(IremiaColors.ink)
                Spacer().frame(height: IremiaSpacing.s2)
                Text(freeMode ? Strings.journal_free_prompt : Strings.journal_subtitle)
                    .font(IremiaText.body)
                    .foregroundColor(IremiaColors.gray500)
                Spacer().frame(height: IremiaSpacing.s5)

                Group {
                    EntryTitleField(title: $title)
                    Spacer().frame(height: IremiaSpacing.s5)

                    if freeMode {
                        Text(Strings.journal_free_title)
                            .font(IremiaText.cardTitle)
                            .foregroundColor(IremiaColors.ink)
                        Spacer().frame(height: IremiaSpacing.s3)
                        JournalTextArea(text: $freeText, placeholder: Strings.journal_free_placeholder, minHeight: 200)
                    } else {
                        Text(Strings.journal_prompts_title)
                            .font(IremiaText.cardTitle)
                            .foregroundColor(IremiaColors.ink)
                        Spacer().frame(height: IremiaSpacing.s1)
                        Text(Strings.journal_prompts_hint)
                            .font(IremiaText.caption)
                            .foregroundColor(IremiaColors.gray500)
                        Spacer().frame(height: IremiaSpacing.s4)

                        ForEach(promptKeys, id: \.self) { key in
                            GuidedPromptField(
                                question: question(for: key),
                                answer: Binding(
                                    get: { answers[key] ?? "" },
                                    set: { answers[key] = $0 }
                                )
                            )
                            Spacer().frame(height: IremiaSpacing.s4)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } actionBar: {
            VStack(alignment: .leading, spacing: 0) {
                // The hint is always laid out and only faded, so the footer keeps a
                // constant height and the scroll area does not jump on the first keystroke.
                Text(Strings.journal_required_hint)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray400)
                    .lineLimit(1)
                    .opacity(canSave ? 0 : 1)

                Spacer().frame(height: IremiaSpacing.s2)
                PrimaryButton(
                    text: Strings.journal_save,
                    action: { if canSave { onSave(title, content) } },
                    enabled: canSave
                )
                if !freeMode {
                    Spacer().frame(height: IremiaSpacing.s1)
                    SecondaryTextButton(text: Strings.journal_free_button, action: { freeMode = true })
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Optional, editable title field shown above the entry body.
struct EntryTitleField: View {
    @Binding var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: IremiaSpacing.s2) {
            Text(Strings.entry_title_optional_hint)
                .font(IremiaText.caption)
                .foregroundColor(IremiaColors.gray500)
            TextField(Strings.entry_title_placeholder, text: $title)
                .font(IremiaText.body)
                .foregroundColor(IremiaColors.ink900)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14).fill(IremiaColors.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14).stroke(IremiaColors.gray300, lineWidth: 1)
                )
        }
    }
}

/// A single optional guided prompt: the question label + a multiline answer field.
private struct GuidedPromptField: View {
    let question: String
    @Binding var answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: IremiaSpacing.s2) {
            HStack(alignment: .firstTextBaseline) {
                Text(question)
                    .font(IremiaText.body)
                    .foregroundColor(IremiaColors.ink)
                Spacer()
                Text(Strings.field_optional)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray400)
            }
            JournalTextArea(text: $answer, placeholder: "", minHeight: 64)
        }
    }
}

/// A generously sized multiline text area matching the journal look.
private struct JournalTextArea: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty && !placeholder.isEmpty {
                Text(placeholder)
                    .font(IremiaText.body)
                    .foregroundColor(IremiaColors.gray400)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }
            TextEditor(text: $text)
                .font(IremiaText.body)
                .foregroundColor(IremiaColors.ink900)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(minHeight: minHeight)
        }
        .background(
            RoundedRectangle(cornerRadius: 14).fill(IremiaColors.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(IremiaColors.gray300, lineWidth: 1)
        )
    }
}

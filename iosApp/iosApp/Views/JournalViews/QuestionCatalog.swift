import SwiftUI

struct QuestionCatalog: View {
    let onBack: () -> Void

    // ✅ Keyboard Focus
    @FocusState private var isKeyboardActive: Bool

    // ✅ Alle Fragen auf Deutsch
    @State private var questions: [String] = [
        "Gab es heute schwierige Momente für dich?",
        "Was ist heute gut gelaufen?",
        "Welche Gedanken oder Sorgen möchtest du heute loslassen?",
        "Was kann dir helfen, die Situation zu verbessern?",
        "Wie hat sich deine Stimmung im Laufe des Tages verändert?",
        "Wofür bist du heute dankbar?",
        "Gibt es etwas, das du morgen anders machen möchtest?"
    ]

    // ✅ Auswahl-State (wie Activities)
    @State private var selectedQuestions: Set<String> = []

    @State private var newQuestionText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                // Subtitle
                Text("Fragen auswählen")
                    .font(.headline)
                    .padding(.top, 12)

                // Questions list
                VStack(spacing: 14) {
                    ForEach(questions, id: \.self) { question in
                        Button {
                            toggleSelection(question)
                        } label: {
                            Text(question)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            selectedQuestions.contains(question)
                                            ? Color.black.opacity(0.2)
                                            : Color(.secondarySystemBackground)
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            selectedQuestions.contains(question)
                                            ? Color.black
                                            : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)

                // Neue Frage hinzufügen
                TextField("Neue Frage hinzufügen", text: $newQuestionText)
                    .focused($isKeyboardActive)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.secondary.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Fragenkatalog")
        .navigationBarTitleDisplayMode(.inline)

        // ✅ keinen doppelten Zurückpfeil
        .navigationBarBackButtonHidden(true)

        .toolbar {
            // Zurück
            ToolbarItem(placement: .topBarLeading) {
                Button { onBack() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.primary)
                }
            }

            // Keyboard Done
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") {
                    isKeyboardActive = false
                }
            }
        }

        // Tap outside closes keyboard
        .onTapGesture {
            isKeyboardActive = false
        }
    }

    // MARK: - Helpers
    private func toggleSelection(_ question: String) {
        if selectedQuestions.contains(question) {
            selectedQuestions.remove(question)
        } else {
            selectedQuestions.insert(question)
        }
    }
}

#Preview {
    NavigationStack {
        QuestionCatalog(onBack: {})
    }
}

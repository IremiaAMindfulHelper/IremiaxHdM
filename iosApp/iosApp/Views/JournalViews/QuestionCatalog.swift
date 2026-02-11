import SwiftUI

struct QuestionCatalog: View {
    let onBack: () -> Void

    // Steuert den Fokus der Texteingabe.
    @FocusState private var isKeyboardActive: Bool

    // Datenquelle der verfügbaren Fragen.
    @State private var questions: [String] = [
        "Gab es heute schwierige Momente für dich?",
        "Was ist heute gut gelaufen?",
        "Welche Gedanken oder Sorgen möchtest du heute loslassen?",
        "Was kann dir helfen, die Situation zu verbessern?",
        "Wie hat sich deine Stimmung im Laufe des Tages verändert?",
        "Wofür bist du heute dankbar?",
        "Gibt es etwas, das du morgen anders machen möchtest?"
    ]

    // Speichert die aktuell ausgewählten Fragen.
    @State private var selectedQuestions: Set<String> = []

    // Eingabetext für eine neue Frage.
    @State private var newQuestionText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerSection
                questionsSection
                addQuestionSection
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Fragenkatalog")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .onTapGesture { isKeyboardActive = false }
    }

    // Überschrift der Ansicht.
    private var headerSection: some View {
        Text("Fragen auswählen")
            .font(.headline)
            .padding(.top, 12)
    }

    // Liste aller Fragen mit Auswahl-Logik.
    private var questionsSection: some View {
        VStack(spacing: 14) {
            ForEach(questions, id: \.self) { question in
                QuestionRow(
                    title: question,
                    isSelected: selectedQuestions.contains(question)
                ) {
                    toggleSelection(question)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // Eingabebereich zum Hinzufügen einer neuen Frage.
    private var addQuestionSection: some View {
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

    // Toolbar mit Zurück-Button und Keyboard-Aktion.
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { onBack() } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.primary)
            }
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Fertig") {
                isKeyboardActive = false
            }
        }
    }

    // Schaltet den Auswahlstatus einer Frage um.
    private func toggleSelection(_ question: String) {
        if selectedQuestions.contains(question) {
            selectedQuestions.remove(question)
        } else {
            selectedQuestions.insert(question)
        }
    }
}

private struct QuestionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            isSelected
                            ? Color.black.opacity(0.2)
                            : Color(.secondarySystemBackground)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isSelected ? Color.black : Color.clear,
                            lineWidth: 2
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        QuestionCatalog(onBack: {})
    }
}

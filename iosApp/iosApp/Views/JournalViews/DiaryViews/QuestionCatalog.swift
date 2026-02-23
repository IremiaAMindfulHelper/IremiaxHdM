import SwiftUI

struct QuestionCatalog: View {
    let onBack: () -> Void

    // Steuert den Fokus der Texteingabe (UI-only -> bleibt in der View).
    @FocusState private var isKeyboardActive: Bool

    // ViewModel hält State + Logik.
    @StateObject private var vm = QuestionCatalogViewModel()

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

    // Liste aller Fragen mit Auswahl-Logik (delegiert ans VM).
    private var questionsSection: some View {
        VStack(spacing: 14) {
            ForEach(vm.questions, id: \.self) { question in
                QuestionRow(
                    title: question,
                    isSelected: vm.selectedQuestions.contains(question)
                ) {
                    vm.toggleSelection(question)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // Eingabebereich zum Hinzufügen einer neuen Frage.
    private var addQuestionSection: some View {
        TextField("Neue Frage hinzufügen", text: $vm.newQuestionText)
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
            .submitLabel(.done)
            .onSubmit {
                vm.addQuestionIfPossible()
                isKeyboardActive = false
            }
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
                // Wenn du beim "Fertig" auch direkt hinzufügen willst:
                vm.addQuestionIfPossible()
                isKeyboardActive = false
            }
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

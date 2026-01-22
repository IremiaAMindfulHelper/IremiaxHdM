import SwiftUI

struct QuestionCatalog: View {
    let onBack: () -> Void

    // ✅ Keyboard Focus
    @FocusState private var isKeyboardActive: Bool

    @State private var questions: [String] = [
        "Were there any difficult moments for you today?",
        "What went well today?",
        "What thoughts or worries do I want to let go of today?",
        "What will help you improve the situation?",
        "How has your mood changed throughout the day?",
        "What are you grateful for today?",
        "Is there anything you would like to do differently tomorrow?"
    ]

    // ✅ Auswahl-State (wie Activities)
    @State private var selectedQuestions: Set<String> = []

    @State private var newQuestionText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                // Subtitle
                Text("Wähle Fragen aus")
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

                // Add new question
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

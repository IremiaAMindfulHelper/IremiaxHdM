import SwiftUI

struct QuestionCatalog: View {
    let onBack: () -> Void

    @State private var questions: [String] = [
        "Were there any difficult moments for you today?",
        "What went well today?",
        "What thoughts or worries do I want to let go of today?",
        "What will help you improve the situation?",
        "How has your mood changed throughout the day?",
        "What are you grateful for today?",
        "Is there anything you would like to do differently tomorrow?"
    ]

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
                            // UI-only (später Auswahl-Logik)
                        } label: {
                            Text(question)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(.secondarySystemBackground))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)

                // Add new question
                TextField("Neue Frage hinzufügen", text: $newQuestionText)
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

        // ✅ WICHTIG: System-Zurückpfeil ausblenden, sonst hast du 2 Pfeile
        .navigationBarBackButtonHidden(true)

        // ✅ Dein eigener Zurückpfeil
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { onBack() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuestionCatalog(onBack: {})
    }
}

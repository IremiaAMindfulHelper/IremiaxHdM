import SwiftUI

struct QuestionCatalog: View {
    @Environment(\.dismiss) private var dismiss

    // UI-only State
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
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    // Subtitle
                    Text("Wähle Fragen aus")
                        .font(.headline)
                        .padding(.top, 12)

                    // Questions (als Buttons)
                    VStack(spacing: 14) {
                        ForEach(questions, id: \.self) { question in
                            QuestionButton(text: question) {
                                // UI-only: tap
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // ✅ Neue Frage hinzufügen (NUR Textfeld, kein Plus Button)
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}

// MARK: - Question Button Card

private struct QuestionButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
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

#Preview {
    QuestionCatalog()
}

import SwiftUI

/*
 Diese View zeigt einen Fragenkatalog, in dem Fragen ausgewählt und neue Fragen hinzugefügt werden können.
 Optik ist an JournalDiaryView angepasst (blauer Header, runde Toolbar-Buttons, Blau statt Grau bei Auswahl).
*/
struct QuestionCatalog: View {
    let onBack: () -> Void

    @FocusState private var isKeyboardActive: Bool
    @StateObject private var vm = QuestionCatalogViewModel()

    // Farben wie im Tagebuch
    private let headerBlue = Color(red: 0.38, green: 0.53, blue: 0.84)
    private let accentBlue = Color(red: 0.55, green: 0.66, blue: 0.88) // ähnlich stripBlue
    private let pageBackground = Color(UIColor.systemGroupedBackground)

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    headerSection
                        .padding(.top, 10)

                    questionsSection

                    addQuestionSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(headerBlue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar { toolbarContent }
        .onTapGesture { isKeyboardActive = false }
    }

    // Anleitung statt "Fragen auswählen"
    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("Füge neue Fragen hinzu")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.black)

            Text("Tippe auf Fragen, um sie hinzuzufügen oder zu entfernen.")
                .font(.system(size: 13.5, weight: .regular))
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
        )
    }

    // Fragenliste
    private var questionsSection: some View {
        VStack(spacing: 12) {
            ForEach(vm.questions, id: \.self) { question in
                QuestionRow(
                    title: question,
                    isSelected: vm.selectedQuestions.contains(question),
                    accentBlue: accentBlue
                ) {
                    vm.toggleSelection(question)
                }
            }
        }
    }

    // Neue Frage hinzufügen
    private var addQuestionSection: some View {
        TextField("Neue Frage hinzufügen", text: $vm.newQuestionText, axis: .vertical)
            .focused($isKeyboardActive)
            .textFieldStyle(.plain)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .lineLimit(1...3)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(accentBlue.opacity(0.55), lineWidth: 1.5)
            )
            .submitLabel(.done)
            .onSubmit {
                vm.addQuestionIfPossible()
                isKeyboardActive = false
            }
            .padding(.top, 6)
    }

    // Toolbar: wie im Tagebuch
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onBack) {
                ToolbarCircleSF(systemName: "chevron.left")
            }
            .buttonStyle(.plain)
            .padding(.leading, 6)
        }

        ToolbarItem(placement: .principal) {
            Text("Fragenkatalog")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.addQuestionIfPossible()
                isKeyboardActive = false
            } label: {
                ToolbarCircleSF(systemName: "checkmark")
            }
            .buttonStyle(.plain)
            .padding(.trailing, 6)
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Fertig") {
                vm.addQuestionIfPossible()
                isKeyboardActive = false
            }
        }
    }
}

/*
 Eine einzelne Zeile im Fragenkatalog.
 Markierung bei Auswahl ist blau statt grau.
*/
private struct QuestionRow: View {
    let title: String
    let isSelected: Bool
    let accentBlue: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16.5, weight: .regular, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isSelected ? accentBlue.opacity(0.28) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            isSelected ? accentBlue.opacity(0.95) : Color.black.opacity(0.06),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(isSelected ? 0.06 : 0.04), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toolbar Button (lokal in dieser Datei)
private struct ToolbarCircleSF: View {
    let systemName: String

    var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 42))
                .foregroundColor(.white.opacity(0.22))

            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        QuestionCatalog(onBack: {})
    }
}

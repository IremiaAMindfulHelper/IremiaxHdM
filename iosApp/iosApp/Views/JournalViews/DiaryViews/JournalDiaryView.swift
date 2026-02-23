import SwiftUI

struct JournalDiaryView: View {
    let onBack: () -> Void
    let onOpenQuestionCatalog: () -> Void
    let entryDate: Date

    // UI/Keyboard-Fokus bleibt in der View
    @FocusState private var isKeyboardActive: Bool

    // ViewModel hält State + Logik
    @StateObject private var vm = JournalDiaryViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 12) {
                        ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                            CategoryCard(title: section.title, dateText: nil, isExpanded: $vm.expanded[index]) {
                                section.content
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)

                    Button { onBack() } label: {
                        Text("Eintrag abschließen")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 6)
                    .padding(.bottom, 18)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))

            // Tooltip Overlay
            if vm.showPencilTooltip {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isKeyboardActive = false
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            vm.hideTooltip()
                        }
                    }
                    .zIndex(9)

                TooltipSpeechBubble(
                    text: "Hier kannst du\ndeine Fragen\nanpassen!",
                    buttonTitle: "OK!",
                    arrowX: 0.86,
                    onClose: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            vm.hideTooltip()
                        }
                    }
                )
                .frame(width: 260)
                .position(
                    x: UIScreen.main.bounds.width - 260 / 2 - 8,
                    y: 105
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                .zIndex(10)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .onTapGesture { isKeyboardActive = false }
        .onAppear {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                vm.showTooltipOnce()
            }
        }
    }

    // Sections: View baut UI, VM liefert State
    private var sections: [SectionDefinition] {
        [
            .init(title: vm.diaryQuestions[0], content: AnyView(DiaryContent(text: $vm.answer1, isKeyboardActive: $isKeyboardActive))),
            .init(title: vm.diaryQuestions[1], content: AnyView(DiaryContent(text: $vm.answer2, isKeyboardActive: $isKeyboardActive))),
            .init(title: vm.diaryQuestions[2], content: AnyView(DiaryContent(text: $vm.answer3, isKeyboardActive: $isKeyboardActive))),
            .init(title: vm.diaryQuestions[3], content: AnyView(DiaryContent(text: $vm.answer4, isKeyboardActive: $isKeyboardActive))),
            .init(title: vm.diaryQuestions[4], content: AnyView(moodPickerContent)),
            .init(title: vm.diaryQuestions[5], content: AnyView(DiaryContent(text: $vm.answer6, isKeyboardActive: $isKeyboardActive))),
            .init(title: vm.diaryQuestions[6], content: AnyView(DiaryContent(text: $vm.answer7, isKeyboardActive: $isKeyboardActive)))
        ]
    }

    private var moodPickerContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            MoodPickerRow(title: "Morgen ☀️", emojis: vm.moodEmojis, selection: $vm.moodSelections[0])
            MoodPickerRow(title: "Mittag 🌤", emojis: vm.moodEmojis, selection: $vm.moodSelections[1])
            MoodPickerRow(title: "Abend 🌆", emojis: vm.moodEmojis, selection: $vm.moodSelections[2])
            MoodPickerRow(title: "Nacht 🌙", emojis: vm.moodEmojis, selection: $vm.moodSelections[3])
        }
    }

    // Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { onBack() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            }
        }

        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text("Tagebuch")
                    .font(.headline)
                    .foregroundColor(.black)

                Text(formattedDiaryDate)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.hideTooltip()
                onOpenQuestionCatalog()
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.black)
                    .imageScale(.large)
            }
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Fertig") { isKeyboardActive = false }
        }
    }

    // Datum
    private var formattedDiaryDate: String {
        Self.diaryDateFormatter.string(from: entryDate)
    }

    private static let diaryDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E dd.MM.yy"
        return f
    }()

    private struct SectionDefinition {
        let title: String
        let content: AnyView
    }
}

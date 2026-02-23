import SwiftUI

struct JournalDiaryView: View {
    let onBack: () -> Void
    let onOpenQuestionCatalog: () -> Void
    let entryDate: Date

    @FocusState private var isKeyboardActive: Bool
    @StateObject private var vm = JournalDiaryViewModel()

    @State private var pencilFrame: CGRect = .zero

    // Farben
    private let headerBlue = Color(red: 0.38, green: 0.53, blue: 0.84)
    private let buttonBlue = Color(red: 0.38, green: 0.53, blue: 0.84)

    // ✅ weniger Rand (wie Referenz)
    private let pageSidePadding: CGFloat = 16
    private let sectionSpacing: CGFloat = 14

    // Tooltip
    private let bubbleWidth: CGFloat = 280
    private let bubbleHeight: CGFloat = 150

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: sectionSpacing) {
                    VStack(spacing: sectionSpacing) {
                        ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                            TimelineCard(
                                title: section.title,
                                isExpanded: $vm.expanded[index],
                                isDone: vm.isSectionDone(index: index)
                            ) {
                                section.content
                            }
                        }
                    }
                    .padding(.horizontal, pageSidePadding)
                    .padding(.top, 12)

                    // ✅ Button blau
                    Button { onBack() } label: {
                        Text("Eintrag abschließen")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(buttonBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 8)
                    }
                    .padding(.horizontal, 70)
                    .padding(.top, 6)
                    .padding(.bottom, 18)
                }
            }
            .background(Color(.systemGray6))
            .blur(radius: vm.showPencilTooltip ? 2 : 0)
            .overlay(
                Color.black.opacity(vm.showPencilTooltip ? 0.10 : 0)
                    .ignoresSafeArea()
            )

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

                tooltipBubble
                    .zIndex(10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)

        .toolbarBackground(headerBlue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)

        .toolbar { toolbarContent }
        .onTapGesture { isKeyboardActive = false }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    if pencilFrame != .zero { vm.showTooltipOnce() }
                }
            }
        }
        .onChange(of: pencilFrame) { _, newValue in
            guard newValue != .zero else { return }
            if vm.showPencilTooltip == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        vm.showTooltipOnce()
                    }
                }
            }
        }
    }

    // MARK: - Tooltip

    private var tooltipBubble: some View {
        GeometryReader { geo in
            let screenW: CGFloat = geo.size.width
            let arrowTargetX: CGFloat = pencilFrame.midX

            let preferredArrowXInBubble: CGFloat = 0.84
            var bubbleLeft: CGFloat = arrowTargetX - bubbleWidth * preferredArrowXInBubble

            let side: CGFloat = 14
            bubbleLeft = min(max(bubbleLeft, side), screenW - bubbleWidth - side)

            // wie vorher: leicht nach rechts + etwas runter
            bubbleLeft += 12
            let bubbleCenterX: CGFloat = bubbleLeft + bubbleWidth / 2

            let bubbleTopY: CGFloat = max(pencilFrame.maxY + 18, 102)
            let bubbleCenterY: CGFloat = bubbleTopY + bubbleHeight / 2

            let rawArrowX: CGFloat = (arrowTargetX - bubbleLeft) / bubbleWidth
            let arrowX: CGFloat = min(max(rawArrowX, 0.12), 0.92)

            return TooltipSpeechBubble(
                text: "Hier kannst du deine\nFragen anpassen!",
                buttonTitle: "Ok",
                arrowX: arrowX,
                onClose: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        vm.hideTooltip()
                    }
                }
            )
            .frame(width: bubbleWidth, height: bubbleHeight)
            .position(x: bubbleCenterX, y: bubbleCenterY)
        }
        .ignoresSafeArea()
    }

    // MARK: - Toolbar

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
            VStack(spacing: 2) {
                Text("Tagebuch")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text(formattedDiaryDate)
                    .font(.system(size: 12.5, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.hideTooltip()
                onOpenQuestionCatalog()
            } label: {
                ToolbarCircleSF(systemName: "square.and.pencil")
                    .background(
                        PencilFrameReader { frame in
                            self.pencilFrame = frame
                        }
                    )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 6)
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Fertig") { isKeyboardActive = false }
        }
    }

    // MARK: - Sections

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
        VStack(alignment: .leading, spacing: 12) {
            MoodPickerRow(title: "Morgen ☀️", emojis: vm.moodEmojis, selection: $vm.moodSelections[0])
            MoodPickerRow(title: "Mittag 🌤", emojis: vm.moodEmojis, selection: $vm.moodSelections[1])
            MoodPickerRow(title: "Abend 🌆", emojis: vm.moodEmojis, selection: $vm.moodSelections[2])
            MoodPickerRow(title: "Nacht 🌙", emojis: vm.moodEmojis, selection: $vm.moodSelections[3])
        }
        .padding(.top, 2)
        .padding(.bottom, 6)
    }

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

// MARK: - Toolbar look

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

// MARK: - Done logic

extension JournalDiaryViewModel {
    func isSectionDone(index: Int) -> Bool {
        func filled(_ s: String) -> Bool { !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        switch index {
        case 0: return filled(answer1)
        case 1: return filled(answer2)
        case 2: return filled(answer3)
        case 3: return filled(answer4)
        case 4: return moodSelections.contains { filled($0) }
        case 5: return filled(answer6)
        case 6: return filled(answer7)
        default: return false
        }
    }
}

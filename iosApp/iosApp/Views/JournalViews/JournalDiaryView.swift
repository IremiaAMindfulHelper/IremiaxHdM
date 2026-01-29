import SwiftUI

// MARK: - Main View
struct JournalDiaryView: View {

    let onBack: () -> Void
    let onOpenQuestionCatalog: () -> Void

    /// ✅ Datum aus EntryView
    let entryDate: Date

    // ✅ Keyboard Focus
    @FocusState private var isKeyboardActive: Bool

    // ✅ Tooltip State
    @State private var showPencilTooltip: Bool = false

    // MARK: - State Variables
    @State private var expanded: [Bool] = Array(repeating: true, count: 7)
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    @State private var answer3: String = ""
    @State private var answer4: String = ""
    @State private var answer5: [String] = Array(repeating: "", count: 4) // Morgen, Mittag, Abend, Nacht
    @State private var answer6: String = ""
    @State private var answer7: String = ""

    // MARK: - Data (✅ alles auf Deutsch)
    private let diaryQuestions = [
        "Gab es heute schwierige Momente für dich?",
        "Was ist gut gelaufen?",
        "Welche Sorgen möchtest du heute loslassen?",
        "Wie kannst du die Situation verbessern?",
        "Wie hat sich deine Stimmung im Laufe des Tages verändert?",
        "Wofür bist du heute dankbar?",
        "Gibt es etwas, das du morgen anders machen möchtest?"
    ]

    private let moodEmojis = ["😢", "🙁", "😐", "😊", "😄"]

    private var formattedDiaryDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E dd.MM.yy"   // z.B. "Di 06.01.26"
        return f.string(from: entryDate)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // ===== Main Content =====
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 12) {

                        CategoryCard(title: diaryQuestions[0], dateText: nil, isExpanded: $expanded[0]) {
                            DiaryContent(text: $answer1, isKeyboardActive: $isKeyboardActive)
                        }

                        CategoryCard(title: diaryQuestions[1], dateText: nil, isExpanded: $expanded[1]) {
                            DiaryContent(text: $answer2, isKeyboardActive: $isKeyboardActive)
                        }

                        CategoryCard(title: diaryQuestions[2], dateText: nil, isExpanded: $expanded[2]) {
                            DiaryContent(text: $answer3, isKeyboardActive: $isKeyboardActive)
                        }

                        CategoryCard(title: diaryQuestions[3], dateText: nil, isExpanded: $expanded[3]) {
                            DiaryContent(text: $answer4, isKeyboardActive: $isKeyboardActive)
                        }

                        CategoryCard(title: diaryQuestions[4], dateText: nil, isExpanded: $expanded[4]) {
                            VStack(alignment: .leading, spacing: 14) {
                                MoodPickerRow(title: "Morgen ☀️", emojis: moodEmojis, selection: $answer5[0])
                                MoodPickerRow(title: "Mittag 🌤", emojis: moodEmojis, selection: $answer5[1])
                                MoodPickerRow(title: "Abend 🌆", emojis: moodEmojis, selection: $answer5[2])
                                MoodPickerRow(title: "Nacht 🌙", emojis: moodEmojis, selection: $answer5[3])
                            }
                        }

                        CategoryCard(title: diaryQuestions[5], dateText: nil, isExpanded: $expanded[5]) {
                            DiaryContent(text: $answer6, isKeyboardActive: $isKeyboardActive)
                        }

                        CategoryCard(title: diaryQuestions[6], dateText: nil, isExpanded: $expanded[6]) {
                            DiaryContent(text: $answer7, isKeyboardActive: $isKeyboardActive)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)

                    // MARK: Submit Button
                    VStack(spacing: 10) {
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
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 6)
                    .padding(.bottom, 18)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))

            // ✅ Wir setzen den Titel über "principal" (stabil & hübsch)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { onBack() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }

                // ✅ Titel + Datum mittig (2 Zeilen)
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
                        showPencilTooltip = false
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
            .onTapGesture { isKeyboardActive = false }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        showPencilTooltip = true
                    }
                }
            }

            // ===== Tooltip Overlay =====
            if showPencilTooltip {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isKeyboardActive = false
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            showPencilTooltip = false
                        }
                    }
                    .zIndex(9)

                TooltipSpeechBubble(
                    text: "Hier kannst du\ndeine Fragen\nanpassen!",
                    buttonTitle: "OK!",
                    arrowX: 0.86,
                    onClose: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            showPencilTooltip = false
                        }
                    }
                )
                .frame(width: 260)
                .position(
                    x: UIScreen.main.bounds.width - 260/2 - 8,
                    y: 105
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                .zIndex(10)
            }
        }
    }
}

// MARK: - Tooltip Speech Bubble (3 Ebenen wie Figma)
private struct TooltipSpeechBubble: View {
    let text: String
    let buttonTitle: String
    let arrowX: CGFloat
    let onClose: () -> Void

    var body: some View {
        ZStack {
            BubbleShape(arrowX: arrowX)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
                .blur(radius: 0.8)

            BubbleShape(arrowX: arrowX)
                .fill(Color.white)
                .overlay(
                    BubbleShape(arrowX: arrowX)
                        .stroke(Color.black.opacity(0.9), lineWidth: 2)
                )

            VStack(spacing: 14) {
                Text(text)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)
                    .padding(.horizontal, 18)

                Button(action: onClose) {
                    Text(buttonTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.08))
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
        .frame(height: 160)
    }
}

private struct BubbleShape: Shape {
    let arrowX: CGFloat

    func path(in rect: CGRect) -> Path {
        let corner: CGFloat = 18
        let strokePad: CGFloat = 2
        let arrowW: CGFloat = 26
        let arrowH: CGFloat = 14

        let bodyRect = CGRect(
            x: rect.minX + strokePad,
            y: rect.minY + arrowH + strokePad,
            width: rect.width - strokePad * 2,
            height: rect.height - arrowH - strokePad * 2
        )

        let ax = bodyRect.minX + (bodyRect.width * arrowX)
        let arrowLeft = max(bodyRect.minX + corner + 8, ax - arrowW / 2)
        let arrowRight = min(bodyRect.maxX - corner - 8, ax + arrowW / 2)
        let arrowMid = (arrowLeft + arrowRight) / 2

        var p = Path()

        p.move(to: CGPoint(x: bodyRect.minX + corner, y: bodyRect.minY))
        p.addLine(to: CGPoint(x: arrowLeft, y: bodyRect.minY))
        p.addLine(to: CGPoint(x: arrowMid, y: bodyRect.minY - arrowH))
        p.addLine(to: CGPoint(x: arrowRight, y: bodyRect.minY))

        p.addLine(to: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.minY))
        p.addArc(
            center: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.minY + corner),
            radius: corner,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY - corner))
        p.addArc(
            center: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.maxY - corner),
            radius: corner,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY))
        p.addArc(
            center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY - corner),
            radius: corner,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bodyRect.minX, y: bodyRect.minY + corner))
        p.addArc(
            center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.minY + corner),
            radius: corner,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )

        p.closeSubpath()
        return p
    }
}

private struct DiaryContent: View {
    @Binding var text: String
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedTextField(placeholder: "…", text: $text, isKeyboardActive: $isKeyboardActive)
        }
        .padding(.top, 8)
    }
}

private struct MoodPickerRow: View {
    let title: String
    let emojis: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)

            HStack(spacing: 10) {
                ForEach(emojis, id: \.self) { emoji in
                    Button { selection = emoji } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selection == emoji ? Color.black.opacity(0.2) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selection == emoji ? Color.black : Color.clear, lineWidth: 2)
                                )
                                .frame(width: 50, height: 40)

                            Text(emoji)
                                .font(.system(size: 24))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CategoryCard<Content: View>: View {
    let title: String
    let dateText: String?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: Content

    private let sideInset: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(.black)

                        if let dateText {
                            Text(dateText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, sideInset + 12)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if isExpanded {
                content
                    .padding(.trailing, sideInset)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.4, green: 0.4, blue: 0.4))
                .frame(width: sideInset),
            alignment: .trailing
        )
        .overlay(
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
                .padding(.trailing, 12)
                .padding(.top, 12),
            alignment: .topTrailing
        )
    }
}

private struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .focused($isKeyboardActive)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .lineLimit(1...6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black, lineWidth: 1)
            )
            .background(Color.white)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        JournalDiaryView(
            onBack: {},
            onOpenQuestionCatalog: {},
            entryDate: Date()
        )
    }
}

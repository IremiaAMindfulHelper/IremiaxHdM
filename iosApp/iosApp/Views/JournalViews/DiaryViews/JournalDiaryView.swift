import SwiftUI

struct JournalDiaryView: View {
    let onBack: () -> Void
    let onOpenQuestionCatalog: () -> Void
    let entryDate: Date

    // Steuert, ob das TextField fokussiert ist (Keyboard an/aus).
    @FocusState private var isKeyboardActive: Bool

    // Steuert, ob der Pencil-Tooltip sichtbar ist.
    @State private var showPencilTooltip = false

    // Verhindert, dass der Tooltip mehrfach beim Re-Render auftaucht.
    @State private var didShowPencilTooltip = false

    // Steuert, welche Cards aufgeklappt sind.
    @State private var expanded = Array(repeating: true, count: 7)

    // Speichert die Antworten der Textfragen.
    @State private var answer1 = ""
    @State private var answer2 = ""
    @State private var answer3 = ""
    @State private var answer4 = ""
    @State private var answer6 = ""
    @State private var answer7 = ""

    // Speichert die Stimmungsauswahl für vier Tageszeiten.
    @State private var moodSelections = Array(repeating: "", count: 4)

    // Texte der Tagebuchfragen.
    private let diaryQuestions = [
        "Gab es heute schwierige Momente für dich?",
        "Was ist gut gelaufen?",
        "Welche Sorgen möchtest du heute loslassen?",
        "Wie kannst du die Situation verbessern?",
        "Wie hat sich deine Stimmung im Laufe des Tages verändert?",
        "Wofür bist du heute dankbar?",
        "Gibt es etwas, das du morgen anders machen möchtest?"
    ]

    // Emoji-Auswahl für die Stimmung.
    private let moodEmojis = ["😢", "🙁", "😐", "😊", "😄"]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 12) {
                        ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                            CategoryCard(title: section.title, dateText: nil, isExpanded: $expanded[index]) {
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

            // Zeigt den Tooltip über der UI.
            if showPencilTooltip {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isKeyboardActive = false
                        hideTooltip()
                    }
                    .zIndex(9)

                TooltipSpeechBubble(
                    text: "Hier kannst du\ndeine Fragen\nanpassen!",
                    buttonTitle: "OK!",
                    arrowX: 0.86,
                    onClose: { hideTooltip() }
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
        .onAppear { showTooltipOnce() }
    }

    // Liefert Titel + Content pro Card, damit der Body nicht aus Copy/Paste besteht.
    private var sections: [SectionDefinition] {
        [
            .init(title: diaryQuestions[0], content: AnyView(DiaryContent(text: $answer1, isKeyboardActive: $isKeyboardActive))),
            .init(title: diaryQuestions[1], content: AnyView(DiaryContent(text: $answer2, isKeyboardActive: $isKeyboardActive))),
            .init(title: diaryQuestions[2], content: AnyView(DiaryContent(text: $answer3, isKeyboardActive: $isKeyboardActive))),
            .init(title: diaryQuestions[3], content: AnyView(DiaryContent(text: $answer4, isKeyboardActive: $isKeyboardActive))),
            .init(title: diaryQuestions[4], content: AnyView(moodPickerContent)),
            .init(title: diaryQuestions[5], content: AnyView(DiaryContent(text: $answer6, isKeyboardActive: $isKeyboardActive))),
            .init(title: diaryQuestions[6], content: AnyView(DiaryContent(text: $answer7, isKeyboardActive: $isKeyboardActive)))
        ]
    }

    // Content für die vier Mood-Picker Reihen.
    private var moodPickerContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            MoodPickerRow(title: "Morgen ☀️", emojis: moodEmojis, selection: $moodSelections[0])
            MoodPickerRow(title: "Mittag 🌤", emojis: moodEmojis, selection: $moodSelections[1])
            MoodPickerRow(title: "Abend 🌆", emojis: moodEmojis, selection: $moodSelections[2])
            MoodPickerRow(title: "Nacht 🌙", emojis: moodEmojis, selection: $moodSelections[3])
        }
    }

    // Toolbar mit Back, Titel/Datum, Pencil und Keyboard-“Fertig”.
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

    // Zeigt den Tooltip nur einmal, wenn die View das erste Mal erscheint.
    private func showTooltipOnce() {
        guard didShowPencilTooltip == false else { return }
        didShowPencilTooltip = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                showPencilTooltip = true
            }
        }
    }

    // Blendet den Tooltip animiert aus.
    private func hideTooltip() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
            showPencilTooltip = false
        }
    }

    // Formatiert das Datum für die Toolbar.
    private var formattedDiaryDate: String {
        Self.diaryDateFormatter.string(from: entryDate)
    }

    // DateFormatter als static, damit er nicht bei jedem Render neu erzeugt wird.
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
        p.addArc(center: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.minY + corner),
                 radius: corner,
                 startAngle: .degrees(-90),
                 endAngle: .degrees(0),
                 clockwise: false)

        p.addLine(to: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY - corner))
        p.addArc(center: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.maxY - corner),
                 radius: corner,
                 startAngle: .degrees(0),
                 endAngle: .degrees(90),
                 clockwise: false)

        p.addLine(to: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY))
        p.addArc(center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY - corner),
                 radius: corner,
                 startAngle: .degrees(90),
                 endAngle: .degrees(180),
                 clockwise: false)

        p.addLine(to: CGPoint(x: bodyRect.minX, y: bodyRect.minY + corner))
        p.addArc(center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.minY + corner),
                 radius: corner,
                 startAngle: .degrees(180),
                 endAngle: .degrees(270),
                 clockwise: false)

        p.closeSubpath()
        return p
    }
}

private struct DiaryContent: View {
    @Binding var text: String
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        RoundedTextField(placeholder: "…", text: $text, isKeyboardActive: $isKeyboardActive)
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
    private let cornerRadius: CGFloat = 18

    var body: some View {
        // Struktur als HStack: links Inhalt, rechts der graue "Handle" als einziger Toggle-Button.
        HStack(spacing: 0) {

            // Linke Seite: Titel + optional Content (hier gibt es KEINEN Button mehr).
            VStack(alignment: .leading, spacing: 0) {
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
                    .padding(.trailing, 12)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)

                if isExpanded {
                    content
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                }
            }

            // Rechte Seite: grauer Bereich ist der EINZIGE Tap-Bereich zum Ein-/Ausklappen.
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                ZStack(alignment: .topTrailing) {
                    // Graue Fläche (dein "Drückbereich")
                    Rectangle()
                        .fill(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .frame(width: sideInset)

                    // Chevron sitzt oben rechts im grauen Bereich.
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                        .padding(.trailing, 12)
                        .padding(.top, 12)
                }
                .frame(width: sideInset)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle()) // sorgt dafür, dass die komplette graue Fläche tappbar ist
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
        )
        .clipShape(
            // Clip sorgt dafür, dass auch der rechte graue Bereich die runden Ecken übernimmt.
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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

#Preview {
    NavigationStack {
        JournalDiaryView(
            onBack: {},
            onOpenQuestionCatalog: {},
            entryDate: Date()
        )
    }
}

import SwiftUI

/// Enthält wiederverwendbare SwiftUI-Views für ein Journal/Diary UI:
/// - Liest Frames per GeometryReader aus (für Overlays/Tooltips)
/// - Zeigt ausklappbare Karten im Timeline-Stil
/// - Rendert eine Tooltip-Sprechblase mit Pfeil
/// - Stellt Eingabefelder und Auswahlreihen (Mood Picker) bereit
/// - Bietet eine schlanke Wrapper-Card für Kategorien
struct PencilFrameReader: View {

    // Callback, der den aktuellen Frame an die aufrufende View zurückgibt
    let onChange: (CGRect) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                // Liefert den Frame beim ersten Anzeigen
                .onAppear { onChange(proxy.frame(in: .global)) }
                // Liefert den Frame erneut, wenn er sich durch Layout-Änderungen verändert
                .onChange(of: proxy.frame(in: .global)) { _, newValue in
                    onChange(newValue)
                }
        }
        // Die View soll keine Touch-Events abfangen, da sie nur misst
        .allowsHitTesting(false)
    }
}

struct TimelineCard<Content: View>: View {

    // Überschrift der Karte
    let title: String

    // Gesteuert von außen: ob der Inhalt aufgeklappt ist
    @Binding var isExpanded: Bool

    // Zustand, der die “fertig”-Darstellung beeinflusst (z. B. Checkmark-Opacity)
    let isDone: Bool

    // Inhalt der Karte als View-Builder-Closure
    @ViewBuilder var content: () -> Content

    // Layout-Konstanten für die rechte Leiste, Ecken und Abstände
    private let rightStripW: CGFloat = 50
    private let corner: CGFloat = 20
    private let stripBlue = Color(red: 0.55, green: 0.66, blue: 0.88)
    private let cardHorizontalPadding: CGFloat = 12

    var body: some View {
        HStack(spacing: 0) {

            // Linke Timeline-Spalte mit Icon und vertikaler Linie
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(stripBlue.opacity(0.55))
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isDone ? 1 : 0.45)
                }
                .padding(.top, 14)

                Rectangle()
                    .fill(stripBlue.opacity(0.45))
                    .frame(width: 4)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
            }
            .frame(width: 46)

            // Hauptbereich mit Titel und optionalem Content
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 14)

                if isExpanded {
                    content()
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Platzhalterhöhe, damit Karten auch im zugeklappten Zustand stabil wirken
                    Color.clear
                        .frame(height: 8)
                        .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Rechte Klickfläche zum Auf- und Zuklappen der Karte
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    isExpanded.toggle()
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(stripBlue)
                        .frame(width: rightStripW)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.trailing, 12)
                        .padding(.top, 14)
                }
            }
            .buttonStyle(.plain)
        }

        // Einheitliche Breite und Karten-Hintergrund mit Schatten
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))

        // Einheitlicher Abstand zum Bildschirmrand
        .padding(.horizontal, cardHorizontalPadding)
    }
}

struct TooltipSpeechBubble: View {

    // Anzeigetext und Button-Text
    let text: String
    let buttonTitle: String

    // Relative X-Position des Pfeils (0...1) innerhalb der Bubble-Breite
    let arrowX: CGFloat

    // Callback für das Schließen
    let onClose: () -> Void

    private let buttonBlue = Color(red: 0.33, green: 0.63, blue: 0.93)

    var body: some View {
        ZStack {

            // Schatten-Layer für einen weichen “Floating”-Effekt
            BubbleShape(arrowX: arrowX)
                .fill(Color.black.opacity(0.16))
                .offset(y: 5)
                .blur(radius: 1)

            // Vorderer Bubble-Layer
            BubbleShape(arrowX: arrowX)
                .fill(Color.white)

            // Inhalt: Text + Button
            VStack(spacing: 12) {
                Text(text)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                Button(action: onClose) {
                    Text(buttonTitle)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 130)
                        .padding(.vertical, 10)
                        .background(buttonBlue.opacity(0.75))
                        .cornerRadius(18)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)
            }
        }
    }
}

struct BubbleShape: Shape {

    // Relative X-Position des Pfeils (0...1)
    let arrowX: CGFloat

    func path(in rect: CGRect) -> Path {

        // Grundmaße für Ecken und Pfeil
        let corner: CGFloat = 20
        let arrowW: CGFloat = 26
        let arrowH: CGFloat = 12

        // Körper der Bubble ohne den Pfeilbereich oben
        let bodyRect = CGRect(
            x: rect.minX,
            y: rect.minY + arrowH,
            width: rect.width,
            height: rect.height - arrowH
        )

        // Berechnet die Pfeilposition innerhalb des BodyRect
        let ax = bodyRect.minX + (bodyRect.width * arrowX)
        let arrowLeft = max(bodyRect.minX + corner + 8, ax - arrowW / 2)
        let arrowRight = min(bodyRect.maxX - corner - 8, ax + arrowW / 2)
        let arrowMid = (arrowLeft + arrowRight) / 2

        // Baut den Pfad: obere Kante mit Pfeil, dann abgerundete Ecken rundherum
        var p = Path()
        p.move(to: CGPoint(x: bodyRect.minX + corner, y: bodyRect.minY))
        p.addLine(to: CGPoint(x: arrowLeft, y: bodyRect.minY))
        p.addLine(to: CGPoint(x: arrowMid, y: bodyRect.minY - arrowH))
        p.addLine(to: CGPoint(x: arrowRight, y: bodyRect.minY))
        p.addLine(to: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.minY))

        p.addArc(
            center: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.minY + corner),
            radius: corner,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY - corner))
        p.addArc(
            center: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.maxY - corner),
            radius: corner,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY))
        p.addArc(
            center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY - corner),
            radius: corner,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bodyRect.minX, y: bodyRect.minY + corner))
        p.addArc(
            center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.minY + corner),
            radius: corner,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        p.closeSubpath()
        return p
    }
}

struct DiaryContent: View {

    // Textinhalt des Eingabefelds
    @Binding var text: String

    // Fokus-State fürs Keyboard, wird von außen gesteuert
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        RoundedTextField(placeholder: "…", text: $text, isKeyboardActive: $isKeyboardActive)
            .padding(.top, 4)
    }
}

struct MoodPickerRow: View {

    // Titel der Zeile und Auswahloptionen
    let title: String
    let emojis: [String]

    // Aktuelle Auswahl
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)

            // Rendert alle Optionen als Buttons und setzt die Selection beim Tippen
            HStack(spacing: 10) {
                ForEach(emojis, id: \.self) { emoji in
                    Button { selection = emoji } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selection == emoji ? Color.black.opacity(0.12) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            selection == emoji ? Color.black.opacity(0.35) : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .frame(width: 48, height: 38)

                            Text(emoji)
                                .font(.system(size: 22))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct RoundedTextField: View {

    // Placeholder-Text und gebundener Eingabetext
    let placeholder: String
    @Binding var text: String

    // Fokus-State fürs Keyboard
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {

        // Mehrzeiliges TextField mit Rahmen und Innenabständen
        TextField(placeholder, text: $text, axis: .vertical)
            .focused($isKeyboardActive)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .lineLimit(1...6)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.16), lineWidth: 1)
            )
    }
}

struct CategoryCard<Content: View>: View {

    // Titel und optionaler Datums-Text für die Kategorie
    let title: String
    let dateText: String?

    // Gesteuert von außen: ob die Kategorie aufgeklappt ist
    @Binding var isExpanded: Bool

    // Optionaler Status, der an TimelineCard durchgereicht wird
    var isDone: Bool = false

    // Kategorie-Inhalt als View-Builder-Closure
    @ViewBuilder var content: () -> Content

    var body: some View {

        // Wrapper um TimelineCard, damit CategoryCard als eigenes Bauteil genutzt werden kann
        TimelineCard(title: title, isExpanded: $isExpanded, isDone: isDone) {
            content()
        }
        .frame(maxWidth: .infinity)
    }
}

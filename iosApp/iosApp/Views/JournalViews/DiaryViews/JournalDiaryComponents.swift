import SwiftUI

struct PencilFrameReader: View {
    let onChange: (CGRect) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { onChange(proxy.frame(in: .global)) }
                .onChange(of: proxy.frame(in: .global)) { _, newValue in
                    onChange(newValue)
                }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Timeline Card (✅ schmaler, mehr Luft links/rechts)

struct TimelineCard<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    let isDone: Bool
    @ViewBuilder var content: Content

    private let rightStripW: CGFloat = 50
    private let corner: CGFloat = 20
    private let stripBlue = Color(red: 0.55, green: 0.66, blue: 0.88)

    // ✅ das ist der wichtigste Wert:
    // je größer, desto weiter weg vom Rand.
    private let cardHorizontalPadding: CGFloat = 12

    var body: some View {
        HStack(spacing: 0) {

            // Left timeline column
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

            // Main content
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 14)

                if isExpanded {
                    content
                        .padding(.bottom, 12)
                } else {
                    Color.clear
                        .frame(height: 8)
                        .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right strip
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
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))

        // ✅ DER FIX: Karte schmaler machen, damit sie nicht am Rand klebt
        .padding(.horizontal, cardHorizontalPadding)
    }
}

// ----- der Rest deiner Datei kann 그대로 bleiben -----

struct TooltipSpeechBubble: View {
    let text: String
    let buttonTitle: String
    let arrowX: CGFloat
    let onClose: () -> Void

    private let buttonBlue = Color(red: 0.33, green: 0.63, blue: 0.93)

    var body: some View {
        ZStack {
            BubbleShape(arrowX: arrowX)
                .fill(Color.black.opacity(0.16))
                .offset(y: 5)
                .blur(radius: 1)

            BubbleShape(arrowX: arrowX)
                .fill(Color.white)

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
    let arrowX: CGFloat

    func path(in rect: CGRect) -> Path {
        let corner: CGFloat = 20
        let arrowW: CGFloat = 26
        let arrowH: CGFloat = 12

        let bodyRect = CGRect(x: rect.minX, y: rect.minY + arrowH, width: rect.width, height: rect.height - arrowH)

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
                 radius: corner, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)

        p.addLine(to: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY - corner))
        p.addArc(center: CGPoint(x: bodyRect.maxX - corner, y: bodyRect.maxY - corner),
                 radius: corner, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        p.addLine(to: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY))
        p.addArc(center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.maxY - corner),
                 radius: corner, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        p.addLine(to: CGPoint(x: bodyRect.minX, y: bodyRect.minY + corner))
        p.addArc(center: CGPoint(x: bodyRect.minX + corner, y: bodyRect.minY + corner),
                 radius: corner, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        p.closeSubpath()
        return p
    }
}

struct DiaryContent: View {
    @Binding var text: String
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        RoundedTextField(placeholder: "…", text: $text, isKeyboardActive: $isKeyboardActive)
            .padding(.top, 4)
    }
}

struct MoodPickerRow: View {
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
                                .fill(selection == emoji ? Color.black.opacity(0.12) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selection == emoji ? Color.black.opacity(0.35) : Color.clear, lineWidth: 2)
                                )
                                .frame(width: 48, height: 38)

                            Text(emoji).font(.system(size: 22))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
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
    let title: String
    let dateText: String?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: Content

    var body: some View {
        TimelineCard(title: title, isExpanded: $isExpanded, isDone: false) {
            content
        }
    }
}

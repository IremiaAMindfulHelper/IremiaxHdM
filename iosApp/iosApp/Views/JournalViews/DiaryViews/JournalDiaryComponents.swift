//
//  JournalDiaryComponents.swift
//  iosApp
//
//  Created by Anke Raab on 23.02.26.
//

import SwiftUI

// MARK: - Tooltip

struct TooltipSpeechBubble: View {
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

struct BubbleShape: Shape {
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

// MARK: - Content Helpers

struct DiaryContent: View {
    @Binding var text: String
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        RoundedTextField(placeholder: "…", text: $text, isKeyboardActive: $isKeyboardActive)
            .padding(.top, 8)
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

struct RoundedTextField: View {
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

// MARK: - Card

struct CategoryCard<Content: View>: View {
    let title: String
    let dateText: String?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: Content

    private let sideInset: CGFloat = 40
    private let cornerRadius: CGFloat = 18

    var body: some View {
        HStack(spacing: 0) {
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

            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .frame(width: sideInset)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                        .padding(.trailing, 12)
                        .padding(.top, 12)
                }
                .frame(width: sideInset)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}

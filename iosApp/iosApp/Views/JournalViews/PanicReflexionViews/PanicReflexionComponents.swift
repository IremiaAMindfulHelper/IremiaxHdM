import SwiftUI

enum PanicTheme {
    static let yellow = Color(red: 0.98, green: 0.86, blue: 0.52)
    static let pageBG  = Color(red: 0.95, green: 0.95, blue: 0.95)
}

struct PanicTimelineCard<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    let isDone: Bool
    @ViewBuilder var content: Content

    private let rightStripW: CGFloat = 50
    private let corner: CGFloat = 20
    private let stripYellow = PanicTheme.yellow
    private let cardHorizontalPadding: CGFloat = 12

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(stripYellow.opacity(0.80))
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black.opacity(isDone ? 0.85 : 0.35))
                }
                .padding(.top, 14)

                Rectangle()
                    .fill(stripYellow.opacity(0.55))
                    .frame(width: 4)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
            }
            .frame(width: 46)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 14)

                if isExpanded {
                    content.padding(.bottom, 12)
                } else {
                    Color.clear.frame(height: 8).padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    isExpanded.toggle()
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(stripYellow)
                        .frame(width: rightStripW)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black.opacity(0.70))
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
        .padding(.horizontal, cardHorizontalPadding)
    }
}

struct PanicCategoryCard<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    var isDone: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        PanicTimelineCard(title: title, isExpanded: $isExpanded, isDone: isDone) {
            content
        }
    }
}

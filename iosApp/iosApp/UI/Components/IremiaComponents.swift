import SwiftUI

// =============================================================================
// Shared Iremia UI building blocks (buttons, chips, cards).
// 1:1 translation of IremiaComponents.kt.
// =============================================================================

/// Full-width teal pill button — the primary call to action.
struct PrimaryButton: View {
    let text: String
    let action: () -> Void
    var enabled: Bool = true
    var trailingIcon: String? = nil

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(text)
                    .font(IremiaText.cardTitle)
                    .foregroundColor(IremiaColors.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    // Let the label report its true wrapped height so the pill
                    // grows with Dynamic Type instead of clipping the text.
                    .fixedSize(horizontal: false, vertical: true)
                if let icon = trailingIcon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(IremiaColors.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .frame(minHeight: 54)
            .background(enabled ? IremiaColors.teal700 : IremiaColors.gray400)
            .clipShape(Capsule())
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }
}

/// Quiet, full-width text button for the secondary action (e.g. "skip").
///
/// Matches Android's Material `TextButton`: full width, centered text, and a
/// comfortable vertical padding / minimum touch target (~48pt) so the links read
/// as clean, well-spaced, tappable elements instead of cramped text.
struct SecondaryTextButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(IremiaText.body)
                .foregroundColor(IremiaColors.gray500)
                .frame(maxWidth: .infinity, minHeight: 48)
                .padding(.vertical, 4)
                .multilineTextAlignment(.center)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Selectable pill chip: filled teal when selected, outlined otherwise.
struct ChoiceChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(IremiaText.body)
                .foregroundColor(selected ? IremiaColors.white : IremiaColors.ink700)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selected ? IremiaColors.teal700 : IremiaColors.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(selected ? Color.clear : IremiaColors.gray300, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

/// A rounded card surface used for content blocks (notes, overview, …).
struct IremiaCard<Content: View>: View {
    var cornerRadius: CGFloat = IremiaShapes.card
    let content: () -> Content

    init(
        cornerRadius: CGFloat = IremiaShapes.card,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding(IremiaSpacing.cardPadding)
            .background(IremiaColors.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

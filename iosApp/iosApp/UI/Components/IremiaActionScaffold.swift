import SwiftUI

// =============================================================================
// Screen skeleton for "scrollable content plus a pinned action bar".
// 1:1 translation of IremiaActionScaffold.kt.
// =============================================================================

/// Height of the scrim drawn above the action bar when content is clipped.
private let scrimHeight: CGFloat = 8

/// Screen skeleton for "scrollable content plus a pinned action bar".
///
/// The middle section takes the space left over by `header` and `actionBar` and
/// scrolls only when it needs to, so on tall screens nothing scrolls at all and
/// the content simply sits where it is. This is what keeps the primary action
/// reachable on small screens and at large Dynamic Type sizes, where a flexible
/// spacer would collapse and push the buttons off-screen.
///
/// A soft top edge above the action bar marks where the scroll area ends.
struct IremiaActionScaffold<Header: View, Content: View, ActionBar: View>: View {
    var contentGutter: CGFloat = IremiaSpacing.screenGutter
    @ViewBuilder var header: () -> Header
    @ViewBuilder var content: () -> Content
    @ViewBuilder var actionBar: () -> ActionBar

    var body: some View {
        VStack(spacing: 0) {
            // spacing: 0 throughout, so slots control their own rhythm with explicit
            // spacers exactly like the Compose `Column` this mirrors.
            VStack(spacing: 0) { header() }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, contentGutter)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) { content() }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, contentGutter)
            }

            VStack(spacing: 0) { actionBar() }
                .padding(.horizontal, contentGutter)
                .padding(.top, IremiaSpacing.s3)
                .padding(.bottom, IremiaSpacing.s3)
                .frame(maxWidth: .infinity)
                .background(IremiaColors.white)
                // Drawn outside the bar's own bounds so it overlays the last
                // scrolling pixels instead of taking layout space.
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.06)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: scrimHeight)
                    .offset(y: -scrimHeight)
                    .allowsHitTesting(false)
                }
        }
    }
}

extension IremiaActionScaffold where Header == EmptyView {
    /// Convenience for screens without a fixed header section.
    init(
        contentGutter: CGFloat = IremiaSpacing.screenGutter,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actionBar: @escaping () -> ActionBar
    ) {
        self.init(
            contentGutter: contentGutter,
            header: { EmptyView() },
            content: content,
            actionBar: actionBar
        )
    }
}

package org.iremia.iremia.ui.components

import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaSpacing

/** Height of the scrim drawn above the action bar when content is clipped. */
private val ScrimHeight = 8.dp

/**
 * Screen skeleton for "scrollable content plus a pinned action bar".
 *
 * The middle section takes the space left over by [header] and [actionBar] and
 * scrolls only when it needs to, so on tall screens nothing scrolls at all and
 * the content simply sits where it is. This is what keeps the primary action
 * reachable on small screens and at large system font scales, where a weighted
 * spacer would collapse to zero and push the buttons off-screen.
 *
 * A soft top edge is drawn above the action bar while the content can still be
 * scrolled, marking where the scroll area ends and hinting that there is more
 * below. It disappears once the end is reached, so screens that fit show no
 * artificial divider.
 *
 * @param header Optional fixed section above the scroll area (e.g. a back button).
 *        It sits inside the screen gutter, like the scrolling content.
 * @param scrollState Scroll state of the middle section; hoist it to observe or
 *        control the scroll position.
 * @param contentHorizontalAlignment Horizontal alignment of the scrolling content.
 * @param contentGutter Horizontal padding applied to header, content and action bar.
 * @param actionBar The pinned bottom actions, typically a [PrimaryButton] and an
 *        optional [SecondaryTextButton].
 * @param content The scrollable body.
 */
@Composable
fun IremiaActionScaffold(
    modifier: Modifier = Modifier,
    header: (@Composable ColumnScope.() -> Unit)? = null,
    scrollState: ScrollState = rememberScrollState(),
    contentHorizontalAlignment: Alignment.Horizontal = Alignment.Start,
    contentGutter: Dp = IremiaSpacing.ScreenGutter,
    actionBar: @Composable ColumnScope.() -> Unit,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding(),
    ) {
        if (header != null) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = contentGutter),
                content = header,
            )
        }

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(scrollState)
                .padding(horizontal = contentGutter),
            horizontalAlignment = contentHorizontalAlignment,
            content = content,
        )

        // NOTE: the scrim is drawn outside the bar's own bounds (negative Y), so it
        // overlays the last scrolling pixels instead of taking layout space.
        val showScrim = scrollState.canScrollForward
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .drawBehind {
                    if (showScrim) {
                        val scrim = ScrimHeight.toPx()
                        drawRect(
                            brush = Brush.verticalGradient(
                                colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.06f)),
                                startY = -scrim,
                                endY = 0f,
                            ),
                            topLeft = Offset(0f, -scrim),
                            size = Size(size.width, scrim),
                        )
                    }
                }
                .background(IremiaColors.White)
                .padding(horizontal = contentGutter)
                .padding(top = IremiaSpacing.S3, bottom = IremiaSpacing.S3),
            content = actionBar,
        )
    }
}

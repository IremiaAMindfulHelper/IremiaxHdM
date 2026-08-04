package org.iremia.iremia.ui.preview

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import org.iremia.iremia.ui.components.PrimaryButton
import org.iremia.iremia.ui.components.SecondaryTextButton
import org.iremia.iremia.ui.journal.episode.EpisodeSavedScreen
import org.iremia.iremia.ui.journal.episode.JournalEntryScreen
import org.iremia.iremia.ui.navigation.IremiaBottomBar
import org.iremia.iremia.ui.navigation.MainTab
import org.iremia.iremia.ui.theme.AppTheme
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaSpacing

/**
 * Regression guard for the responsive-layout fixes.
 *
 * The bugs these previews cover only appear at the extremes: a small screen
 * combined with a large system font scale. Rendering every screen across that
 * matrix makes a regression visible in the preview pane instead of only on a
 * physical device.
 *
 * NOTE: font scales above 1.5 approximate Android 14's non-linear scaling only
 * roughly, so a real device check still belongs in the test pass.
 */
@Preview(name = "small · 1.0x", device = "spec:width=360dp,height=640dp", fontScale = 1.0f)
@Preview(name = "small · 1.5x", device = "spec:width=360dp,height=640dp", fontScale = 1.5f)
@Preview(name = "small · 2.0x", device = "spec:width=360dp,height=640dp", fontScale = 2.0f)
@Preview(name = "tall · 1.0x", device = "spec:width=412dp,height=915dp", fontScale = 1.0f)
@Preview(name = "tall · 2.0x", device = "spec:width=412dp,height=915dp", fontScale = 2.0f)
annotation class ResponsivePreviews

@ResponsivePreviews
@Composable
private fun EpisodeSavedScreenPreview() {
    AppTheme {
        Column(Modifier.fillMaxSize().background(IremiaColors.White)) {
            EpisodeSavedScreen(
                entryCount = 7,
                goal = 30,
                onInsights = {},
                onHome = {},
                onViewGarden = {},
            )
        }
    }
}

@ResponsivePreviews
@Composable
private fun JournalEntryScreenPreview() {
    AppTheme {
        JournalEntryScreen(onBack = {}, onSave = { _, _ -> })
    }
}

@ResponsivePreviews
@Composable
private fun IremiaBottomBarPreview() {
    AppTheme {
        IremiaBottomBar(selectedTab = MainTab.Wellbeing, onTabSelected = {})
    }
}

@ResponsivePreviews
@Composable
private fun ButtonsPreview() {
    AppTheme {
        Column(
            Modifier
                .background(IremiaColors.White)
                .padding(IremiaSpacing.ScreenGutter),
        ) {
            PrimaryButton(text = "Im Garten ansehen", onClick = {})
            Spacer(Modifier.height(IremiaSpacing.S3))
            PrimaryButton(text = "Eintrag speichern", onClick = {}, enabled = false)
            Spacer(Modifier.height(IremiaSpacing.S3))
            SecondaryTextButton(text = "Einfach nur Journal-Eintrag machen", onClick = {})
        }
    }
}

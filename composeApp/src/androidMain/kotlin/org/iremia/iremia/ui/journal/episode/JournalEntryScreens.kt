package org.iremia.iremia.ui.journal.episode

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Eco
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.iremia.iremia.ui.components.IremiaActionScaffold
import org.iremia.iremia.ui.components.IremiaCard
import org.iremia.iremia.ui.components.PrimaryButton
import org.iremia.iremia.ui.components.SecondaryTextButton
import org.iremia.iremia.ui.journal.JournalPrompt
import org.iremia.iremia.ui.journal.composeGuidedJournalContent
import org.iremia.iremia.ui.journal.journalPrompts
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.ui.theme.IremiaText
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

// =============================================================================
// Block 1: entry-type chooser + journal entry (guided + free).
// All user-facing text resolves through moko-resources (German only).
// =============================================================================

/**
 * First step of the capture flow: choose whether to record a panic attack or a
 * journal entry. Neutral, autonomy-preserving copy; no default is pre-selected.
 */
@Composable
fun EntryTypeChooserScreen(
    onBack: () -> Unit,
    onPickPanic: () -> Unit,
    onPickJournal: () -> Unit,
) {
    val context = LocalContext.current
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(IremiaColors.White)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = IremiaSpacing.ScreenGutter)
            .padding(top = IremiaSpacing.S2, bottom = IremiaSpacing.S5),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(
                    Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = localized(SharedRes.strings.nav_back).toString(context),
                    tint = IremiaColors.Ink900,
                )
            }
        }

        Spacer(Modifier.height(IremiaSpacing.S5))
        Text(localized(SharedRes.strings.entry_type_title).toString(context), style = IremiaText.H1, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S2))
        Text(localized(SharedRes.strings.entry_type_subtitle).toString(context), style = IremiaText.Body, color = IremiaColors.Gray500)

        Spacer(Modifier.height(IremiaSpacing.S6))
        EntryTypeCard(
            icon = Icons.Filled.Favorite,
            iconTint = IremiaColors.Teal700,
            iconBackground = IremiaColors.Teal50,
            title = localized(SharedRes.strings.entry_type_panic_title).toString(context),
            description = localized(SharedRes.strings.entry_type_panic_desc).toString(context),
            onClick = onPickPanic,
        )
        Spacer(Modifier.height(IremiaSpacing.S3))
        EntryTypeCard(
            icon = Icons.Filled.Eco,
            iconTint = IremiaColors.Garden700,
            iconBackground = IremiaColors.Garden100,
            title = localized(SharedRes.strings.entry_type_journal_title).toString(context),
            description = localized(SharedRes.strings.entry_type_journal_desc).toString(context),
            onClick = onPickJournal,
        )
    }
}

/** A large, tappable choice card for one entry type. */
@Composable
private fun EntryTypeCard(
    icon: ImageVector,
    iconTint: androidx.compose.ui.graphics.Color,
    iconBackground: androidx.compose.ui.graphics.Color,
    title: String,
    description: String,
    onClick: () -> Unit,
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(IremiaShapes.Card)
            .border(1.dp, IremiaColors.Gray200, IremiaShapes.Card)
            .clickable { onClick() }
            .padding(20.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .clip(CircleShape)
                    .background(iconBackground),
                contentAlignment = Alignment.Center,
            ) {
                Icon(icon, contentDescription = null, tint = iconTint, modifier = Modifier.size(26.dp))
            }
            Spacer(Modifier.size(16.dp))
            Column(Modifier.weight(1f)) {
                Text(title, style = IremiaText.CardTitle, color = IremiaColors.Ink)
                Spacer(Modifier.height(IremiaSpacing.S1))
                Text(description, style = IremiaText.Caption, color = IremiaColors.Gray500)
            }
            Icon(
                Icons.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = IremiaColors.Gray400,
                modifier = Modifier.size(24.dp),
            )
        }
    }
}

/**
 * The journal entry screen. Starts guided: optional reflection prompts the user
 * can answer freely, plus an always-visible button to switch to a single big free
 * text field. A journal entry only requires *some* text (guided answers or free
 * text); the title is optional and auto-derived when left blank.
 *
 * @param onBack Leave the journal flow (back to the type chooser).
 * @param onSave Emit (title, content). Content is non-empty when this fires.
 */
@Composable
fun JournalEntryScreen(
    onBack: () -> Unit,
    onSave: (title: String, content: String) -> Unit,
) {
    val context = LocalContext.current
    val prompts = remember { journalPrompts(context) }

    // Guided answers keyed by the stable prompt key so they survive recomposition.
    val answers = remember { mutableStateMapOf<String, String>() }
    var freeMode by rememberSaveable { mutableStateOf(false) }
    var freeText by rememberSaveable { mutableStateOf("") }
    var title by rememberSaveable { mutableStateOf("") }

    val content: String = if (freeMode) {
        freeText
    } else {
        composeGuidedJournalContent(prompts, answers)
    }
    val canSave = content.isNotBlank()

    IremiaActionScaffold(
        modifier = Modifier.background(IremiaColors.White),
        header = {
            Spacer(Modifier.height(IremiaSpacing.S2))
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onBack) {
                    Icon(
                        Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = localized(SharedRes.strings.nav_back).toString(context),
                        tint = IremiaColors.Ink900,
                    )
                }
            }
        },
        actionBar = {
            // The hint is always composed and only faded out, so the footer keeps a
            // constant height and the scroll area does not jump on the first keystroke.
            // autoSize shrinks it rather than truncating at large font scales.
            BasicText(
                localized(SharedRes.strings.journal_required_hint).toString(context),
                style = IremiaText.Caption.copy(
                    color = if (canSave) Color.Transparent else IremiaColors.Gray400,
                ),
                maxLines = 1,
                autoSize = TextAutoSize.StepBased(minFontSize = 10.sp, maxFontSize = 13.sp),
            )
            Spacer(Modifier.height(IremiaSpacing.S2))
            PrimaryButton(
                text = localized(SharedRes.strings.journal_save).toString(context),
                onClick = { if (canSave) onSave(title, content) },
                enabled = canSave,
            )
            // The free-text button stays visible in guided mode as a clearly offered
            // alternative; once in free mode there's nothing to switch back to that
            // wouldn't lose text, so we keep it one-directional and prominent.
            if (!freeMode) {
                Spacer(Modifier.height(IremiaSpacing.S1))
                SecondaryTextButton(
                    text = localized(SharedRes.strings.journal_free_button).toString(context),
                    onClick = { freeMode = true },
                )
            }
        },
    ) {
        // Title and subtitle scroll away: at large font scales the H1 alone eats
        // most of a small screen.
        Spacer(Modifier.height(IremiaSpacing.S4))
        Text(localized(SharedRes.strings.journal_title).toString(context), style = IremiaText.H1, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S2))
        Text(
            if (freeMode) localized(SharedRes.strings.journal_free_prompt).toString(context)
            else localized(SharedRes.strings.journal_subtitle).toString(context),
            style = IremiaText.Body,
            color = IremiaColors.Gray500,
        )
        Spacer(Modifier.height(IremiaSpacing.S5))

        Column {
            // Optional title, common to both modes.
            EntryTitleField(title = title, onTitleChange = { title = it })
            Spacer(Modifier.height(IremiaSpacing.S5))

            if (freeMode) {
                Text(localized(SharedRes.strings.journal_free_title).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink)
                Spacer(Modifier.height(IremiaSpacing.S3))
                JournalTextArea(
                    value = freeText,
                    onValueChange = { freeText = it },
                    placeholder = localized(SharedRes.strings.journal_free_placeholder).toString(context),
                    minHeight = 220.dp,
                )
            } else {
                Text(localized(SharedRes.strings.journal_prompts_title).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink)
                Spacer(Modifier.height(IremiaSpacing.S1))
                Text(localized(SharedRes.strings.journal_prompts_hint).toString(context), style = IremiaText.Caption, color = IremiaColors.Gray500)
                Spacer(Modifier.height(IremiaSpacing.S4))

                prompts.forEach { prompt ->
                    GuidedPromptField(
                        prompt = prompt,
                        answer = answers[prompt.key].orEmpty(),
                        onAnswerChange = { answers[prompt.key] = it },
                    )
                    Spacer(Modifier.height(IremiaSpacing.S4))
                }
            }
        }
    }
}

/** Optional, editable title field shown above the entry body. */
@Composable
fun EntryTitleField(title: String, onTitleChange: (String) -> Unit) {
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current
    Column {
        Text(
            localized(SharedRes.strings.entry_title_optional_hint).toString(context),
            style = IremiaText.Caption,
            color = IremiaColors.Gray500,
        )
        Spacer(Modifier.height(IremiaSpacing.S2))
        OutlinedTextField(
            value = title,
            onValueChange = onTitleChange,
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            placeholder = { Text(localized(SharedRes.strings.entry_title_placeholder).toString(context), style = IremiaText.Body, color = IremiaColors.Gray400) },
            shape = IremiaShapes.Field,
            textStyle = IremiaText.Body,
            colors = journalFieldColors(),
            // Single-line field: the IME shows a "done" key that closes the keyboard.
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
        )
    }
}

/** A single optional guided prompt: the question label + a multiline answer field. */
@Composable
private fun GuidedPromptField(prompt: JournalPrompt, answer: String, onAnswerChange: (String) -> Unit) {
    val context = LocalContext.current
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(prompt.question, style = IremiaText.Body, color = IremiaColors.Ink, modifier = Modifier.weight(1f))
            Spacer(Modifier.size(8.dp))
            Text(localized(SharedRes.strings.field_optional).toString(context), style = IremiaText.Caption, color = IremiaColors.Gray400)
        }
        Spacer(Modifier.height(IremiaSpacing.S2))
        JournalTextArea(value = answer, onValueChange = onAnswerChange, placeholder = "", minHeight = 72.dp)
    }
}

/**
 * A generously sized multiline text area matching the journal look.
 *
 * NOTE: Multiline fields keep the IME's newline key, so they intentionally do *not*
 * use ImeAction.Done, which would cost the user paragraph breaks. Instead a small
 * "done" button appears above the field while it has focus, giving an explicit way
 * to close the keyboard besides tapping outside or the system back button.
 */
@Composable
private fun JournalTextArea(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    minHeight: androidx.compose.ui.unit.Dp,
) {
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current
    var isFocused by remember { mutableStateOf(false) }

    Column {
        if (isFocused) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End,
            ) {
                Text(
                    text = localized(SharedRes.strings.keyboard_done).toString(context),
                    style = IremiaText.Caption,
                    color = IremiaColors.Teal700,
                    modifier = Modifier
                        .clickable { focusManager.clearFocus() }
                        .padding(vertical = 4.dp, horizontal = 8.dp),
                )
            }
        }
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = minHeight)
                .onFocusChanged { isFocused = it.isFocused },
            placeholder = if (placeholder.isEmpty()) null else {
                { Text(placeholder, style = IremiaText.Body, color = IremiaColors.Gray400) }
            },
            shape = IremiaShapes.Field,
            textStyle = IremiaText.Body,
            colors = journalFieldColors(),
        )
    }
}

/**
 * Shared text-field colors so typed text is dark on the white field (the Material3
 * default rendered near-white on this surface).
 */
@Composable
private fun journalFieldColors() = OutlinedTextFieldDefaults.colors(
    focusedTextColor = IremiaColors.Ink900,
    unfocusedTextColor = IremiaColors.Ink900,
    cursorColor = IremiaColors.Teal700,
    focusedContainerColor = IremiaColors.White,
    unfocusedContainerColor = IremiaColors.White,
    focusedBorderColor = IremiaColors.Teal700,
    unfocusedBorderColor = IremiaColors.Gray300,
)

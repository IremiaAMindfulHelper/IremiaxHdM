package org.iremia.iremia.ui.journal

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.unit.dp
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import org.iremia.iremia.domain.note.EntryType
import org.iremia.iremia.domain.note.EpisodeDraft
import org.iremia.iremia.domain.note.Note
import org.iremia.iremia.ui.components.IremiaCard
import org.iremia.iremia.ui.journal.episode.EntryTitleField
import org.iremia.iremia.ui.components.PrimaryButton
import org.iremia.iremia.ui.components.SecondaryTextButton
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.ui.theme.IremiaText
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

/**
 * Full-screen detail for one episode. Shows everything that was captured and
 * lets the user edit the text, intensity and "after" mood, then save.
 *
 * @param note The episode to show.
 * @param onClose Dismiss the screen.
 * @param onSave Persist the edited [EpisodeDraft] (id is the [note]'s id).
 */
@Composable
fun EpisodeDetailScreen(
    note: Note,
    onClose: () -> Unit,
    onSave: (EpisodeDraft) -> Unit,
) {
    val context = LocalContext.current
    val isPanic = note.type == EntryType.PANIC
    var editing by remember { mutableStateOf(false) }
    var content by remember(note.id) { mutableStateOf(note.content) }
    var title by remember(note.id) { mutableStateOf(note.title.orEmpty()) }
    var strength by remember(note.id) { mutableStateOf((note.strength ?: 5).toFloat()) }
    var moodAfter by remember(note.id) { mutableStateOf(note.moodAfter ?: -1) }

    val dateText = remember(note.createdAt) {
        val dt = Instant.fromEpochMilliseconds(note.createdAt).toLocalDateTime(TimeZone.currentSystemDefault())
        val month = dt.month.name.take(3).lowercase().replaceFirstChar { it.uppercase() }
        val time = "${dt.hour.toString().padStart(2, '0')}:${dt.minute.toString().padStart(2, '0')}"
        "${dt.dayOfMonth}. $month ${dt.year} · $time"
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(IremiaColors.Gray100)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = IremiaSpacing.ScreenGutter)
            .padding(vertical = IremiaSpacing.S3),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(localized(SharedRes.strings.episode_detail_title).toString(context), style = IremiaText.H2, color = IremiaColors.Ink)
            IconButton(onClick = onClose) {
                Icon(Icons.Filled.Close, contentDescription = localized(SharedRes.strings.nav_close).toString(context), tint = IremiaColors.Ink900)
            }
        }
        Text(dateText, style = IremiaText.Caption, color = IremiaColors.Gray500)
        Spacer(Modifier.height(IremiaSpacing.S1))
        // The entry's title (user-set or derived from the text).
        Text(note.displayTitle, style = IremiaText.H2, color = IremiaColors.Ink)

        Spacer(Modifier.height(IremiaSpacing.S4))

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState()),
        ) {
            // --- Editable title (edit mode only) ---
            if (editing) {
                EntryTitleField(title = title, onTitleChange = { title = it })
                Spacer(Modifier.height(IremiaSpacing.S3))
            }

            // --- Reflection text ---
            IremiaCard(modifier = Modifier.fillMaxWidth()) {
                Column(Modifier.fillMaxWidth()) {
                    Text(localized(SharedRes.strings.episode_reflection_title).toString(context), style = IremiaText.Eyebrow, color = IremiaColors.Teal700)
                    Spacer(Modifier.height(IremiaSpacing.S2))
                    if (editing) {
                        // Multiline field: keep the newline key and offer an explicit
                        // "done" button while focused to close the keyboard.
                        val focusManager = LocalFocusManager.current
                        var noteFocused by remember { mutableStateOf(false) }
                        if (noteFocused) {
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
                            value = content,
                            onValueChange = { content = it },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(120.dp)
                                .onFocusChanged { noteFocused = it.isFocused },
                            textStyle = IremiaText.Body,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedTextColor = IremiaColors.Ink900,
                                unfocusedTextColor = IremiaColors.Ink900,
                                cursorColor = IremiaColors.Teal700,
                                focusedContainerColor = IremiaColors.White,
                                unfocusedContainerColor = IremiaColors.White,
                            ),
                        )
                    } else {
                        Text(
                            content.ifBlank { localized(SharedRes.strings.garden_entry_sheet_empty).toString(context) },
                            style = IremiaText.Body,
                            color = IremiaColors.Ink700,
                        )
                    }
                }
            }

            // Intensity + mood are panic-only; journal entries hide them.
            if (isPanic) {
                Spacer(Modifier.height(IremiaSpacing.S3))

                // --- Intensity ---
                IremiaCard(modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.fillMaxWidth()) {
                        Text(localized(SharedRes.strings.episode_strength_label).toString(context), style = IremiaText.Eyebrow, color = IremiaColors.Teal700)
                        Spacer(Modifier.height(IremiaSpacing.S2))
                        if (editing) {
                            Slider(
                                value = strength,
                                onValueChange = { strength = it },
                                valueRange = 1f..10f,
                                steps = 8,
                                colors = SliderDefaults.colors(
                                    thumbColor = IremiaColors.Teal700,
                                    activeTrackColor = IremiaColors.Teal700,
                                    inactiveTrackColor = IremiaColors.Gray200,
                                ),
                            )
                        }
                        Text("${strength.toInt()}/10", style = IremiaText.CardTitle, color = IremiaColors.Ink)
                    }
                }

                Spacer(Modifier.height(IremiaSpacing.S3))

                // --- Mood ---
                IremiaCard(modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.fillMaxWidth()) {
                        Text(localized(SharedRes.strings.episode_mood_after).toString(context), style = IremiaText.Eyebrow, color = IremiaColors.Teal700)
                        Spacer(Modifier.height(IremiaSpacing.S2))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            moodFaces.forEachIndexed { idx, face ->
                                val selected = idx == moodAfter
                                Box(
                                    modifier = Modifier
                                        .size(40.dp)
                                        .clip(IremiaShapes.Pill)
                                        .background(if (selected) IremiaColors.Teal100 else IremiaColors.Gray100)
                                        .then(if (editing) Modifier.clickable { moodAfter = idx } else Modifier),
                                    contentAlignment = Alignment.Center,
                                ) {
                                    Text(face, style = IremiaText.CardTitle)
                                }
                            }
                        }
                    }
                }
            }

            // --- Context chips (read-only) ---
            val contextItems = note.places + note.activities + note.bodySignals
            if (contextItems.isNotEmpty()) {
                Spacer(Modifier.height(IremiaSpacing.S3))
                IremiaCard(modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.fillMaxWidth()) {
                        Text(localized(SharedRes.strings.episode_context_title).toString(context), style = IremiaText.Eyebrow, color = IremiaColors.Teal700)
                        Spacer(Modifier.height(IremiaSpacing.S2))
                        Text(contextItems.joinToString(" · "), style = IremiaText.Body, color = IremiaColors.Ink700)
                    }
                }
            }
        }

        Spacer(Modifier.height(IremiaSpacing.S3))

        if (editing) {
            PrimaryButton(localized(SharedRes.strings.episode_reflection_save).toString(context), onClick = {
                onSave(
                    EpisodeDraft(
                        content = content,
                        type = note.type,
                        title = title.ifBlank { null },
                        strength = if (isPanic) strength.toInt() else null,
                        places = note.places,
                        activities = note.activities,
                        bodySignals = note.bodySignals,
                        moodBefore = if (isPanic) note.moodBefore else null,
                        moodAfter = if (isPanic) moodAfter.takeIf { it >= 0 } else null,
                    )
                )
                editing = false
            })
        } else {
            PrimaryButton(localized(SharedRes.strings.episode_detail_edit).toString(context), onClick = { editing = true })
        }
        Spacer(Modifier.height(IremiaSpacing.S1))
        SecondaryTextButton(localized(SharedRes.strings.nav_close).toString(context), onClose)
    }
}

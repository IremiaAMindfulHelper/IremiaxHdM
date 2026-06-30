package org.iremia.iremia.ui.journal.episode

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Eco
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TimePicker
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.iremia.iremia.ui.components.ChoiceChip
import org.iremia.iremia.ui.components.IremiaCard
import org.iremia.iremia.ui.components.PrimaryButton
import org.iremia.iremia.ui.components.SecondaryTextButton
import org.iremia.iremia.ui.journal.activityOptions
import org.iremia.iremia.ui.journal.bodySignalOptions
import org.iremia.iremia.ui.journal.moodFaces
import org.iremia.iremia.ui.journal.placeOptions
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.ui.theme.IremiaText
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

// =============================================================================
// "Episode festhalten" wizard screens (SIC-24).
// All user-facing text is resolved through moko-resources (SharedRes.strings).
// No persistence yet.
// =============================================================================

/** Shared chrome for a wizard step: back + progress header, title, content, actions. */
@Composable
fun EpisodeStepScaffold(
    stepIndex: Int,
    stepCount: Int,
    title: String,
    onBack: () -> Unit,
    primaryLabel: String,
    onPrimary: () -> Unit,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    primaryTrailingIcon: Boolean = false,
    secondaryLabel: String? = null,
    onSecondary: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit,
) {
    val context = LocalContext.current
    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = IremiaSpacing.ScreenGutter)
            .padding(top = IremiaSpacing.S2, bottom = IremiaSpacing.S3),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = localized(SharedRes.strings.nav_back).toString(context), tint = IremiaColors.Ink900)
            }
            LinearProgressIndicator(
                progress = { stepIndex.toFloat() / stepCount },
                modifier = Modifier
                    .weight(1f)
                    .height(4.dp)
                    .clip(IremiaShapes.Pill),
                color = IremiaColors.Teal700,
                trackColor = IremiaColors.Gray200,
            )
            Spacer(Modifier.size(12.dp))
            Text("$stepIndex/$stepCount", style = IremiaText.Caption, color = IremiaColors.Gray500)
        }

        Spacer(Modifier.height(IremiaSpacing.S5))
        Text(title, style = IremiaText.H1, color = IremiaColors.Ink)
        if (subtitle != null) {
            Spacer(Modifier.height(IremiaSpacing.S2))
            Text(subtitle, style = IremiaText.Body, color = IremiaColors.Gray500)
        }
        Spacer(Modifier.height(IremiaSpacing.S5))

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState()),
            content = content,
        )

        Spacer(Modifier.height(IremiaSpacing.S3))
        PrimaryButton(
            text = primaryLabel,
            onClick = onPrimary,
            trailingIcon = if (primaryTrailingIcon) Icons.AutoMirrored.Filled.ArrowForward else null,
        )
        if (secondaryLabel != null && onSecondary != null) {
            Spacer(Modifier.height(IremiaSpacing.S1))
            SecondaryTextButton(secondaryLabel, onSecondary)
        }
    }
}

/** Step 1/3 — when it happened + intensity slider. */
@Composable
fun EpisodeIntensityStep(
    hour: Int,
    minute: Int,
    onTimeChange: (Int, Int) -> Unit,
    strength: Float,
    onStrengthChange: (Float) -> Unit,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onSkip: () -> Unit,
) {
    val context = LocalContext.current
    EpisodeStepScaffold(
        stepIndex = 1,
        stepCount = 3,
        title = localized(SharedRes.strings.episode_title).toString(context),
        subtitle = localized(SharedRes.strings.episode_subtitle).toString(context),
        onBack = onBack,
        primaryLabel = localized(SharedRes.strings.episode_next).toString(context),
        primaryTrailingIcon = true,
        onPrimary = onNext,
        secondaryLabel = localized(SharedRes.strings.episode_skip_step).toString(context),
        onSecondary = onSkip,
    ) {
        var showTimePicker by rememberSaveable { mutableStateOf(false) }

        Text(localized(SharedRes.strings.episode_when).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S2))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(IremiaShapes.Field)
                .border(1.dp, IremiaColors.Gray300, IremiaShapes.Field)
                .clickable { showTimePicker = true }
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            val timeStr = "%02d:%02d".format(hour, minute)
            Text(
                text = localized(SharedRes.strings.episode_today_time).toString(context).replace("%1\$s", timeStr),
                style = IremiaText.Body,
                color = IremiaColors.Ink,
                modifier = Modifier.weight(1f),
            )
            Icon(Icons.Filled.Schedule, contentDescription = null, tint = IremiaColors.Gray500, modifier = Modifier.size(20.dp))
        }

        if (showTimePicker) {
            TimePickerDialog(
                initialHour = hour,
                initialMinute = minute,
                onConfirm = { h, m ->
                    onTimeChange(h, m)
                    showTimePicker = false
                },
                onDismiss = { showTimePicker = false },
            )
        }

        Spacer(Modifier.height(IremiaSpacing.S6))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Bottom,
        ) {
            Text(localized(SharedRes.strings.episode_strength_label).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink)
            Text(strength.toInt().toString(), style = IremiaText.H1, color = IremiaColors.Teal700)
        }
        Slider(
            value = strength,
            onValueChange = onStrengthChange,
            valueRange = 1f..10f,
            steps = 8,
            colors = SliderDefaults.colors(
                thumbColor = IremiaColors.Teal700,
                activeTrackColor = IremiaColors.Teal700,
                inactiveTrackColor = IremiaColors.Gray200,
            ),
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(localized(SharedRes.strings.episode_strength_low).toString(context), style = IremiaText.Caption, color = IremiaColors.Gray400)
            Text(localized(SharedRes.strings.episode_strength_high).toString(context), style = IremiaText.Caption, color = IremiaColors.Gray400)
        }
    }
}

/** Step 2/3 — context chips (place / activity / body signals). */
@Composable
fun EpisodeContextStep(
    places: List<String>,
    onTogglePlace: (String) -> Unit,
    activities: List<String>,
    onToggleActivity: (String) -> Unit,
    bodySignals: List<String>,
    onToggleSignal: (String) -> Unit,
    onBack: () -> Unit,
    onNext: () -> Unit,
    onSkip: () -> Unit,
) {
    val context = LocalContext.current
    EpisodeStepScaffold(
        stepIndex = 2,
        stepCount = 3,
        title = localized(SharedRes.strings.episode_context_title).toString(context),
        onBack = onBack,
        primaryLabel = localized(SharedRes.strings.episode_next).toString(context),
        primaryTrailingIcon = true,
        onPrimary = onNext,
        secondaryLabel = localized(SharedRes.strings.episode_skip_step).toString(context),
        onSecondary = onSkip,
    ) {
        ChipGroup(localized(SharedRes.strings.episode_context_where).toString(context), placeOptions(context), places, onTogglePlace)
        Spacer(Modifier.height(IremiaSpacing.S5))
        ChipGroup(localized(SharedRes.strings.episode_context_activity).toString(context), activityOptions(context), activities, onToggleActivity)
        Spacer(Modifier.height(IremiaSpacing.S5))
        ChipGroup(localized(SharedRes.strings.episode_context_body).toString(context), bodySignalOptions(context), bodySignals, onToggleSignal)
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun ChipGroup(
    title: String,
    options: List<String>,
    selected: List<String>,
    onToggle: (String) -> Unit,
) {
    Text(title, style = IremiaText.CardTitle, color = IremiaColors.Ink)
    Spacer(Modifier.height(IremiaSpacing.S3))
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        options.forEach { option ->
            ChoiceChip(
                label = option,
                selected = option in selected,
                onClick = { onToggle(option) },
            )
        }
    }
}

/** Step 3/3 — free note + mood before/after. */
@Composable
fun EpisodeReflectionStep(
    note: String,
    onNoteChange: (String) -> Unit,
    moodBefore: Int,
    onMoodBefore: (Int) -> Unit,
    moodAfter: Int,
    onMoodAfter: (Int) -> Unit,
    onBack: () -> Unit,
    onSave: () -> Unit,
) {
    val context = LocalContext.current
    EpisodeStepScaffold(
        stepIndex = 3,
        stepCount = 3,
        title = localized(SharedRes.strings.episode_reflection_title).toString(context),
        onBack = onBack,
        primaryLabel = localized(SharedRes.strings.episode_reflection_save).toString(context),
        onPrimary = onSave,
        secondaryLabel = localized(SharedRes.strings.episode_reflection_save_no_note).toString(context),
        onSecondary = onSave,
    ) {
        Text(localized(SharedRes.strings.episode_reflection_prompt).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S2))
        OutlinedTextField(
            value = note,
            onValueChange = onNoteChange,
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp),
            placeholder = { Text(localized(SharedRes.strings.episode_reflection_placeholder).toString(context), style = IremiaText.Body, color = IremiaColors.Gray400) },
            shape = IremiaShapes.Field,
        )

        Spacer(Modifier.height(IremiaSpacing.S6))
        Text(localized(SharedRes.strings.episode_mood_title).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S3))
        MoodRow(localized(SharedRes.strings.episode_mood_before).toString(context), moodBefore, onMoodBefore)
        Spacer(Modifier.height(IremiaSpacing.S3))
        MoodRow(localized(SharedRes.strings.episode_mood_after).toString(context), moodAfter, onMoodAfter)
    }
}

@Composable
private fun MoodRow(label: String, selectedIndex: Int, onSelect: (Int) -> Unit) {
    Column(Modifier.fillMaxWidth()) {
        Text(label, style = IremiaText.Caption, color = IremiaColors.Gray500)
        Spacer(Modifier.height(IremiaSpacing.S2))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            moodFaces.forEachIndexed { index, face ->
                val isSelected = index == selectedIndex
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(48.dp)
                        .clip(IremiaShapes.CardSm)
                        .background(if (isSelected) IremiaColors.Teal50 else IremiaColors.Gray100)
                        .then(
                            if (isSelected) Modifier.border(1.5.dp, IremiaColors.Teal700, IremiaShapes.CardSm)
                            else Modifier
                        )
                        .clickable { onSelect(index) },
                    contentAlignment = Alignment.Center,
                ) {
                    Text(face, fontSize = 24.sp)
                }
            }
        }
    }
}

/** Material 3 time picker wrapped in a confirm/cancel dialog. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun TimePickerDialog(
    initialHour: Int,
    initialMinute: Int,
    onConfirm: (Int, Int) -> Unit,
    onDismiss: () -> Unit,
) {
    val context = LocalContext.current
    val state = rememberTimePickerState(
        initialHour = initialHour,
        initialMinute = initialMinute,
        is24Hour = true,
    )
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(onClick = { onConfirm(state.hour, state.minute) }) {
                Text(localized(SharedRes.strings.dialog_ok).toString(context), color = IremiaColors.Teal700)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(localized(SharedRes.strings.dialog_cancel).toString(context), color = IremiaColors.Gray500)
            }
        },
        text = { TimePicker(state = state) },
    )
}

/** Final confirmation screen after saving an episode. */
@Composable
fun EpisodeSavedScreen(
    entryCount: Int,
    goal: Int,
    onInsights: () -> Unit,
    onHome: () -> Unit,
) {
    val context = LocalContext.current
    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = IremiaSpacing.ScreenGutter)
            .padding(vertical = IremiaSpacing.S5),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(IremiaSpacing.S8))
        Box(
            modifier = Modifier
                .size(64.dp)
                .clip(CircleShape)
                .background(IremiaColors.Teal50),
            contentAlignment = Alignment.Center,
        ) {
            Icon(Icons.Filled.Check, contentDescription = null, tint = IremiaColors.Teal700, modifier = Modifier.size(36.dp))
        }
        Spacer(Modifier.height(IremiaSpacing.S4))
        Text(localized(SharedRes.strings.episode_saved_title).toString(context), style = IremiaText.H1, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S2))
        Text(
            localized(SharedRes.strings.episode_saved_body).toString(context),
            style = IremiaText.Body,
            color = IremiaColors.Gray500,
        )

        Spacer(Modifier.height(IremiaSpacing.S5))
        Row(
            modifier = Modifier
                .clip(IremiaShapes.Pill)
                .background(IremiaColors.Garden100)
                .padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(Icons.Filled.Eco, contentDescription = null, tint = IremiaColors.Garden700, modifier = Modifier.size(18.dp))
            Spacer(Modifier.size(8.dp))
            Text(localized(SharedRes.strings.episode_saved_tree_badge).toString(context), style = IremiaText.Caption, color = IremiaColors.Garden900)
        }

        Spacer(Modifier.height(IremiaSpacing.S6))
        IremiaCard(modifier = Modifier.fillMaxWidth()) {
            Column(Modifier.fillMaxWidth()) {
                Text(localized(SharedRes.strings.episode_saved_dataset_title).toString(context), style = IremiaText.Eyebrow, color = IremiaColors.Teal700)
                Spacer(Modifier.height(IremiaSpacing.S2))
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(entryCount.toString(), style = IremiaText.NumXl, color = IremiaColors.Ink)
                    Spacer(Modifier.size(8.dp))
                    Text(localized(SharedRes.strings.episode_saved_entries).toString(context), style = IremiaText.Body, color = IremiaColors.Gray600, modifier = Modifier.padding(bottom = 6.dp))
                }
                Spacer(Modifier.height(IremiaSpacing.S2))
                Text(
                    localized(SharedRes.strings.episode_saved_goal_hint).toString(context).replace("%1\$d", goal.toString()),
                    style = IremiaText.Caption,
                    color = IremiaColors.Gray500,
                )
                Spacer(Modifier.height(IremiaSpacing.S3))
                LinearProgressIndicator(
                    progress = { entryCount.toFloat() / goal },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(6.dp)
                        .clip(IremiaShapes.Pill),
                    color = IremiaColors.Teal700,
                    trackColor = IremiaColors.Gray200,
                )
                Spacer(Modifier.height(IremiaSpacing.S1))
                Text("$entryCount / $goal", style = IremiaText.Caption, color = IremiaColors.Gray400)
            }
        }

        Spacer(Modifier.weight(1f))
        PrimaryButton(localized(SharedRes.strings.episode_saved_insights).toString(context), onInsights, trailingIcon = Icons.AutoMirrored.Filled.ArrowForward)
        Spacer(Modifier.height(IremiaSpacing.S1))
        SecondaryTextButton(localized(SharedRes.strings.episode_saved_home).toString(context), onHome)
    }
}

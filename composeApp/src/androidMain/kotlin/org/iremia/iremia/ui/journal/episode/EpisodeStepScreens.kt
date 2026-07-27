package org.iremia.iremia.ui.journal.episode

import androidx.compose.foundation.Image
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
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Eco
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DatePickerDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.SelectableDates
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TimePicker
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberTimePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import io.github.alexzhirkevich.compottie.DotLottie
import io.github.alexzhirkevich.compottie.LottieClipSpec
import io.github.alexzhirkevich.compottie.LottieCompositionSpec
import io.github.alexzhirkevich.compottie.animateLottieCompositionAsState
import io.github.alexzhirkevich.compottie.rememberLottieComposition
import io.github.alexzhirkevich.compottie.rememberLottiePainter
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
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
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EpisodeIntensityStep(
    dateMillis: Long,
    onDateChange: (Long) -> Unit,
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
        var showDatePicker by rememberSaveable { mutableStateOf(false) }
        var showTimePicker by rememberSaveable { mutableStateOf(false) }

        Text(localized(SharedRes.strings.episode_when).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S2))

        // Date field — pick the day it happened (today or in the past, no future).
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(IremiaShapes.Field)
                .border(1.dp, IremiaColors.Gray300, IremiaShapes.Field)
                .clickable { showDatePicker = true }
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = formatEpisodeDate(dateMillis),
                style = IremiaText.Body,
                color = IremiaColors.Ink,
                modifier = Modifier.weight(1f),
            )
            Icon(Icons.Filled.CalendarToday, contentDescription = null, tint = IremiaColors.Gray500, modifier = Modifier.size(20.dp))
        }

        Spacer(Modifier.height(IremiaSpacing.S2))

        // Time field — opens after the date is set, as requested.
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
                text = timeStr,
                style = IremiaText.Body,
                color = IremiaColors.Ink,
                modifier = Modifier.weight(1f),
            )
            Icon(Icons.Filled.Schedule, contentDescription = null, tint = IremiaColors.Gray500, modifier = Modifier.size(20.dp))
        }

        if (showDatePicker) {
            EpisodeDatePickerDialog(
                initialDateMillis = dateMillis,
                onConfirm = { millis ->
                    onDateChange(millis)
                    showDatePicker = false
                    // After choosing the date, prompt for the time next.
                    showTimePicker = true
                },
                onDismiss = { showDatePicker = false },
            )
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
            // A larger thumb with a white ring + drop shadow so the handle clearly
            // stands out from the track.
            thumb = {
                Box(
                    modifier = Modifier
                        .size(26.dp)
                        .shadow(4.dp, CircleShape)
                        .clip(CircleShape)
                        .background(IremiaColors.White)
                        .padding(3.dp)
                        .clip(CircleShape)
                        .background(IremiaColors.Teal700),
                )
            },
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
            textStyle = IremiaText.Body,
            // NOTE: Explicit colors so the typed text is dark on the white field;
            // the Material3 default text color rendered near-white on this surface.
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = IremiaColors.Ink900,
                unfocusedTextColor = IremiaColors.Ink900,
                cursorColor = IremiaColors.Teal700,
                focusedContainerColor = IremiaColors.White,
                unfocusedContainerColor = IremiaColors.White,
                focusedBorderColor = IremiaColors.Teal700,
                unfocusedBorderColor = IremiaColors.Gray300,
            ),
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

/**
 * Material 3 date picker for choosing the day an episode happened. Future dates are
 * disabled — an episode can only be in the present or the past.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EpisodeDatePickerDialog(
    initialDateMillis: Long,
    onConfirm: (Long) -> Unit,
    onDismiss: () -> Unit,
) {
    val context = LocalContext.current
    val todayEndUtc = remember { startOfTodayUtc() + 24L * 60 * 60 * 1000 - 1 }
    val state = rememberDatePickerState(
        initialSelectedDateMillis = initialDateMillis,
        selectableDates = object : SelectableDates {
            override fun isSelectableDate(utcTimeMillis: Long): Boolean = utcTimeMillis <= todayEndUtc
            override fun isSelectableYear(year: Int): Boolean = year <= java.util.Calendar.getInstance().get(java.util.Calendar.YEAR)
        },
    )
    DatePickerDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(
                onClick = { state.selectedDateMillis?.let(onConfirm) },
                enabled = state.selectedDateMillis != null,
            ) {
                Text(localized(SharedRes.strings.dialog_ok).toString(context), color = IremiaColors.Teal700)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(localized(SharedRes.strings.dialog_cancel).toString(context), color = IremiaColors.Gray500)
            }
        },
    ) {
        DatePicker(state = state, colors = DatePickerDefaults.colors())
    }
}

/** Today's start-of-day in UTC millis (bound for the date picker). */
private fun startOfTodayUtc(): Long {
    val utc = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC"))
    utc.set(java.util.Calendar.HOUR_OF_DAY, 0)
    utc.set(java.util.Calendar.MINUTE, 0)
    utc.set(java.util.Calendar.SECOND, 0)
    utc.set(java.util.Calendar.MILLISECOND, 0)
    return utc.timeInMillis
}

/** Formats a UTC start-of-day millis as a short local date like "5. Jun 2026". */
private fun formatEpisodeDate(dateMillis: Long): String {
    val utc = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC")).apply { timeInMillis = dateMillis }
    val months = listOf("Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez")
    val day = utc.get(java.util.Calendar.DAY_OF_MONTH)
    val month = months[utc.get(java.util.Calendar.MONTH)]
    val year = utc.get(java.util.Calendar.YEAR)
    return "$day. $month $year"
}

/** Final confirmation screen after saving an entry. */
@Composable
fun EpisodeSavedScreen(
    entryCount: Int,
    goal: Int,
    onInsights: () -> Unit,
    onHome: () -> Unit,
    onViewGarden: () -> Unit = {},
    entryType: org.iremia.iremia.domain.note.EntryType = org.iremia.iremia.domain.note.EntryType.PANIC,
    strength: Int? = null,
    plantResult: org.iremia.iremia.data.garden.PlantResult? = null,
) {
    val context = LocalContext.current
    val isJournal = entryType == org.iremia.iremia.domain.note.EntryType.JOURNAL
    val newlyPlanted = plantResult?.planted ?: true

    // Badge text: what happened in the garden. When the day already had this type,
    // say so instead of claiming a new plant (plan 6.2 / Block 3).
    val badgeText = when {
        !newlyPlanted && isJournal -> localized(SharedRes.strings.episode_saved_already_flower).toString(context)
        !newlyPlanted -> localized(SharedRes.strings.episode_saved_already_tree).toString(context)
        isJournal -> localized(SharedRes.strings.episode_saved_flower_badge).toString(context)
        else -> localized(SharedRes.strings.episode_saved_tree_badge).toString(context)
    }

    // Gentle impulse text (placeholder, no real exercise). Panic strength >= 7 gets
    // the breathing hint; lower panic a calm-moment hint; journal a warm note.
    val impulseText = when {
        isJournal -> localized(SharedRes.strings.saved_impulse_journal).toString(context)
        (strength ?: 0) >= 7 -> localized(SharedRes.strings.saved_impulse_panic_high).toString(context)
        else -> localized(SharedRes.strings.saved_impulse_panic_low).toString(context)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = IremiaSpacing.ScreenGutter)
            .padding(vertical = IremiaSpacing.S5),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(IremiaSpacing.S6))
        // A large growth animation so the user sees growth after saving. It plays
        // even when no new plant was set (plan 6.2), acknowledging the entry.
        EpisodeGrowthAnimation(modifier = Modifier.size(240.dp))
        Spacer(Modifier.height(IremiaSpacing.S4))
        Text(localized(SharedRes.strings.episode_saved_title).toString(context), style = IremiaText.H1, color = IremiaColors.Ink)
        Spacer(Modifier.height(IremiaSpacing.S2))
        Text(
            localized(SharedRes.strings.episode_saved_body).toString(context),
            style = IremiaText.Body,
            color = IremiaColors.Gray500,
        )

        // Impulse text: a gentle, non-directive suggestion matched to the entry.
        Spacer(Modifier.height(IremiaSpacing.S3))
        Text(
            impulseText,
            style = IremiaText.Body,
            color = IremiaColors.Teal700,
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
            Text(badgeText, style = IremiaText.Caption, color = IremiaColors.Garden900)
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
        PrimaryButton(localized(SharedRes.strings.episode_saved_view_garden).toString(context), onViewGarden, trailingIcon = Icons.Filled.Eco)
        Spacer(Modifier.height(IremiaSpacing.S1))
        SecondaryTextButton(localized(SharedRes.strings.episode_saved_insights).toString(context), onInsights)
        Spacer(Modifier.height(IremiaSpacing.S1))
        SecondaryTextButton(localized(SharedRes.strings.episode_saved_home).toString(context), onHome)
    }
}

/** Plays the plant-growth Lottie once, so the user sees their new tree grow. */
@Composable
private fun EpisodeGrowthAnimation(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val growBytes = remember {
        context.resources.openRawResource(SharedRes.files.tree_growth_without_background_lottie.rawResId)
            .use { it.readBytes() }
    }
    val composition by rememberLottieComposition { LottieCompositionSpec.DotLottie(growBytes) }
    // Idiomatic Compottie auto-play: drives progress itself once the composition
    // loads. High speed + clipping the slow first fifth makes the tree shoot up
    // fast and skip the sluggish sprouting intro.
    val progress by animateLottieCompositionAsState(
        composition = composition,
        iterations = 1,
        isPlaying = true,
        speed = 4f,
        clipSpec = LottieClipSpec.Progress(0.2f, 1f),
    )
    val painter = rememberLottiePainter(composition = composition, progress = { progress })

    Image(painter = painter, contentDescription = null, modifier = modifier)
}

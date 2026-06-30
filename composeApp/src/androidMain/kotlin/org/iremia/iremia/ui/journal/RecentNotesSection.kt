package org.iremia.iremia.ui.journal

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.EditNote
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import org.iremia.iremia.domain.note.Note
import org.iremia.iremia.ui.components.IremiaCard
import org.iremia.iremia.ui.theme.IremiaColors
import androidx.compose.ui.draw.clip
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaText
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

/**
 * "Letzte Notizen" section: a header with an add affordance and a list of recent
 * journal note cards. Presentational only; [onAdd] / [onNoteClick] are stubs for now.
 */
@Composable
fun RecentNotesSection(
    notes: List<Note>,
    onAdd: () -> Unit,
    onNoteClick: (Note) -> Unit,
    onDelete: (Note) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = androidx.compose.ui.platform.LocalContext.current
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(localized(SharedRes.strings.recent_notes_title).toString(context), style = IremiaText.H2, color = IremiaColors.Ink)
            Icon(
                Icons.Filled.Add,
                contentDescription = localized(SharedRes.strings.recent_notes_add).toString(context),
                tint = IremiaColors.Teal700,
                modifier = Modifier
                    .size(44.dp)
                    .clickable(onClick = onAdd)
                    .padding(8.dp),
            )
        }

        Spacer(Modifier.height(12.dp))

        // Prominent labeled add button beside the small header icon.
        OutlinedButton(
            onClick = onAdd,
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 48.dp),
            border = BorderStroke(1.5.dp, IremiaColors.Teal700),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = IremiaColors.Teal700),
        ) {
            Icon(Icons.Filled.Add, contentDescription = null, modifier = Modifier.size(18.dp))
            Spacer(Modifier.size(8.dp))
            Text(localized(SharedRes.strings.recent_notes_add).toString(context), style = IremiaText.CardTitle)
        }

        Spacer(Modifier.height(12.dp))

        notes.forEach { note ->
            NoteCard(note, onClick = { onNoteClick(note) }, onDelete = { onDelete(note) })
            Spacer(Modifier.height(10.dp))
        }
    }
}

@Composable
private fun NoteCard(note: Note, onClick: () -> Unit, onDelete: () -> Unit) {
    val dateTime = remember(note.createdAt) {
        Instant.fromEpochMilliseconds(note.createdAt)
            .toLocalDateTime(TimeZone.currentSystemDefault())
    }
    
    // Simple formatting for prototype
    val dateStr = "${dateTime.dayOfMonth}. ${dateTime.month.name.take(3).lowercase().replaceFirstChar { it.uppercase() }}"
    val timeStr = "${dateTime.hour.toString().padStart(2, '0')}:${dateTime.minute.toString().padStart(2, '0')}"

    IremiaCard(
        shape = IremiaShapes.CardSm,
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
    ) {
        Column(Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Filled.EditNote,
                        contentDescription = null,
                        tint = IremiaColors.Gray400,
                        modifier = Modifier.size(16.dp),
                    )
                    Spacer(Modifier.size(6.dp))
                    Text("$dateStr · $timeStr", style = IremiaText.Caption, color = IremiaColors.Gray500)
                }
                
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Filled.Delete,
                        contentDescription = "Löschen",
                        tint = IremiaColors.Gray400,
                        modifier = Modifier
                            .size(20.dp)
                            .clickable(onClick = onDelete),
                    )
                    Spacer(Modifier.size(8.dp))
                    Icon(
                        Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = IremiaColors.Gray400,
                        modifier = Modifier.size(20.dp),
                    )
                }
            }

            Spacer(Modifier.height(6.dp))
            val title = note.content.lineSequence().firstOrNull()?.takeIf { it.isNotBlank() } ?: "—"
            // ~50-char preview of the body text.
            val preview = note.content.replace("\n", " ").trim().take(50)
                .let { if (note.content.length > 50) "$it…" else it }

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(Modifier.weight(1f)) {
                    Text(title, style = IremiaText.CardTitle, color = IremiaColors.Ink, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    if (preview.isNotEmpty()) {
                        Spacer(Modifier.height(2.dp))
                        Text(
                            preview,
                            style = IremiaText.Body,
                            color = IremiaColors.Gray500,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
                // Mood emoji (from the "after" mood), if captured.
                note.moodAfter?.let { idx ->
                    moodFaces.getOrNull(idx)?.let { face ->
                        Spacer(Modifier.size(8.dp))
                        Text(face, style = IremiaText.CardTitle)
                    }
                }
            }

            // Intensity indicator: a small bar tinted by strength.
            note.strength?.let { strength ->
                Spacer(Modifier.height(8.dp))
                IntensityBar(strength = strength)
            }
        }
    }
}

/** A compact bar that visualises episode intensity (1..10) with a matching color. */
@Composable
private fun IntensityBar(strength: Int) {
    val fraction = (strength.coerceIn(1, 10)) / 10f
    val color = when {
        strength <= 3 -> IremiaColors.Garden500
        strength <= 6 -> IremiaColors.Warning
        else -> IremiaColors.Danger
    }
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .weight(1f)
                .height(6.dp)
                .clip(IremiaShapes.Pill)
                .background(IremiaColors.Gray200),
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(fraction)
                    .height(6.dp)
                    .clip(IremiaShapes.Pill)
                    .background(color),
            )
        }
        Spacer(Modifier.size(8.dp))
        Text("$strength/10", style = IremiaText.Caption, color = IremiaColors.Gray500)
    }
}

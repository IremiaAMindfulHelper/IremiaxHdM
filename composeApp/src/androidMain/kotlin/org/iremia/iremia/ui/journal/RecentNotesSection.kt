package org.iremia.iremia.ui.journal

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.EditNote
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import org.iremia.iremia.ui.components.IremiaCard
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaText

/**
 * "Letzte Notizen" section: a header with an add affordance and a list of recent
 * journal note cards. Presentational only; [onAdd] / [onNoteClick] are stubs for now.
 */
@Composable
fun RecentNotesSection(
    notes: List<JournalNote>,
    onAdd: () -> Unit,
    onNoteClick: (JournalNote) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text("Letzte Notizen", style = IremiaText.H2, color = IremiaColors.Ink)
            Icon(
                Icons.Filled.Add,
                contentDescription = "Notiz hinzufügen",
                tint = IremiaColors.Teal700,
                modifier = Modifier
                    .size(28.dp)
                    .clickable(onClick = onAdd),
            )
        }

        Spacer(Modifier.height(12.dp))

        notes.forEach { note ->
            NoteCard(note, onClick = { onNoteClick(note) })
            Spacer(Modifier.height(10.dp))
        }
    }
}

@Composable
private fun NoteCard(note: JournalNote, onClick: () -> Unit) {
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
                    Text("${note.date} · ${note.time}", style = IremiaText.Caption, color = IremiaColors.Gray500)
                }
                Icon(
                    Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = IremiaColors.Gray400,
                    modifier = Modifier.size(20.dp),
                )
            }

            Spacer(Modifier.height(6.dp))
            Text(note.title, style = IremiaText.CardTitle, color = IremiaColors.Ink)
            Spacer(Modifier.height(2.dp))
            Text(
                note.preview,
                style = IremiaText.Body,
                color = IremiaColors.Gray500,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}

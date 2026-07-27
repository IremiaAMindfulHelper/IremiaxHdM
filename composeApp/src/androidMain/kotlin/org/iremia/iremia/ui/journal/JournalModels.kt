package org.iremia.iremia.ui.journal

import android.content.Context
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

// =============================================================================
// Dummy data for the Journal prototype (SIC-24).
// NOTE: sample content for development only; replaced by real repository / KMP
// flow later. Visible strings resolve through moko-resources for localization.
// =============================================================================

/** A single recent journal note shown in the "Letzte Notizen" list. */
data class JournalNote(
    val date: String,
    val time: String,
    val title: String,
    val preview: String,
)

/** Sample notes for the recent-notes section. */
fun sampleNotes(context: Context): List<JournalNote> = listOf(
    JournalNote("13. Apr", "14:30",
        localized(SharedRes.strings.sample_note_title_1).toString(context),
        localized(SharedRes.strings.sample_note_preview_1).toString(context)),
    JournalNote("11. Apr", "09:15",
        localized(SharedRes.strings.sample_note_title_2).toString(context),
        localized(SharedRes.strings.sample_note_preview_2).toString(context)),
    JournalNote("8. Apr", "21:40",
        localized(SharedRes.strings.sample_note_title_3).toString(context),
        localized(SharedRes.strings.sample_note_preview_3).toString(context)),
)

/**
 * Entry counts per day for the last 30 days (garden overview), oldest → newest.
 * 0 = empty day, higher = more entries (denser/greener dot).
 */
val sampleGardenDays: List<Int> = listOf(
    1, 0, 0, 1, 1, 0, 2, 0, 1, 0, 1, 1, 0, 0, 1,
    0, 1, 2, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1,
)

/** Total trees planted (derived sample value shown in the overview). */
val sampleTreesPlanted: Int = sampleGardenDays.count { it > 0 }

/** Context options for step 2 of the episode flow. Localized via moko-resources. */
fun placeOptions(context: Context): List<String> = listOf(
    localized(SharedRes.strings.episode_place_home).toString(context),
    localized(SharedRes.strings.episode_place_work).toString(context),
    localized(SharedRes.strings.episode_place_public).toString(context),
    localized(SharedRes.strings.episode_place_outside).toString(context),
    localized(SharedRes.strings.episode_place_commute).toString(context),
)

fun activityOptions(context: Context): List<String> = listOf(
    localized(SharedRes.strings.episode_activity_sleeping).toString(context),
    localized(SharedRes.strings.episode_activity_working).toString(context),
    localized(SharedRes.strings.episode_activity_sports).toString(context),
    localized(SharedRes.strings.episode_activity_social).toString(context),
    localized(SharedRes.strings.episode_activity_eating).toString(context),
    localized(SharedRes.strings.episode_activity_traveling).toString(context),
)

fun bodySignalOptions(context: Context): List<String> = listOf(
    localized(SharedRes.strings.episode_body_heart).toString(context),
    localized(SharedRes.strings.episode_body_dizzy).toString(context),
    localized(SharedRes.strings.episode_body_breathless).toString(context),
    localized(SharedRes.strings.episode_body_shaking).toString(context),
)

/** Mood faces (worst → best) used by the "Stimmung davor / danach" selectors. */
val moodFaces = listOf("😣", "🙁", "😐", "🙂", "😄")

/**
 * One optional reflection prompt in the guided journal flow, identified by a
 * stable [key] so answers survive recomposition regardless of the localized text.
 */
data class JournalPrompt(val key: String, val question: String)

/**
 * The optional reflection question pairs for the guided journal entry, in the
 * order defined in the plan. Each pair is offered as a "difficult / good" duo;
 * all are optional. Localized via moko-resources.
 */
fun journalPrompts(context: Context): List<JournalPrompt> = listOf(
    JournalPrompt("annoyed", localized(SharedRes.strings.journal_q_annoyed).toString(context)),
    JournalPrompt("pleased", localized(SharedRes.strings.journal_q_pleased).toString(context)),
    JournalPrompt("stressed", localized(SharedRes.strings.journal_q_stressed).toString(context)),
    JournalPrompt("relaxed", localized(SharedRes.strings.journal_q_relaxed).toString(context)),
    JournalPrompt("hard", localized(SharedRes.strings.journal_q_hard).toString(context)),
    JournalPrompt("welldone", localized(SharedRes.strings.journal_q_welldone).toString(context)),
    JournalPrompt("worried", localized(SharedRes.strings.journal_q_worried).toString(context)),
    JournalPrompt("lookforward", localized(SharedRes.strings.journal_q_lookforward).toString(context)),
    JournalPrompt("burdened", localized(SharedRes.strings.journal_q_burdened).toString(context)),
    JournalPrompt("grateful", localized(SharedRes.strings.journal_q_grateful).toString(context)),
)

/**
 * Builds the entry text from answered guided prompts: each answered question is
 * rendered as "Question\nAnswer", pairs separated by blank lines. Unanswered
 * prompts are skipped. This becomes the entry [content] so the guided answers are
 * preserved as readable text (no separate schema needed).
 */
fun composeGuidedJournalContent(prompts: List<JournalPrompt>, answers: Map<String, String>): String =
    prompts
        .mapNotNull { prompt ->
            val answer = answers[prompt.key]?.trim().orEmpty()
            if (answer.isEmpty()) null else "${prompt.question}\n$answer"
        }
        .joinToString("\n\n")

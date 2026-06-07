package org.iremia.iremia.ui.journal

// =============================================================================
// Dummy data for the Journal prototype (SIC-24).
// NOTE: hardcoded German sample content; replaced by the real repository / KMP
// flow later. Visible strings will move to moko-resources in a localization pass.
// =============================================================================

/** A single recent journal note shown in the "Letzte Notizen" list. */
data class JournalNote(
    val date: String,
    val time: String,
    val title: String,
    val preview: String,
)

/** Sample notes for the recent-notes section. */
val sampleNotes: List<JournalNote> = listOf(
    JournalNote("13. Apr", "14:30", "Erkenntnis aus der Therapie", "Angstgefühle annehmen, statt sie weg…"),
    JournalNote("11. Apr", "09:15", "Morgen-Reflexion", "Nach der Atemübung ging es direkt…"),
    JournalNote("8. Apr", "21:40", "Vor dem Schlafen", "Heute zwei ruhige Momente bewusst…"),
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

/** Context options for step 2 of the episode flow. */
val placeOptions = listOf("Zuhause", "Arbeit", "Öffentlich", "Draußen", "Unterwegs")
val activityOptions = listOf("Geschlafen", "Gearbeitet", "Sport", "Social Media", "Gegessen", "Gereist")
val bodySignalOptions = listOf("Herzrasen", "Schwindel", "Atemlos", "Zittern")

/** Mood faces (worst → best) used by the "Stimmung davor / danach" selectors. */
val moodFaces = listOf("😣", "🙁", "😐", "🙂", "😄")

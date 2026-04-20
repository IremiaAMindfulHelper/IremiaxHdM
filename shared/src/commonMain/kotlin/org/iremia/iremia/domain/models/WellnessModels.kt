package org.iremia.iremia.domain.models

/**
 * Categorization for general wellness content.
 */
enum class WellnessExerciseType {
    CALCULATION, BREATHING, MEMORY, MANTRA
}

/**
 * Model representing a standalone exercise in the library.
 * NOTE: ' Dauer' and 'Beschreibung' are kept as strings for flexible UI formatting.
 */
data class WellnessExercise(
    val id: Int,
    val kategorie: String,
    val titel: String,
    val dauer: String,
    val beschreibung: String,
    val imageName: String,
    val type: WellnessExerciseType
)

/**
 * Model for affirmations and mantras.
 */
data class WellnessMantra(
    val id: Int,
    val titel: String,
    val spruch: String
)

/**
 * Model for audio-based wellness content.
 */
data class WellnessSound(
    val id: Int,
    val titel: String,
    val beschreibung: String
)
package org.iremia.iremia.domain.models

enum class WellnessExerciseType {
    CALCULATION, BREATHING, MEMORY, MANTRA
}

data class WellnessExercise(
    val id: Int,
    val kategorie: String,
    val titel: String,
    val dauer: String,
    val beschreibung: String,
    val imageName: String,
    val type: WellnessExerciseType
)

data class WellnessMantra(
    val id: Int,
    val titel: String,
    val spruch: String
)

data class WellnessSound(
    val id: Int,
    val titel: String,
    val beschreibung: String
)
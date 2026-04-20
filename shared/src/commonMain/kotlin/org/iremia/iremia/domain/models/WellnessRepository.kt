package org.iremia.iremia.domain.data

import org.iremia.iremia.domain.models.*
/**
 * Central data repository for all wellness and SOS content.
 */

object WellnessRepository {
    val exercises = listOf(
        WellnessExercise(0, "Grounding", "Atemführung", "3 Min", "Beruhige deinen Atem.", "Atemfuehrung", WellnessExerciseType.BREATHING),
        WellnessExercise(1, "Denken", "Mathe Quiz", "10 Min", "Fokus durch Kopfrechnen.", "Mathequiz", WellnessExerciseType.CALCULATION),
        WellnessExercise(2, "Denken", "Memory", "-", "Finde die passenden Paare.", "Memory", WellnessExerciseType.MEMORY),
        WellnessExercise(3, "Meditation", "Mantra", "-", "Spüre in dich hinein.", "Mantra", WellnessExerciseType.MANTRA)
    )

    val mantras = listOf(
        WellnessMantra(0, "Innere Ruhe", "Ich bin ganz bei mir und finde Frieden."),
        WellnessMantra(1, "Selbstvertrauen", "Ich vertraue meinen Fähigkeiten."),
        WellnessMantra(2, "Gelassenheit", "Ich lasse los, was ich nicht kontrollieren kann."),
        WellnessMantra(3, "Stärke", "Jeder Atemzug schenkt mir neue Kraft und Ruhe."),
        WellnessMantra(4, "Gegenwart", "Ich bin hier, ich bin sicher und ich bin wertvoll.")
    )

    val sounds = listOf(
        WellnessSound(0, "Meeresrauschen", "Lass dich von sanften Wellen beruhigen."),
        WellnessSound(1, "Regenplätschern", "Finde Gelassenheit in den Tropfen."),
        WellnessSound(2, "Waldgeräusche", "Entspanne dich mit den Klängen des Waldes.")
    )
}
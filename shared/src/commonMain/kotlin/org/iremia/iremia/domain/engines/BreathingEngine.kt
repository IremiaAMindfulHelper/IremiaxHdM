package org.iremia.iremia.domain.engines

/**
 * Defines the state of the breathing cycle.
 */
enum class BreathingType { IN, HOLD, OUT }

/**
 * Represents a specific phase within the breathing exercise.
 * @param title The display text for the user.
 * @param duration The length of the phase in seconds.
 * @param type The functional type of breathing.
 */
data class BreathingPhase(val title: String, val duration: Double, val type: BreathingType)

/**
 * Logic engine for guided breathing.
 * Manages intro animations, exercise timing, and gesture scoring.
 */
class BreathingEngine {
    val totalTime = 180
    var timeLeft = 180
    var points = 0
    var isIntroActive = true

    val phases = listOf(
        BreathingPhase("Atme ein", 4.0, BreathingType.IN),
        BreathingPhase("Halte", 4.0, BreathingType.HOLD),
        BreathingPhase("Atme aus", 4.0, BreathingType.OUT)
    )
    var currentPhaseIndex = 0
    var currentPhaseTime = phases[0].duration

    private var tickCounter = 0 // Internal counter to convert 0.1s ticks to 1s intervals
    private var hasCountedInhale = false
    private var hasCountedExhale = false

    /**
     * Advances the engine state.
     * NOTE: This should be called every 0.1s to ensure smooth UI animations.
     */
    fun updateTimer(onIntroFinished: () -> Unit = {}) {
        if (isIntroActive) {
            handleIntroLogic(onIntroFinished)
        } else if (timeLeft > 0) {
            handleExerciseLogic()
        }
    }

    private fun handleIntroLogic(onIntroFinished: () -> Unit) {
        if (currentPhaseTime > 0.1) {
            currentPhaseTime -= 0.1
        } else {
            if (currentPhaseIndex < phases.size - 1) {
                currentPhaseIndex++
                currentPhaseTime = phases[currentPhaseIndex].duration
            } else {
                isIntroActive = false
                onIntroFinished()
            }
        }
    }

    private fun handleExerciseLogic() {
        tickCounter++
        if (tickCounter >= 10) {
            timeLeft -= 1
            tickCounter = 0
        }
    }

    fun getCurrentPhase(): BreathingPhase = phases[currentPhaseIndex]

    /**
     * Returns the image suffix for the UI (Inhale/Exhale)
     */
    fun getImageNameSuffix(): String {
        return when (getCurrentPhase().type) {
            BreathingType.IN, BreathingType.HOLD -> "ein"
            BreathingType.OUT -> "aus"
        }
    }

    /**
     * Calculates cloud scaling factor (0.8 to 1.2).
     */
    fun getScaleFactor(): Double {
        val phase = getCurrentPhase()
        val progress = (phase.duration - currentPhaseTime) / phase.duration
        return when (phase.type) {
            BreathingType.IN -> 0.8 + (0.4 * progress)
            BreathingType.HOLD -> 1.2
            BreathingType.OUT -> 1.2 - (0.4 * progress)
        }
    }

    /**
     * Evaluates a drag gesture.
     * @param offset The vertical displacement.
     * @return True if a point was awarded.
     */
    fun handleGesture(offset: Float): Boolean {
        if (isIntroActive) return false
        var pointAdded = false

        if (offset < -100 && !hasCountedInhale) {
            points += 1
            hasCountedInhale = true
            hasCountedExhale = false
            pointAdded = true
        } else if (offset > 100 && !hasCountedExhale) {
            points += 1
            hasCountedExhale = true
            hasCountedInhale = false
            pointAdded = true
        }
        return pointAdded
    }

    fun resetFlags() {
        hasCountedInhale = false
        hasCountedExhale = false
    }
}
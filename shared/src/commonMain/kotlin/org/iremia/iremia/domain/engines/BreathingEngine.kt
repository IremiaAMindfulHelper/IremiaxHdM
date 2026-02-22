package org.iremia.iremia.domain.engines

enum class BreathingType { IN, HOLD, OUT }
data class BreathingPhase(val title: String, val duration: Double, val type: BreathingType)

class BreathingEngine {
    val totalTime = 180
    var timeLeft = 180
    var points = 0
    var isIntroActive = true

    // Phasen Definition
    val phases = listOf(
        BreathingPhase("Atme ein", 4.0, BreathingType.IN),
        BreathingPhase("Halte", 4.0, BreathingType.HOLD),
        BreathingPhase("Atme aus", 4.0, BreathingType.OUT)
    )
    var currentPhaseIndex = 0
    var currentPhaseTime = phases[0].duration

    private var tickCounter = 0 // Hilft, 0.1s Ticks in 1s umzuwandeln
    private var hasCountedInhale = false
    private var hasCountedExhale = false

    fun updateTimer(onIntroFinished: () -> Unit = {}) {
        if (isIntroActive) {
            // Intro Logik (schneller Takt für Animation)
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
        } else if (timeLeft > 0) {
            // Übungs Logik: Erst nach 10 Ticks (1 Sekunde) timeLeft abziehen
            tickCounter++
            if (tickCounter >= 10) {
                timeLeft -= 1
                tickCounter = 0
            }
        }
    }

    fun getCurrentPhase(): BreathingPhase = phases[currentPhaseIndex]

    // Bestimmt das Bild-Suffix ("ein" oder "aus")
    fun getImageNameSuffix(): String {
        return when (getCurrentPhase().type) {
            BreathingType.IN, BreathingType.HOLD -> "ein" // Identisches Bild für In & Hold
            BreathingType.OUT -> "aus"
        }
    }

    // Berechnet die Skalierung der Wolke (0.8 bis 1.2)
    fun getScaleFactor(): Double {
        val phase = getCurrentPhase()
        val progress = (phase.duration - currentPhaseTime) / phase.duration
        return when (phase.type) {
            BreathingType.IN -> 0.8 + (0.4 * progress)
            BreathingType.HOLD -> 1.2 // Bleibt voll aufgebläht
            BreathingType.OUT -> 1.2 - (0.4 * progress)
        }
    }

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
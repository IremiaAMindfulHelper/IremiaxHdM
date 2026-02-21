package org.iremia.iremia.domain

class BreathingEngine {
    val totalTime = 180
    var timeLeft = 180
    var points = 0
    var isIntroActive = true

    // Interne Flags für die Logik
    private var hasCountedInhale = false
    private var hasCountedExhale = false

    fun updateTimer() {
        if (!isIntroActive && timeLeft > 0) timeLeft -= 1
    }

    fun handleGesture(offset: Float): Boolean {
        if (isIntroActive) return false

        var pointAdded = false
        // Einatmen Logik
        if (offset < -100 && !hasCountedInhale) {
            points += 1
            hasCountedInhale = true
            hasCountedExhale = false
            pointAdded = true
        }
        // Ausatmen Logik
        else if (offset > 100 && !hasCountedExhale) {
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
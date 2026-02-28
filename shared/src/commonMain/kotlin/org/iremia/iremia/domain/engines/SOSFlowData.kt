package org.iremia.iremia.domain.engines

import org.iremia.iremia.domain.models.SOSStep
import org.iremia.iremia.domain.models.StepType

/**
 * Singleton providing the static configuration for the SOS exercise flow.
 */
object SOSFlowData {
    /**
     * The ordered list of steps in the SOS intervention.
     */
    val steps = listOf(
        SOSStep(0, "Atmung", "wind", StepType.BREATHING),
        SOSStep(1, "Rechnen", "plus.forwardslash.minus", StepType.CALCULATION),
        SOSStep(2, "Memory", "square.grid.2x2", StepType.MEMORY),
        SOSStep(3, "Mantra", "quote.bubble", StepType.MANTRA)
    )

    /**
     * Calculates the next step index.
     */
    fun getNextStepIndex(currentIndex: Int): Int {
        return if (currentIndex < steps.size - 1) currentIndex + 1 else currentIndex
    }
}
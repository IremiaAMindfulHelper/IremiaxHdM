package org.iremia.iremia.domain.engines

import org.iremia.iremia.domain.models.SOSStep
import org.iremia.iremia.domain.models.StepType

object SOSFlowData {
    val steps = listOf(
        SOSStep(0, "Atmung", "wind", StepType.BREATHING),
        SOSStep(1, "Rechnen", "plus.forwardslash.minus", StepType.CALCULATION),
        SOSStep(2, "Memory", "square.grid.2x2", StepType.MEMORY),
        SOSStep(3, "Mantra", "quote.bubble", StepType.MANTRA)
    )

    fun getNextStepIndex(currentIndex: Int): Int {
        return if (currentIndex < steps.size - 1) currentIndex + 1 else currentIndex
    }
}
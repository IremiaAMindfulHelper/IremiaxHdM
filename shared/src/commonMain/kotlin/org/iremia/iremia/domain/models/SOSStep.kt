package org.iremia.iremia.domain.models

enum class StepType {
    CALCULATION, BREATHING, MEMORY, MANTRA
}

data class SOSStep(
    val id: Int,
    val name: String,
    val icon: String,
    val type: StepType
)
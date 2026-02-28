package org.iremia.iremia.domain.models

/**
 * Defines the functional types of exercises available in the SOS flow.
 */
enum class StepType {
    CALCULATION, BREATHING, MEMORY, MANTRA
}

/**
 * Represents a single stage within the SOS intervention flow.
 * @param icon The SF Symbol name or asset identifier for the UI.
 */
data class SOSStep(
    val id: Int,
    val name: String,
    val icon: String,
    val type: StepType
)
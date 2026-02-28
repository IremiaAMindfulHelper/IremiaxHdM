package org.iremia.iremia.domain.models

/**
 * Data container for a single math problem.
 * Used by the CalculationEngine to pass data to the UI.
 */
data class QuestionData(
    val a: Int,
    val b: Int,
    val operation: MathOperation,
    val answerOptions: List<Int>,
    val correctAnswer: Int
)
package org.iremia.iremia.domain.models

data class QuestionData(
    val a: Int,
    val b: Int,
    val operation: MathOperation,
    val answerOptions: List<Int>,
    val correctAnswer: Int
)
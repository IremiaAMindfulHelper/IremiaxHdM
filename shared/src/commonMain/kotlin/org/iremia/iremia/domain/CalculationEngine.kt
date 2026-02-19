package org.iremia.iremia.domain

import kotlin.random.Random

// 1. Die Enum für die Rechenarten
enum class MathOperation(val symbol: String) {
    PLUS("+"),
    MINUS("−");

    fun compute(a: Int, b: Int): Int = when (this) {
        PLUS -> a + b
        MINUS -> a - b
    }

    companion object {
        fun random() = entries.random()
    }
}

// 2. Das Datenmodell für eine Aufgabe
data class QuestionData(
    val a: Int,
    val b: Int,
    val operation: MathOperation,
    val answerOptions: List<Int>,
    val correctAnswer: Int
)

// 3. Die Engine, die alles steuert
class CalculationEngine {
    val totalQuestions = 3

    fun generateQuestion(): QuestionData {
        val op = MathOperation.random()
        val a = Random.nextInt(5, 21)
        val b = Random.nextInt(1, a + 1)
        val correct = op.compute(a, b)

        val options = mutableSetOf(correct)
        while (options.size < 4) {
            val offset = Random.nextInt(-5, 6)
            if (offset != 0) {
                options.add(correct + offset)
            }
        }

        return QuestionData(
            a = a,
            b = b,
            operation = op,
            answerOptions = options.toList().shuffled(),
            correctAnswer = correct
        )
    }
}
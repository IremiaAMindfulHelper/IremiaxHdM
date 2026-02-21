package org.iremia.iremia.domain.engines

// MARK: - IMPORTS
import org.iremia.iremia.domain.models.MathOperation
import org.iremia.iremia.domain.models.QuestionData
import kotlin.random.Random

// MARK: - ENGINE
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
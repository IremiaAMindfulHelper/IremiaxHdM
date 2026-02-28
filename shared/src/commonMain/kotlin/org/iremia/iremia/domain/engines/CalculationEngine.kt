package org.iremia.iremia.domain.engines

import org.iremia.iremia.domain.models.MathOperation
import org.iremia.iremia.domain.models.QuestionData
import kotlin.random.Random

/**
 * Generates randomized mathematical problems for cognitive grounding.
 */
class CalculationEngine {
    val totalQuestions = 3

    /**
     * Creates a new question with one correct answer and three plausible distractors.
     */
    fun generateQuestion(): QuestionData {
        val op = MathOperation.random()
        val a = Random.nextInt(5, 21)
        val b = Random.nextInt(1, a + 1)
        val correct = op.compute(a, b)

        val options = mutableSetOf(correct)
        while (options.size < 4) {
            // NOTE: Using a small offset to create distractors close to the correct answer.
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
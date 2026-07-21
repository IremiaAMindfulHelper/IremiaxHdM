package org.iremia.iremia.insights

import org.iremia.iremia.domain.insights.EntrySignal
import org.iremia.iremia.domain.insights.ExerciseSession
import org.iremia.iremia.domain.insights.MotivationAlgorithm
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Locks in the algorithm's core promise (rule 4): the score is monotonic-positive.
 * Positive signals and initiative only ever raise it; low activity or a quiet week
 * never lowers it. Also checks copy stays non-judgmental (never negative headline).
 */
class MotivationAlgorithmTest {

    private val now = 1_700_000_000_000L
    private val dayMs = 24L * 60 * 60 * 1000

    private fun entry(daysAgo: Int, intensity: Int, moodAfter: Int = 3, sentiment: Float = 0.2f) =
        EntrySignal(
            createdAt = now - daysAgo * dayMs,
            intensity = intensity,
            moodBefore = (moodAfter - 1).coerceIn(0, 4),
            moodAfter = moodAfter,
            sentiment = sentiment,
        )

    @Test
    fun adding_a_positive_entry_never_lowers_the_score() {
        val base = listOf(entry(2, 5), entry(10, 6))
        val withMore = base + entry(1, 3, moodAfter = 4, sentiment = 0.8f)

        val scoreBase = MotivationAlgorithm.compute(now, base, emptyList()).score
        val scoreMore = MotivationAlgorithm.compute(now, withMore, emptyList()).score

        assertTrue(scoreMore >= scoreBase, "adding a positive entry must not lower the score")
    }

    @Test
    fun adding_an_exercise_session_never_lowers_the_score() {
        val entries = listOf(entry(2, 5), entry(9, 6))
        val noExercise = MotivationAlgorithm.compute(now, entries, emptyList()).score
        val withExercise = MotivationAlgorithm.compute(
            now, entries, listOf(ExerciseSession(now - dayMs, 180))
        ).score

        assertTrue(withExercise >= noExercise, "doing an exercise must not lower the score")
    }

    @Test
    fun a_quiet_week_does_not_lower_the_score_below_baseline() {
        // No entries at all -> score stays at the neutral baseline, never below.
        // Adding any entry can only raise it (checked in the other tests).
        val empty = MotivationAlgorithm.compute(now, emptyList(), emptyList()).score
        val oneCalm = MotivationAlgorithm.compute(now, listOf(entry(1, 2, moodAfter = 4, sentiment = 0.8f)), emptyList()).score
        assertTrue(empty >= 40, "low activity must never drop the score near zero")
        assertTrue(oneCalm >= empty, "adding an entry must never lower the score")
    }

    @Test
    fun improving_intensity_trend_is_reported_as_positive() {
        // Older entries high intensity, newer entries low -> improvement.
        val entries = listOf(
            entry(20, 8), entry(18, 9), // older half
            entry(3, 2), entry(1, 3),   // newer half
        )
        val insight = MotivationAlgorithm.compute(now, entries, emptyList())
        assertTrue(insight.isPositive)
        assertEquals("insight_fact_fewer_attacks", insight.factTitleKey)
    }

    @Test
    fun a_calm_entry_after_bad_ones_raises_the_score() {
        // 10 high-intensity entries, then one calm entry — the score must go up,
        // so the demo ("10 schlechte, dann ein guter") visibly reacts.
        val bad = (1..10).map { entry(20 - it, 9, moodAfter = 1, sentiment = -0.8f) }
        val scoreBad = MotivationAlgorithm.compute(now, bad, emptyList()).score
        val withGood = bad + entry(0, 2, moodAfter = 4, sentiment = 0.9f)
        val scoreGood = MotivationAlgorithm.compute(now, withGood, emptyList()).score
        assertTrue(scoreGood > scoreBad, "a calm entry after bad ones must raise the score")
    }

    @Test
    fun score_is_clamped_to_0_100() {
        val many = (0 until 60).map { entry(it % 30, 1, moodAfter = 4, sentiment = 1f) }
        val score = MotivationAlgorithm.compute(now, many, emptyList()).score
        assertTrue(score in 0..100)
    }

    @Test
    fun headline_is_never_a_negative_tone() {
        // Even a worsening trend must not produce a guilt/negative headline.
        val worsening = listOf(entry(40, 2), entry(3, 9))
        val insight = MotivationAlgorithm.compute(now, worsening, emptyList())
        assertTrue(
            insight.headlineKey.startsWith("insight_headline_positive") ||
                insight.headlineKey.startsWith("insight_headline_neutral"),
            "headline must stay positive or neutral, never negative",
        )
    }
}

package org.iremia.iremia.domain.insights

import kotlin.random.Random

/**
 * Deterministic dummy data generators for signals the app doesn't persist yet.
 *
 * These feed the motivation algorithm so it can be exercised end-to-end and tested.
 * Everything is seeded so output is stable and unit-testable. Real sources implement
 * the same interfaces later and drop in without changing the scoring.
 */
object DummyInsightData {

    private const val DAY_MS = 24L * 60 * 60 * 1000

    /**
     * Generates plausible exercise sessions over the last [days], trending slightly
     * more frequent toward the present (models growing initiative).
     */
    fun exerciseSource(now: Long, days: Int = 30, seed: Long = 42): ExerciseSource =
        object : ExerciseSource {
            override fun sessions(): List<ExerciseSession> {
                val random = Random(seed)
                val out = mutableListOf<ExerciseSession>()
                for (d in 0 until days) {
                    // Higher chance of a session on more recent days.
                    val recencyBoost = (days - d).toFloat() / days
                    if (random.nextFloat() < 0.25f + 0.35f * recencyBoost) {
                        val dayStart = now - d * DAY_MS
                        out += ExerciseSession(
                            completedAt = dayStart - random.nextInt(0, 12) * 60L * 60 * 1000,
                            durationSeconds = 120 + random.nextInt(0, 300),
                        )
                    }
                }
                return out
            }
        }

    /**
     * Generates historical entries over the last [days] with intensity gently
     * trending downward (calmer over time) so new users still see a trend/sparkline.
     */
    fun historicalEntrySource(now: Long, days: Int = 60, seed: Long = 7): HistoricalEntrySource =
        object : HistoricalEntrySource {
            override fun entries(): List<EntrySignal> {
                val random = Random(seed)
                val out = mutableListOf<EntrySignal>()
                for (d in 0 until days) {
                    if (random.nextFloat() < 0.5f) continue // not every day has an entry
                    // Older days = higher intensity; newer days = calmer.
                    val progress = d.toFloat() / days // 0 (recent) .. 1 (old)
                    val base = 3f + progress * 4f // ~3 recent, ~7 old
                    val intensity = (base + random.nextInt(-1, 2)).coerceIn(1f, 10f).toInt()
                    val moodAfter = (4 - (intensity / 3)).coerceIn(0, 4)
                    out += EntrySignal(
                        createdAt = now - d * DAY_MS - random.nextInt(0, 20) * 60L * 60 * 1000,
                        intensity = intensity,
                        moodBefore = (moodAfter - 1).coerceIn(0, 4),
                        moodAfter = moodAfter,
                        sentiment = ((4 - intensity).toFloat() / 4f).coerceIn(-1f, 1f),
                    )
                }
                return out
            }
        }
}

package org.iremia.iremia.domain.insights

import kotlin.math.roundToInt

/**
 * Computes the gentle "last 30 days" [MotivationInsight] shown in the home hero card.
 *
 * Design (agreed with product):
 * - **Rolling 30 days** vs the previous 30 days.
 * - Four analyses: time patterns, behavior clusters, progress trends, weighting score.
 * - **Monotonic-positive score**: only positive signals and initiative raise it; low
 *   activity never lowers it — it only lowers confidence, which softens the copy.
 * - Copy is returned as moko string **keys**; the UI resolves them.
 *
 * Pure and deterministic given its inputs, so it is fully unit-testable.
 */
object MotivationAlgorithm {

    private const val WINDOW_DAYS = 30
    private const val DAY_MS = 24L * 60 * 60 * 1000
    private const val WINDOW_MS = WINDOW_DAYS * DAY_MS

    /**
     * @param now Current time in millis.
     * @param entries Real + dummy entry signals (any order).
     * @param exercises Exercise sessions (real or dummy).
     * @return The insight to render.
     */
    fun compute(
        now: Long,
        entries: List<EntrySignal>,
        exercises: List<ExerciseSession>,
    ): MotivationInsight {
        // Chronological order so "newer half vs older half" reflects real progress,
        // even when every entry is within the same month (demo-friendly).
        val ordered = entries.sortedBy { it.createdAt }
        val recentWindow = ordered.filter { it.createdAt >= now - WINDOW_MS }
        // Use the 30-day window when it has data, otherwise fall back to all entries
        // so a fresh account with a few entries still produces a live insight.
        val basis = if (recentWindow.isNotEmpty()) recentWindow else ordered

        val trend = buildTrend(basis)
        val trendPoints = buildTrendPoints(basis)
        val progress = analyzeProgress(basis)
        val score = weightingScore(basis, exercises, progress)
        val confidence = confidenceFor(basis.size + exercises.size)
        val isPositive = progress.improved

        return MotivationInsight(
            headlineKey = headlineKey(isPositive, confidence),
            factTitleKey = if (isPositive) "insight_fact_fewer_attacks" else "insight_fact_steady_attacks",
            factSubtitleKey = if (isPositive) "insight_fact_vs_prev_30" else "insight_fact_keep_going",
            trend = trend,
            score = score,
            isPositive = isPositive,
            confidence = confidence,
            trendPoints = trendPoints,
        )
    }

    // Intensity difference (vs. running average) below which a point counts as steady.
    private const val STEADY_BAND = 0.75f

    /**
     * Builds the tappable per-point breakdown (Block 2). Each entry with an
     * intensity becomes a point; its [TrendDirection] compares that intensity to the
     * running average of the entries before it, so the user can see which entry
     * calmed or intensified the recent course. Never judgmental — just up/down/steady.
     */
    private fun buildTrendPoints(ordered: List<EntrySignal>): List<TrendPoint> {
        val withIntensity = ordered.filter { it.intensity != null }
        if (withIntensity.isEmpty()) return emptyList()

        val points = mutableListOf<TrendPoint>()
        var runningSum = 0f
        var runningCount = 0
        for (entry in withIntensity) {
            val intensity = entry.intensity!!.toFloat()
            val direction = if (runningCount == 0) {
                TrendDirection.STEADY
            } else {
                val avg = runningSum / runningCount
                when {
                    intensity <= avg - STEADY_BAND -> TrendDirection.CALMER
                    intensity >= avg + STEADY_BAND -> TrendDirection.MORE_INTENSE
                    else -> TrendDirection.STEADY
                }
            }
            points += TrendPoint(
                value = intensity,
                entryId = entry.entryId,
                createdAt = entry.createdAt,
                intensity = entry.intensity,
                direction = direction,
            )
            runningSum += intensity
            runningCount++
        }
        return points
    }

    // ---- Analysis 3: progress trends (average intensity, newer half vs older half) ----

    private data class Progress(val improved: Boolean, val recentAvg: Float, val previousAvg: Float)

    /**
     * Compares the newer half of the entries against the older half (both already
     * chronologically ordered). This reacts immediately to what the user logs — a
     * run of high-intensity entries followed by a calm one visibly moves the result,
     * even within a single month.
     */
    private fun analyzeProgress(ordered: List<EntrySignal>): Progress {
        val withIntensity = ordered.mapNotNull { e -> e.intensity?.let { e.createdAt to it } }
        if (withIntensity.size < 2) {
            val avg = withIntensity.map { it.second }.averageOrNull() ?: 0f
            // Too little data to compare -> gently positive, never negative.
            return Progress(improved = true, recentAvg = avg, previousAvg = avg)
        }
        val mid = withIntensity.size / 2
        val olderAvg = withIntensity.take(mid).map { it.second }.average().toFloat()
        val newerAvg = withIntensity.drop(mid).map { it.second }.average().toFloat()
        // Lower recent intensity = improvement.
        return Progress(improved = newerAvg <= olderAvg, recentAvg = newerAvg, previousAvg = olderAvg)
    }

    /**
     * Builds a ~15-point sparkline from the entries in chronological order, so the
     * line traces the actual sequence of logged intensities (higher = more panic).
     */
    private fun buildTrend(ordered: List<EntrySignal>): List<Float> {
        val values = ordered.mapNotNull { it.intensity?.toFloat() }
        if (values.isEmpty()) return List(15) { 3f }
        if (values.size <= 15) return values
        // Downsample to 15 buckets by averaging consecutive chunks.
        val buckets = 15
        val chunk = values.size.toFloat() / buckets
        return (0 until buckets).map { i ->
            val from = (i * chunk).toInt()
            val to = ((i + 1) * chunk).toInt().coerceAtLeast(from + 1).coerceAtMost(values.size)
            values.subList(from, to).average().toFloat()
        }
    }

    // ---- Analysis 4: weighting score (monotonic-positive, no negative terms) ----

    private fun weightingScore(
        recent: List<EntrySignal>,
        exercises: List<ExerciseSession>,
        progress: Progress,
    ): Int {
        val base = 45f
        var bonus = 0f

        // Initiative: journaling and doing exercises only ever add.
        bonus += recent.size * 2.0f
        bonus += exercises.count { it.completedAt >= 0 } * 2.0f

        // Positive mood-after, low-intensity and positive sentiment add (demo-friendly
        // weights so a single calm entry visibly lifts the score).
        bonus += recent.count { (it.moodAfter ?: 0) >= 3 } * 3.0f
        bonus += recent.count { (it.intensity ?: 10) <= 3 } * 3.0f
        bonus += recent.count { it.sentiment > 0f } * 2.0f

        // A downward intensity trend adds; a flat/worse trend simply adds nothing.
        if (progress.improved && progress.previousAvg > 0f) {
            val drop = (progress.previousAvg - progress.recentAvg).coerceAtLeast(0f)
            bonus += drop * 6f
        }

        return (base + bonus).roundToInt().coerceIn(0, 100)
    }

    // ---- Confidence + copy selection ----

    private fun confidenceFor(sampleSize: Int): InsightConfidence = when {
        sampleSize >= 12 -> InsightConfidence.HIGH
        sampleSize >= 5 -> InsightConfidence.MEDIUM
        else -> InsightConfidence.LOW
    }

    private fun headlineKey(isPositive: Boolean, confidence: InsightConfidence): String {
        val tone = if (isPositive) "positive" else "neutral"
        val level = when (confidence) {
            InsightConfidence.HIGH -> "high"
            InsightConfidence.MEDIUM -> "medium"
            InsightConfidence.LOW -> "low"
        }
        return "insight_headline_${tone}_$level"
    }

    private fun List<Int>.averageOrNull(): Float? =
        if (isEmpty()) null else sum().toFloat() / size
}

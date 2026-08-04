@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.insights

import kotlin.native.ObjCName

/**
 * Confidence in an insight, derived from how much data backs it.
 *
 * Low activity never lowers the motivation score — it only lowers confidence,
 * which softens the copy shown to the user.
 */
@ObjCName("InsightConfidence", exact = true)
enum class InsightConfidence { LOW, MEDIUM, HIGH }

/**
 * Whether a trend point pulled the recent course up, down, or held it steady.
 * Presented to the user as a gentle, never-judgmental plus/minus (plan Block 2).
 */
@ObjCName("TrendDirection", exact = true)
enum class TrendDirection { CALMER, STEADY, MORE_INTENSE }

/**
 * One tappable point on the home trend graph, resolved back to the entry behind it.
 *
 * @property value The plotted intensity value (matches [MotivationInsight.trend]).
 * @property entryId The source entry id, or null when the point has none.
 * @property createdAt The entry's timestamp in millis (for the day/date shown).
 * @property intensity The entry's panic intensity, or null (journal entries).
 * @property direction How this point moved the recent course vs. the running average.
 */
@ObjCName("TrendPoint", exact = true)
data class TrendPoint(
    val value: Float,
    val entryId: Long?,
    val createdAt: Long,
    val intensity: Int?,
    val direction: TrendDirection,
)

/**
 * The gentle, non-judgmental "last 30 days" insight rendered in the home screen's
 * blue hero card.
 *
 * This is the output shape shared by the (upcoming) motivation algorithm and the
 * temporary mock used while the UI is built, so the two are interchangeable.
 *
 * @property headlineKey moko-resources string key for the headline copy.
 * @property factTitleKey moko-resources string key for the fact title.
 * @property factSubtitleKey moko-resources string key for the fact subtitle.
 * @property trend Sparkline points (older → newer). Higher = more panic activity.
 * @property score 0..100, monotonic-positive: only rises for positive signals and
 *           initiative; low activity never lowers it.
 * @property isPositive Whether the trend is an improvement (drives copy + chart tone).
 * @property confidence How strongly the data supports the headline.
 */
@ObjCName("MotivationInsight", exact = true)
data class MotivationInsight(
    val headlineKey: String,
    val factTitleKey: String,
    val factSubtitleKey: String,
    val trend: List<Float>,
    val score: Int,
    val isPositive: Boolean,
    val confidence: InsightConfidence,
    // Per-point breakdown for the tappable graph (Block 2). Empty for the
    // placeholder and when there are no entries to resolve.
    val trendPoints: List<TrendPoint> = emptyList(),
) {
    companion object {
        /**
         * A neutral, always-positive placeholder used before the algorithm runs
         * (or when there is not enough data). Kept here so both platforms and the
         * algorithm share one fallback.
         */
        val placeholder: MotivationInsight = MotivationInsight(
            headlineKey = "insight_headline_positive_high",
            factTitleKey = "insight_fact_fewer_attacks",
            factSubtitleKey = "insight_fact_vs_prev_30",
            trend = listOf(3f, 5f, 4f, 7f, 6f, 8f, 6f, 5f, 6f, 4f, 3f, 4f, 2.5f, 3f, 2f),
            score = 72,
            isPositive = true,
            confidence = InsightConfidence.HIGH,
        )
    }
}

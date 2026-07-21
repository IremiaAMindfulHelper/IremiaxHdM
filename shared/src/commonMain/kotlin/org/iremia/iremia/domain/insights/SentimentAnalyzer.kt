package org.iremia.iremia.domain.insights

/**
 * Lightweight, dependency-free German keyword sentiment.
 *
 * Not ML — just weighted positive/negative word lists, enough to nudge the insight
 * score and never the sole basis for a claim. Returns a value in -1f..1f.
 */
object SentimentAnalyzer {

    private val positive = setOf(
        "ruhig", "ruhiger", "besser", "gut", "entspannt", "gelöst", "geschafft",
        "stolz", "dankbar", "leichter", "sicher", "gelassen", "erleichtert", "froh",
        "hilft", "geholfen", "positiv", "mut", "hoffnung", "geschlafen",
    )

    private val negative = setOf(
        "angst", "panik", "schlimm", "schlecht", "unruhig", "nervös", "zittern",
        "atemnot", "herzrasen", "schwindel", "überfordert", "erschöpft", "müde",
        "traurig", "hilflos", "schwer", "stress", "gestresst", "wach",
    )

    /** Score a comment in -1f (very negative) .. 1f (very positive). 0 = neutral/empty. */
    fun score(text: String): Float {
        if (text.isBlank()) return 0f
        val words = text.lowercase()
            .split(Regex("[^\\p{L}]+"))
            .filter { it.isNotBlank() }
        if (words.isEmpty()) return 0f

        var pos = 0
        var neg = 0
        for (w in words) {
            if (w in positive) pos++
            if (w in negative) neg++
        }
        val total = pos + neg
        if (total == 0) return 0f
        return ((pos - neg).toFloat() / total).coerceIn(-1f, 1f)
    }
}

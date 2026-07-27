package org.iremia.iremia.domain.note

/**
 * Derives a short, human-readable title from an entry's free text.
 *
 * Deliberately local and rule-based (no AI): takes the first non-empty line,
 * trims it, and caps the length at a word boundary so list rows stay tidy. The
 * user can always override the result; this only fills in a sensible default.
 *
 * @param content The entry's free text.
 * @param maxLength Soft upper bound for the generated title.
 * @return A trimmed title, or an empty string when there is no usable text.
 */
fun deriveTitle(content: String, maxLength: Int = 40): String {
    val firstLine = content
        .lineSequence()
        .map { it.trim() }
        .firstOrNull { it.isNotEmpty() }
        ?: return ""

    if (firstLine.length <= maxLength) return firstLine

    // Cut at the last word boundary within the limit so we don't split a word;
    // fall back to a hard cut if the first word already exceeds the limit.
    val hardCut = firstLine.take(maxLength)
    val lastSpace = hardCut.lastIndexOf(' ')
    val base = if (lastSpace >= maxLength / 2) hardCut.take(lastSpace) else hardCut
    return base.trimEnd() + "…"
}

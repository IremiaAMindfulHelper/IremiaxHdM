package org.iremia.iremia.ui.journal

import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import kotlinx.datetime.daysUntil
import kotlinx.datetime.isoDayNumber
import kotlinx.datetime.plus
import java.text.DateFormatSymbols
import java.util.Calendar

// =============================================================================
// Pure date helpers for the Journal calendar.
//
// Kept free of Compose so the week/month math stays trivially testable and can be
// reused by both the collapsed (week) and expanded (month) calendar views.
// Weeks are Monday-first, matching the design and the German locale.
// =============================================================================

/** Number of days in [month] (1-based) of [year]. */
fun daysInMonth(year: Int, month: Int): Int {
    val first = LocalDate(year, month, 1)
    return first.daysUntil(first.plus(1, DateTimeUnit.MONTH))
}

/**
 * The seven dates of a rolling week starting at [start] (inclusive).
 *
 * Used for the collapsed strip so "today" stays the leftmost cell and the next six
 * days follow, instead of snapping to a fixed Monday→Sunday week.
 */
fun rollingWeek(start: LocalDate): List<LocalDate> =
    (0..6).map { start.plus(it, DateTimeUnit.DAY) }

/** Localized short weekday label for [date] (device locale), e.g. "Sun". */
fun shortWeekdayLabel(date: LocalDate): String {
    val calendarDay = when (date.dayOfWeek) {
        DayOfWeek.MONDAY -> Calendar.MONDAY
        DayOfWeek.TUESDAY -> Calendar.TUESDAY
        DayOfWeek.WEDNESDAY -> Calendar.WEDNESDAY
        DayOfWeek.THURSDAY -> Calendar.THURSDAY
        DayOfWeek.FRIDAY -> Calendar.FRIDAY
        DayOfWeek.SATURDAY -> Calendar.SATURDAY
        DayOfWeek.SUNDAY -> Calendar.SUNDAY
        else -> Calendar.MONDAY
    }
    return DateFormatSymbols.getInstance().shortWeekdays[calendarDay].trimEnd('.')
}

/**
 * Monday-first calendar grid for [month] (1-based) of [year].
 *
 * Leading/trailing cells are `null` so the 1st lands under its weekday column and
 * the final week row is always complete (multiple of 7 cells).
 */
fun monthGrid(year: Int, month: Int): List<LocalDate?> {
    val leading = LocalDate(year, month, 1).dayOfWeek.isoDayNumber - 1
    val days = daysInMonth(year, month)
    val cellCount = ((leading + days + 6) / 7) * 7 // round up to whole weeks
    return (0 until cellCount).map { index ->
        val dayNumber = index - leading + 1
        if (dayNumber in 1..days) LocalDate(year, month, dayNumber) else null
    }
}

/** A specific month of a specific year. */
data class YearMonth(val year: Int, val month: Int)

/**
 * A window of consecutive months centered on [date]'s month, from [monthsBefore]
 * months in the past to [monthsAfter] months in the future. Used to feed the
 * scrollable multi-month (expanded) calendar.
 */
fun monthsAround(date: LocalDate, monthsBefore: Int, monthsAfter: Int): List<YearMonth> {
    val firstOfMonth = LocalDate(date.year, date.monthNumber, 1)
    return (-monthsBefore..monthsAfter).map { offset ->
        val shifted = firstOfMonth.plus(offset, DateTimeUnit.MONTH)
        YearMonth(shifted.year, shifted.monthNumber)
    }
}

/** Localized Monday → Sunday short weekday labels (device locale), e.g. ["Mo", …]. */
fun weekdayLabels(): List<String> {
    val short = DateFormatSymbols.getInstance().shortWeekdays
    val mondayFirst = listOf(
        Calendar.MONDAY, Calendar.TUESDAY, Calendar.WEDNESDAY, Calendar.THURSDAY,
        Calendar.FRIDAY, Calendar.SATURDAY, Calendar.SUNDAY,
    )
    // Trim the trailing dot some locales add (e.g. German "Mo.").
    return mondayFirst.map { short[it].trimEnd('.') }
}

/** Localized full month name for [month] (1-based), e.g. "April" (device locale). */
fun monthName(month: Int): String =
    DateFormatSymbols.getInstance().months[month - 1]

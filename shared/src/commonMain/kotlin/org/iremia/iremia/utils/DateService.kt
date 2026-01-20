package org.iremia.iremia.utils

import kotlinx.datetime.*

class DateService {
    private val timeZone = TimeZone.currentSystemDefault()

    fun getToday(): LocalDate {
        return Clock.System.todayIn(timeZone)
    }

    // Checks if the given date is in the future compared to today
    fun isInFuture(date: LocalDate): Boolean {
        return date > getToday()
    }

    fun canSelectDate(date: LocalDate): Boolean {
        return !isInFuture(date)
    }

    // Formats a LocalDate to a string like "Montag, 01.02."
    fun formatDateHeader(date: LocalDate): String {
        val dayName = when (date.dayOfWeek) {
            DayOfWeek.MONDAY -> "Montag"
            DayOfWeek.TUESDAY -> "Dienstag"
            DayOfWeek.WEDNESDAY -> "Mittwoch"
            DayOfWeek.THURSDAY -> "Donnerstag"
            DayOfWeek.FRIDAY -> "Freitag"
            DayOfWeek.SATURDAY -> "Samstag"
            DayOfWeek.SUNDAY -> "Sonntag"
            else -> ""
        }

        val day = date.dayOfMonth.toString().padStart(2, '0')
        val month = date.monthNumber.toString().padStart(2, '0')

        return "$dayName, $day.$month."
    }

}

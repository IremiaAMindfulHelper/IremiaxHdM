package org.iremia.iremia.controller

import kotlinx.datetime.LocalDate
import org.iremia.iremia.utils.DateService

class JournalCalendarController {
    private val dateService = DateService()

    // Checks if the given date can be selected (i.e., is not in the future)
    fun canSelectDate(year: Int, month: Int, day: Int): Boolean {
        return try {
            val date = LocalDate(year, month, day)
            dateService.canSelectDate(date)
        } catch (e: IllegalArgumentException) {
            false
        }
    }

    // Formats the given date to a header string
    fun getHeaderText(year: Int, month: Int, day: Int): String {
        val date = LocalDate(year, month, day)
        return dateService.formatDateHeader(date)
    }
}

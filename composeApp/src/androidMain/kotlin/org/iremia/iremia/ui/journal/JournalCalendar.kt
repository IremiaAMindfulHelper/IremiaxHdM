package org.iremia.iremia.ui.journal

import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import kotlinx.datetime.LocalDate
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.ui.theme.IremiaText
import org.iremia.library.SharedRes
import org.iremia.iremia.utils.localized

/** How many months before/after today the expanded calendar lets you scroll. */
private const val MONTH_WINDOW = 12

/** Fixed viewport height of the expanded (scrollable) multi-month calendar. */
private val EXPANDED_HEIGHT = 360.dp

/**
 * Collapsible Journal calendar shown at the top of the Journal screen.
 *
 * Sits on the brand blue "header wash" ([IremiaShapes.HeaderWash]) and shows the
 * selected month/year plus a "today" shortcut. Collapsed it renders the single
 * week containing [selectedDate]; expanded it becomes a vertically scrollable list
 * of months (each with its own label and weekday header) so the user can browse
 * past and future months. Days with a journal entry get a small dot.
 *
 * Selection ([selectedDate]) is hoisted to the caller; the expanded/collapsed
 * state is local UI state, since it does not affect anything outside the calendar.
 *
 * @param selectedDate The currently selected day (drives the visible week/month).
 * @param today Today's date, highlighted distinctly when not selected.
 * @param entryDates Dates that have at least one journal entry (rendered with a dot).
 * @param onDateSelected Called with the tapped day.
 * @param onTodayClick Called when the user taps the "today" shortcut.
 * @param modifier Modifier applied to the calendar container.
 */
@Composable
fun JournalCalendar(
    selectedDate: LocalDate,
    today: LocalDate,
    entryDates: Set<LocalDate>,
    onDateSelected: (LocalDate) -> Unit,
    onTodayClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var expanded by rememberSaveable { mutableStateOf(false) }
    val context = LocalContext.current

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(IremiaColors.BlueHeader, IremiaShapes.HeaderWash)
            .padding(horizontal = IremiaSpacing.ScreenGutter)
            .padding(top = IremiaSpacing.S5, bottom = IremiaSpacing.S2)
            .animateContentSize(),
    ) {
        // --- Month / year + "today" shortcut ---
        // NOTE: The month/year title toggles expand/collapse too. It is always at the
        // top and never covered by the scrollable month list, so it stays a reliable
        // close target even when the calendar is expanded.
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.clickable { expanded = !expanded },
            ) {
                Text(monthName(selectedDate.monthNumber), style = IremiaText.H1, color = IremiaColors.Ink)
                Text(selectedDate.year.toString(), style = IremiaText.H1, color = IremiaColors.Gray400)
                Icon(
                    imageVector = if (expanded) Icons.Filled.KeyboardArrowUp else Icons.Filled.KeyboardArrowDown,
                    contentDescription = null,
                    tint = IremiaColors.Gray500,
                )
            }
            Text(
                text = localized(SharedRes.strings.today).toString(context),
                style = IremiaText.Body,
                color = IremiaColors.Teal700,
                modifier = Modifier
                    .clickable { onTodayClick() }
                    .padding(IremiaSpacing.S2),
            )
        }

        Spacer(Modifier.height(IremiaSpacing.S4))

        if (expanded) {
            ExpandedMonths(selectedDate, today, entryDates, onDateSelected)
        } else {
            // Collapsed: a rolling week with today as the leftmost cell.
            val week = rollingWeek(today)
            WeekdayHeader(week.map { shortWeekdayLabel(it) })
            Spacer(Modifier.height(IremiaSpacing.S1))
            CalendarWeekRow(week, selectedDate, today, entryDates, onDateSelected)
        }

        ExpandHandle(expanded = expanded, onToggle = { expanded = !expanded })
    }
}

/** Vertically scrollable list of months, auto-scrolled to the selected month. */
@Composable
private fun ExpandedMonths(
    selectedDate: LocalDate,
    today: LocalDate,
    entryDates: Set<LocalDate>,
    onDateSelected: (LocalDate) -> Unit,
) {
    val months = remember(today) { monthsAround(today, MONTH_WINDOW, MONTH_WINDOW) }
    val listState = rememberLazyListState()

    // Jump to the selected month when the calendar is first expanded.
    LaunchedEffect(Unit) {
        val index = months.indexOfFirst {
            it.year == selectedDate.year && it.month == selectedDate.monthNumber
        }
        if (index >= 0) listState.scrollToItem(index)
    }

    LazyColumn(
        state = listState,
        modifier = Modifier
            .fillMaxWidth()
            .height(EXPANDED_HEIGHT),
        verticalArrangement = Arrangement.spacedBy(IremiaSpacing.S5),
    ) {
        items(months) { month ->
            MonthSection(month, selectedDate, today, entryDates, onDateSelected)
        }
    }
}

/** One labelled month block: "MÄRZ 2026" + weekday header + the month's day grid. */
@Composable
private fun MonthSection(
    month: YearMonth,
    selectedDate: LocalDate,
    today: LocalDate,
    entryDates: Set<LocalDate>,
    onDateSelected: (LocalDate) -> Unit,
) {
    Column(Modifier.fillMaxWidth()) {
        Text(
            text = "${monthName(month.month).uppercase()} ${month.year}",
            style = IremiaText.Eyebrow,
            color = IremiaColors.Teal700,
        )
        Spacer(Modifier.height(IremiaSpacing.S2))
        WeekdayHeader(weekdayLabels())
        Spacer(Modifier.height(IremiaSpacing.S1))
        monthGrid(month.year, month.month).chunked(7).forEach { week ->
            CalendarWeekRow(week, selectedDate, today, entryDates, onDateSelected)
        }
    }
}

/** Weekday labels row; the labels are supplied so collapsed and month views can differ. */
@Composable
private fun WeekdayHeader(labels: List<String>) {
    Row(Modifier.fillMaxWidth()) {
        labels.forEach { label ->
            Text(
                text = label,
                style = IremiaText.Caption,
                color = IremiaColors.Gray500,
                textAlign = TextAlign.Center,
                modifier = Modifier.weight(1f),
            )
        }
    }
}

/** The pull handle + chevron that toggles between the week and month views. */
@Composable
private fun ExpandHandle(expanded: Boolean, onToggle: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            // Min 44dp tall so the handle is a comfortable, reliable tap target.
            .heightIn(min = 44.dp)
            .clickable { onToggle() }
            .padding(top = IremiaSpacing.S1),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Box(
            modifier = Modifier
                .width(32.dp)
                .height(4.dp)
                .clip(IremiaShapes.Pill)
                .background(IremiaColors.Gray300),
        )
        Icon(
            imageVector = if (expanded) Icons.Filled.KeyboardArrowUp else Icons.Filled.KeyboardArrowDown,
            contentDescription = null,
            tint = IremiaColors.Gray500,
        )
    }
}

/** One Monday-first row of day cells; `null` entries render as empty padding cells. */
@Composable
private fun CalendarWeekRow(
    week: List<LocalDate?>,
    selectedDate: LocalDate,
    today: LocalDate,
    entryDates: Set<LocalDate>,
    onDateSelected: (LocalDate) -> Unit,
) {
    Row(Modifier.fillMaxWidth()) {
        week.forEach { date ->
            DayCell(
                date = date,
                selected = date == selectedDate,
                isToday = date == today,
                hasEntry = date != null && date in entryDates,
                onClick = onDateSelected,
                modifier = Modifier.weight(1f),
            )
        }
    }
}

/**
 * A single day in the calendar: the number in a circle (filled teal when selected,
 * teal text when it is today) with an optional entry dot underneath.
 */
@Composable
private fun DayCell(
    date: LocalDate?,
    selected: Boolean,
    isToday: Boolean,
    hasEntry: Boolean,
    onClick: (LocalDate) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.height(48.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        if (date == null) return@Column

        Box(
            modifier = Modifier
                .size(34.dp)
                .clip(CircleShape)
                .background(if (selected) IremiaColors.Teal700 else Color.Transparent)
                .clickable { onClick(date) },
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = date.dayOfMonth.toString(),
                style = IremiaText.Body,
                color = when {
                    selected -> IremiaColors.White
                    isToday -> IremiaColors.Teal700
                    else -> IremiaColors.Ink900
                },
            )
        }

        Spacer(Modifier.height(3.dp))

        Box(
            modifier = Modifier
                .size(5.dp)
                .clip(CircleShape)
                .background(
                    when {
                        !hasEntry -> Color.Transparent
                        selected -> IremiaColors.White
                        else -> IremiaColors.Teal500
                    }
                ),
        )
    }
}

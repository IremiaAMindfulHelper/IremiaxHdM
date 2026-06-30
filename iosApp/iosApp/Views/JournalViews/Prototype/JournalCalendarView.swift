import SwiftUI
import Shared

// =============================================================================
// Collapsible Journal calendar — 1:1 translation of JournalCalendar.kt (300 lines).
// =============================================================================

/// How many months before/after today the expanded calendar lets you scroll.
private let monthWindow = 12
/// Fixed viewport height of the expanded multi-month calendar.
private let expandedHeight: CGFloat = 360

/// Collapsible Journal calendar shown at the top of the Journal screen.
///
/// Collapsed: a rolling week with today as the leftmost cell.
/// Expanded: a vertically scrollable list of months.
struct JournalCalendarView: View {
    let selectedDate: Date
    let today: Date
    let entryDates: Set<DateComponents>
    let onDateSelected: (Date) -> Void
    let onTodayClick: () -> Void

    @State private var expanded = false

    var body: some View {
        let cal = Calendar(identifier: .iso8601)
        let selMonth = cal.component(.month, from: selectedDate)
        let selYear = cal.component(.year, from: selectedDate)

        VStack(spacing: 0) {
            // Month / year + "today" shortcut
            HStack {
                HStack(spacing: 4) {
                    Text(monthName(month: selMonth))
                        .font(IremiaText.h1)
                        .foregroundColor(IremiaColors.ink)
                    Text(String(selYear))
                        .font(IremiaText.h1)
                        .foregroundColor(IremiaColors.gray400)
                }
                Spacer()
                Button(action: onTodayClick) {
                    Text("Heute")
                        .font(IremiaText.body)
                        .foregroundColor(IremiaColors.teal700)
                }
                .buttonStyle(.plain)
            }

            Spacer().frame(height: IremiaSpacing.s4)

            if expanded {
                ExpandedMonthsView(
                    selectedDate: selectedDate,
                    today: today,
                    entryDates: entryDates,
                    onDateSelected: onDateSelected
                )
            } else {
                let week = rollingWeek(start: today)
                WeekdayHeaderView(labels: week.map { shortWeekdayLabel(date: $0) })
                Spacer().frame(height: IremiaSpacing.s1)
                CalendarWeekRow(
                    week: week.map { Optional($0) },
                    selectedDate: selectedDate,
                    today: today,
                    entryDates: entryDates,
                    onDateSelected: onDateSelected
                )
            }

            ExpandHandleView(expanded: expanded) {
                withAnimation(.easeInOut(duration: IremiaMotion.dur)) {
                    expanded.toggle()
                }
            }
        }
        .padding(.horizontal, IremiaSpacing.screenGutter)
        .padding(.top, IremiaSpacing.s5)
        .padding(.bottom, IremiaSpacing.s2)
        .background(
            IremiaShapes.headerWash()
                .fill(IremiaColors.blueHeader)
        )
        .animation(.easeInOut(duration: IremiaMotion.dur), value: expanded)
    }
}

// MARK: - Expanded Months

/// Vertically scrollable list of months, auto-scrolled to the selected month.
private struct ExpandedMonthsView: View {
    let selectedDate: Date
    let today: Date
    let entryDates: Set<DateComponents>
    let onDateSelected: (Date) -> Void

    var body: some View {
        let months = monthsAround(date: today, monthsBefore: monthWindow, monthsAfter: monthWindow)
        let cal = Calendar(identifier: .iso8601)
        let selYear = cal.component(.year, from: selectedDate)
        let selMonth = cal.component(.month, from: selectedDate)
        let targetId = selYear * 100 + selMonth

        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: IremiaSpacing.s5) {
                    ForEach(months) { month in
                        MonthSectionView(
                            month: month,
                            selectedDate: selectedDate,
                            today: today,
                            entryDates: entryDates,
                            onDateSelected: onDateSelected
                        )
                        .id(month.id)
                    }
                }
            }
            .frame(height: expandedHeight)
            .onAppear {
                proxy.scrollTo(targetId, anchor: .top)
            }
        }
    }
}

// MARK: - Month Section

/// One labelled month block: "MÄRZ 2026" + weekday header + the month's day grid.
private struct MonthSectionView: View {
    let month: YearMonth
    let selectedDate: Date
    let today: Date
    let entryDates: Set<DateComponents>
    let onDateSelected: (Date) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(monthName(month: month.month).uppercased()) \(String(month.year))")
                .font(IremiaText.eyebrow)
                .foregroundColor(IremiaColors.teal700)
                .tracking(0.06 * 12)

            Spacer().frame(height: IremiaSpacing.s2)
            WeekdayHeaderView(labels: weekdayLabels())
            Spacer().frame(height: IremiaSpacing.s1)

            let grid = monthGrid(year: month.year, month: month.month)
            let weeks = grid.chunked(into: 7)
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                CalendarWeekRow(
                    week: week,
                    selectedDate: selectedDate,
                    today: today,
                    entryDates: entryDates,
                    onDateSelected: onDateSelected
                )
            }
        }
    }
}

// MARK: - Weekday Header

/// Weekday labels row.
private struct WeekdayHeaderView: View {
    let labels: [String]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray500)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Expand Handle

/// The pull handle + chevron that toggles between the week and month views.
private struct ExpandHandleView: View {
    let expanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 0) {
                Capsule()
                    .fill(IremiaColors.gray300)
                    .frame(width: 32, height: 4)
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(IremiaColors.gray500)
                    .font(.system(size: 16))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, IremiaSpacing.s1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar Week Row

/// One Monday-first row of day cells; nil entries render as empty.
private struct CalendarWeekRow: View {
    let week: [Date?]
    let selectedDate: Date
    let today: Date
    let entryDates: Set<DateComponents>
    let onDateSelected: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                DayCellView(
                    date: date,
                    selected: date != nil && isSameDay(date!, selectedDate),
                    isToday: date != nil && isSameDay(date!, today),
                    hasEntry: hasEntry(date),
                    onClick: onDateSelected
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func hasEntry(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let cal = Calendar(identifier: .iso8601)
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        return entryDates.contains(comps)
    }
}

// MARK: - Day Cell

/// A single day: number in a circle (teal when selected) with an optional entry dot.
private struct DayCellView: View {
    let date: Date?
    let selected: Bool
    let isToday: Bool
    let hasEntry: Bool
    let onClick: (Date) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let date = date {
                Button {
                    onClick(date)
                } label: {
                    Text("\(dayOfMonth(date))")
                        .font(IremiaText.body)
                        .foregroundColor(textColor)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(selected ? IremiaColors.teal700 : Color.clear)
                        )
                }
                .buttonStyle(.plain)

                Spacer().frame(height: 3)

                Circle()
                    .fill(dotColor)
                    .frame(width: 5, height: 5)
            } else {
                Spacer().frame(height: 34 + 3 + 5)
            }
        }
        .frame(height: 48)
    }

    private var textColor: SwiftUI.Color {
        if selected { return IremiaColors.white }
        if isToday { return IremiaColors.teal700 }
        return IremiaColors.ink900
    }

    private var dotColor: SwiftUI.Color {
        if !hasEntry { return Color.clear }
        if selected { return IremiaColors.white }
        return IremiaColors.teal500
    }
}

// MARK: - Array Helper

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

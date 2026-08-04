import Foundation

// =============================================================================
// Pure date helpers for the Journal calendar.
// 1:1 translation of CalendarMath.kt.
// Weeks are Monday-first, matching the design and the German locale.
// =============================================================================

/// Number of days in a given month (1-based) of a given year.
func daysInMonth(year: Int, month: Int) -> Int {
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    let cal = Calendar(identifier: .iso8601)
    guard let date = cal.date(from: comps) else { return 30 }
    return cal.range(of: .day, in: .month, for: date)?.count ?? 30
}

/// The seven dates of a rolling week starting at `start` (inclusive).
/// Used for the collapsed strip so "today" stays the leftmost cell.
func rollingWeek(start: Date) -> [Date] {
    let cal = Calendar(identifier: .iso8601)
    return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
}

/// Localized short weekday label for a date, e.g. "Mon".
func shortWeekdayLabel(date: Date) -> String {
    let fmt = DateFormatter()
    fmt.locale = Locale.autoupdatingCurrent
    fmt.dateFormat = "E"
    let label = fmt.string(from: date)
    // Trim trailing dot some locales add (e.g. German "Mo.")
    return label.hasSuffix(".") ? String(label.dropLast()) : label
}

/// A specific month of a specific year.
struct YearMonth: Hashable, Identifiable {
    let year: Int
    let month: Int
    var id: Int { year * 100 + month }
}

/// Monday-first calendar grid for a month. Leading/trailing nil cells
/// so the 1st lands under its weekday column.
func monthGrid(year: Int, month: Int) -> [Date?] {
    let cal = Calendar(identifier: .iso8601)
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = 1
    guard let firstDay = cal.date(from: comps) else { return [] }

    // ISO weekday: Monday = 1, Sunday = 7
    let weekday = cal.component(.weekday, from: firstDay)
    // Convert to Monday-first index (0 = Monday)
    let mondayBased = (weekday + 5) % 7
    let days = daysInMonth(year: year, month: month)
    let cellCount = ((mondayBased + days + 6) / 7) * 7

    return (0..<cellCount).map { index in
        let dayNumber = index - mondayBased + 1
        if dayNumber >= 1 && dayNumber <= days {
            var dc = DateComponents()
            dc.year = year
            dc.month = month
            dc.day = dayNumber
            return cal.date(from: dc)
        }
        return nil
    }
}

/// A window of consecutive months centered on a date.
func monthsAround(date: Date, monthsBefore: Int, monthsAfter: Int) -> [YearMonth] {
    let cal = Calendar(identifier: .iso8601)
    let year = cal.component(.year, from: date)
    let month = cal.component(.month, from: date)

    return (-monthsBefore...monthsAfter).map { offset in
        var totalMonth = (year * 12 + month - 1) + offset
        let y = totalMonth / 12
        let m = totalMonth % 12 + 1
        return YearMonth(year: y, month: m)
    }
}

/// Localized Monday → Sunday short weekday labels, e.g. ["Mon", …, "Sun"].
func weekdayLabels() -> [String] {
    let cal = Calendar(identifier: .iso8601)
    let fmt = DateFormatter()
    fmt.locale = Locale.autoupdatingCurrent
    // Build dates for a known Monday→Sunday week
    var comps = DateComponents()
    comps.year = 2024
    comps.month = 1
    comps.day = 1 // Monday
    let monday = cal.date(from: comps)!

    return (0..<7).map { offset in
        let day = cal.date(byAdding: .day, value: offset, to: monday)!
        return shortWeekdayLabel(date: day)
    }
}

/// Localized full month name for a 1-based month, e.g. "April".
func monthName(month: Int) -> String {
    let fmt = DateFormatter()
    fmt.locale = Locale.autoupdatingCurrent
    return fmt.monthSymbols[month - 1]
}

// MARK: - Date comparison helpers

/// Extract day-of-month from a Date.
func dayOfMonth(_ date: Date) -> Int {
    Calendar(identifier: .iso8601).component(.day, from: date)
}

/// Check if two dates are the same calendar day.
func isSameDay(_ a: Date, _ b: Date) -> Bool {
    Calendar(identifier: .iso8601).isDate(a, inSameDayAs: b)
}

/// Get today's date at start of day.
func startOfToday() -> Date {
    Calendar(identifier: .iso8601).startOfDay(for: Date())
}

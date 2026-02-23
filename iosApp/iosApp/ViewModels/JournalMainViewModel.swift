import Foundation

final class JournalMainViewModel: ObservableObject {

    @Published var rootMode: JournalRootMode
    @Published private(set) var currentYear: Int
    @Published private(set) var currentMonth: Int
    @Published private(set) var cells: [UnifiedCell] = []

    init(rootMode: JournalRootMode = .emotions, year: Int = 2026, month: Int = 1) {
        self.rootMode = rootMode
        self.currentYear = year
        self.currentMonth = month
        rebuildCells()
    }

    enum Action {
        case none
        case createEntry(Date)
        case openMoodPopup(Date, MoodMark)
        case openPanicPopup(Date)
    }

    // Wird vom Toggle genutzt
    func setIsPanic(_ isOn: Bool) {
        rootMode = isOn ? .panicAttacks : .emotions
        rebuildCells()
    }

    func shiftMonth(by delta: Int) {
        let base = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let newDate = calendar.date(byAdding: .month, value: delta, to: base) ?? base
        let comps = calendar.dateComponents([.year, .month], from: newDate)
        currentYear = comps.year ?? currentYear
        currentMonth = comps.month ?? currentMonth
        rebuildCells()
    }

    var monthTitle: String {
        let date = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    func handleTap(on cell: UnifiedCell) -> Action {
        // Monat wechseln, wenn Zelle aus Vor-/Folgemontag ist
        if !cell.isInDisplayedMonth, let offset = cell.monthOffset {
            shiftMonth(by: offset)
        }

        guard cell.isTappable else { return .none }
        guard let date = dateForCell(cell) else { return .none }

        switch rootMode {
        case .emotions:
            switch cell.style {
            case .mood(.plus):
                return .createEntry(date)
            case .mood(.gradientA):
                return .openMoodPopup(date, .moodGradientA)
            case .mood(.gradientB):
                return .openMoodPopup(date, .moodGradientB)
            default:
                return .none
            }

        case .panicAttacks:
            switch cell.style {
            case .panic(.plus), .panic(.filled):
                return .createEntry(date)
            case .panic(.brokenHeart):
                return .openPanicPopup(date)
            default:
                return .none
            }
        }
    }

    // MARK: - Calendar internals

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "de_DE")
        cal.firstWeekday = 2
        return cal
    }

    private var isDemoMonth: Bool { currentYear == 2026 && currentMonth == 1 }
    private var todayStart: Date { calendar.startOfDay(for: Date()) }

    /// Erlaubt Interaktionen nur für Heute und Zukunft (Vergangenheit ist gesperrt).
    private func isTodayOrFuture(year: Int, month: Int, day: Int) -> Bool {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { return false }
        return calendar.startOfDay(for: date) >= todayStart
    }

    private func dateForCell(_ cell: UnifiedCell) -> Date? {
        let y = cell.effectiveYear ?? currentYear
        let m = cell.effectiveMonth ?? currentMonth
        return calendar.date(from: DateComponents(year: y, month: m, day: cell.day))
    }

    private func styleForPlus() -> CellStyle {
        switch rootMode {
        case .emotions: return .mood(.plus)
        case .panicAttacks: return .panic(.plus)
        }
    }

    private func rebuildCells() {
        cells = buildCalendarCells()
    }

    private func buildCalendarCells() -> [UnifiedCell] {
        let cal = calendar

        let firstOfMonth = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        let weekday = cal.component(.weekday, from: firstOfMonth)
        let leading = (weekday - cal.firstWeekday + 7) % 7

        let prevMonthDate = cal.date(byAdding: .month, value: -1, to: firstOfMonth)!
        let daysInPrevMonth = cal.range(of: .day, in: .month, for: prevMonthDate)!.count
        let nextMonthDate = cal.date(byAdding: .month, value: 1, to: firstOfMonth)!

        var result: [UnifiedCell] = []

        // Leading (Vormonat)
        if leading > 0 {
            let startDay = daysInPrevMonth - leading + 1
            let prevYM = cal.dateComponents([.year, .month], from: prevMonthDate)

            for d in startDay...daysInPrevMonth {
                let y = prevYM.year ?? currentYear
                let m = prevYM.month ?? currentMonth
                let allowed = isTodayOrFuture(year: y, month: m, day: d)

                result.append(
                    UnifiedCell(
                        day: d,
                        isInDisplayedMonth: false,
                        style: allowed ? styleForPlus() : .none,
                        monthOffset: -1,
                        effectiveYear: y,
                        effectiveMonth: m,
                        isTappable: allowed
                    )
                )
            }
        }

        // Current month
        for d in 1...daysInMonth {
            let allowed = isTodayOrFuture(year: currentYear, month: currentMonth, day: d)

            let style: CellStyle
            if !allowed {
                style = .none
            } else if isDemoMonth {
                switch rootMode {
                case .emotions:
                    if d == 6 { style = .mood(.gradientA) }
                    else if d == 7 { style = .mood(.gradientB) }
                    else { style = .mood(.plus) }

                case .panicAttacks:
                    if d == 6 || d == 7 { style = .panic(.brokenHeart) }
                    else if [16, 17, 18].contains(d) { style = .panic(.filled) }
                    else { style = .panic(.plus) }
                }
            } else {
                style = styleForPlus()
            }

            result.append(
                UnifiedCell(
                    day: d,
                    isInDisplayedMonth: true,
                    style: style,
                    monthOffset: 0,
                    effectiveYear: currentYear,
                    effectiveMonth: currentMonth,
                    isTappable: allowed
                )
            )
        }

        // Trailing (Folgemontag) bis 42
        let nextYM = cal.dateComponents([.year, .month], from: nextMonthDate)
        var nextDay = 1

        while result.count < 42 {
            let y = nextYM.year ?? currentYear
            let m = nextYM.month ?? currentMonth
            let allowed = isTodayOrFuture(year: y, month: m, day: nextDay)

            result.append(
                UnifiedCell(
                    day: nextDay,
                    isInDisplayedMonth: false,
                    style: allowed ? styleForPlus() : .none,
                    monthOffset: 1,
                    effectiveYear: y,
                    effectiveMonth: m,
                    isTappable: allowed
                )
            )
            nextDay += 1
        }

        return result
    }
}

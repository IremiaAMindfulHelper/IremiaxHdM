import Foundation

// Diese Klasse verwaltet den Zustand der Journal-Hauptansicht.
// Sie hält den aktuell angezeigten Monat und baut daraus eine feste 6x7-Kalenderansicht (42 Zellen) auf.
// Je nach Modus (Stimmung oder Panikattacken) bekommen die Zellen unterschiedliche Marker-Stile und Tap-Aktionen.
// Außerdem bietet sie Methoden, um Marker-Daten zu setzen und den Monat zu wechseln.

final class JournalMainViewModel: ObservableObject {

    // Steuert, welcher Modus in der Hauptansicht aktiv ist.
    @Published var rootMode: JournalRootMode

    // Aktuell angezeigtes Jahr und Monat.
    @Published private(set) var currentYear: Int
    @Published private(set) var currentMonth: Int

    // Fertig aufgebaute Kalenderzellen für die UI (immer 42 Einträge).
    @Published private(set) var cells: [UnifiedCell] = []

    // Gespeicherte Marker-Daten pro Datum.
    private var moodByDate: [Date: MoodMark] = [:]
    private var panicCountByDate: [Date: Int] = [:]

    // Initialisiert das ViewModel. Wenn Jahr/Monat nicht übergeben werden,
    // wird der aktuelle Monat verwendet.
    init(rootMode: JournalRootMode = .emotions, year: Int? = nil, month: Int? = nil) {
        self.rootMode = rootMode

        let cal = Self.makeCalendar()
        let now = Date()
        let comps = cal.dateComponents([.year, .month], from: now)

        self.currentYear = year ?? (comps.year ?? 2026)
        self.currentMonth = month ?? (comps.month ?? 1)

        seedDemoMarksFor23And24()
        rebuildCells()
    }

    // Beschreibt, was nach einem Tap auf eine Kalenderzelle passieren soll.
    enum Action {
        case none
        case createEntry(Date)
        case openMoodPopup(Date, MoodMark)
        case openPanicPopup(Date)
    }

    // Schaltet zwischen Panikattacken- und Stimmungsmodus um und baut die Zellen neu auf.
    func setIsPanic(_ isOn: Bool) {
        rootMode = isOn ? .panicAttacks : .emotions
        rebuildCells()
    }

    // Wechselt den Monat um delta Monate (z. B. -1 für vorheriger Monat, +1 für nächster Monat).
    func shiftMonth(by delta: Int) {
        let base = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let newDate = calendar.date(byAdding: .month, value: delta, to: base) ?? base
        let comps = calendar.dateComponents([.year, .month], from: newDate)

        currentYear = comps.year ?? currentYear
        currentMonth = comps.month ?? currentMonth

        rebuildCells()
    }

    // Liefert den Titel des aktuell angezeigten Monats im deutschen Format.
    var monthTitle: String {
        let date = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    // Reagiert auf Taps in der UI und gibt eine Aktion zurück, die die View ausführen kann.
    func handleTap(on cell: UnifiedCell) -> Action {
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

    // Speichert einen Stimmungsmarker für ein Datum und aktualisiert die Zellen.
    func setMoodMark(for date: Date, mark: MoodMark) {
        moodByDate[normalized(date)] = mark
        rebuildCells()
    }

    // Speichert die Anzahl der Panikattacken für ein Datum und aktualisiert die Zellen.
    func setPanicCount(for date: Date, count: Int) {
        panicCountByDate[normalized(date)] = count
        rebuildCells()
    }

    // Erzeugt einen Kalender mit deutscher Locale und Montag als Wochenstart.
    private static func makeCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "de_DE")
        cal.firstWeekday = 2
        return cal
    }

    // Liefert immer einen Kalender mit den gewünschten Einstellungen.
    private var calendar: Calendar { Self.makeCalendar() }

    // Start des heutigen Tages, um Vergleiche unabhängig von Uhrzeiten zu machen.
    private var todayStart: Date { calendar.startOfDay(for: Date()) }

    // Prüft, ob ein Datum heute oder in der Zukunft liegt.
    private func isTodayOrFuture(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) >= todayStart
    }

    // Normalisiert ein Datum auf Tagesstart, damit es als Dictionary-Key stabil ist.
    private func normalized(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // Rechnet die Zelle auf ein konkretes Datum um (inklusive Zellen aus Vor- und Folgemonat).
    private func dateForCell(_ cell: UnifiedCell) -> Date? {
        let y = cell.effectiveYear ?? currentYear
        let m = cell.effectiveMonth ?? currentMonth
        return calendar.date(from: DateComponents(year: y, month: m, day: cell.day))
    }

    // Baut die Kalenderzellen neu auf und schreibt sie in die Published-Property.
    private func rebuildCells() {
        cells = buildCalendarCells()
    }

    // Erstellt die 6x7 Kalenderansicht (42 Zellen) inklusive Leading/Trailing-Tage.
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

        // Baut die Zellen für den Vormonat, die am Anfang des Rasters sichtbar sind.
        if leading > 0 {
            let startDay = daysInPrevMonth - leading + 1
            let prevYM = cal.dateComponents([.year, .month], from: prevMonthDate)

            for d in startDay...daysInPrevMonth {
                let y = prevYM.year ?? currentYear
                let m = prevYM.month ?? currentMonth
                let date = cal.date(from: DateComponents(year: y, month: m, day: d))!
                result.append(
                    makeCell(
                        day: d,
                        date: date,
                        isInDisplayedMonth: false,
                        monthOffset: -1,
                        effectiveYear: y,
                        effectiveMonth: m
                    )
                )
            }
        }

        // Baut alle Zellen des aktuell angezeigten Monats.
        for d in 1...daysInMonth {
            let date = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: d))!
            result.append(
                makeCell(
                    day: d,
                    date: date,
                    isInDisplayedMonth: true,
                    monthOffset: 0,
                    effectiveYear: currentYear,
                    effectiveMonth: currentMonth
                )
            )
        }

        // Füllt mit Zellen aus dem Folgemonat auf, bis genau 42 Zellen erreicht sind.
        let nextYM = cal.dateComponents([.year, .month], from: nextMonthDate)
        var nextDay = 1

        while result.count < 42 {
            let y = nextYM.year ?? currentYear
            let m = nextYM.month ?? currentMonth
            let date = cal.date(from: DateComponents(year: y, month: m, day: nextDay))!
            result.append(
                makeCell(
                    day: nextDay,
                    date: date,
                    isInDisplayedMonth: false,
                    monthOffset: 1,
                    effectiveYear: y,
                    effectiveMonth: m
                )
            )
            nextDay += 1
        }

        return result
    }

    // Erstellt eine einzelne Zelle und entscheidet anhand von Modus, Datum und gespeicherten Markern über den Stil.
    private func makeCell(
        day: Int,
        date: Date,
        isInDisplayedMonth: Bool,
        monthOffset: Int,
        effectiveYear: Int,
        effectiveMonth: Int
    ) -> UnifiedCell {

        let key = normalized(date)

        let storedMood = moodByDate[key]
        let storedPanic = (panicCountByDate[key] ?? 0)

        let hasMoodMarker = (storedMood != nil)
        let hasPanicMarker = (storedPanic > 0)

        let canCreateNew = isTodayOrFuture(key)

        let style: CellStyle
        switch rootMode {
        case .emotions:
            if let mood = storedMood {
                style = (mood == .moodGradientA) ? .mood(.gradientA) : .mood(.gradientB)
            } else if canCreateNew {
                style = .mood(.plus)
            } else {
                style = .none
            }

        case .panicAttacks:
            if hasPanicMarker {
                style = .panic(.brokenHeart)
            } else if canCreateNew {
                style = .panic(.plus)
            } else {
                style = .none
            }
        }

        let isTappable = canCreateNew || hasMoodMarker || hasPanicMarker

        return UnifiedCell(
            day: day,
            isInDisplayedMonth: isInDisplayedMonth,
            style: style,
            monthOffset: monthOffset,
            effectiveYear: effectiveYear,
            effectiveMonth: effectiveMonth,
            isTappable: isTappable
        )
    }

    // Legt Demo-Daten für den 23. und 24. im aktuell angezeigten Monat an.
    private func seedDemoMarksFor23And24() {
        if let d23 = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 23)) {
            moodByDate[normalized(d23)] = .moodGradientA
        }
        if let d24 = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 24)) {
            moodByDate[normalized(d24)] = .moodGradientB
        }

        if let d23 = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 23)) {
            panicCountByDate[normalized(d23)] = 1
        }
        if let d24 = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 24)) {
            panicCountByDate[normalized(d24)] = 2
        }
    }
}

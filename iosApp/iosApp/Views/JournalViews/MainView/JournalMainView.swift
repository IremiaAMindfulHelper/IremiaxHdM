import SwiftUI

/// Eine einzige Journal-Seite für Stimmung + Panik.
/// - Der Toggle schaltet nur den Mode (rootMode), aber es bleibt dieselbe View.
/// - Der Kalender bleibt gleich, nur Markierungen + Tap-Verhalten ändern sich pro Mode.
struct JournalMainView: View {
    @Binding var rootMode: JournalRootMode

    // Stimmung: Popup für einen bestehenden Tag (Datum + Mark).
    let onPlusButtonTappedMood: (_ date: Date, _ mark: MoodMark) -> Void

    // Panik: Popup für einen Tag mit Panik-Markierung.
    let onPlusButtonTappedPanic: (_ date: Date) -> Void

    // Erstellung/Bearbeitung eines Eintrags für ein Datum.
    let onCreateEntry: (_ date: Date) -> Void

    @State private var currentYear: Int = 2026
    @State private var currentMonth: Int = 1

    // Toggle-Binding (Stimmung <-> Panik) über rootMode.
    private var isPanicBinding: Binding<Bool> {
        Binding(
            get: { rootMode == .panicAttacks },
            set: { isOn in
                withAnimation { rootMode = isOn ? .panicAttacks : .emotions }
            }
        )
    }

    private let titleTopInset: CGFloat = 34
    private let gridCircleSize: CGFloat = 38
    private let gridPlusSize: CGFloat = 16
    private let gridSpacing: CGFloat = 14
    private let gridColumnSpacing: CGFloat = 12
    private let dayFontSize: CGFloat = 14

    var body: some View {
        VStack(spacing: 0) {
            header

            modeToggleRow

            monthSwitcher

            weekdayHeader

            calendarGrid

            Spacer(minLength: 0)
        }
        .background(Color.white)
    }

    // MARK: - UI Blocks

    private var header: some View {
        VStack(spacing: 0) {
            Text("Journal")
                .font(.system(size: 40, weight: .regular, design: .rounded))
                .padding(.top, 18)
                .padding(.bottom, 14)
            Divider()
        }
        .safeAreaPadding(.top, titleTopInset)
    }

    private var modeToggleRow: some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.black.opacity(isPanicBinding.wrappedValue ? 0.25 : 0.75))
                Text("Stimmung")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.black.opacity(isPanicBinding.wrappedValue ? 0.45 : 0.85))
            }

            Toggle("", isOn: isPanicBinding)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(.black.opacity(0.8))
                .scaleEffect(0.95)

            VStack(spacing: 6) {
                BrokenHeartIcon(size: 26, isActive: isPanicBinding.wrappedValue)
                Text("Panik")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.black.opacity(isPanicBinding.wrappedValue ? 0.85 : 0.45))
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    private var monthSwitcher: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { shiftMonth(by: -1) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.7))
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text(monthTitle)
                .font(.system(size: 26, weight: .regular, design: .rounded))
                .foregroundStyle(.black.opacity(0.9))

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { shiftMonth(by: 1) }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.7))
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
    }

    private var weekdayHeader: some View {
        let labels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
        return HStack(spacing: 0) {
            ForEach(labels, id: \.self) { d in
                Text(d)
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(.black.opacity(0.85))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.12))
        )
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    private var calendarGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: gridColumnSpacing), count: 7)
        let cells = calendarCells

        return LazyVGrid(columns: cols, spacing: gridSpacing) {
            ForEach(cells) { cell in
                UnifiedDayCell(
                    day: cell.day,
                    style: cell.style,
                    circleSize: gridCircleSize,
                    plusSize: gridPlusSize,
                    dayFontSize: dayFontSize,
                    onTap: { handleTap(on: cell) }
                )
                .opacity(cell.isInDisplayedMonth ? 1.0 : 0.55)
                .allowsHitTesting(cell.isTappable)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    // MARK: - Tap Handling (je nach Mode anderes Verhalten)

    private func handleTap(on cell: UnifiedCell) {
        // Tap auf Vormonat-/Folgemontag-Zellen kann den Monat wechseln.
        if !cell.isInDisplayedMonth, let offset = cell.monthOffset {
            withAnimation(.easeInOut(duration: 0.2)) { shiftMonth(by: offset) }
        }

        guard cell.isTappable else { return }
        guard let date = dateForCell(cell) else { return }

        switch rootMode {
        case .emotions:
            // Stimmung: plus -> neuer Eintrag, moodGradient -> Popup
            switch cell.style {
            case .mood(.plus):
                onCreateEntry(date)
            case .mood(.gradientA):
                onPlusButtonTappedMood(date, .moodGradientA)
            case .mood(.gradientB):
                onPlusButtonTappedMood(date, .moodGradientB)
            case .panic:
                // kommt in emotions nicht vor, aber sicherheitshalber
                onCreateEntry(date)
            case .none:
                break
            }

        case .panicAttacks:
            // Panik: plus/filled -> Eintrag öffnen, brokenHeart -> Popup
            switch cell.style {
            case .panic(.plus), .panic(.filled):
                onCreateEntry(date)
            case .panic(.brokenHeart):
                onPlusButtonTappedPanic(date)
            case .mood:
                // kommt in panic nicht vor, aber sicherheitshalber
                onCreateEntry(date)
            case .none:
                break
            }
        }
    }

    // MARK: - Calendar Helpers

    private func dateForCell(_ cell: UnifiedCell) -> Date? {
        let y = cell.effectiveYear ?? currentYear
        let m = cell.effectiveMonth ?? currentMonth
        return calendar.date(from: DateComponents(year: y, month: m, day: cell.day))
    }

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "de_DE")
        cal.firstWeekday = 2 // Montag
        return cal
    }

    private var monthTitle: String {
        let date = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    private var isDemoMonth: Bool { currentYear == 2026 && currentMonth == 1 }
    private var todayStart: Date { calendar.startOfDay(for: Date()) }

    private func isPastOrToday(year: Int, month: Int, day: Int) -> Bool {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { return false }
        return calendar.startOfDay(for: date) <= todayStart
    }

    /// Erzeugt 42 Zellen und wählt die Markierungen abhängig von rootMode.
    private var calendarCells: [UnifiedCell] {
        let cal = calendar

        let firstOfMonth = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        let weekday = cal.component(.weekday, from: firstOfMonth)
        let leading = (weekday - cal.firstWeekday + 7) % 7

        let prevMonthDate = cal.date(byAdding: .month, value: -1, to: firstOfMonth)!
        let daysInPrevMonth = cal.range(of: .day, in: .month, for: prevMonthDate)!.count
        let nextMonthDate = cal.date(byAdding: .month, value: 1, to: firstOfMonth)!

        var cells: [UnifiedCell] = []

        // Leading (Vormonat)
        if leading > 0 {
            let startDay = daysInPrevMonth - leading + 1
            let prevYM = cal.dateComponents([.year, .month], from: prevMonthDate)

            for d in startDay...daysInPrevMonth {
                let y = prevYM.year ?? currentYear
                let m = prevYM.month ?? currentMonth
                let allowed = isPastOrToday(year: y, month: m, day: d)

                cells.append(
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

        // Aktueller Monat
        for d in 1...daysInMonth {
            let allowed = isPastOrToday(year: currentYear, month: currentMonth, day: d)

            let style: CellStyle
            if !allowed {
                style = .none
            } else if isDemoMonth {
                // Demo-Design: in emotions zwei Gradient-Tage, in panic zwei BrokenHeart-Tage + filled-Tage
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
                // Normal: nur plus (je nach Mode in mood/panic)
                style = styleForPlus()
            }

            cells.append(
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

        while cells.count < 42 {
            let y = nextYM.year ?? currentYear
            let m = nextYM.month ?? currentMonth
            let allowed = isPastOrToday(year: y, month: m, day: nextDay)

            cells.append(
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

        return cells
    }

    /// Plus-Style je nach aktuellem Mode.
    private func styleForPlus() -> CellStyle {
        switch rootMode {
        case .emotions: return .mood(.plus)
        case .panicAttacks: return .panic(.plus)
        }
    }

    private func shiftMonth(by delta: Int) {
        let base = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let newDate = calendar.date(byAdding: .month, value: delta, to: base) ?? base
        let comps = calendar.dateComponents([.year, .month], from: newDate)
        currentYear = comps.year ?? currentYear
        currentMonth = comps.month ?? currentMonth
    }
}

// MARK: - Types

/// Mood-Marks (damit dein existierender Mood-Popup Callback weiter passt)
enum MoodMark: Equatable {
    case moodGradientA
    case moodGradientB
}

/// Unified Zell-Style für beide Modi
private enum CellStyle: Equatable {
    case mood(MoodCellStyle)
    case panic(PanicCellStyle)
    case none
}

private enum MoodCellStyle: Equatable {
    case plus
    case gradientA
    case gradientB
}

private enum PanicCellStyle: Equatable {
    case plus
    case filled
    case brokenHeart
}

private struct UnifiedCell: Identifiable {
    let id = UUID()
    let day: Int
    let isInDisplayedMonth: Bool
    let style: CellStyle
    let monthOffset: Int?
    let effectiveYear: Int?
    let effectiveMonth: Int?
    let isTappable: Bool
}

// MARK: - Cell View

private struct UnifiedDayCell: View {
    let day: Int
    let style: CellStyle

    let circleSize: CGFloat
    let plusSize: CGFloat
    let dayFontSize: CGFloat
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(circleFill)
                    .frame(width: circleSize, height: circleSize)

                // Plus in Mood oder Panic (plus/filled)
                if showsPlus {
                    Image(systemName: "plus")
                        .font(.system(size: plusSize, weight: .bold))
                        .foregroundStyle(.black.opacity(0.8))
                }

                // BrokenHeart nur im Panic-Modus
                if case .panic(.brokenHeart) = style {
                    BrokenHeartIcon(size: 22, isActive: true)
                }
            }
            .onTapGesture { onTap() }

            Text("\(day)")
                .font(.system(size: dayFontSize, design: .rounded))
                .foregroundStyle(.black.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
    }

    private var showsPlus: Bool {
        switch style {
        case .mood(.plus):
            return true
        case .panic(.plus), .panic(.filled):
            return true
        default:
            return false
        }
    }

    private var circleFill: AnyShapeStyle {
        switch style {
        case .mood(.plus), .panic(.plus), .panic(.filled):
            return AnyShapeStyle(Color.black.opacity(0.25))

        case .mood(.gradientA):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.red.opacity(0.9), Color.blue.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

        case .mood(.gradientB):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.green.opacity(0.9), Color.blue.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

        case .panic(.brokenHeart), .none:
            return AnyShapeStyle(Color.black.opacity(0.06))
        }
    }
}

// MARK: - Icon

private struct BrokenHeartIcon: View {
    let size: CGFloat
    let isActive: Bool

    var body: some View {
        ZStack {
            Image(systemName: "heart")
                .font(.system(size: size))
                .foregroundStyle(.black.opacity(isActive ? 0.85 : 0.35))

            Image(systemName: "bolt.fill")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(.black.opacity(isActive ? 0.85 : 0.35))
        }
    }
}

// MARK: - Preview

struct JournalMainView_Previews: PreviewProvider {
    static var previews: some View {
        JournalMainView(
            rootMode: .constant(.emotions),
            onPlusButtonTappedMood: { _, _ in },
            onPlusButtonTappedPanic: { _ in },
            onCreateEntry: { _ in }
        )
    }
}

import SwiftUI

struct JournalMainViewPanicAttacks: View {
    @Binding var rootMode: JournalRootMode

    // Öffnet das Popup für einen Tag mit Panik-Markierung.
    let onPlusButtonTapped: (_ date: Date) -> Void

    // Öffnet die Erstellung/Bearbeitung eines Eintrags für ein Datum.
    let onCreateEntry: (_ date: Date) -> Void

    @State private var currentYear: Int = 2026
    @State private var currentMonth: Int = 1

    // Bindet den Toggle an den Root-Mode (Stimmung <-> Panik).
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
            VStack(spacing: 0) {
                Text("Journal")
                    .font(.system(size: 40, weight: .regular, design: .rounded))
                    .padding(.top, 18)
                    .padding(.bottom, 14)
                Divider()
            }
            .safeAreaPadding(.top, titleTopInset)

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

            let labels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
            HStack(spacing: 0) {
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

            let cols = Array(repeating: GridItem(.flexible(), spacing: gridColumnSpacing), count: 7)
            let cells = calendarCells

            LazyVGrid(columns: cols, spacing: gridSpacing) {
                ForEach(cells) { cell in
                    PanicDayCell(
                        day: cell.day,
                        mark: cell.mark,
                        isInDisplayedMonth: cell.isInDisplayedMonth,
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

            Spacer(minLength: 0)
        }
        .background(Color.white)
    }

    // Reagiert auf Tap: Monat wechseln, Eintrag öffnen oder Popup öffnen.
    private func handleTap(on cell: PanicCell) {
        if !cell.isInDisplayedMonth, let offset = cell.monthOffset {
            withAnimation(.easeInOut(duration: 0.2)) { shiftMonth(by: offset) }
        }

        guard cell.isTappable else { return }
        guard let date = dateForCell(cell) else { return }

        if cell.mark == .plus || cell.mark == .filled {
            onCreateEntry(date)
            return
        }

        if cell.mark == .brokenHeart {
            onPlusButtonTapped(date)
        }
    }

    // Berechnet das Datum für eine Zelle anhand ihres effektiven Jahres/Monats.
    private func dateForCell(_ cell: PanicCell) -> Date? {
        let y = cell.effectiveYear ?? currentYear
        let m = cell.effectiveMonth ?? currentMonth
        return calendar.date(from: DateComponents(year: y, month: m, day: cell.day))
    }

    // Konfiguriert den Kalender für deutsche Locale und Wochenstart Montag.
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "de_DE")
        cal.firstWeekday = 2
        return cal
    }

    // Baut den Monats-Titel aus aktuellem Jahr/Monat.
    private var monthTitle: String {
        let date = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    private var isDemoMonth: Bool { currentYear == 2026 && currentMonth == 1 }
    private var todayStart: Date { calendar.startOfDay(for: Date()) }

    // Erlaubt Interaktionen nur für Tage bis einschließlich heute.
    private func isPastOrToday(year: Int, month: Int, day: Int) -> Bool {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { return false }
        return calendar.startOfDay(for: date) <= todayStart
    }

    // Erzeugt die 42 Kalenderzellen (Vormonat, aktueller Monat, Folgemonat).
    private var calendarCells: [PanicCell] {
        let cal = calendar

        let firstOfMonth = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        let weekday = cal.component(.weekday, from: firstOfMonth)
        let leading = (weekday - cal.firstWeekday + 7) % 7

        let prevMonthDate = cal.date(byAdding: .month, value: -1, to: firstOfMonth)!
        let daysInPrevMonth = cal.range(of: .day, in: .month, for: prevMonthDate)!.count
        let nextMonthDate = cal.date(byAdding: .month, value: 1, to: firstOfMonth)!

        var cells: [PanicCell] = []

        if leading > 0 {
            let startDay = daysInPrevMonth - leading + 1
            let prevYM = cal.dateComponents([.year, .month], from: prevMonthDate)

            for d in startDay...daysInPrevMonth {
                let y = prevYM.year ?? currentYear
                let m = prevYM.month ?? currentMonth
                let allowed = isPastOrToday(year: y, month: m, day: d)

                cells.append(
                    PanicCell(
                        day: d,
                        isInDisplayedMonth: false,
                        mark: allowed ? .plus : .none,
                        monthOffset: -1,
                        effectiveYear: y,
                        effectiveMonth: m,
                        isTappable: allowed
                    )
                )
            }
        }

        for d in 1...daysInMonth {
            let allowed = isPastOrToday(year: currentYear, month: currentMonth, day: d)

            let mark: PanicMark
            if !allowed {
                mark = .none
            } else if isDemoMonth {
                if d == 6 || d == 7 {
                    mark = .brokenHeart
                } else if [16, 17, 18].contains(d) {
                    mark = .filled
                } else {
                    mark = .plus
                }
            } else {
                mark = .plus
            }

            cells.append(
                PanicCell(
                    day: d,
                    isInDisplayedMonth: true,
                    mark: mark,
                    monthOffset: 0,
                    effectiveYear: currentYear,
                    effectiveMonth: currentMonth,
                    isTappable: allowed
                )
            )
        }

        let nextYM = cal.dateComponents([.year, .month], from: nextMonthDate)
        var nextDay = 1

        while cells.count < 42 {
            let y = nextYM.year ?? currentYear
            let m = nextYM.month ?? currentMonth
            let allowed = isPastOrToday(year: y, month: m, day: nextDay)

            cells.append(
                PanicCell(
                    day: nextDay,
                    isInDisplayedMonth: false,
                    mark: allowed ? .plus : .none,
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

    // Verschiebt den angezeigten Monat um delta Monate.
    private func shiftMonth(by delta: Int) {
        let base = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let newDate = calendar.date(byAdding: .month, value: delta, to: base) ?? base
        let comps = calendar.dateComponents([.year, .month], from: newDate)
        currentYear = comps.year ?? currentYear
        currentMonth = comps.month ?? currentMonth
    }
}

private struct PanicCell: Identifiable {
    let id = UUID()
    let day: Int
    let isInDisplayedMonth: Bool
    let mark: PanicMark
    let monthOffset: Int?
    let effectiveYear: Int?
    let effectiveMonth: Int?
    let isTappable: Bool
}

private enum PanicMark: Equatable {
    case plus
    case filled
    case brokenHeart
    case none
}

private struct PanicDayCell: View {
    let day: Int
    let mark: PanicMark
    let isInDisplayedMonth: Bool

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

                if mark == .plus || mark == .filled {
                    Image(systemName: "plus")
                        .font(.system(size: plusSize, weight: .bold))
                        .foregroundStyle(.black.opacity(0.8))
                }

                if mark == .brokenHeart {
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

    private var circleFill: AnyShapeStyle {
        switch mark {
        case .plus, .filled:
            return AnyShapeStyle(Color.black.opacity(0.25))
        case .brokenHeart, .none:
            return AnyShapeStyle(Color.black.opacity(0.06))
        }
    }
}

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

struct JournalMainViewPanicAttacks_Previews: PreviewProvider {
    static var previews: some View {
        JournalMainViewPanicAttacks(
            rootMode: .constant(.panicAttacks),
            onPlusButtonTapped: { _ in },
            onCreateEntry: { _ in }
        )
    }
}

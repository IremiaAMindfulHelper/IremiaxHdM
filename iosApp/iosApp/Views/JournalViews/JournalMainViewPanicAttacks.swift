import SwiftUI

struct JournalMainViewPanicAttacks: View { // Anke

    @Binding var rootMode: JournalRootMode

    /// broken heart -> Popup (Sheet kommt im Parent)
    let onPlusButtonTapped: (_ header: String) -> Void

    /// ✅ + / filled -> JournalEntryView (mit Datum)
    let onCreateEntry: (_ date: Date) -> Void

    // Kalender State (nur Swift)
    @State private var currentYear: Int = 2026
    @State private var currentMonth: Int = 1

    private var isPanicBinding: Binding<Bool> {
        Binding(
            get: { rootMode == .panicAttacks },
            set: { isOn in
                withAnimation {
                    rootMode = isOn ? .panicAttacks : .emotions
                }
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

            // Header
            VStack(spacing: 0) {
                Text("Journal")
                    .font(.system(size: 40, weight: .regular, design: .rounded))
                    .padding(.top, 18)
                    .padding(.bottom, 14)

                Divider()
            }
            .safeAreaPadding(.top, titleTopInset)

            // Mode Switch
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

            // Month header
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        goToPreviousMonth()
                    }
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        goToNextMonth()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.7))
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)

            // Weekday row
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

            // Days grid
            let cols = Array(repeating: GridItem(.flexible(), spacing: gridColumnSpacing), count: 7)
            let cells = calendarCells

            LazyVGrid(columns: cols, spacing: gridSpacing) {
                ForEach(cells) { cell in
                    DayCell(
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

    private func handleTap(on cell: DemoCell) {
        // Tap auf ausgegraute Zellen -> Monat wechseln
        if !cell.isInDisplayedMonth, let offset = cell.monthOffset {
            withAnimation(.easeInOut(duration: 0.2)) {
                shiftMonth(by: offset)
            }
        }

        // Zukunft -> nicht antippbar
        guard cell.isTappable else { return }

        let year = cell.effectiveYear ?? currentYear
        let month = cell.effectiveMonth ?? currentMonth

        // ✅ + / filled -> Entry erstellen (nur Vergangenheit/Heute) + Datum übergeben
        if cell.mark == .plus || cell.mark == .filled {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: cell.day)) {
                onCreateEntry(date)
            }
            return
        }

        // ✅ broken heart -> Popup
        if cell.mark == .brokenHeart {
            let header = makeHeaderText(year: year, month: month, day: cell.day)
            onPlusButtonTapped(header)
        }
    }

    private func makeHeaderText(year: Int, month: Int, day: Int) -> String {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day

        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: comps) else {
            return "Tag \(String(format: "%02d", day)).\(String(format: "%02d", month))."
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM."
        return formatter.string(from: date).capitalized
    }

    // MARK: - Kalender/Logik

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "de_DE")
        cal.firstWeekday = 2 // Montag
        return cal
    }

    private var monthTitle: String {
        let cal = calendar
        let date = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    /// Demo-Panik-Tage NUR für Januar 2026 (Broken Hearts bleiben, aber nicht in allen Monaten)
    private var isDemoMonth: Bool {
        currentYear == 2026 && currentMonth == 1
    }

    /// "Heute" (Start des Tages), damit Uhrzeit egal ist
    private var todayStart: Date {
        calendar.startOfDay(for: Date())
    }

    private func isPastOrToday(year: Int, month: Int, day: Int) -> Bool {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
            return false
        }
        let d = calendar.startOfDay(for: date)
        return d <= todayStart
    }

    private var calendarCells: [DemoCell] {
        let cal = calendar

        let firstOfMonth = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        let weekday = cal.component(.weekday, from: firstOfMonth) // 1=So ... 7=Sa
        let leading = (weekday - cal.firstWeekday + 7) % 7

        let prevMonthDate = cal.date(byAdding: .month, value: -1, to: firstOfMonth)!
        let daysInPrevMonth = cal.range(of: .day, in: .month, for: prevMonthDate)!.count

        let nextMonthDate = cal.date(byAdding: .month, value: 1, to: firstOfMonth)!

        var cells: [DemoCell] = []

        // Leading Tage (Vormonat)
        if leading > 0 {
            let startDay = daysInPrevMonth - leading + 1
            let prevYM = cal.dateComponents([.year, .month], from: prevMonthDate)

            for d in startDay...daysInPrevMonth {
                let y = prevYM.year ?? currentYear
                let m = prevYM.month ?? currentMonth
                let allowed = isPastOrToday(year: y, month: m, day: d)

                cells.append(
                    DemoCell(
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

        // Tage im aktuellen Monat
        for d in 1...daysInMonth {
            let allowed = isPastOrToday(year: currentYear, month: currentMonth, day: d)

            let mark: DemoMark
            if !allowed {
                // Zukunft -> kein Plus, keine Herzen
                mark = .none
            } else if isDemoMonth {
                // ✅ Demo nur im Januar 2026 (und nur für erlaubte Tage)
                if d == 6 || d == 7 {
                    mark = .brokenHeart
                } else if [16, 17, 18].contains(d) {
                    mark = .filled
                } else {
                    mark = .plus
                }
            } else {
                // ✅ alle anderen Monate: nur Plus (keine Demo-Herzen)
                mark = .plus
            }

            cells.append(
                DemoCell(
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

        // Trailing Tage (Nächster Monat) -> auf 42 auffüllen
        let nextYM = cal.dateComponents([.year, .month], from: nextMonthDate)
        var nextDay = 1

        while cells.count < 42 {
            let y = nextYM.year ?? currentYear
            let m = nextYM.month ?? currentMonth
            let allowed = isPastOrToday(year: y, month: m, day: nextDay)

            cells.append(
                DemoCell(
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

    private func goToPreviousMonth() {
        shiftMonth(by: -1)
    }

    private func goToNextMonth() {
        shiftMonth(by: 1)
    }

    private func shiftMonth(by delta: Int) {
        let cal = calendar
        let base = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let newDate = cal.date(byAdding: .month, value: delta, to: base) ?? base
        let comps = cal.dateComponents([.year, .month], from: newDate)
        currentYear = comps.year ?? currentYear
        currentMonth = comps.month ?? currentMonth
    }
}

// MARK: - Helpers

private struct DemoCell: Identifiable {
    let id = UUID()
    let day: Int
    let isInDisplayedMonth: Bool
    let mark: DemoMark

    let monthOffset: Int?
    let effectiveYear: Int?
    let effectiveMonth: Int?

    /// darf man hier eintragen/antippen?
    let isTappable: Bool

    init(
        day: Int,
        isInDisplayedMonth: Bool,
        mark: DemoMark,
        monthOffset: Int? = nil,
        effectiveYear: Int? = nil,
        effectiveMonth: Int? = nil,
        isTappable: Bool = true
    ) {
        self.day = day
        self.isInDisplayedMonth = isInDisplayedMonth
        self.mark = mark
        self.monthOffset = monthOffset
        self.effectiveYear = effectiveYear
        self.effectiveMonth = effectiveMonth
        self.isTappable = isTappable
    }
}

private enum DemoMark: Equatable {
    case plus
    case filled
    case brokenHeart
    case none
}

// MARK: - DayCell

private struct DayCell: View {
    let day: Int
    let mark: DemoMark
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

                // ✅ Plus bei .plus UND .filled
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
        case .brokenHeart:
            return AnyShapeStyle(Color.black.opacity(0.06))
        case .none:
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

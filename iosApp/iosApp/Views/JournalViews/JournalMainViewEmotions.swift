import SwiftUI

struct JournalMainViewEmotions: View { // Anke

    @Binding var rootMode: JournalRootMode

    /// ✅ farbiger Kreis -> Popup (Date + Mark kommt im Parent)
    let onPlusButtonTapped: (_ date: Date, _ mark: DemoMark) -> Void

    /// ✅ + -> JournalEntryView
    let onCreateEntry: (_ date: Date) -> Void

    @State private var currentYear: Int = 2026
    @State private var currentMonth: Int = 1

    private var isPanicBinding: Binding<Bool> {
        Binding(
            get: { rootMode == .panicAttacks },
            set: { newValue in
                withAnimation { rootMode = newValue ? .panicAttacks : .emotions }
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
        if !cell.isInDisplayedMonth, let offset = cell.monthOffset {
            withAnimation(.easeInOut(duration: 0.2)) { shiftMonth(by: offset) }
        }

        guard cell.isTappable else { return }
        guard let date = dateForCell(cell) else { return }

        if cell.mark == .plus {
            onCreateEntry(date)
            return
        }

        if cell.mark == .moodGradientA || cell.mark == .moodGradientB {
            onPlusButtonTapped(date, cell.mark) // ✅ Mark mitgeben
        }
    }

    private func dateForCell(_ cell: DemoCell) -> Date? {
        let y = cell.effectiveYear ?? currentYear
        let m = cell.effectiveMonth ?? currentMonth
        return calendar.date(from: DateComponents(year: y, month: m, day: cell.day))
    }

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "de_DE")
        cal.firstWeekday = 2
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

    private var calendarCells: [DemoCell] {
        let cal = calendar

        let firstOfMonth = cal.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        let weekday = cal.component(.weekday, from: firstOfMonth)
        let leading = (weekday - cal.firstWeekday + 7) % 7

        let prevMonthDate = cal.date(byAdding: .month, value: -1, to: firstOfMonth)!
        let daysInPrevMonth = cal.range(of: .day, in: .month, for: prevMonthDate)!.count
        let nextMonthDate = cal.date(byAdding: .month, value: 1, to: firstOfMonth)!

        var cells: [DemoCell] = []

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

        for d in 1...daysInMonth {
            let allowed = isPastOrToday(year: currentYear, month: currentMonth, day: d)

            let mark: DemoMark
            if !allowed {
                mark = .none
            } else if isDemoMonth {
                if d == 6 { mark = .moodGradientA }
                else if d == 7 { mark = .moodGradientB }
                else { mark = .plus }
            } else {
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

    private func shiftMonth(by delta: Int) {
        let base = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) ?? Date()
        let newDate = calendar.date(byAdding: .month, value: delta, to: base) ?? base
        let comps = calendar.dateComponents([.year, .month], from: newDate)
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
    let isTappable: Bool
}

enum DemoMark: Equatable {
    case plus
    case moodGradientA
    case moodGradientB
    case none
}

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

                if mark == .plus {
                    Image(systemName: "plus")
                        .font(.system(size: plusSize, weight: .bold))
                        .foregroundStyle(.black.opacity(0.8))
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
        case .plus:
            return AnyShapeStyle(Color.black.opacity(0.25))
        case .moodGradientA:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.red.opacity(0.9), Color.blue.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .moodGradientB:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.green.opacity(0.9), Color.blue.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
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

struct JournalMainViewEmotions_Previews: PreviewProvider {
    static var previews: some View {
        JournalMainViewEmotions(
            rootMode: .constant(.emotions),
            onPlusButtonTapped: { _, _ in },
            onCreateEntry: { _ in }
        )
    }
}

import SwiftUI

struct JournalMainViewEmotions: View { // Anke

    @Binding var rootMode: JournalRootMode

    /// farbiger Kreis -> Popup (Sheet kommt im Parent)
    let onPlusButtonTapped: (_ header: String) -> Void

    /// + -> JournalEntryView
    let onCreateEntry: () -> Void

    // Kalender State (nur Swift)
    @State private var currentYear: Int = 2026
    @State private var currentMonth: Int = 1

    private var isPanicBinding: Binding<Bool> {
        Binding(
            get: { rootMode == .panicAttacks },
            set: { newValue in
                withAnimation {
                    rootMode = newValue ? .panicAttacks : .emotions
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

            // Month header (nur UI)
            HStack {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.7))
                        .frame(width: 40, height: 40)
                }

                Spacer()

                Text("Januar\u{202F}26")
                    .font(.system(size: 26, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.9))

                Spacer()

                Button { } label: {
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
            let cells = demoCells

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
        // ✅ + -> JournalEntryView
        if cell.mark == .plus {
            onCreateEntry()
            return
        }

        // ✅ farbig -> Popup
        if cell.mark == .moodGradientA || cell.mark == .moodGradientB {
            let header = makeHeaderText(year: currentYear, month: currentMonth, day: cell.day)
            onPlusButtonTapped(header)
        }
    }

    private func makeHeaderText(year: Int, month: Int, day: Int) -> String {
        // Einfaches Format wie: "Mittwoch, 07.01."
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
        // "Mittwoch, 07.01."
        return formatter.string(from: date).capitalized
    }

    private var demoCells: [DemoCell] {
        let leading = [29, 30, 31].map {
            DemoCell(day: $0, isInDisplayedMonth: false, mark: .plus)
        }

        let monthDays: [DemoCell] = (1...31).map { d in
            if d == 6 { return DemoCell(day: d, isInDisplayedMonth: true, mark: .moodGradientA) }
            if d == 7 { return DemoCell(day: d, isInDisplayedMonth: true, mark: .moodGradientB) }
            if [16, 17, 18].contains(d) { return DemoCell(day: d, isInDisplayedMonth: true, mark: .filled) }
            return DemoCell(day: d, isInDisplayedMonth: true, mark: .plus)
        }

        var all = leading + monthDays
        while all.count < 42 {
            let next = all.count - (leading.count + monthDays.count) + 1
            all.append(DemoCell(day: next, isInDisplayedMonth: false, mark: .plus))
        }
        return Array(all.prefix(42))
    }
}

// MARK: - Helpers

private struct DemoCell: Identifiable {
    let id = UUID()
    let day: Int
    let isInDisplayedMonth: Bool
    let mark: DemoMark
}

private enum DemoMark: Equatable {
    case plus
    case filled
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

                if mark == .plus || mark == .filled {
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
        case .filled:
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

struct JournalMainView_Previews: PreviewProvider {
    static var previews: some View {
        JournalMainViewEmotions(
            rootMode: .constant(.emotions),
            onPlusButtonTapped: { _ in },
            onCreateEntry: { }
        )
    }
}

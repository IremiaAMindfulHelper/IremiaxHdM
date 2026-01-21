import SwiftUI
import Shared

struct JournalMainViewEmotions: View { // Anke
    
    let onPlusButtonTapped: () -> Void

    @State private var isPanic: Bool = false
    @State private var showPopup: Bool = false
    @State private var popupHeader: String = ""
    @State private var selectedDay: Int = 0
    @State private var currentYear: Int = 2026
    @State private var currentMonth: Int = 1

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

            // Mode Switch (nur Optik)
            HStack(spacing: 16) {
                VStack(spacing: 6) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.black.opacity(isPanic ? 0.25 : 0.75))
                    Text("Stimmung")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.black.opacity(isPanic ? 0.45 : 0.85))
                }

                Toggle("", isOn: $isPanic)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(.black.opacity(0.8))
                    .scaleEffect(0.95)

                VStack(spacing: 6) {
                    BrokenHeartIcon(size: 26, isActive: isPanic)
                    Text("Panik")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.black.opacity(isPanic ? 0.85 : 0.45))
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 4)

            // Month header (Buttons ohne Funktion – nur UI)
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

            // Days grid (nur Mock-Optik)
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
                        onTap: {
                            // KOTLIN
                            let controller = JournalCalendarController()
                            if controller.canSelectDate(
                                year: Int32(currentYear),
                                month: Int32(currentMonth),
                                day: Int32(cell.day)
                            ) {
                                let header = controller.getHeaderText(
                                    year: Int32(currentYear),
                                    month: Int32(currentMonth),
                                    day: Int32(cell.day)
                                )
                                selectedDay = cell.day
                                popupHeader = header
                                showPopup = true
                            } else {
                                print("Date is in Future")
                            }
                        }

                    )
                    // ✅ Out-of-month wird automatisch heller (wie 29/30/31)
                    .opacity(cell.isInDisplayedMonth ? 1.0 : 0.55)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 6)

            Spacer(minLength: 0)
        }
        .background(Color.white)
        .overlay {
            if showPopup {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                showPopup = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        JournalMainPopUpView(
                            onEintragBearbeiten: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    showPopup = false
                                }
                            },
                            dateHeader: popupHeader
                        )
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(response: 0.35, dampingFraction: 0.9), value: showPopup)
                }
                .transition(.opacity)
            }
        }
    }

    private var demoCells: [DemoCell] {
        // Beispiel: Januar 2026 startet Do (Mo-basiert: 4. Spalte)
        // Wir legen 3 Vormonatstage (29,30,31) + 31 Tage + Rest auffüllen
        let leading = [29, 30, 31].map {
            DemoCell(day: $0, isInDisplayedMonth: false, mark: .plus)
        }

        let monthDays: [DemoCell] = (1...31).map { d in
            if d == 6 { return DemoCell(day: d, isInDisplayedMonth: true, mark: .moodGradientA) }
            if d == 7 { return DemoCell(day: d, isInDisplayedMonth: true, mark: .moodGradientB) }

            // ✅ 16/17/18 sollen "filled" bleiben, aber trotzdem dunkel + Plus anzeigen
            if [16, 17, 18].contains(d) { return DemoCell(day: d, isInDisplayedMonth: true, mark: .filled) }

            return DemoCell(day: d, isInDisplayedMonth: true, mark: .plus)
        }

        var all = leading + monthDays

        // ✅ FIX: Folgemonat (1...8) soll wie Vormonat aussehen (hellgrau + Plus)
        while all.count < 42 {
            let next = all.count - (leading.count + monthDays.count) + 1
            all.append(DemoCell(day: next, isInDisplayedMonth: false, mark: .plus))
        }

        return Array(all.prefix(42))
    }
}

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

                // ✅ Plus bei .plus und .filled
                if mark == .plus || mark == .filled {
                    Image(systemName: "plus")
                        .font(.system(size: plusSize, weight: .bold))
                        .foregroundStyle(.black.opacity(0.8))
                }
            }
            .onTapGesture {
                onTap()
            }

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
            // ✅ FIX: soll so dunkel sein wie normale Plus-Tage (z.B. 15)
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
        JournalNavigationView()
    }
}

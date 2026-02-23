import SwiftUI

struct JournalMainView: View {
    @Binding var rootMode: JournalRootMode

    let onPlusButtonTappedMood: (_ date: Date, _ mark: MoodMark) -> Void
    let onPlusButtonTappedPanic: (_ date: Date) -> Void
    let onCreateEntry: (_ date: Date) -> Void

    @StateObject private var vm: JournalMainViewModel

    private let titleTopInset: CGFloat = 34
    private let gridCircleSize: CGFloat = 38
    private let gridPlusSize: CGFloat = 16
    private let gridSpacing: CGFloat = 14
    private let gridColumnSpacing: CGFloat = 12
    private let dayFontSize: CGFloat = 14

    init(
        rootMode: Binding<JournalRootMode>,
        onPlusButtonTappedMood: @escaping (_ date: Date, _ mark: MoodMark) -> Void,
        onPlusButtonTappedPanic: @escaping (_ date: Date) -> Void,
        onCreateEntry: @escaping (_ date: Date) -> Void
    ) {
        self._rootMode = rootMode
        self.onPlusButtonTappedMood = onPlusButtonTappedMood
        self.onPlusButtonTappedPanic = onPlusButtonTappedPanic
        self.onCreateEntry = onCreateEntry
        _vm = StateObject(wrappedValue: JournalMainViewModel(rootMode: rootMode.wrappedValue))
    }

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

        // Parent -> VM sync (iOS 17+ API)
        .onChange(of: rootMode) {
            if vm.rootMode != rootMode {
                vm.setIsPanic(rootMode == .panicAttacks)
            }
        }

        // VM -> Parent sync
        .onChange(of: vm.rootMode) {
            if rootMode != vm.rootMode {
                rootMode = vm.rootMode
            }
        }
    }

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
        let isPanicBinding = Binding<Bool>(
            get: { vm.rootMode == .panicAttacks },
            set: { isOn in
                withAnimation { vm.setIsPanic(isOn) }
            }
        )

        return HStack(spacing: 16) {
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
                withAnimation(.easeInOut(duration: 0.2)) { vm.shiftMonth(by: -1) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.7))
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text(vm.monthTitle)
                .font(.system(size: 26, weight: .regular, design: .rounded))
                .foregroundStyle(.black.opacity(0.9))

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { vm.shiftMonth(by: 1) }
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

        return LazyVGrid(columns: cols, spacing: gridSpacing) {
            ForEach(vm.cells) { cell in
                UnifiedDayCell(
                    day: cell.day,
                    style: cell.style,
                    circleSize: gridCircleSize,
                    plusSize: gridPlusSize,
                    dayFontSize: dayFontSize,
                    onTap: { handleTap(cell) }
                )
                .opacity(cell.isInDisplayedMonth ? 1.0 : 0.55)
                .allowsHitTesting(cell.isTappable)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private func handleTap(_ cell: UnifiedCell) {
        switch vm.handleTap(on: cell) {
        case .none:
            break
        case .createEntry(let date):
            onCreateEntry(date)
        case .openMoodPopup(let date, let mark):
            onPlusButtonTappedMood(date, mark)
        case .openPanicPopup(let date):
            onPlusButtonTappedPanic(date)
        }
    }
}

// MARK: - Cell Views (UI-only)

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

                if showsPlus {
                    Image(systemName: "plus")
                        .font(.system(size: plusSize, weight: .bold))
                        .foregroundStyle(.black.opacity(0.8))
                }

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

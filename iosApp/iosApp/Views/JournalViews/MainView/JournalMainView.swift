import SwiftUI

struct JournalMainView: View {
    @Binding var rootMode: JournalRootMode

    let onPlusButtonTappedMood: (_ date: Date, _ mark: MoodMark) -> Void
    let onPlusButtonTappedPanic: (_ date: Date) -> Void
    let onCreateEntry: (_ date: Date) -> Void

    @StateObject private var vm: JournalMainViewModel

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
            headerRow
            topControlsRow
                .padding(.top, 6)

            calendarCard
                .padding(.top, 14)

            // bewusst kleiner Abstand, damit es nicht “bis unten” wirkt
            Spacer(minLength: 16)
        }
        .background(Color.white)

        .onChange(of: rootMode) {
            if vm.rootMode != rootMode {
                vm.setIsPanic(rootMode == .panicAttacks)
            }
        }

        .onChange(of: vm.rootMode) {
            if rootMode != vm.rootMode {
                rootMode = vm.rootMode
            }
        }
    }

    // MARK: - Header (zarter)

    private var headerRow: some View {
        HStack {
            Text("Journal")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.78))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .safeAreaPadding(.top, 6)
    }

    // MARK: - Controls Row

    private var topControlsRow: some View {
        let isPanicBinding = Binding<Bool>(
            get: { vm.rootMode == .panicAttacks },
            set: { isOn in withAnimation { vm.setIsPanic(isOn) } }
        )

        return HStack(spacing: 14) {
            chip {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.70), Color.blue.opacity(0.70)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
            }

            chip {
                Toggle("", isOn: isPanicBinding)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(.black.opacity(0.85))
                    .scaleEffect(0.88)
                    .frame(height: 24)
            }

            chip {
                BrokenHeartIcon(size: 22, isActive: isPanicBinding.wrappedValue)
            }

            Spacer(minLength: 0)

            monthNavCapsule
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func chip<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.06))
            )
    }

    private var monthNavCapsule: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { vm.shiftMonth(by: -1) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.70))
                    .frame(width: 44, height: 36)
            }

            Rectangle()
                .fill(Color.black.opacity(0.10))
                .frame(width: 1, height: 20)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { vm.shiftMonth(by: 1) }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.70))
                    .frame(width: 44, height: 36)
            }
        }
        .background(
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.06))
        )
    }

    // MARK: - Calendar Card (kompakt + zarte Schrift)

    private var calendarCard: some View {
        VStack(spacing: 0) {
            Text(vm.monthTitle)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundStyle(.black.opacity(0.75))
                .padding(.top, 14)

            weekdayRow
                .padding(.top, 10)

            Rectangle()
                .fill(Color.black.opacity(0.45))
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            calendarGrid
                .padding(.top, 12)
                .padding(.bottom, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }

    private var weekdayRow: some View {
        let labels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
        return HStack(spacing: 0) {
            ForEach(labels, id: \.self) { d in
                Text(d)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.65))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }

    private var calendarGrid: some View {
        // >>> KOMPAKT wie Prototype <<<
        let circleSize: CGFloat = 34
        let plusSize: CGFloat = 14
        let dayFontSize: CGFloat = 13

        let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

        return LazyVGrid(columns: cols, spacing: 10) {
            ForEach(vm.cells) { cell in
                UnifiedDayCell(
                    day: cell.day,
                    style: cell.style,
                    circleSize: circleSize,
                    plusSize: plusSize,
                    dayFontSize: dayFontSize,
                    isTappable: cell.isTappable,
                    onTap: { handleTap(cell) }
                )
                .opacity(cell.isInDisplayedMonth ? 1.0 : 0.72)
                .allowsHitTesting(cell.isTappable)
            }
        }
        .padding(.horizontal, 16)
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

// MARK: - Cell

private struct UnifiedDayCell: View {
    let day: Int
    let style: CellStyle
    let circleSize: CGFloat
    let plusSize: CGFloat
    let dayFontSize: CGFloat
    let isTappable: Bool
    let onTap: () -> Void

    var body: some View {
        let isPastDisabled = (!isTappable && !hasMarker)

        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(circleFill(isPastDisabled: isPastDisabled))
                    .frame(width: circleSize, height: circleSize)

                if showsPlus && !isPastDisabled {
                    Image(systemName: "plus")
                        .font(.system(size: plusSize, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.75))
                }

                if case .panic(.brokenHeart) = style {
                    BrokenHeartIcon(size: plusSize + 6, isActive: true)
                }
            }
            .contentShape(Circle())
            .onTapGesture {
                guard isTappable else { return }
                onTap()
            }

            Text("\(day)")
                .font(.system(size: dayFontSize, weight: .regular, design: .rounded))
                .foregroundStyle(isPastDisabled ? .black.opacity(0.42) : .black.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
    }

    private var hasMarker: Bool {
        switch style {
        case .mood(.gradientA), .mood(.gradientB), .panic(.brokenHeart):
            return true
        default:
            return false
        }
    }

    private var showsPlus: Bool {
        switch style {
        case .mood(.plus), .panic(.plus), .panic(.filled):
            return true
        default:
            return false
        }
    }

    private func circleFill(isPastDisabled: Bool) -> AnyShapeStyle {
        if isPastDisabled {
            // abgelaufen => dunkler grau
            return AnyShapeStyle(Color.black.opacity(0.18))
        }

        switch style {
        case .mood(.plus), .panic(.plus), .panic(.filled):
            return AnyShapeStyle(Color.black.opacity(0.08))

        case .mood(.gradientA):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.green.opacity(0.70), Color.blue.opacity(0.80)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

        case .mood(.gradientB):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.orange.opacity(0.70), Color.yellow.opacity(0.70)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

        case .panic(.brokenHeart), .none:
            return AnyShapeStyle(Color.black.opacity(0.05))
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
                .foregroundStyle(.black.opacity(isActive ? 0.78 : 0.35))

            Image(systemName: "bolt.fill")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(.black.opacity(isActive ? 0.78 : 0.35))
        }
    }
}

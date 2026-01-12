//
//  JournalMainViewPanicAttacks.swift
//  iosApp
//
//  Created by Anke Raab on 12.01.26.
//

import SwiftUI

struct JournalMainViewPanicAttacks: View { // Anke

    // nur für Optik (Toggle bewegt sich, sonst keine Navigation/Logik nötig)
    @State private var isPanic: Bool = true


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

            // Days grid (nur Mock-Optik) – statt bunten Kugeln: gebrochene Herzen
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
                        dayFontSize: dayFontSize
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


    private var demoCells: [DemoCell] {
        // Beispiel: Januar 2026 startet Do (Mo-basiert: 4. Spalte)
        // 3 Vormonatstage (29,30,31) + 31 Tage + Rest auffüllen
        let leading = [29, 30, 31].map { DemoCell(day: $0, isInDisplayedMonth: false, mark: .plus) }

        let monthDays: [DemoCell] = (1...31).map { d in
            // Demo: 6 & 7 = brokenHeart (statt Mood-Grads)
            if d == 6 { return DemoCell(day: d, isInDisplayedMonth: true, mark: .brokenHeart) }
            if d == 7 { return DemoCell(day: d, isInDisplayedMonth: true, mark: .brokenHeart) }

            // Demo: 16/17/18 = filled
            if [16, 17, 18].contains(d) { return DemoCell(day: d, isInDisplayedMonth: true, mark: .filled) }

            // Rest: plus (wie Mock)
            return DemoCell(day: d, isInDisplayedMonth: true, mark: .plus)
        }

        var all = leading + monthDays
        while all.count < 42 {
            let next = all.count - (leading.count + monthDays.count) + 1
            all.append(DemoCell(day: next, isInDisplayedMonth: false, mark: .none))
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
    case brokenHeart
    case none
}

// MARK: - DayCell (Mock)

private struct DayCell: View {
    let day: Int
    let mark: DemoMark
    let isInDisplayedMonth: Bool

    let circleSize: CGFloat
    let plusSize: CGFloat
    let dayFontSize: CGFloat

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

                if mark == .brokenHeart {
                    BrokenHeartIcon(size: 22, isActive: true)
                }
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
            return AnyShapeStyle(Color.black.opacity(0.12))
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
        JournalMainViewPanicAttacks()
    }
}

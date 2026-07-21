import SwiftUI
import shared

// =============================================================================
// InsightHomeView — Home (Start) screen rebuilt from design_handoff_iremia_home.
//
// The blue HeroInsightCard binds to a shared `MotivationInsight`. A placeholder is
// used until the motivation algorithm is wired in, so the layout is complete now
// and the real insight slots in without UI changes.
// =============================================================================

/// Home design tokens (from design_handoff_iremia_home). Local to the home view so
/// it matches the handoff exactly without touching the app-wide palette.
private enum HomeColors {
    static let bg = Color(hex: 0xEDF1F1)
    static let card = Color.white
    static let ink = Color(hex: 0x1A2A2E)
    static let inkSoft = Color(hex: 0x566B71)
    static let inkMute = Color(hex: 0x8B989D)
    static let line = Color(hex: 0x1A2A2E).opacity(0.08)
    static let teal = Color(hex: 0x0E7B8A)
    static let tealDeep = Color(hex: 0x1A7283)
    static let tealDeep2 = Color(hex: 0x0E5965)
    static let tealSoft = Color(hex: 0xD7E9EB)
    static let tealSofter = Color(hex: 0xE7F1F2)
    static let onTeal = Color(hex: 0xEAF6F7)
    static let chartLine = Color(hex: 0xA9E6E2)
}

struct InsightHomeView: View {
    /// Drives the blue insight card from the shared motivation algorithm.
    @StateObject private var motivation = MotivationObservable()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                greetingHeader
                HeroInsightCard(insight: motivation.insight)
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                patternsSection
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                DailyFlashcard()
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                Color.clear.frame(height: 120) // clear the floating tab bar
            }
        }
        .background(HomeColors.bg.ignoresSafeArea())
        .task {
            motivation.start()
        }
    }

    private var greetingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(Strings.home_greeting_evening.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.7)
                    .foregroundColor(HomeColors.ink.opacity(0.5))
                Spacer().frame(height: 6)
                Text(Strings.home_greeting_name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(HomeColors.ink)
                Spacer().frame(height: 7)
                Text(Strings.home_greeting_subtitle)
                    .font(.system(size: 13.5))
                    .foregroundColor(HomeColors.inkSoft)
            }
            Spacer()
            ZStack {
                Circle().fill(Color.white.opacity(0.65)).frame(width: 56, height: 56)
                Circle().fill(HomeColors.teal.opacity(0.25)).frame(width: 50, height: 50)
                Text("L").font(.system(size: 22, weight: .bold)).foregroundColor(HomeColors.tealDeep)
            }
        }
        .padding(.top, 18)
        .padding(.horizontal, 22)
        .padding(.bottom, 26)
        .background(
            HomeColors.tealSoft
                .clipShape(RoundedCorners(radius: 30, corners: [.bottomLeft, .bottomRight]))
                .ignoresSafeArea(edges: .top)
        )
    }

    private var patternsSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text(Strings.home_patterns_title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(HomeColors.ink)
                Spacer()
                Text("✦ " + Strings.home_patterns_auto)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(HomeColors.teal)
            }
            PatternCard(title: Strings.home_pattern_move_title, meta: Strings.home_pattern_move_meta)
            PatternCard(title: Strings.home_pattern_evening_title, meta: Strings.home_pattern_evening_meta)
            PatternCard(title: Strings.home_pattern_breath_title, meta: Strings.home_pattern_breath_meta)
        }
    }
}

// MARK: - Hero insight card

private struct HeroInsightCard: View {
    let insight: MotivationInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(Strings.home_hero_label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.3)
                    .foregroundColor(HomeColors.onTeal.opacity(0.62))
                Spacer()
                Text(Strings.home_hero_no_rating)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(HomeColors.onTeal.opacity(0.62))
                    .padding(.horizontal, 9).padding(.vertical, 3)
                    .overlay(Capsule().stroke(HomeColors.onTeal.opacity(0.22), lineWidth: 1))
            }

            Spacer().frame(height: 14)
            Text(localizedInsightKey(insight.headlineKey))
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(HomeColors.onTeal)
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 16)

            Rectangle().fill(HomeColors.onTeal.opacity(0.16)).frame(height: 1)
            Spacer().frame(height: 14)

            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(HomeColors.chartLine.opacity(0.18))
                            .frame(width: 34, height: 34)
                        Text(insight.isPositive ? "↓" : "→")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(HomeColors.chartLine)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text(localizedInsightKey(insight.factTitleKey))
                            .font(.system(size: 14.5, weight: .bold))
                            .foregroundColor(HomeColors.onTeal)
                        Text(localizedInsightKey(insight.factSubtitleKey))
                            .font(.system(size: 12))
                            .foregroundColor(HomeColors.onTeal.opacity(0.7))
                    }
                }
                Spacer()
                TrendChart(points: insight.trend.map { CGFloat(truncating: $0) })
                    .frame(width: 74, height: 34)
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [HomeColors.tealDeep, HomeColors.tealDeep2],
                startPoint: .top, endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

/// Small line+area sparkline. Higher value = higher on screen.
private struct TrendChart: View {
    let points: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxV = points.max() ?? 1
            let minV = points.min() ?? 0
            let range = (maxV - minV) > 0 ? (maxV - minV) : 1
            let stepX = points.count > 1 ? w / CGFloat(points.count - 1) : w
            let chartPoints = points.enumerated().map { index, value in
                CGPoint(x: CGFloat(index) * stepX, y: h - ((value - minV) / range) * h)
            }

            if chartPoints.count >= 2 {
                let line = Path { p in
                    p.move(to: chartPoints[0])
                    for point in chartPoints.dropFirst() { p.addLine(to: point) }
                }
                let area = Path { p in
                    p.move(to: chartPoints[0])
                    for point in chartPoints.dropFirst() { p.addLine(to: point) }
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.closeSubpath()
                }
                area.fill(
                    LinearGradient(
                        colors: [HomeColors.chartLine.opacity(0.4), .clear],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                line.stroke(HomeColors.chartLine, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                Circle().fill(HomeColors.onTeal).frame(width: 5.2, height: 5.2)
                    .position(chartPoints[chartPoints.count - 1])
            }
        }
    }
}

// MARK: - Pattern cards

private struct PatternCard: View {
    let title: String
    let meta: String

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                RoundedRectangle(cornerRadius: 13).fill(HomeColors.tealSofter).frame(width: 42, height: 42)
                Text("✦").font(.system(size: 18)).foregroundColor(HomeColors.teal)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14.5, weight: .semibold)).foregroundColor(HomeColors.ink)
                Text(meta).font(.system(size: 12)).foregroundColor(HomeColors.inkMute)
            }
            Spacer()
            MiniBars()
        }
        .padding(14)
        .background(HomeColors.card)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(HomeColors.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct MiniBars: View {
    private let heights: [CGFloat] = [0.45, 0.6, 0.5, 0.7, 0.6, 0.85, 1.0]
    var body: some View {
        HStack(alignment: .bottom, spacing: 3.2) {
            ForEach(0..<heights.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1.7)
                    .fill(i == heights.count - 1 ? HomeColors.teal : HomeColors.teal.opacity(0.28))
                    .frame(width: 3.4, height: 22 * heights[i])
            }
        }
        .frame(width: 46, height: 22, alignment: .bottom)
    }
}

// MARK: - Daily flashcard

private struct DailyFlashcard: View {
    private let cards: [String] = [
        Strings.home_flashcard_1, Strings.home_flashcard_2, Strings.home_flashcard_3,
        Strings.home_flashcard_4, Strings.home_flashcard_5,
    ]
    @State private var index = 0

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("✦ " + Strings.home_flashcard_label)
                    .font(.system(size: 11, weight: .bold)).tracking(1.1)
                    .foregroundColor(HomeColors.teal)
                Spacer()
                Text("\(index + 1) / \(cards.count)")
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(HomeColors.inkMute)
            }
            Text(cards[index])
                .font(.system(size: 15.5, weight: .medium))
                .foregroundColor(HomeColors.ink)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
                .padding(.horizontal, 18).padding(.vertical, 20)
                .background(HomeColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .id(index)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.32), value: index)
            HStack {
                circleButton(system: "chevron.left", label: Strings.home_flashcard_prev) {
                    if index > 0 { index -= 1 }
                }
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<cards.count, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i == index ? HomeColors.teal : HomeColors.teal.opacity(0.22))
                            .frame(width: i == index ? 18 : 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: index)
                    }
                }
                Spacer()
                circleButton(system: "chevron.right", label: Strings.home_flashcard_next) {
                    if index < cards.count - 1 { index += 1 }
                }
            }
        }
        .padding(16)
        .background(HomeColors.tealSofter)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(HomeColors.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func circleButton(system: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(HomeColors.teal)
                .frame(width: 34, height: 34)
                .background(HomeColors.card)
                .overlay(Circle().stroke(HomeColors.line, lineWidth: 1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

// MARK: - Insight copy resolution

/// Resolves an insight copy key to its localized shared string. Central so this
/// view and the shared algorithm agree on the same keys.
private func localizedInsightKey(_ key: String) -> String {
    switch key {
    case "insight_headline_positive_high": return Strings.insight_headline_positive_high
    case "insight_headline_positive_medium": return Strings.insight_headline_positive_medium
    case "insight_headline_positive_low": return Strings.insight_headline_positive_low
    case "insight_headline_neutral_high": return Strings.insight_headline_neutral_high
    case "insight_headline_neutral_medium": return Strings.insight_headline_neutral_medium
    case "insight_headline_neutral_low": return Strings.insight_headline_neutral_low
    case "insight_fact_fewer_attacks": return Strings.insight_fact_fewer_attacks
    case "insight_fact_steady_attacks": return Strings.insight_fact_steady_attacks
    case "insight_fact_vs_prev_30": return Strings.insight_fact_vs_prev_30
    case "insight_fact_keep_going": return Strings.insight_fact_keep_going
    default: return Strings.insight_headline_neutral_low
    }
}

// MARK: - Helpers

private extension Color {
    /// Build a Color from a 0xRRGGBB integer.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}

/// Rounds only the specified corners (used for the greeting header's bottom corners).
private struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

import SwiftUI

struct BreathingWatchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    // Anchors the breath clock. Reset on every appearance (and when the app
    // returns to the foreground) so reopening the view always starts at
    // elapsed 0 = breathe in, instead of resuming wherever wall-clock time
    // happens to land.
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(start)
                .truncatingRemainder(dividingBy: BreathStep.cycle)
            let step = BreathStep(elapsed: elapsed)
            // Eased (smoothstep) glow so the light surges through the middle of
            // the breath rather than tracking the bloom linearly.
            let glow = step.bloom * step.bloom * (3 - 2 * step.bloom)

            ZStack {
                // Solid black base so the wash can dissolve into it.
                Color.black.ignoresSafeArea()

                // Base wash: a faint teal glow whose alpha falls off all the way
                // to transparent (into the black) — no opaque outer stop, so the
                // compressed state melts into the background instead of reading
                // as a hard-edged teal disc.
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 89 / 255, green: 170 / 255, blue: 168 / 255)
                            .opacity(0.50 - 0.06 * glow), location: 0),
                        .init(color: Color(red: 10 / 255, green: 92 / 255, blue: 90 / 255)
                            .opacity(0.30 - 0.05 * glow), location: 0.45),
                        .init(color: Color(red: 10 / 255, green: 92 / 255, blue: 90 / 255)
                            .opacity(0), location: 0.95)
                    ]),
                    center: .center,
                    startRadius: 0,
                    // Small but clearly visible halo hugging the flower when
                    // held; grows into the full bloom on the inhale (where the
                    // hot core, not this wash, supplies the extra brightness).
                    endRadius: 82 + 73 * glow
                )
                .ignoresSafeArea()

                // Hot core that blooms in from nothing on the inhale (a
                // qualitative change, not just a scale) and fades out fully on
                // the exhale, so the light feels alive rather than zoomed.
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 150 / 255, green: 222 / 255, blue: 220 / 255),
                        .clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 40 + 70 * glow
                )
                .scaleEffect(0.7 + 0.5 * glow)
                .opacity(0.5 * glow)
                .ignoresSafeArea()
                .blendMode(.screen)

                // Centre on the full screen so the flower lines up with the
                // gradient's core (both ignore the safe area).
                BreathFlower(phase: step.phase)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(.white.opacity(0.1)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.trailing, 8)
                    .padding(.top, 4)

                    Spacer()

                    Text(step.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                    Text("\(step.count)")
                        .font(.system(size: 20, weight: .light, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .contentTransition(.numericText())
                }
                .padding(.bottom, 4)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { start = Date() }
        .onChange(of: scenePhase) { phase in
            if phase == .active { start = Date() }
        }
    }
}

/// Breath guidance derived from the same clock as the flower, so the text and
/// counter stay locked to the bloom. The phases map onto the visual morph
/// stages of the 16s loop: breathe in 0–4s (103→100, the big petal curves
/// expand), hold 4–8s (100→101, the small lines follow), breathe out 8–16s
/// (101→103, the whole flower compresses). The compressed state has no hold —
/// the loop runs straight from compression back into the next breathe in.
/// Bloom tracks real openness, so it rises through both the in and the hold
/// (peaking fully open at 101) and falls back on the exhale.
private struct BreathStep {
    static let cycle: TimeInterval = 16

    let label: String
    let count: Int
    let phase: CGFloat   // normalized flower-loop position (0...1)
    let bloom: CGFloat   // expansion amount (0 compressed ... 1 open), drives the glow

    init(elapsed: TimeInterval) {
        phase = CGFloat(elapsed / BreathStep.cycle)
        switch elapsed {
        case ..<4:
            label = "Breathe in"
            count = 4 - Int(elapsed)
            bloom = CGFloat(elapsed / 4 * 0.5)             // 0 → 0.5 (103→100)
        case ..<8:
            label = "Hold"
            count = 4 - Int(elapsed - 4)
            bloom = CGFloat(0.5 + (elapsed - 4) / 4 * 0.5) // 0.5 → 1.0 (100→101)
        default:
            label = "Breathe out"
            count = 8 - Int(elapsed - 8)
            bloom = CGFloat(1 - (elapsed - 8) / 8)         // 1.0 → 0 (101→103)
        }
    }
}

// MARK: - Bloom flower

/// Vector flower recreated from Figma "Flow 2" (Screen Ideation/Sandbox).
/// Driven by the breath clock via `phase` (0...1 over the 20s loop) so the
/// bloom stays in sync with the on-screen guidance.
private struct BreathFlower: View {
    var phase: CGFloat

    var body: some View {
        ZStack {
            BloomFlower(phase: phase)
                .fill(Color(white: 0.85).opacity(0.92))

            // Centre dot (fixed at the flower's centre).
            Circle()
                .fill(Color(white: 0.85).opacity(0.85))
                .frame(width: 4, height: 4)
        }
        .frame(width: 150, height: 150 * 223 / 187)
    }
}

/// Morphing flower shape. `phase` is the normalized position in the Flow 2 loop
/// (0...1); SwiftUI animates it linearly and `path(in:)` maps it onto the three
/// keyframes, interpolating the petal paths per control point (mirroring Figma's
/// SMART_ANIMATE), fitted/centred into the 187×223 viewBox.
private struct BloomFlower: Shape {
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let viewBox = CGSize(width: 187, height: 223)
        let scale = min(rect.width / viewBox.width, rect.height / viewBox.height)
        let dx = rect.minX + (rect.width - viewBox.width * scale) / 2
        let dy = rect.minY + (rect.height - viewBox.height * scale) / 2
        let xf = CGAffineTransform(translationX: dx, y: dy).scaledBy(x: scale, y: scale)

        let (from, to, t) = keyframes(for: phase)
        var combined = Path()
        for (a, b) in zip(from, to) {
            combined.addPath(SVGPath.interpolate(a, b, t: t).applying(xf))
        }
        return combined
    }

    /// Maps the loop position onto a pair of keyframes + local progress over the
    /// 16s loop (4+4+8s). Each breath phase owns one morph stage, with no pause
    /// at the compressed state: breathe in 103→100 (4s, big petals expand),
    /// hold 100→101 (4s, small lines follow), breathe out 101→103 (8s, the whole
    /// flower compresses). Normalized boundaries: 4/16=0.25, 8/16=0.5.
    private func keyframes(for p: CGFloat) -> ([[SVGPath.Op]], [[SVGPath.Op]], CGFloat) {
        let k100 = FlowerGeometry.closedOps
        let k101 = FlowerGeometry.midOps
        let k103 = FlowerGeometry.openOps
        switch p {
        case ..<0.25: return (k103, k100, p / 0.25)            // breathe in: 103→100
        case ..<0.5:  return (k100, k101, (p - 0.25) / 0.25)   // hold: 100→101
        default:      return (k101, k103, min((p - 0.5) / 0.5, 1)) // breathe out: 101→103
        }
    }
}

/// Raw vector data exported from Figma Flow 2, in the 187×223 viewBox.
/// `closed` is frame 100 (1528:559), `open` is frame 103 (1528:663); the two
/// arrays are index-aligned by petal so they morph cleanly.
private enum FlowerGeometry {
    static let closed = [
        "M79 85C79 85 83.5825 75 94 75C104.417 75 109 85 109 85C107.854 80.8333 105.25 70 94 70C82.75 70 80.1458 80.8333 79 85Z",
        "M113 89.7749C113 89.7749 123.939 90.9358 127.255 100.811C130.571 110.687 122.55 118.214 122.55 118.214C126.135 115.802 135.576 109.885 131.995 99.2197C128.413 88.5549 117.315 89.5348 113 89.7749Z",
        "M63.9796 117.397C63.9796 117.397 56.3212 109.501 60.0978 99.7923C63.8745 90.0835 74.8555 89.4381 74.8555 89.4381C70.5569 88.9954 59.5165 87.495 55.438 97.9797C51.3595 108.464 60.5118 114.819 63.9796 117.397Z",
        "M90.1073 139.544C90.1073 139.544 80.5421 144.976 72.0916 138.884C63.6411 132.792 65.7717 122 65.7717 122C64.2646 126.05 60.0418 136.361 69.1677 142.94C78.2935 149.518 86.7412 142.254 90.1073 139.544Z",
        "M121.784 122C121.784 122 123.633 132.843 115.027 138.714C106.421 144.584 97.0001 138.905 97.0001 138.905C100.295 141.701 108.551 149.184 117.844 142.844C127.138 136.505 123.185 126.088 121.784 122Z",
        "M77 117.031C80.0552 113.465 87.9033 113.157 90.8771 113.619C88.9047 115.541 82.0581 118.234 77 117.031Z",
        "M94.7047 130.272C91.7798 126.599 92.9568 118.833 93.9719 116C95.4872 118.299 96.8406 125.531 94.7047 130.272Z",
        "M111.239 118.762C106.673 119.856 100.137 115.502 98 113.382C100.725 112.983 107.849 114.82 111.239 118.762Z",
        "M106.379 109.234C104.367 111.655 99.1095 111.942 97.1114 111.662C98.414 110.354 102.976 108.479 106.379 109.234Z",
        "M94.0158 99C95.9044 101.518 94.9647 106.699 94.2295 108.578C93.2587 107.007 92.4924 102.135 94.0158 99Z",
        "M81 109.212C83.9063 108.003 88.6951 110.191 90.3345 111.367C88.5732 111.921 83.6623 111.461 81 109.212Z",
        "M86.1414 122.251C86.4276 119.117 90.5975 115.902 92.4025 115C92.0704 116.816 89.3733 120.946 86.1414 122.251Z",
        "M101.898 122.805C98.9209 121.782 96.7886 116.967 96.3417 115C98.0269 115.754 101.397 119.355 101.898 122.805Z",
        "M83.4748 98C87.92 99.5118 91.1229 106.683 91.7986 109.616C89.2814 108.499 84.2371 103.143 83.4748 98Z",
        "M106.042 99.0001C105.614 103.676 99.3929 108.47 96.7001 109.814C97.1963 107.105 101.221 100.946 106.042 99.0001Z",
    ]

    static let open = [
        "M88.241 101.814C88.241 101.814 90.0172 97.9381 94.0552 97.9381C98.0932 97.9381 99.8695 101.814 99.8695 101.814C99.4254 100.199 98.4159 96 94.0552 96C89.6945 96 88.6851 100.199 88.241 101.814Z",
        "M101.42 103.665C101.42 103.665 105.66 104.115 106.945 107.943C108.231 111.771 105.122 114.689 105.122 114.689C106.511 113.753 110.171 111.46 108.783 107.326C107.395 103.192 103.093 103.572 101.42 103.665Z",
        "M82.4187 114.372C82.4187 114.372 79.4502 111.311 80.9141 107.548C82.378 103.785 86.6344 103.534 86.6344 103.534C84.9682 103.363 80.6888 102.781 79.1079 106.845C77.527 110.909 81.0745 113.372 82.4187 114.372Z",
        "M92.5464 122.956C92.5464 122.956 88.8387 125.062 85.5632 122.7C82.2876 120.339 83.1135 116.156 83.1135 116.156C82.5293 117.726 80.8925 121.723 84.4298 124.273C87.9671 126.823 91.2416 124.007 92.5464 122.956Z",
        "M104.825 116.156C104.825 116.156 105.542 120.359 102.206 122.634C98.8698 124.91 95.2182 122.709 95.2182 122.709C96.4952 123.793 99.6954 126.693 103.298 124.236C106.9 121.778 105.368 117.74 104.825 116.156Z",
        "M69 119.031C72.0552 115.465 79.9033 115.157 82.8771 115.619C80.9047 117.541 74.0581 120.234 69 119.031Z",
        "M95.2047 137.272C92.2798 133.599 93.4568 125.833 94.4719 123C95.9872 125.299 97.3406 132.531 95.2047 137.272Z",
        "M118.239 120.762C113.673 121.856 107.137 117.502 105 115.382C107.725 114.983 114.849 116.82 118.239 120.762Z",
        "M118.267 103.992C116.256 106.413 110.998 106.7 109 106.42C110.303 105.112 114.865 103.236 118.267 103.992Z",
        "M93.5158 86C95.4044 88.5181 94.4647 93.699 93.7295 95.5779C92.7587 94.0075 91.9924 89.1351 93.5158 86Z",
        "M69 103.712C71.9063 102.503 76.6951 104.691 78.3345 105.867C76.5732 106.421 71.6623 105.961 69 103.712Z",
        "M77.1414 131.251C77.4276 128.116 81.5975 124.901 83.4025 124C83.0704 125.816 80.3733 129.946 77.1414 131.251Z",
        "M109.898 131.805C106.921 130.782 104.789 125.967 104.342 124C106.027 124.754 109.397 128.355 109.898 131.805Z",
        "M79.4748 91C83.92 92.5118 87.1229 99.6832 87.7986 102.616C85.2814 101.499 80.2371 96.1432 79.4748 91Z",
        "M110.042 92.0001C109.614 96.6757 103.393 101.47 100.7 102.814C101.196 100.105 105.221 93.9461 110.042 92.0001Z",
    ]

    static let mid = [
        "M76.3882 80.3043C76.3882 80.3043 81.9802 68.1014 94.6925 68.1014C107.405 68.1014 112.997 80.3043 112.997 80.3043C111.599 75.2198 108.421 62 94.6925 62C80.9643 62 77.7864 75.2198 76.3882 80.3043Z",
        "M117.878 86.1311C117.878 86.1311 131.226 87.5477 135.273 99.5987C139.32 111.65 129.532 120.835 129.532 120.835C133.906 117.891 145.427 110.671 141.057 97.6565C136.687 84.6424 123.143 85.838 117.878 86.1311Z",
        "M58.0591 119.838C58.0591 119.838 48.7136 110.203 53.3223 98.3553C57.9309 86.5077 71.3309 85.7201 71.3309 85.7201C66.0853 85.1799 52.6128 83.349 47.6359 96.1433C42.659 108.938 53.8274 116.692 58.0591 119.838Z",
        "M89.9424 146.863C89.9424 146.863 78.2702 153.492 67.9581 146.058C57.6461 138.624 60.2461 125.455 60.2461 125.455C58.4069 130.397 53.2539 142.979 64.3901 151.007C75.5262 159.035 85.8348 150.17 89.9424 146.863Z",
        "M128.597 125.455C128.597 125.455 130.853 138.687 120.351 145.85C109.85 153.014 98.3537 146.084 98.3537 146.084C102.374 149.496 112.449 158.627 123.79 150.891C135.131 143.155 130.307 130.443 128.597 125.455Z",
        "M36 129.031C39.0552 125.465 46.9033 125.157 49.8771 125.619C47.9047 127.541 41.0581 130.234 36 129.031Z",
        "M95.2047 171.272C92.2798 167.599 93.4568 159.833 94.4719 157C95.9872 159.3 97.3406 166.531 95.2047 171.272Z",
        "M149.239 130.153C144.673 131.247 138.137 126.892 136 124.773C138.725 124.374 145.849 126.21 149.239 130.153Z",
        "M106.379 109.234C104.367 111.655 99.1095 111.942 97.1114 111.662C98.414 110.354 102.976 108.479 106.379 109.234Z",
        "M94.0158 99C95.9044 101.518 94.9647 106.699 94.2295 108.578C93.2587 107.007 92.4924 102.135 94.0158 99Z",
        "M81 109.212C83.9063 108.003 88.6951 110.191 90.3345 111.367C88.5732 111.921 83.6623 111.461 81 109.212Z",
        "M86.1414 122.251C86.4276 119.117 90.5975 115.902 92.4025 115C92.0704 116.816 89.3733 120.946 86.1414 122.251Z",
        "M101.898 122.805C98.9209 121.782 96.7886 116.967 96.3417 115C98.0269 115.754 101.397 119.355 101.898 122.805Z",
        "M57.4748 64.0001C61.92 65.5119 65.1229 72.6833 65.7986 75.616C63.2814 74.499 58.2371 69.1433 57.4748 64.0001Z",
        "M132.042 62.9999C131.614 67.6756 125.393 72.4695 122.7 73.8135C123.196 71.1047 127.221 64.946 132.042 62.9999Z",
    ]

    static let closedOps = closed.map(SVGPath.ops)
    static let midOps = mid.map(SVGPath.ops)
    static let openOps = open.map(SVGPath.ops)
}

/// Minimal absolute-coordinate SVG path parser. Parses the M, L, C and Z
/// commands in the exported flower data into ordered ops, and interpolates two
/// structurally-identical paths point-by-point (matching Figma SMART_ANIMATE).
private enum SVGPath {
    struct Op { let cmd: Character; let nums: [CGFloat] }
    private enum Token { case command(Character), number(CGFloat) }

    static func ops(_ d: String) -> [Op] {
        let tokens = tokenize(d)
        var result: [Op] = []
        var index = 0
        var command: Character = " "

        func nextNumber() -> CGFloat {
            guard index < tokens.count, case .number(let value) = tokens[index] else { return 0 }
            index += 1
            return value
        }

        while index < tokens.count {
            if case .command(let c) = tokens[index] {
                command = c
                index += 1
                if c == "Z" || c == "z" {
                    result.append(Op(cmd: "Z", nums: []))
                    continue
                }
            }

            switch command {
            case "M":
                result.append(Op(cmd: "M", nums: [nextNumber(), nextNumber()]))
                command = "L" // extra pairs after M are implicit line-tos
            case "L":
                result.append(Op(cmd: "L", nums: [nextNumber(), nextNumber()]))
            case "C":
                result.append(Op(cmd: "C", nums: [
                    nextNumber(), nextNumber(), nextNumber(), nextNumber(), nextNumber(), nextNumber()
                ]))
            default:
                index += 1
            }
        }
        return result
    }

    static func interpolate(_ a: [Op], _ b: [Op], t: CGFloat) -> Path {
        var path = Path()
        for (oa, ob) in zip(a, b) {
            let n = zip(oa.nums, ob.nums).map { $0 + ($1 - $0) * t }
            switch oa.cmd {
            case "M": path.move(to: CGPoint(x: n[0], y: n[1]))
            case "L": path.addLine(to: CGPoint(x: n[0], y: n[1]))
            case "C": path.addCurve(to: CGPoint(x: n[4], y: n[5]),
                                    control1: CGPoint(x: n[0], y: n[1]),
                                    control2: CGPoint(x: n[2], y: n[3]))
            case "Z", "z": path.closeSubpath()
            default: break
            }
        }
        return path
    }

    private static func tokenize(_ d: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(d)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c.isLetter {
                tokens.append(.command(c))
                i += 1
            } else if c == "-" || c == "." || c.isNumber {
                var j = i
                if chars[j] == "-" { j += 1 }
                var seenDot = false
                while j < chars.count {
                    let d2 = chars[j]
                    if d2.isNumber {
                        j += 1
                    } else if d2 == "." && !seenDot {
                        seenDot = true
                        j += 1
                    } else {
                        break
                    }
                }
                if let value = Double(String(chars[i..<j])) {
                    tokens.append(.number(CGFloat(value)))
                }
                i = j
            } else {
                i += 1 // skip whitespace and commas
            }
        }
        return tokens
    }
}

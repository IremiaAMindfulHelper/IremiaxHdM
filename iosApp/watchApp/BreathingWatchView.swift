import SwiftUI

struct BreathingWatchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase = BreathPhase.inhale
    @State private var expanded = false
    @State private var countdown = 4

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(red: 90 / 255, green: 92 / 255, blue: 120 / 255)
                        .opacity(expanded ? 0.45 : 0.25),
                    Color(red: 38 / 255, green: 39 / 255, blue: 55 / 255),
                    Color(red: 28 / 255, green: 29 / 255, blue: 35 / 255)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 120
            )
            .ignoresSafeArea()

            BreathFlower(expanded: expanded)

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

                Text(phase.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text("\(countdown)")
                    .font(.system(size: 20, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .contentTransition(.numericText())
            }
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { animatePhase() }
        .onReceive(ticker) { _ in
            withAnimation(.easeInOut(duration: 0.3)) { countdown -= 1 }
            if countdown <= 0 {
                phase = phase.next
                countdown = 4
                animatePhase()
            }
        }
    }

    private func animatePhase() {
        switch phase {
        case .inhale:
            withAnimation(.easeInOut(duration: 4)) { expanded = true }
        case .hold:
            break
        case .exhale:
            withAnimation(.easeInOut(duration: 4)) { expanded = false }
        }
    }
}

private enum BreathPhase {
    case inhale, hold, exhale

    var label: String {
        switch self {
        case .inhale: "Breathe in"
        case .hold: "Hold"
        case .exhale: "Breathe out"
        }
    }

    var next: BreathPhase {
        switch self {
        case .inhale: .hold
        case .hold: .exhale
        case .exhale: .inhale
        }
    }
}

private struct BreathFlower: View {
    let expanded: Bool
    private let petalCount = 7

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(expanded ? 0.25 : 0.15))
                .frame(width: expanded ? 10 : 6, height: expanded ? 10 : 6)

            ForEach(0..<petalCount, id: \.self) { i in
                Ellipse()
                    .fill(
                        Color(red: 90 / 255, green: 92 / 255, blue: 120 / 255)
                            .opacity(expanded ? 0.7 : 0.4)
                    )
                    .frame(width: expanded ? 22 : 10, height: expanded ? 32 : 12)
                    .offset(y: expanded ? -38 : -6)
                    .rotationEffect(.degrees(Double(i) * 360.0 / Double(petalCount)))
            }
        }
    }
}

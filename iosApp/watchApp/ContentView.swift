import SwiftUI

struct ContentView: View {
    @State private var selectedMood: MoodLevel?

    var body: some View {
        NavigationStack {
            if selectedMood == nil {
                MoodCheckView { mood in
                    JourneyStore.shared.add(mood: mood)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMood = mood
                    }
                } onDismiss: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMood = .neutral
                    }
                }
            } else {
                HomeMenuView()
            }
        }
    }
}

private struct HomeMenuView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let bubble = w * 0.235
            let quickHelp = w * 0.285
            let small = w * 0.155

            ZStack {
                BottomGlow()
                    .frame(width: w * 1.05, height: w * 1.05)
                    .position(x: w * 0.5, y: h * 1.02)

                MessageOfDayBanner()
                    .frame(width: w * 0.88, height: h * 0.19)
                    .position(x: w * 0.5, y: h * 0.20)

                NavigationLink {
                    BreathingWatchView()
                } label: {
                    BubbleButton(title: "Breathe", size: bubble)
                }
                .buttonStyle(.plain)
                .position(x: w * 0.500, y: h * 0.46)

                NavigationLink {
                    LearnPlaceholderView()
                } label: {
                    BubbleButton(title: "Learn", size: bubble)
                }
                .buttonStyle(.plain)
                .position(x: w * 0.155, y: h * 0.61)

                NavigationLink {
                    JourneyView()
                } label: {
                    BubbleButton(title: "Journey", size: bubble)
                }
                .buttonStyle(.plain)
                .position(x: w * 0.845, y: h * 0.61)

                NavigationLink {
                    EmergencyVoiceView()
                } label: {
                    QuickHelpButton(size: quickHelp)
                }
                .buttonStyle(.plain)
                .position(x: w * 0.500, y: h * 0.79)

                NavigationLink {
                    EmergencyVoiceView()
                } label: {
                    SmallIconButton(icon: "mic.fill", size: small)
                }
                .buttonStyle(.plain)
                .position(x: w * 0.115, y: h * 0.86)

                NavigationLink {
                    ContactsListView()
                } label: {
                    SmallIconButton(icon: "gearshape.fill", size: small)
                }
                .buttonStyle(.plain)
                .position(x: w * 0.885, y: h * 0.86)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MessageOfDayBanner: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.iremiaBannerTeal,
                            Color.iremiaBannerTeal.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 1) {
                Text("Message of the day")
                    .font(.system(size: 10, weight: .semibold))
                Text("Lorem ipsum dolor est")
                    .font(.system(size: 10, weight: .regular))
            }
            .foregroundStyle(Color.iremiaLabel)
            .padding(.leading, 9)
            .padding(.top, 5)
        }
    }
}

private struct BubbleButton: View {
    let title: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.iremiaPetrol)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.iremiaLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: size, height: size)
    }
}

private struct QuickHelpButton: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.iremiaQuickHelp)
                .shadow(color: Color.iremiaQuickHelp.opacity(0.55), radius: 6)
            Text("Quick\nhelp")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(-2)
        }
        .frame(width: size, height: size)
    }
}

private struct SmallIconButton: View {
    let icon: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.iremiaPetrol)
            Image(systemName: icon)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

private struct BottomGlow: View {
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.iremiaPetrol.opacity(0.55),
                        Color.iremiaPetrol.opacity(0.0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 110
                )
            )
            .allowsHitTesting(false)
    }
}

private struct LearnPlaceholderView: View {
    var body: some View {
        PlaceholderContent(icon: "book.fill", title: "Learn")
            .navigationTitle("Learn")
    }
}

private struct PlaceholderContent: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundStyle(Color.iremiaPrimary)
            Text(title)
                .font(.headline)
            Text("Coming soon")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

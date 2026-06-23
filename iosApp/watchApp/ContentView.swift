import SwiftUI

struct ContentView: View {
    @State private var moodFlowStep: MoodFlowStep = .initial

    var body: some View {
        NavigationStack {
            switch moodFlowStep {
            case .initial:
                MoodCheckView { mood in
                    JourneyStore.shared.add(mood: mood)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if mood == .good {
                            moodFlowStep = .goodResponse
                        } else {
                            moodFlowStep = .category(mood)
                        }
                    }
                } onDismiss: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        moodFlowStep = .done
                    }
                }

            case .goodResponse:
                GoodResponseView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        moodFlowStep = .done
                    }
                }

            case .category(let mood):
                MoodCategoryView(mood: mood) { category in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        moodFlowStep = .detail(mood, category)
                    }
                } onMicCompleted: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        moodFlowStep = .done
                    }
                }

            case .detail(let mood, let category):
                MoodDetailView(mood: mood, category: category) { detail in
                    // Journey context is attached by MoodResponseView once the
                    // Claude response (or its local fallback) is known.
                    withAnimation(.easeInOut(duration: 0.3)) {
                        moodFlowStep = .response(mood, category, detail)
                    }
                } onMicCompleted: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        moodFlowStep = .done
                    }
                }

            case .response(let mood, let category, let detail):
                MoodResponseView(mood: mood, category: category, detail: detail) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        moodFlowStep = .done
                    }
                }

            case .done:
                HomeMenuView()
            }
        }
    }
}

private enum MoodFlowStep {
    case initial
    case goodResponse
    case category(MoodLevel)
    case detail(MoodLevel, MoodCategory)
    case response(MoodLevel, MoodCategory, MoodDetail)
    case done
}

private struct GoodResponseView: View {
    var onDone: () -> Void
    @State private var appeared = false
    @State private var message: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DecorativeCirclesView(mood: .good).ignoresSafeArea()

            if let message {
                VStack(spacing: 16) {
                    Spacer(minLength: 0)

                    Text(message)
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.iremiaResponseText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)

                    Button { onDone() } label: {
                        Text("Continue")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.iremiaPetrol)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(Color.iremiaLabel))
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .tint(Color.iremiaLabel)
                    .scaleEffect(0.9)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5), value: appeared)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { appeared = true }
        .task {
            // Record the good mood in the shared Claude history too, so later
            // check-ins can reference it. Falls back to the static message.
            let response = await WatchConnectivityManager.shared.requestMoodResponse(
                mood: "Good", category: nil, detail: nil
            )
            let text = response ?? "That's great!\nKeep it up"
            JourneyStore.shared.attachResponse(text)
            withAnimation(.easeOut(duration: 0.3)) {
                message = text
            }
        }
    }
}

private struct HomeMenuView: View {
    // Figma reference frame ("Apple Watch Series 10 42mm"): 187 × 223 pt.
    // Everything is laid out in these coordinates, then scaled by a single
    // factor and centred — so the spacing is a pixel-faithful copy of the
    // Figma design and stays identical across every watch size (40–49 mm all
    // share ~0.84 aspect). Sizing and gaps scale together, so nothing overlaps.
    private static let refW: CGFloat = 187
    private static let refH: CGFloat = 223

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / Self.refW, geo.size.height / Self.refH)
            let ox = (geo.size.width - Self.refW * s) / 2
            let oy = (geo.size.height - Self.refH * s) / 2

            // On-screen point for a Figma centre coordinate: ox + x*s, oy + y*s.
            ZStack {
                BottomGlow()
                    .frame(width: 187 * s, height: 187 * s)
                    .position(x: ox + 93.5 * s, y: oy + 242.5 * s)

                MessageOfDayBanner()
                    .frame(width: 163 * s, height: 42 * s)
                    .position(x: ox + 93.5 * s, y: oy + 50 * s)

                // Breathe — top centre
                NavigationLink {
                    BreathingWatchView()
                } label: {
                    BubbleButton(title: "Breathe", size: 51 * s)
                }
                .buttonStyle(.plain)
                .position(x: ox + 94 * s, y: oy + 103.5 * s)

                // Learn — mid left
                NavigationLink {
                    LearnPlaceholderView()
                } label: {
                    BubbleButton(title: "Learn", size: 51 * s)
                }
                .buttonStyle(.plain)
                .position(x: ox + 38 * s, y: oy + 137.5 * s)

                // Journey — mid right
                NavigationLink {
                    JourneyView()
                } label: {
                    BubbleButton(title: "Journey", size: 51 * s)
                }
                .buttonStyle(.plain)
                .position(x: ox + 150 * s, y: oy + 137.5 * s)

                // Microphone — big centre button → emergency voice access
                NavigationLink {
                    EmergencyVoiceView()
                } label: {
                    MicCenterButton(size: 52 * s)
                }
                .buttonStyle(.plain)
                .position(x: ox + 94 * s, y: oy + 167 * s)

                // SOS — bottom left → emergency contacts
                NavigationLink {
                    ContactsListView()
                } label: {
                    SosButton(size: 33 * s)
                }
                .buttonStyle(.plain)
                .position(x: ox + 40 * s, y: oy + 197 * s)

                // Settings — bottom right → placeholder
                NavigationLink {
                    SettingsPlaceholderView()
                } label: {
                    SettingsButton(size: 33 * s)
                }
                .buttonStyle(.plain)
                .position(x: ox + 145 * s, y: oy + 195 * s)
            }
        }
        .ignoresSafeArea()
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MessageOfDayBanner: View {
    @ObservedObject private var store = DailyMessageStore.shared

    var body: some View {
        ZStack {
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

            Text(store.message)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.iremiaLabel)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 9)
        }
        .task { await store.refresh() }
    }
}

private struct BubbleButton: View {
    let title: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.iremiaEntryBg)
                .overlay(Circle().stroke(Color.iremiaBannerTeal, lineWidth: 1))
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.iremiaCategoryLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: size, height: size)
    }
}

private struct MicCenterButton: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.iremiaBannerTeal.opacity(0.2))
                .overlay(Circle().stroke(Color.iremiaBannerTeal, lineWidth: 1.5))
            Image(systemName: "mic.fill")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

private struct SosButton: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.iremiaSOS)
                .overlay(Circle().stroke(Color.iremiaSOSStroke, lineWidth: 1))
            Text("SOS")
                .font(.system(size: size * 0.32, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: size, height: size)
    }
}

private struct SettingsButton: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.iremiaBannerTeal)
            Image(systemName: "gearshape.fill")
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

private struct SettingsPlaceholderView: View {
    var body: some View {
        PlaceholderContent(icon: "gearshape.fill", title: "Settings")
            .navigationTitle("Settings")
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

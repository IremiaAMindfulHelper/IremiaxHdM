import SwiftUI

// Shared teal→black gradient used on all mood-check screens (matches Journey/other pages)
private var moodGradient: LinearGradient {
    LinearGradient(
        colors: [Color.iremiaJourneyTeal.opacity(0.40), Color.black],
        startPoint: .top,
        endPoint: UnitPoint(x: 0.5, y: 0.72)
    )
}

// MARK: - MoodLevel

enum MoodLevel: String, CaseIterable {
    case good, neutral, bad

    var emoji: String {
        switch self {
        case .good: return "😊"
        case .neutral: return "😐"
        case .bad: return "😞"
        }
    }

    var color: Color {
        switch self {
        case .good: return Color(red: 145/255, green: 255/255, blue: 106/255)
        case .neutral: return Color(red: 255/255, green: 255/255, blue: 124/255)
        case .bad: return Color(red: 255/255, green: 114/255, blue: 114/255)
        }
    }

    var label: String {
        switch self {
        case .good: return "Good"
        case .neutral: return "Okay"
        case .bad: return "Bad"
        }
    }

    // Weather-concept icons from Figma (mid-fidelity-wireframe-concepts, frame 1558:1608).
    // Vector SVGs in Assets.xcassets, already tinted to the Figma teal (#A4DFDD).
    var iconName: String {
        switch self {
        case .good: return "mood_good"
        case .neutral: return "mood_okay"
        case .bad: return "mood_bad"
        }
    }
}

// MARK: - MoodCategory

enum MoodCategory: String, CaseIterable {
    case body = "Body"
    case life = "Life"
    case mind = "Mind"

    // allCases order maps to BubbleTriangle: [top, bottom-left, bottom-right]
    // Figma: Body(top), Life(bottom-left), Mind(bottom-right)

    var details: [MoodDetail] {
        switch self {
        case .body: return [.breath, .heart, .nausea]
        case .life: return [.stress, .health, .people]
        case .mind: return [.tired, .anxious, .sad]
        }
    }
}

// MARK: - MoodDetail

enum MoodDetail: String {
    case breath = "Breath"
    case heart = "Heart"
    case nausea = "Nausea"
    case stress = "Stress"
    case health = "Health"
    case people = "People"
    case tired = "Tired"
    case anxious = "Anxious"
    case sad = "Sad"
}

// MARK: - Personalized Responses

struct MoodResponses {
    static func message(mood: MoodLevel, category: MoodCategory, detail: MoodDetail) -> String {
        switch mood {
        case .good:
            return positiveMessage(category: category, detail: detail)
        case .neutral, .bad:
            return supportiveMessage(category: category, detail: detail)
        }
    }

    private static func positiveMessage(category: MoodCategory, detail: MoodDetail) -> String {
        switch (category, detail) {
        case (.body, .breath): return "Your breath is steady. Stay present — your body is carrying you well."
        case (.body, .heart): return "Your heart is with you. That energy you feel is strength."
        case (.body, .nausea): return "You're pushing through. Even small steps forward matter today."
        case (.life, .stress): return "You're managing well. Take a moment to appreciate how far you've come."
        case (.life, .health): return "Your body is working for you. Keep nurturing it — it's paying off."
        case (.life, .people): return "The connections around you are a gift. Hold onto that warmth."
        case (.mind, .tired): return "Rest is strength. You're doing more than you realise."
        case (.mind, .anxious): return "Even with some tension, you're showing up. That counts."
        case (.mind, .sad): return "That's great! Keep it up — you're doing better than you think."
        default: return "That's great! Keep it up."
        }
    }

    private static func supportiveMessage(category: MoodCategory, detail: MoodDetail) -> String {
        switch (category, detail) {
        case (.body, .breath): return "Try a slow breath in for 4 counts, hold for 4, out for 4. Your body knows how to settle."
        case (.body, .heart): return "Heart sensations can feel intense. Ground yourself — name 3 things you can see right now."
        case (.body, .nausea): return "Being unwell is tough. Rest is not weakness — your body needs care right now."
        case (.life, .stress): return "Life's pressures are real. Focus on one small thing you can control today."
        case (.life, .health): return "Your health matters. Even rest and gentleness are a form of progress."
        case (.life, .people): return "Relationships can weigh on us. It's okay to step back and protect your peace."
        case (.mind, .tired): return "A tired mind needs rest, not more demands. Give yourself permission to slow down."
        case (.mind, .anxious): return "Anxiety can feel overwhelming. Ground yourself: name 3 things you can see right now."
        case (.mind, .sad): return "Sadness is a signal, not a flaw. Be gentle with yourself — this will pass."
        default: return "Take a slow breath. You are safe."
        }
    }
}

// MARK: - Mood Icon (Figma weather-concept vectors)

/// Renders the Figma weather mood icon, scaled to fit a square box of `size`.
/// Drop-in replacement for the old `MoodFaceView` circle (icons are wider than tall,
/// so they sit centred within the box and never exceed `size` in width).
///
/// Pass `tint` to recolor the icon (template rendering) — e.g. the darker
/// `#0A5C5A` used on bright list-row backgrounds. When `tint` is nil the icon
/// keeps the Figma teal (#A4DFDD) baked into the SVG.
struct MoodIconView: View {
    let mood: MoodLevel
    let size: CGFloat
    var tint: Color? = nil

    var body: some View {
        icon
            .resizable()
            .scaledToFit()
            .foregroundStyle(tint ?? Color.iremiaJourneyTitle)
            .frame(width: size, height: size)
    }

    private var icon: Image {
        if tint != nil {
            return Image(mood.iconName).renderingMode(.template)
        } else {
            return Image(mood.iconName)
        }
    }
}

// MARK: - Choice Bubble

private struct ChoiceBubble: View {
    let title: String
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.iremiaCategoryBubble)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.iremiaCategoryLabel)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mic Button

private struct MicButton: View {
    let size: CGFloat
    var onTap: () -> Void = {}

    var body: some View {
        Button { onTap() } label: {
            ZStack {
                Circle().fill(Color.iremiaPetrol)
                Image(systemName: "mic.fill")
                    .font(.system(size: size * 0.3, weight: .semibold))
                    .foregroundStyle(Color.iremiaLabel)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 1: Initial Mood Check

struct MoodCheckView: View {
    var onMoodSelected: (MoodLevel) -> Void
    var onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            moodGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("How are you\nfeeling today?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.iremiaLabel)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                HStack(spacing: 12) {
                    ForEach(MoodLevel.allCases, id: \.self) { mood in
                        Button {
                            onMoodSelected(mood)
                        } label: {
                            VStack(spacing: 8) {
                                MoodIconView(mood: mood, size: 48)
                                Text(mood.label)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.iremiaJourneyTitle)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
                .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                Spacer()

                Button { onDismiss() } label: {
                    Text("Dismiss")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.iremiaDismiss)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 6)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - BubbleTriangle layout helper

private struct BubbleTriangle: View {
    let items: [String]
    let onSelect: (Int) -> Void
    let bubbleSize: CGFloat
    var onMicTap: () -> Void = {}

    var body: some View {
        // Figma-exact diamond: step = 30px in 51px circles → 21px overlap per row.
        // The previous "cramped" look was wrong horizontal spacing; Spacer() now
        // places Life/Mind at 20% / 80% of available width, matching the Figma.
        let overlap = bubbleSize * 0.41

        VStack(spacing: -overlap) {
            // top circle — centered, on top visually in overlap region
            if items.count >= 1 {
                ChoiceBubble(title: items[0], size: bubbleSize) { onSelect(0) }
                    .zIndex(3)
            }
            // bottom-left and bottom-right — spread to Figma's 12px margins (~8pt on watch)
            if items.count >= 3 {
                HStack {
                    ChoiceBubble(title: items[1], size: bubbleSize) { onSelect(1) }
                    Spacer()
                    ChoiceBubble(title: items[2], size: bubbleSize) { onSelect(2) }
                }
                .padding(.horizontal, 8)
                .zIndex(2)
            }
            // mic at bottom center — behind choice bubbles in the overlap region
            MicButton(size: bubbleSize, onTap: onMicTap)
                .zIndex(1)
        }
    }
}

// MARK: - Step 2: Category Selection

struct MoodCategoryView: View {
    let mood: MoodLevel
    var onCategorySelected: (MoodCategory) -> Void
    var onMicCompleted: (() -> Void)?

    @State private var showMic = false

    var body: some View {
        ZStack {
            moodGradient.ignoresSafeArea()

            VStack {
                Text("What made you\nfeel this way?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.iremiaLabel)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.top, 4)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                BubbleTriangle(
                    items: MoodCategory.allCases.map { $0.rawValue },
                    onSelect: { i in onCategorySelected(MoodCategory.allCases[i]) },
                    bubbleSize: 51,
                    onMicTap: { showMic = true }
                )
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showMic) {
            MoodMicView {
                showMic = false
                onMicCompleted?()
            } onCancel: {
                showMic = false
            }
        }
    }
}

// MARK: - Step 3: Detail Selection

struct MoodDetailView: View {
    let mood: MoodLevel
    let category: MoodCategory
    var onDetailSelected: (MoodDetail) -> Void
    var onMicCompleted: (() -> Void)?

    @State private var showMic = false

    var body: some View {
        ZStack {
            moodGradient.ignoresSafeArea()

            VStack {
                Text("What about your \(category.rawValue.lowercased())\nmade you feel that?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.iremiaLabel)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.top, 4)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                BubbleTriangle(
                    items: category.details.map { $0.rawValue },
                    onSelect: { i in onDetailSelected(category.details[i]) },
                    bubbleSize: 51,
                    onMicTap: { showMic = true }
                )
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showMic) {
            MoodMicView {
                showMic = false
                onMicCompleted?()
            } onCancel: {
                showMic = false
            }
        }
    }
}

// MARK: - Step 4: Personalized Response (Claude, with local fallback)

struct MoodResponseView: View {
    let mood: MoodLevel
    let category: MoodCategory
    let detail: MoodDetail
    var onDone: () -> Void

    @State private var appeared = false
    @State private var message: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            DecorativeCirclesView(mood: mood)
                .ignoresSafeArea()

            if let message {
                VStack(spacing: 16) {
                    Spacer(minLength: 0)

                    Text(message)
                        .font(.system(size: 13, weight: .medium))
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
            let response = await WatchConnectivityManager.shared.requestMoodResponse(
                mood: mood.label,
                category: category.rawValue,
                detail: detail.rawValue
            ) ?? MoodResponses.message(mood: mood, category: category, detail: detail)
            JourneyStore.shared.attachMoodContext(
                category: category.rawValue,
                detail: detail.rawValue,
                response: response
            )
            withAnimation(.easeOut(duration: 0.3)) { message = response }
        }
    }
}

// MARK: - Decorative circles background (matches Figma frames 28 & 38)

struct DecorativeCirclesView: View {
    let mood: MoodLevel

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                if mood == .good {
                    // Frame 28 circle positions (normalized to 187x223)
                    circle(w: w, h: h, cx: 0.90, cy: 0.91, r: 0.23)
                    circle(w: w, h: h, cx: 0.13, cy: 0.68, r: 0.31)
                    circle(w: w, h: h, cx: 0.90, cy: -0.02, r: 0.31)
                    circle(w: w, h: h, cx: 0.40, cy: 0.89, r: 0.11)
                    circle(w: w, h: h, cx: 0.24, cy: 0.14, r: 0.14)
                } else {
                    // Frame 38 circle positions (normalized to 187x223)
                    circle(w: w, h: h, cx: 0.95, cy: 1.00, r: 0.22)
                    circle(w: w, h: h, cx: 0.05, cy: 0.92, r: 0.41)
                    circle(w: w, h: h, cx: 0.93, cy: -0.02, r: 0.28)
                    circle(w: w, h: h, cx: 0.96, cy: 0.64, r: 0.12)
                    circle(w: w, h: h, cx: 0.23, cy: 0.15, r: 0.14)
                    circle(w: w, h: h, cx: 0.36, cy: 0.04, r: 0.20)
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func circle(w: CGFloat, h: CGFloat, cx: CGFloat, cy: CGFloat, r: CGFloat) -> some View {
        let radius = r * w
        return Circle()
            .fill(Color.iremiaPetrol.opacity(0.55))
            .frame(width: radius * 2, height: radius * 2)
            .position(x: cx * w, y: cy * h)
    }
}

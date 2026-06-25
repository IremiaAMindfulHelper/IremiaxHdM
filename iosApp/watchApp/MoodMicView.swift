import SwiftUI

// MARK: - Shared voice input

/// The single voice-input surface used everywhere in the Watch app (mood
/// check-in and emergency). It records via `VoiceCaptureController`, shows the
/// live transcript streamed back from the iPhone, and ends in either a response
/// or an error — there is no canned fallback text.
struct VoiceInputView: View {
    /// Called once with the final transcript + response so the caller can log
    /// the session in the Journey.
    var onLogged: (_ transcript: String, _ response: String) -> Void
    /// Dismiss after a response (or after acknowledging an error).
    var onClose: () -> Void
    /// Dismiss after the user cancelled while listening.
    var onCancel: () -> Void

    @StateObject private var controller = VoiceCaptureController()
    // Observe the shared singleton directly rather than via @EnvironmentObject:
    // this view is presented through a fullScreenCover (mood flow), which does
    // not reliably inherit environment objects.
    @ObservedObject private var connectivity = WatchConnectivityManager.shared

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GeometryReader { geo in
                Circle()
                    .fill(Color.iremiaPetrol.opacity(0.18))
                    .frame(width: geo.size.width, height: geo.size.width)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.82)
            }
            .ignoresSafeArea()

            switch controller.phase {
            case .idle, .listening:
                listeningView
            case .processing:
                ProgressView()
                    .tint(Color.iremiaLabel)
                    .scaleEffect(0.9)
            case .responded(let text):
                resultView(text, isError: false)
            case .error(let text):
                resultView(text, isError: true)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await controller.begin() }
        .onDisappear { controller.teardown() }
    }

    // MARK: Listening

    private var listeningView: some View {
        VStack(spacing: 0) {
            Text("Listening...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.iremiaLabel)
                .padding(.top, 8)

            if !connectivity.liveTranscript.isEmpty {
                Text(connectivity.liveTranscript)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.iremiaLabel.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .lineLimit(2)
            }

            Spacer()

            HStack(spacing: 5) {
                LeftWaveformBars(level: controller.level)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Button { Task { await controller.stopAndRespond() } } label: {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.iremiaPetrol)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                RightWaveformBars(level: controller.level)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 6)

            Spacer()

            Button {
                controller.cancel()
                onCancel()
            } label: {
                Text("Cancel")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.iremiaLabel)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Response / error

    private func resultView(_ text: String, isError: Bool) -> some View {
        ZStack {
            DecorativeCirclesView(mood: .bad).ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer(minLength: 0)
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.iremiaResponseText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                Button {
                    if !isError {
                        onLogged(controller.transcript, text)
                    }
                    onClose()
                } label: {
                    Text(isError ? "Close" : "Continue")
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
        }
        .ignoresSafeArea()
    }
}

// MARK: - Mood check-in entry point

struct MoodMicView: View {
    var onComplete: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VoiceInputView(
            onLogged: { _, response in
                JourneyStore.shared.attachMoodContext(
                    category: "Voice", detail: "Check-in", response: response
                )
            },
            onClose: onComplete,
            onCancel: onCancel
        )
    }
}

// MARK: - Waveform bars (shared by every voice screen)

struct LeftWaveformBars: View {
    let level: Float
    private let heights:     [CGFloat] = [0.10, 0.18, 0.30, 0.55, 0.80, 1.00, 0.70, 0.45]
    private let frequencies: [Double]  = [1.9,  2.4,  2.1,  1.4,  1.3,  0.9,  1.7,  1.5]
    private let phases:      [Double]  = [1.2,  3.5,  0.4,  2.3,  0.0,  0.8,  1.5,  2.9]

    var body: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let amp = 0.18 + CGFloat(level)
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<heights.count, id: \.self) { i in
                    let osc = CGFloat(abs(sin(t * frequencies[i] + phases[i])))
                    Capsule()
                        .fill(Color.iremiaLabel)
                        .frame(width: 3, height: max(4, 36 * heights[i] * osc * amp))
                }
            }
            .frame(height: 40)
        }
    }
}

struct RightWaveformBars: View {
    let level: Float
    private let heights:     [CGFloat] = [0.65, 1.00, 0.60, 0.42, 0.28, 0.20, 0.15, 0.12]
    private let frequencies: [Double]  = [1.1,  0.8,  1.5,  1.2,  1.8,  2.3,  1.6,  1.0]
    private let phases:      [Double]  = [3.1,  1.8,  0.2,  2.7,  1.1,  3.8,  0.6,  2.1]

    var body: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let amp = 0.18 + CGFloat(level)
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<heights.count, id: \.self) { i in
                    let osc = CGFloat(abs(sin(t * frequencies[i] + phases[i])))
                    Capsule()
                        .fill(Color.iremiaLabel)
                        .frame(width: 3, height: max(4, 36 * heights[i] * osc * amp))
                }
            }
            .frame(height: 40)
        }
    }
}

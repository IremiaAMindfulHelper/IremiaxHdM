import SwiftUI
import AVFoundation

let moodMicResponse =
    "It sounds like your body is working hard right now. That's okay — it's trying to protect you. Place one hand on your chest, breathe in slowly for 4 counts, and out for 4. You're doing well."

// MARK: - Mic level monitor

@MainActor
final class MicLevelMonitor: ObservableObject {
    @Published var level: Float = 0

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var smoothed: Float = 0

    func start() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setActive(true)
        } catch { return }

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("iremia_mic_level.caf")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44_100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        guard let rec = try? AVAudioRecorder(url: url, settings: settings) else { return }
        rec.isMeteringEnabled = true
        rec.record()
        recorder = rec

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            rec.updateMeters()
            let db = rec.averagePower(forChannel: 0)
            // Threshold at -35 dB (ignores ambient noise), peaks at -5 dB.
            // Tighter range makes the level jump quickly when someone speaks.
            let mapped = max(0, min(1, (db + 35) / 30))
            Task { @MainActor in
                // Fast attack so bars react immediately; slow decay so they
                // don't snap back the instant someone stops speaking.
                let alpha: Float = mapped > self.smoothed ? 0.25 : 0.90
                self.smoothed = self.smoothed * alpha + mapped * (1 - alpha)
                self.level = self.smoothed
            }
        }
    }

    func stop() {
        timer?.invalidate(); timer = nil
        recorder?.stop(); recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        level = 0
    }
}

// MARK: - Recording screen

struct MoodMicView: View {
    var onComplete: () -> Void
    var onCancel: () -> Void

    @StateObject private var monitor = MicLevelMonitor()
    @State private var phase: Phase = .listening

    enum Phase { case listening, processing, responded }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Background circle positioned in lower half matching Figma Ellipse 35
            GeometryReader { geo in
                Circle()
                    .fill(Color.iremiaPetrol.opacity(0.18))
                    .frame(width: geo.size.width, height: geo.size.width)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.82)
            }
            .ignoresSafeArea()

            switch phase {
            case .listening:
                listeningView

            case .processing:
                ProgressView()
                    .tint(Color.iremiaLabel)
                    .scaleEffect(0.9)

            case .responded:
                ZStack {
                    DecorativeCirclesView(mood: .bad).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Spacer(minLength: 0)
                        Text(moodMicResponse)
                            .font(.system(size: 13, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.iremiaResponseText)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16)
                        Button {
                            JourneyStore.shared.attachMoodContext(
                                category: "Body",
                                detail: "Heart",
                                response: moodMicResponse
                            )
                            onComplete()
                        } label: {
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
                }
                .ignoresSafeArea()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                Task { @MainActor in if granted { monitor.start() } }
            }
        }
        .onDisappear { monitor.stop() }
        .task {
            // 15 s safety fallback — user can stop manually via the stop button
            try? await Task.sleep(for: .seconds(15))
            guard phase == .listening else { return }
            stopAndProcess()
        }
    }

    // MARK: Listening layout

    private var listeningView: some View {
        VStack(spacing: 0) {
            Text("Listening...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.iremiaLabel)
                .padding(.top, 8)

            Spacer()

            // HStack(spacing:5) + frame(maxWidth:.infinity) on both bar sides gives
            // each exactly (available − button − 2×spacing) / 2 wide, so the
            // button lands at the mathematical centre on any screen size.
            // Left bars trail-align so they press right up to the 5pt gap;
            // right bars lead-align so they do the same from the other side.
            HStack(spacing: 5) {
                LeftWaveformBars(level: monitor.level)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                StopButtonView { stopAndProcess() }
                RightWaveformBars(level: monitor.level)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 6)

            Spacer()

            Button { stopAndCancel() } label: {
                Text("Cancel")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.iremiaLabel)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stopAndProcess() {
        monitor.stop()
        withAnimation(.easeInOut(duration: 0.3)) { phase = .processing }
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            withAnimation(.easeInOut(duration: 0.4)) { phase = .responded }
        }
    }

    private func stopAndCancel() {
        monitor.stop()
        onCancel()
    }
}

// MARK: - Stop button (Figma Rectangle 28: 39×39, rgb 9,91,90)

private struct StopButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.iremiaPetrol)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Left waveform (Figma Group 21 — 5 bars, x=4 to x=60)

struct LeftWaveformBars: View {
    let level: Float
    // 8 bars (same count as right) so both groups are 52pt wide and extend
    // equally close to their screen edge. Heights build toward the button
    // (rightmost = nearest to button).
    private let heights:     [CGFloat] = [0.10, 0.18, 0.30, 0.55, 0.80, 1.00, 0.70, 0.45]
    private let frequencies: [Double]  = [1.9,  2.4,  2.1,  1.4,  1.3,  0.9,  1.7,  1.5]
    private let phases:      [Double]  = [1.2,  3.5,  0.4,  2.3,  0.0,  0.8,  1.5,  2.9]

    var body: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            // Additive: small idle baseline so bars always move gently,
            // plus the real audio level on top for a clear jump when speaking.
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

// MARK: - Right waveform (Figma Group 22 — 8 bars, x=127 to x=182)

struct RightWaveformBars: View {
    let level: Float
    // Boost the far-end bars so all 8 bars are visibly animated throughout.
    private let heights:     [CGFloat] = [0.65, 1.00, 0.60, 0.42, 0.28, 0.20, 0.15, 0.12]
    private let frequencies: [Double]  = [1.1,  0.8,  1.5,  1.2,  1.8,  2.3,  1.6,  1.0]
    private let phases:      [Double]  = [3.1,  1.8,  0.2,  2.7,  1.1,  3.8,  0.6,  2.1]

    var body: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            // Additive: small idle baseline so bars always move gently,
            // plus the real audio level on top for a clear jump when speaking.
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

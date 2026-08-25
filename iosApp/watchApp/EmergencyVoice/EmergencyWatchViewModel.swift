import Foundation
import AVFoundation

/// Shared engine behind every voice input in the Watch app.
///
/// The Watch records audio and streams it to the iPhone, which transcribes it
/// live (pushing partials back into `WatchConnectivityManager.liveTranscript`).
/// On stop the iPhone returns the transcript and, when it can, the Claude answer
/// — the original path, used whenever the phone is unlocked.
///
/// A locked iPhone can still transcribe but can't read the API key, so it
/// returns the transcript without an answer; in that case the Watch computes the
/// answer itself with `WatchClaudeAssistant` (same model, system prompt and
/// knowledge base). This is what keeps voice working while the iPhone is locked.
/// Any failure ends in `.error`; there are no canned fallback sentences.
@MainActor
final class VoiceCaptureController: ObservableObject {
    enum Phase: Equatable {
        case idle
        case listening
        case processing
        case responded(String)
        case error(String)
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var level: Float = 0

    /// Final transcript of the last session (for the Journey log).
    private(set) var transcript: String = ""

    private let engine = AVAudioEngine()
    private var streaming = false

    // Lifecycle

    func begin() async {
        guard case .idle = phase else { return }

        let granted = await requestMicPermission()
        guard granted else {
            phase = .error("Microphone access is needed to speak. Enable it in Settings.")
            return
        }
        guard await WatchConnectivityManager.shared.startVoice() else {
            phase = .error("Can't reach your iPhone. Open the Iremia app on your phone and try again.")
            return
        }
        do {
            try startEngine()
            phase = .listening
        } catch {
            WatchConnectivityManager.shared.cancelVoice()
            phase = .error("Couldn't start recording. Please try again.")
        }
    }

    /// User tapped stop — finish streaming and show the answer. The iPhone always
    /// returns the transcript; it also returns the answer when it can compute one
    /// (typically while unlocked). When it can't — e.g. it's locked and can't
    /// read the API key — the Watch answers itself using the transcript, so voice
    /// still works.
    func stopAndRespond() async {
        guard case .listening = phase else { return }
        stopEngine()
        phase = .processing

        guard let result = await WatchConnectivityManager.shared.finishVoice() else {
            phase = .error("Something didn't work. Please try again.")
            return
        }
        transcript = result.transcript
        if let response = result.response {
            phase = .responded(response)
        } else {
            await respondOnWatch(to: result.transcript)
        }
    }

    /// Runs the crisis check + Claude call on the Watch and updates `phase`.
    /// Used when the iPhone transcribed but couldn't produce an answer itself.
    private func respondOnWatch(to text: String) async {
        if CrisisKeywords.contains(text) {
            let msg = CrisisKeywords.helplineMessage
            await WatchClaudeAssistant.shared.noteExchange(user: text, assistant: msg)
            phase = .responded(msg)
            return
        }
        guard let answer = await WatchClaudeAssistant.shared.respondToVoice(text) else {
            phase = .error("Something didn't work. Please try again.")
            return
        }
        phase = .responded(answer)
    }

    /// User cancelled — drop everything.
    func cancel() {
        stopEngine()
        WatchConnectivityManager.shared.cancelVoice()
        phase = .idle
    }

    /// Called from the view's onDisappear to release the mic if still open.
    func teardown() {
        if streaming {
            stopEngine()
            WatchConnectivityManager.shared.cancelVoice()
        }
    }

    // MARK: - Recording + streaming

    private func startEngine() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [])
        try session.setActive(true)

        let input = engine.inputNode
        let inputFormat = input.outputFormat(forBus: 0)
        let streamFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32, sampleRate: 16_000, channels: 1, interleaved: false
        )!
        guard let converter = AVAudioConverter(from: inputFormat, to: streamFormat) else {
            throw NSError(domain: "Voice", code: -1)
        }

        input.removeTap(onBus: 0)
        // The converter is captured here so the audio thread never touches
        // main-actor state; it is released when the tap is removed.
        input.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.process(buffer, converter: converter, to: streamFormat)
        }
        engine.prepare()
        try engine.start()
        streaming = true
    }

    private func stopEngine() {
        guard streaming else { return }
        streaming = false
        engine.inputNode.removeTap(onBus: 0)
        if engine.isRunning { engine.stop() }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        level = 0
    }

    /// Converts a captured buffer to the wire format, ships it to the iPhone,
    /// and publishes the RMS level for the waveform. Runs on the audio thread.
    private nonisolated func process(
        _ buffer: AVAudioPCMBuffer, converter: AVAudioConverter, to streamFormat: AVAudioFormat
    ) {
        let ratio = streamFormat.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 1
        guard let out = AVAudioPCMBuffer(pcmFormat: streamFormat, frameCapacity: capacity) else { return }

        var fed = false
        var convError: NSError?
        converter.convert(to: out, error: &convError) { _, status in
            if fed { status.pointee = .noDataNow; return nil }
            fed = true
            status.pointee = .haveData
            return buffer
        }
        guard convError == nil, out.frameLength > 0, let channel = out.floatChannelData?[0] else { return }

        let frames = Int(out.frameLength)
        let data = Data(bytes: channel, count: frames * MemoryLayout<Float>.size)
        WatchConnectivityManager.shared.sendVoiceAudio(data)

        // RMS → 0…1 level, same feel as the old meter (peaks quickly, decays slow).
        var sum: Float = 0
        for i in 0..<frames { sum += channel[i] * channel[i] }
        let rms = sqrt(sum / Float(max(frames, 1)))
        let db = 20 * log10(max(rms, 1e-7))
        let mapped = max(0, min(1, (db + 50) / 45))
        Task { @MainActor [weak self] in
            guard let self else { return }
            let alpha: Float = mapped > self.level ? 0.25 : 0.9
            self.level = self.level * alpha + mapped * (1 - alpha)
        }
    }

    private func requestMicPermission() async -> Bool {
        await withCheckedContinuation { c in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                c.resume(returning: granted)
            }
        }
    }
}

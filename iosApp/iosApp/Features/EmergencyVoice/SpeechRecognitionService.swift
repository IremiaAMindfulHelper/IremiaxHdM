import Foundation
import AVFoundation
import Speech

/// Streaming speech recognition for the consolidated voice flow. The Watch
/// captures audio with its own microphone (the one next to the user's mouth)
/// and streams raw PCM chunks to the iPhone; this service feeds them into a
/// live `SFSpeechAudioBufferRecognitionRequest` and reports partial results
/// back so the Watch can show what is being said in real time. The iPhone
/// never opens its own microphone — there is exactly one mic in the chain.
final class SpeechRecognitionService {
    /// Canonical wire format for the streamed audio: 16 kHz mono Float32.
    /// Both sides must agree on this so the iPhone can rebuild the PCM buffers.
    static let streamFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32, sampleRate: 16_000, channels: 1, interleaved: false
    )!

    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    private let lock = NSLock()
    private var latest = ""
    private var finishContinuation: CheckedContinuation<String, Never>?
    private var didFinish = false

    /// Called on the main queue with the latest partial transcript.
    var onPartial: ((String) -> Void)?

    /// Only speech-recognition authorization is needed — the iPhone does not
    /// record, so it never needs the microphone permission.
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { c in
            SFSpeechRecognizer.requestAuthorization { status in
                c.resume(returning: status == .authorized)
            }
        }
    }

    /// Opens a streaming recognition request for the given language (e.g.
    /// "de-DE" or "en-US"). Returns false if recognition is unavailable, so
    /// callers can surface an error instead of a canned reply.
    func start(localeIdentifier: String) -> Bool {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        guard let recognizer, recognizer.isAvailable else { return false }
        self.recognizer = recognizer
        cancel()

        lock.lock(); latest = ""; didFinish = false; lock.unlock()

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        self.request = req

        self.task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }
            if let result {
                let text = result.bestTranscription.formattedString
                self.lock.lock(); self.latest = text; self.lock.unlock()
                let onPartial = self.onPartial
                DispatchQueue.main.async { onPartial?(text) }
                if result.isFinal { self.resolveFinish() }
            }
            if error != nil { self.resolveFinish() }
        }
        return true
    }

    /// Appends one streamed PCM chunk (raw 16 kHz mono Float32 samples).
    func append(_ data: Data) {
        guard let request, !data.isEmpty else { return }
        let frames = data.count / MemoryLayout<Float>.size
        guard frames > 0,
              let buffer = AVAudioPCMBuffer(
                pcmFormat: Self.streamFormat, frameCapacity: AVAudioFrameCount(frames)
              ) else { return }
        buffer.frameLength = AVAudioFrameCount(frames)
        data.withUnsafeBytes { raw in
            if let src = raw.baseAddress, let dst = buffer.floatChannelData?[0] {
                memcpy(dst, src, frames * MemoryLayout<Float>.size)
            }
        }
        request.append(buffer)
    }

    /// Closes the audio stream and awaits the final transcript. Returns
    /// whatever was recognised (possibly empty); callers treat empty as an
    /// error. A timeout guards against a recognition task that never finalises.
    func finish() async -> String {
        request?.endAudio()
        let transcript = await withCheckedContinuation { (c: CheckedContinuation<String, Never>) in
            lock.lock()
            if didFinish {
                let t = latest; lock.unlock(); c.resume(returning: t)
            } else {
                finishContinuation = c; lock.unlock()
                Task { [weak self] in
                    try? await Task.sleep(for: .seconds(5))
                    self?.resolveFinish()
                }
            }
        }
        task = nil
        request = nil
        return transcript
    }

    /// Tears down any in-flight recognition without awaiting a result.
    func cancel() {
        task?.cancel()
        request?.endAudio()
        task = nil
        request = nil
        resolveFinish()
    }

    private func resolveFinish() {
        lock.lock()
        guard !didFinish else { lock.unlock(); return }
        didFinish = true
        let c = finishContinuation
        finishContinuation = nil
        let t = latest
        lock.unlock()
        c?.resume(returning: t)
    }
}

import Foundation
import Speech

/// Transcribes an audio clip recorded on the Watch. The Watch captures the
/// audio (its microphone is the one next to the user's mouth) and ships the
/// clip to the iPhone, which runs recognition on the file. The iPhone never
/// opens its own microphone, so there is no audio-session contention with the
/// Watch and the transcribed audio is actually what the user said.
final class SpeechRecognitionService {
    private let recognizer: SFSpeechRecognizer?

    init(locale: Locale = Locale(identifier: "de-DE")) {
        self.recognizer = SFSpeechRecognizer(locale: locale)
    }

    /// Only speech-recognition authorization is needed now — the iPhone does
    /// not record, so it never needs the microphone permission.
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { c in
            SFSpeechRecognizer.requestAuthorization { status in
                c.resume(returning: status == .authorized)
            }
        }
    }

    /// Writes the clip to a temporary file and transcribes it. Returns an empty
    /// string on any failure so callers fall back to a safe canned response.
    func transcribe(audioData: Data) async -> String {
        guard let recognizer, recognizer.isAvailable else { return "" }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("iremia_voice_\(UUID().uuidString).m4a")
        do {
            try audioData.write(to: url)
        } catch {
            print("[Voice] could not write audio clip: \(error)")
            return ""
        }
        defer { try? FileManager.default.removeItem(at: url) }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        return await withCheckedContinuation { continuation in
            var resumed = false
            func finish(_ text: String) {
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: text)
            }
            recognizer.recognitionTask(with: request) { result, error in
                if let result, result.isFinal {
                    finish(result.bestTranscription.formattedString)
                } else if error != nil {
                    // Surface whatever partial we have; empty triggers fallback.
                    finish(result?.bestTranscription.formattedString ?? "")
                }
            }
        }
    }
}

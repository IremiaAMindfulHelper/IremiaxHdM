import Foundation

final class EmergencyVoiceCoordinator {
    static let shared = EmergencyVoiceCoordinator()

    private let speech = SpeechRecognitionService()
    private let tts = TTSService()
    private let assistant = ClaudeAssistantService()
    private var didRequestAuth = false

    private init() {
        speech.onPartialTranscript = { text in
            PhoneConnectivityManager.shared.sendPartialTranscript(text)
        }
    }

    func startRecording() {
        print("[Voice] startRecording received from Watch")
        Task.detached { [weak self] in
            guard let self else { return }
            if !self.didRequestAuth {
                self.didRequestAuth = true
                let granted = await self.speech.requestAuthorization()
                print("[Voice] permissions granted=\(granted)")
            }
            do {
                try self.speech.start()
                print("[Voice] speech.start() OK")
            } catch {
                print("[Voice] speech.start() FAILED: \(error)")
            }
        }
    }

    /// Discards an in-flight recording without asking Claude (e.g. when the
    /// user cancels the mood mic screen on the Watch).
    func cancelRecording() {
        _ = speech.stop()
        print("[Voice] recording cancelled")
    }

    /// Stops recording, transcribes, asks Claude (or falls back), optionally
    /// speaks the answer locally, and returns the same text to the Watch.
    func stopRecordingAndRespond(speak: Bool = true) async -> String {
        let transcript = speech.stop()
        print("[Voice] transcript=\"\(transcript)\"")

        if CrisisKeywords.contains(transcript) {
            let msg = CrisisKeywords.helplineMessage
            print("[Voice] crisis keyword detected → helpline message")
            await assistant.noteExchange(user: transcript, assistant: msg)
            if speak { tts.speak(msg) }
            return msg
        }

        let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        let answer: String
        if text.isEmpty {
            print("[Voice] empty transcript → fallback")
            answer = EmergencyFallback.random()
        } else {
            print("[Voice] calling Claude with \(text.count) chars")
            answer = await assistant.respond(to: text)
            print("[Voice] Claude/responder returned: \"\(answer.prefix(80))...\"")
        }
        if speak { tts.speak(answer) }
        return answer
    }

    /// Predefined-state input from the Watch mood-check buttons. Shares the
    /// same conversation history as the voice flow. Returns nil when Claude
    /// is unavailable so the Watch can fall back to its local messages.
    func respondToMoodCheck(mood: String, category: String?, detail: String?) async -> String? {
        print("[Voice] mood check: mood=\(mood) category=\(category ?? "-") detail=\(detail ?? "-")")
        return await assistant.respondToMoodCheck(mood: mood, category: category, detail: detail)
    }
}

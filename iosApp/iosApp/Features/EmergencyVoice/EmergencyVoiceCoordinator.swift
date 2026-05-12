import Foundation

final class EmergencyVoiceCoordinator {
    static let shared = EmergencyVoiceCoordinator()

    private let speech = SpeechRecognitionService()
    private let tts = TTSService()
    private let responder: EmergencyResponder = CohereRAGService()
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

    /// Stops recording, transcribes, asks Cohere (or falls back), speaks the
    /// answer locally, and returns the same text to the Watch.
    func stopRecordingAndRespond() async -> String {
        let transcript = speech.stop()
        print("[Voice] transcript=\"\(transcript)\"")

        if CrisisKeywords.contains(transcript) {
            let msg = CrisisKeywords.helplineMessage
            print("[Voice] crisis keyword detected → helpline message")
            tts.speak(msg)
            return msg
        }

        let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        let answer: String
        if text.isEmpty {
            print("[Voice] empty transcript → fallback")
            answer = EmergencyFallback.random()
        } else {
            print("[Voice] calling Cohere with \(text.count) chars")
            answer = await responder.respond(to: text)
            print("[Voice] Cohere/responder returned: \"\(answer.prefix(80))...\"")
        }
        tts.speak(answer)
        return answer
    }
}

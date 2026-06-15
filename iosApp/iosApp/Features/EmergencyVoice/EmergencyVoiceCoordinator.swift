import Foundation

final class EmergencyVoiceCoordinator {
    static let shared = EmergencyVoiceCoordinator()

    private let speech = SpeechRecognitionService()
    private let tts = TTSService()
    private let assistant = ClaudeAssistantService()
    private var didRequestAuth = false

    private init() {}

    /// Transcribes an audio clip recorded on the Watch, asks Claude (or falls
    /// back), optionally speaks the answer locally, and returns both the answer
    /// and the transcript (the Watch logs the transcript in the Journey).
    func transcribeAndRespond(audio: Data, speak: Bool) async -> (response: String, transcript: String) {
        if !didRequestAuth {
            didRequestAuth = true
            let granted = await speech.requestAuthorization()
            print("[Voice] speech auth granted=\(granted)")
        }

        let transcript = await speech.transcribe(audioData: audio)
        print("[Voice] transcript=\"\(transcript)\"")
        let response = await respond(toTranscript: transcript, speak: speak)
        return (response, transcript)
    }

    /// Predefined-state input from the Watch mood-check buttons. Shares the
    /// same conversation history as the voice flow. Returns nil when Claude
    /// is unavailable so the Watch can fall back to its local messages.
    func respondToMoodCheck(mood: String, category: String?, detail: String?) async -> String? {
        print("[Voice] mood check: mood=\(mood) category=\(category ?? "-") detail=\(detail ?? "-")")
        return await assistant.respondToMoodCheck(mood: mood, category: category, detail: detail)
    }

    /// Shared post-transcript logic: crisis check first, then Claude, then a
    /// safe fallback — never an empty state.
    private func respond(toTranscript transcript: String, speak: Bool) async -> String {
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
}

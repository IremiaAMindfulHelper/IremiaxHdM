import Foundation

/// Drives the iPhone half of the consolidated voice flow: it streams Watch
/// audio into live recognition, reports partial transcripts back to the Watch,
/// and on stop turns the final transcript into a Claude response. Anything that
/// fails (no transcript, API unavailable) returns nil so the Watch shows an
/// error rather than a canned fallback sentence.
final class EmergencyVoiceCoordinator {
    static let shared = EmergencyVoiceCoordinator()

    private let speech = SpeechRecognitionService()
    private let assistant = ClaudeAssistantService()
    private var didRequestAuth = false

    private init() {}

    // MARK: - Streaming voice

    /// Begins a live recognition session. `onPartial` is invoked on the main
    /// queue with the running transcript so the Watch can display it.
    func startVoiceStream(localeIdentifier: String, onPartial: @escaping (String) -> Void) async -> Bool {
        if !didRequestAuth {
            didRequestAuth = true
            let granted = await speech.requestAuthorization()
            print("[Voice] speech auth granted=\(granted)")
        }
        speech.onPartial = onPartial
        let started = speech.start(localeIdentifier: localeIdentifier)
        print("[Voice] stream started=\(started) locale=\(localeIdentifier)")
        return started
    }

    /// Feeds one streamed PCM chunk from the Watch into recognition.
    func appendVoiceAudio(_ data: Data) {
        speech.append(data)
    }

    /// Closes the stream, runs crisis → Claude, and returns the final transcript
    /// plus (when it could compute one) the answer. Returns nil only when nothing
    /// was understood. When the iPhone can't produce an answer — e.g. it's locked
    /// and can't read the API key from the Keychain — `response` is nil and the
    /// Watch answers itself from the transcript, so voice still works.
    func finishVoiceStream() async -> (response: String?, transcript: String)? {
        let transcript = await speech.finish()
        speech.onPartial = nil
        let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[Voice] final transcript=\"\(text)\"")
        guard !text.isEmpty else { return nil }

        if CrisisKeywords.contains(text) {
            let msg = CrisisKeywords.helplineMessage
            print("[Voice] crisis keyword detected → helpline message")
            await assistant.noteExchange(user: text, assistant: msg)
            return (msg, text)
        }

        print("[Voice] calling Claude with \(text.count) chars")
        let answer = await assistant.respondToVoice(text)
        if answer == nil {
            print("[Voice] Claude unavailable on iPhone → returning transcript for on-watch answer")
        }
        return (answer, text)
    }

    /// Aborts an in-flight session (user cancelled on the Watch).
    func cancelVoiceStream() {
        speech.onPartial = nil
        speech.cancel()
    }

    // MARK: - Preset mood-check buttons (unchanged)

    /// Predefined-state input from the Watch mood-check buttons. Returns nil
    /// when Claude is unavailable so the Watch falls back to its local messages.
    func respondToMoodCheck(mood: String, category: String?, detail: String?) async -> String? {
        print("[Voice] mood check: mood=\(mood) category=\(category ?? "-") detail=\(detail ?? "-")")
        return await assistant.respondToMoodCheck(mood: mood, category: category, detail: detail)
    }

    /// Encouraging message-of-the-day for the Watch home screen. Returns nil
    /// when Claude is unavailable so the Watch keeps its cached/local message.
    func dailyMessage(history summary: String) async -> String? {
        print("[Voice] daily message requested (\(summary.count) chars of history)")
        return await assistant.dailyMessage(history: summary)
    }
}

import Foundation
import WatchConnectivity

/// User preference for the speech-recognition language. German is the default;
/// the Settings toggle flips it to English. Stored as a Bool in UserDefaults so
/// the SwiftUI Toggle and the connectivity layer share one source of truth.
enum VoiceSettings {
    static let englishKey = "voiceRecognitionEnglish"

    /// "de-DE" by default, "en-US" when the English toggle is on.
    static var localeIdentifier: String {
        UserDefaults.standard.bool(forKey: englishKey) ? "en-US" : "de-DE"
    }
}

/// User preference for the home-menu layout. `false` (default) keeps the
/// original bubble menu; the Settings toggle flips it to the alternate
/// pill-based concept. Stored as a Bool in UserDefaults so ContentView and the
/// Settings toggle share one source of truth.
enum HomeMenuSettings {
    static let alternateLayoutKey = "homeMenuAlternateLayout"
}

struct WatchContact: Identifiable, Codable {
    let id: Int64
    let name: String
    let phoneNumber: String
}

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    @Published var contacts: [WatchContact] = []
    @Published var liveTranscript: String = ""

    func clearLiveTranscript() {
        DispatchQueue.main.async { self.liveTranscript = "" }
    }

    /// Waits up to `timeout` for the phone to become reachable. Returns true as
    /// soon as it is. This closes the race where the very first request right
    /// after launch (e.g. the Good-mood check fired after a single tap on the
    /// launch screen) would fail because the session hadn't finished activating
    /// or the iPhone app hadn't been woken yet, sending the user to the local
    /// fallback even though Claude was available a moment later.
    private func waitForReachable(timeout: TimeInterval = 3) async -> Bool {
        let session = WCSession.default
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if session.activationState == .activated, session.isReachable { return true }
            try? await Task.sleep(for: .milliseconds(150))
        }
        return session.activationState == .activated && session.isReachable
    }

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Voice streaming

    /// Opens a live recognition session on the iPhone. The phone transcribes
    /// the streamed audio and pushes partials back via `partialTranscript`.
    /// The recognition language follows the user's Settings toggle (German by
    /// default). Returns false when the phone is unreachable so the caller
    /// shows an error.
    func startVoice() async -> Bool {
        guard await waitForReachable() else { return false }
        clearLiveTranscript()
        WCSession.default.sendMessage(
            ["action": "voiceStart", "locale": VoiceSettings.localeIdentifier],
            replyHandler: nil, errorHandler: nil
        )
        return true
    }

    /// Streams one raw PCM chunk (16 kHz mono Float32) to the iPhone. Sent over
    /// the same sendMessage channel as start/stop so the phone receives
    /// start → chunks → stop strictly in order (no cross-channel reordering).
    func sendVoiceAudio(_ data: Data) {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        session.sendMessage(["voiceAudio": data], replyHandler: nil, errorHandler: nil)
    }

    /// Tells the iPhone the user stopped speaking and awaits the result. The
    /// iPhone always returns the final `transcript` when it understood anything;
    /// it also returns a `response` when it could compute one itself (typically
    /// while unlocked). Returns nil only when the phone is unreachable or nothing
    /// was understood. When `response` is nil the caller answers on the Watch
    /// using the transcript — this is what keeps voice working while the iPhone
    /// is locked (a locked phone can transcribe but can't read the API key).
    func finishVoice() async -> (response: String?, transcript: String)? {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return nil }
        return await withCheckedContinuation { continuation in
            session.sendMessage(
                ["action": "voiceStop"],
                replyHandler: { reply in
                    if let transcript = reply["transcript"] as? String, !transcript.isEmpty {
                        continuation.resume(returning: (reply["response"] as? String, transcript))
                    } else {
                        continuation.resume(returning: nil)
                    }
                },
                errorHandler: { _ in continuation.resume(returning: nil) }
            )
        }
    }

    /// Aborts an in-flight session without waiting for a response.
    func cancelVoice() {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        session.sendMessage(["action": "voiceCancel"], replyHandler: nil, errorHandler: nil)
    }

    // Claude mood check

    /// Asks the iPhone to generate a Claude response for a mood check-in made
    /// with the preset buttons. Returns nil when the phone is unreachable or
    /// the API call failed, so callers can fall back to local messages.
    func requestMoodResponse(mood: String, category: String?, detail: String?) async -> String? {
        guard await waitForReachable() else { return nil }
        let session = WCSession.default
        var message: [String: Any] = ["action": "moodCheck", "mood": mood]
        if let category { message["category"] = category }
        if let detail { message["detail"] = detail }
        return await withCheckedContinuation { continuation in
            session.sendMessage(
                message,
                replyHandler: { reply in
                    continuation.resume(returning: reply["response"] as? String)
                },
                errorHandler: { _ in
                    continuation.resume(returning: nil)
                }
            )
        }
    }

    // Message of the day

    /// Asks the iPhone for an encouraging home-screen message, passing a short
    /// summary of the user's recent Journey so Claude can reference it. Returns
    /// nil when the phone is unreachable or the call failed, so callers can keep
    /// the cached/local message.
    func requestDailyMessage(history summary: String) async -> String? {
        guard await waitForReachable() else { return nil }
        let session = WCSession.default
        let message: [String: Any] = ["action": "dailyMessage", "history": summary]
        return await withCheckedContinuation { continuation in
            session.sendMessage(
                message,
                replyHandler: { reply in
                    continuation.resume(returning: reply["response"] as? String)
                },
                errorHandler: { _ in
                    continuation.resume(returning: nil)
                }
            )
        }
    }

    // WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        // Load contacts that were sent before this session activated
        updateContacts(from: session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        updateContacts(from: context)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let text = message["partialTranscript"] as? String {
            DispatchQueue.main.async { self.liveTranscript = text }
        }
        updateContacts(from: message)
    }

    private func updateContacts(from payload: [String: Any]) {
        guard let data = payload["emergencyContacts"] as? Data,
              let decoded = try? JSONDecoder().decode([WatchContact].self, from: data) else { return }
        DispatchQueue.main.async { self.contacts = decoded }
    }
}

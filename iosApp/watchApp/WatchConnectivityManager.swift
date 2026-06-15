import Foundation
import WatchConnectivity

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

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Voice transcription

    /// Sends an audio clip recorded on the Watch to the iPhone, which
    /// transcribes it and asks Claude. Returns the spoken/displayed response
    /// plus the transcript (for the Journey log), or nil when the phone is
    /// unreachable or the call failed so callers can fall back locally.
    func requestVoiceResponse(audio: Data, speak: Bool) async -> (response: String, transcript: String)? {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return nil }
        let message: [String: Any] = ["action": "transcribe", "audio": audio, "speak": speak]
        return await withCheckedContinuation { continuation in
            session.sendMessage(
                message,
                replyHandler: { reply in
                    if let response = reply["response"] as? String {
                        continuation.resume(returning: (response, reply["transcript"] as? String ?? ""))
                    } else {
                        continuation.resume(returning: nil)
                    }
                },
                errorHandler: { _ in
                    continuation.resume(returning: nil)
                }
            )
        }
    }

    // MARK: - Claude mood check

    /// Asks the iPhone to generate a Claude response for a mood check-in made
    /// with the preset buttons. Returns nil when the phone is unreachable or
    /// the API call failed, so callers can fall back to local messages.
    func requestMoodResponse(mood: String, category: String?, detail: String?) async -> String? {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return nil }
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

    // MARK: - WCSessionDelegate

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

import Foundation
import WatchConnectivity

struct WatchEmergencyContact: Identifiable, Codable {
    let id: Int64
    let name: String
    let phoneNumber: String
}

class PhoneConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneConnectivityManager()

    private var lastContacts: [WatchEmergencyContact] = []

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendContacts(_ contacts: [WatchEmergencyContact]) {
        lastContacts = contacts
        guard WCSession.default.activationState == .activated else { return }
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        let context = ["emergencyContacts": data]
        try? WCSession.default.updateApplicationContext(context)
    }

    /// Streams a live partial transcript back to the Watch during recording.
    func sendPartialTranscript(_ text: String) {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        session.sendMessage(["partialTranscript": text], replyHandler: nil, errorHandler: nil)
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        // Resend on activation so the Watch gets contacts even if it was off during initial load
        guard !lastContacts.isEmpty else { return }
        sendContacts(lastContacts)
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        // Resend whenever Watch becomes reachable (e.g. user opens Watch app)
        guard session.isReachable, !lastContacts.isEmpty else { return }
        guard let data = try? JSONEncoder().encode(lastContacts) else { return }
        session.sendMessage(["emergencyContacts": data], replyHandler: nil)
    }

    // MARK: - Voice: control channel (no reply)

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Streamed audio chunk (same channel as control, so it stays ordered).
        if let audio = message["voiceAudio"] as? Data {
            EmergencyVoiceCoordinator.shared.appendVoiceAudio(audio)
            return
        }
        switch message["action"] as? String {
        case "voiceStart":
            let locale = message["locale"] as? String ?? "de-DE"
            Task {
                _ = await EmergencyVoiceCoordinator.shared.startVoiceStream(localeIdentifier: locale) { partial in
                    PhoneConnectivityManager.shared.sendPartialTranscript(partial)
                }
            }
        case "voiceCancel":
            EmergencyVoiceCoordinator.shared.cancelVoiceStream()
        default:
            break
        }
    }

    // MARK: - Voice + mood: request/reply

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        let action = message["action"] as? String ?? "(none)"
        print("[Voice] iPhone received message (with reply) action=\(action)")
        switch action {
        case "voiceStop":
            Task {
                if let result = await EmergencyVoiceCoordinator.shared.finishVoiceStream() {
                    replyHandler(["response": result.response, "transcript": result.transcript])
                } else {
                    // Nothing understood or Claude unavailable — the Watch shows an error.
                    replyHandler(["error": true])
                }
            }
        case "moodCheck":
            let mood = message["mood"] as? String ?? ""
            let category = message["category"] as? String
            let detail = message["detail"] as? String
            Task {
                if let response = await EmergencyVoiceCoordinator.shared.respondToMoodCheck(
                    mood: mood, category: category, detail: detail
                ) {
                    replyHandler(["response": response])
                } else {
                    replyHandler(["error": true])
                }
            }
        case "dailyMessage":
            let summary = message["history"] as? String ?? ""
            Task {
                if let response = await EmergencyVoiceCoordinator.shared.dailyMessage(history: summary) {
                    replyHandler(["response": response])
                } else {
                    replyHandler(["error": true])
                }
            }
        default:
            replyHandler(["error": true])
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}

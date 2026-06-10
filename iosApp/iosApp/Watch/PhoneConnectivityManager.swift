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

    func sendPartialTranscript(_ text: String) {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        session.sendMessage(["partialTranscript": text], replyHandler: nil, errorHandler: nil)
    }

    func sendContacts(_ contacts: [WatchEmergencyContact]) {
        lastContacts = contacts
        guard WCSession.default.activationState == .activated else { return }
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        let context = ["emergencyContacts": data]
        try? WCSession.default.updateApplicationContext(context)
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

    // MARK: - Voice action routing

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let action = message["action"] as? String ?? "(none)"
        print("[Voice] iPhone received message (no reply) action=\(action)")
        switch action {
        case "startRecording":
            EmergencyVoiceCoordinator.shared.startRecording()
        case "cancelRecording":
            EmergencyVoiceCoordinator.shared.cancelRecording()
        default:
            break
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        let action = message["action"] as? String ?? "(none)"
        print("[Voice] iPhone received message (with reply) action=\(action)")
        guard let action = message["action"] as? String else {
            replyHandler(["response": EmergencyFallback.random()])
            return
        }
        switch action {
        case "stopRecording":
            let speak = (message["speak"] as? Bool) ?? true
            Task {
                let response = await EmergencyVoiceCoordinator.shared.stopRecordingAndRespond(speak: speak)
                replyHandler(["response": response])
            }
        case "startRecording":
            EmergencyVoiceCoordinator.shared.startRecording()
            replyHandler(["ok": true])
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
                    // No payload — the Watch falls back to its local messages.
                    replyHandler(["error": true])
                }
            }
        default:
            replyHandler(["response": EmergencyFallback.random()])
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}

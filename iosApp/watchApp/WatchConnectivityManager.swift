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

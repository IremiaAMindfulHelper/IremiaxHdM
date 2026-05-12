import Foundation
import WatchConnectivity

enum EmergencyState: Equatable {
    case idle
    case recording
    case processing
    case responding(String)
}

@MainActor
final class EmergencyWatchViewModel: ObservableObject {
    @Published var state: EmergencyState = .idle

    func tapped() {
        switch state {
        case .idle:
            startRecording()
        case .recording:
            stopAndAsk()
        case .processing, .responding:
            state = .idle
        }
    }

    private func startRecording() {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isReachable else {
            state = .responding("Connect your iPhone and try again.")
            return
        }
        WatchConnectivityManager.shared.clearLiveTranscript()
        WCSession.default.sendMessage(
            ["action": "startRecording"],
            replyHandler: nil,
            errorHandler: { _ in }
        )
        state = .recording
    }

    private func stopAndAsk() {
        state = .processing
        guard WCSession.default.isReachable else {
            state = .responding(fallback)
            return
        }
        WCSession.default.sendMessage(
            ["action": "stopRecording"],
            replyHandler: { [weak self] reply in
                let text = (reply["response"] as? String) ?? self?.fallback ?? ""
                Task { @MainActor in self?.state = .responding(text) }
            },
            errorHandler: { [weak self] _ in
                Task { @MainActor in self?.state = .responding(self?.fallback ?? "") }
            }
        )
    }

    private var fallback: String {
        "Take a slow breath. You are safe."
    }
}

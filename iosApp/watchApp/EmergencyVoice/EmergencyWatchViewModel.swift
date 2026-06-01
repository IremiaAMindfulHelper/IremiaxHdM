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

    private var timeoutTask: Task<Void, Never>?

    func tapped() {
        switch state {
        case .idle:
            startRecording()
        case .recording:
            stopAndAsk()
        case .processing, .responding:
            timeoutTask?.cancel()
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

        timeoutTask?.cancel()
        timeoutTask = Task {
            try? await Task.sleep(for: .seconds(15))
            guard !Task.isCancelled, state == .processing else { return }
            let transcript = WatchConnectivityManager.shared.liveTranscript
            state = .responding(fallback)
            JourneyStore.shared.attachVoiceSession(transcript: transcript, response: fallback)
        }

        WCSession.default.sendMessage(
            ["action": "stopRecording"],
            replyHandler: { [weak self] reply in
                let responseText = (reply["response"] as? String) ?? self?.fallback ?? ""
                Task { @MainActor in
                    self?.timeoutTask?.cancel()
                    self?.state = .responding(responseText)
                    let transcript = WatchConnectivityManager.shared.liveTranscript
                    JourneyStore.shared.attachVoiceSession(
                        transcript: transcript,
                        response: responseText
                    )
                }
            },
            errorHandler: { [weak self] _ in
                Task { @MainActor in
                    self?.timeoutTask?.cancel()
                    let fb = self?.fallback ?? ""
                    self?.state = .responding(fb)
                    let transcript = WatchConnectivityManager.shared.liveTranscript
                    JourneyStore.shared.attachVoiceSession(transcript: transcript, response: fb)
                }
            }
        )
    }

    private var fallback: String {
        "Take a slow breath. You are safe."
    }
}

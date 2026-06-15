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

    /// Called when the user taps the mic in the idle state.
    func startRecording() {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isReachable else {
            state = .responding("Connect your iPhone and try again.")
            return
        }
        state = .recording
    }

    /// Called when the user taps stop. The View hands over the clip recorded
    /// on the Watch; we send it to the iPhone for transcription + Claude.
    func stopAndAsk(audio: Data?) {
        state = .processing

        guard let audio, WCSession.default.isReachable else {
            finish(response: fallback, transcript: "")
            return
        }

        timeoutTask?.cancel()
        timeoutTask = Task {
            try? await Task.sleep(for: .seconds(20))
            guard !Task.isCancelled, state == .processing else { return }
            finish(response: fallback, transcript: "")
        }

        Task {
            let result = await WatchConnectivityManager.shared.requestVoiceResponse(audio: audio, speak: true)
            timeoutTask?.cancel()
            finish(response: result?.response ?? fallback, transcript: result?.transcript ?? "")
        }
    }

    func reset() {
        timeoutTask?.cancel()
        state = .idle
    }

    private func finish(response: String, transcript: String) {
        state = .responding(response)
        JourneyStore.shared.attachVoiceSession(transcript: transcript, response: response)
    }

    private var fallback: String {
        "Take a slow breath. You are safe."
    }
}

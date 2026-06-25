import SwiftUI

/// Emergency voice access from the Watch home screen. Same consolidated voice
/// surface as the mood check-in; the session is logged in the Journey.
struct EmergencyVoiceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VoiceInputView(
            onLogged: { transcript, response in
                JourneyStore.shared.attachVoiceSession(transcript: transcript, response: response)
            },
            onClose: { dismiss() },
            onCancel: { dismiss() }
        )
    }
}

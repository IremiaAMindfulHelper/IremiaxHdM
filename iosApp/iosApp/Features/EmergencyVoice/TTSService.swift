import Foundation
import AVFoundation

final class TTSService {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.42
        utterance.pitchMultiplier = 0.95
        utterance.volume = 1.0
        // Audio session is already active (.playAndRecord) from the recording phase.
        synth.speak(utterance)
    }

    func stop() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
    }
}

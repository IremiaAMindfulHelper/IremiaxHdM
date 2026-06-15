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
        // The iPhone no longer records (the Watch does), so activate a playback
        // session here. .duckOthers lowers any other audio; .spokenAudio routes
        // to the paired Watch speaker over Bluetooth like other spoken content.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        synth.speak(utterance)
    }

    func stop() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
    }
}

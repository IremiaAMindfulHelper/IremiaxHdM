import Foundation
import AVFoundation
import Speech

final class SpeechRecognitionService {
    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var transcript: String = ""
    var onPartialTranscript: ((String) -> Void)?

    init(locale: Locale = Locale(identifier: "de-DE")) {
        self.recognizer = SFSpeechRecognizer(locale: locale)
    }

    func requestAuthorization() async -> Bool {
        let speech: Bool = await withCheckedContinuation { c in
            SFSpeechRecognizer.requestAuthorization { status in
                c.resume(returning: status == .authorized)
            }
        }
        guard speech else { return false }
        return await withCheckedContinuation { c in
            AVAudioApplication.requestRecordPermission { granted in
                c.resume(returning: granted)
            }
        }
    }

    func start() throws {
        guard let recognizer, recognizer.isAvailable else {
            throw NSError(domain: "Speech", code: -1)
        }
        _ = stop()
        transcript = ""

        let session = AVAudioSession.sharedInstance()
        // playAndRecord lets TTS speak the response without re-activating the session afterwards.
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if #available(iOS 13, *) { req.requiresOnDeviceRecognition = false }
        self.request = req

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        self.task = recognizer.recognitionTask(with: req) { [weak self] result, _ in
            guard let self, let r = result else { return }
            let text = r.bestTranscription.formattedString
            self.transcript = text
            self.onPartialTranscript?(text)
        }
    }

    /// Stops audio capture and returns the final transcript. Leaves the audio
    /// session active so the TTS can speak immediately afterwards without
    /// having to re-acquire the audio hardware.
    func stop() -> String {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task?.finish()
        request = nil
        task = nil
        return transcript
    }
}

import Foundation

protocol EmergencyResponder {
    func respond(to input: String) async -> String
}

enum EmergencyFallback {
    static let strings = [
        "You are safe. Breathe slowly: 4 seconds in, 6 seconds out.",
        "This sensation is uncomfortable but not dangerous. It will pass.",
        "Your body is protecting you. Focus on your next breath."
    ]

    static func random() -> String { strings.randomElement() ?? strings[0] }
}

enum CrisisKeywords {
    static let keywords = [
        "sterben", "suizid", "umbringen", "verletzen",
        "die", "suicide", "kill myself", "hurt myself"
    ]
    static let helplineMessage =
        "Please call the Telefonseelsorge: 0800 111 0 111. Free and 24/7."

    static func contains(_ text: String) -> Bool {
        let lower = text.lowercased()
        return keywords.contains { lower.contains($0) }
    }
}

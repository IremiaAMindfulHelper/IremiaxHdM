import Foundation

/// Safety net that runs before Claude: if the user voices intent to harm
/// themselves, we always show the helpline immediately rather than relying on
/// the model. This is a deliberate response, not a connectivity fallback.
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

import Foundation

// MARK: - Claude Messages API wire types

private struct ClaudeSystemBlock: Encodable {
    let type = "text"
    let text: String
    let cacheControl: CacheControl?

    struct CacheControl: Encodable {
        let type = "ephemeral"
    }

    enum CodingKeys: String, CodingKey {
        case type, text
        case cacheControl = "cache_control"
    }
}

private struct ClaudeChatMessage: Encodable {
    let role: String
    let content: String
}

private struct ClaudeChatRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: [ClaudeSystemBlock]
    let messages: [ClaudeChatMessage]
    let outputConfig: OutputConfig

    struct OutputConfig: Encodable {
        let effort: String
    }

    enum CodingKeys: String, CodingKey {
        case model, system, messages
        case maxTokens = "max_tokens"
        case outputConfig = "output_config"
    }
}

private struct ClaudeChatResponse: Decodable {
    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
    let content: [ContentBlock]?
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case content
        case stopReason = "stop_reason"
    }
}

private struct RAGEntry: Decodable {
    let id: String
    let category: String
    let title: String
    let text: String
}

// MARK: - Service

/// Talks to the Claude API and keeps the full conversation history of the
/// session — voice transcripts and mood-check button selections alike — so
/// Claude can connect new input with everything the user shared before.
actor ClaudeAssistantService: EmergencyResponder {
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-opus-4-8"
    private let timeoutSeconds: TimeInterval = 12
    private let systemBlocks: [ClaudeSystemBlock]
    private var history: [ClaudeChatMessage] = []

    init() {
        self.systemBlocks = Self.buildSystemBlocks()
    }

    // MARK: Voice input

    func respond(to input: String) async -> String {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return EmergencyFallback.random() }
        if let answer = await complete(userMessage: text) {
            return answer
        }
        // Keep the history consistent with what the user actually heard.
        let fallback = EmergencyFallback.random()
        history.append(ClaudeChatMessage(role: "assistant", content: fallback))
        return fallback
    }

    // MARK: Mood-check buttons

    /// Predefined-state input from the Watch mood check. Returns nil when the
    /// API is unavailable so the Watch can fall back to its local messages.
    func respondToMoodCheck(mood: String, category: String?, detail: String?) async -> String? {
        var parts = ["Mood check-in via the preset buttons on my watch.", "Mood: \(mood)."]
        if let category, !category.isEmpty { parts.append("Area: \(category).") }
        if let detail, !detail.isEmpty { parts.append("Specifically: \(detail).") }
        return await complete(userMessage: parts.joined(separator: " "))
    }

    /// Records an exchange that was answered locally (e.g. the crisis helpline
    /// message) so later requests still carry the complete history.
    func noteExchange(user: String, assistant: String) {
        history.append(ClaudeChatMessage(role: "user", content: user))
        history.append(ClaudeChatMessage(role: "assistant", content: assistant))
    }

    // MARK: Claude API call

    private func complete(userMessage: String) async -> String? {
        // Record the input first so it stays part of the history even if this
        // particular request fails. Consecutive user turns are valid API input.
        history.append(ClaudeChatMessage(role: "user", content: userMessage))

        guard let apiKey = KeychainHelper.get(KeychainHelper.anthropicAPIKeyService),
              !apiKey.isEmpty else {
            print("[Claude] no API key in Keychain → fallback. Did .env get read at build time?")
            return nil
        }

        let body = ClaudeChatRequest(
            model: model,
            maxTokens: 300,
            system: systemBlocks,
            messages: history,
            outputConfig: .init(effort: "low")
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutSeconds
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                let preview = String(data: data, encoding: .utf8)?.prefix(300) ?? ""
                print("[Claude] HTTP \(status): \(preview)")
                return nil
            }
            let decoded = try JSONDecoder().decode(ClaudeChatResponse.self, from: data)
            let text = (decoded.content ?? [])
                .filter { $0.type == "text" }
                .compactMap { $0.text }
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else {
                print("[Claude] 200 but no text content. stop_reason=\(decoded.stopReason ?? "nil")")
                return nil
            }
            history.append(ClaudeChatMessage(role: "assistant", content: text))
            return text
        } catch {
            print("[Claude] request failed: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: System prompt with verified panic-attack knowledge

    private static func buildSystemBlocks() -> [ClaudeSystemBlock] {
        let persona = """
        Du bist Iremia, ein ruhiger, mitfühlender Begleiter bei Panikattacken und Angst. \
        Deine Antworten werden auf einer Apple Watch angezeigt und teilweise vorgelesen.

        Regeln:
        - Antworte in maximal 2 kurzen Sätzen.
        - Antworte in der Sprache der letzten Nutzereingabe (Deutsch oder Englisch).
        - Stütze fachliche Aussagen ausschließlich auf das bereitgestellte, inhaltlich gesicherte Wissen. Erfinde keine medizinischen Fakten.
        - Keine Diagnosen, keine Medikamentenempfehlungen.
        - Nutze den bisherigen Gesprächsverlauf: Greife frühere Angaben auf (z. B. wiederkehrende Symptome oder Stimmungen), wenn es hilft.
        - Bei akuter Panik: kurz validieren, dann genau eine konkrete, sofort umsetzbare Technik nennen.
        - Bei Suizidgedanken oder Selbstverletzungsabsichten: verweise auf die Telefonseelsorge 0800 111 0 111 (kostenlos, rund um die Uhr).
        """

        guard let knowledge = loadKnowledge() else {
            return [ClaudeSystemBlock(text: persona, cacheControl: nil)]
        }
        return [
            ClaudeSystemBlock(text: persona, cacheControl: nil),
            ClaudeSystemBlock(text: knowledge, cacheControl: .init())
        ]
    }

    private static func loadKnowledge() -> String? {
        guard let url = Bundle.main.url(forResource: "iremia_rag", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([RAGEntry].self, from: data),
              !entries.isEmpty else {
            print("[Claude] iremia_rag.json missing — answering without knowledge base")
            return nil
        }
        let body = entries
            .map { "## \($0.title) (\($0.category))\n\($0.text)" }
            .joined(separator: "\n\n")
        return "Inhaltlich gesichertes Wissen über Panikattacken und Hilfetechniken:\n\n" + body
    }
}

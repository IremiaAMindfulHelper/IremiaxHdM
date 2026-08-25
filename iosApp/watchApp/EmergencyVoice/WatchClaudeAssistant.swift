import Foundation

/// Safety net that runs before Claude on the Watch: if the user voices intent to
/// harm themselves, we always show the helpline immediately rather than relying
/// on the model. Mirrors the iPhone `CrisisKeywords`. Deliberate response, not a
/// connectivity fallback.
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

// Claude Messages API wire types

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

// Service

/// Watch-side Claude client. Same behaviour as the iPhone `ClaudeAssistantService`,
/// but runs directly on the Watch over its own network connection so voice input
/// no longer depends on the iPhone being unlocked/reachable. The Anthropic API
/// key is read from the bundled `Secrets.plist` (written at build time by
/// scripts/generate-secrets.sh), and the verified knowledge base ships in the
/// Watch bundle as `iremia_rag.json`.
actor WatchClaudeAssistant {
    static let shared = WatchClaudeAssistant()

    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-opus-4-8"
    private let timeoutSeconds: TimeInterval = 12
    private let systemBlocks: [ClaudeSystemBlock]
    private var history: [ClaudeChatMessage] = []

    private init() {
        self.systemBlocks = Self.buildSystemBlocks()
    }

    // Voice input

    /// Voice transcript → Claude. Returns nil when the input is empty or the API
    /// is unavailable so the caller can surface an error instead of a canned
    /// fallback sentence.
    func respondToVoice(_ input: String) async -> String? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        return await complete(userMessage: text)
    }

    /// Records an exchange that was answered locally (e.g. the crisis helpline
    /// message) so later requests still carry the complete history.
    func noteExchange(user: String, assistant: String) {
        history.append(ClaudeChatMessage(role: "user", content: user))
        history.append(ClaudeChatMessage(role: "assistant", content: assistant))
    }

    // Claude API call

    private func complete(userMessage: String) async -> String? {
        // Record the input first so it stays part of the history even if this
        // particular request fails. Consecutive user turns are valid API input.
        history.append(ClaudeChatMessage(role: "user", content: userMessage))
        guard let text = await send(history) else { return nil }
        history.append(ClaudeChatMessage(role: "assistant", content: text))
        return text
    }

    /// Sends a messages array to Claude and returns the text reply, or nil on any
    /// failure. Stateless — callers decide what (if anything) to keep.
    private func send(_ messages: [ClaudeChatMessage]) async -> String? {
        guard let apiKey = Self.anthropicAPIKey(), !apiKey.isEmpty else {
            print("[Claude/Watch] no API key in bundled Secrets.plist → error. Did .env get read at build time?")
            return nil
        }

        let body = ClaudeChatRequest(
            model: model,
            maxTokens: 300,
            system: systemBlocks,
            messages: messages,
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
                print("[Claude/Watch] HTTP \(status): \(preview)")
                return nil
            }
            let decoded = try JSONDecoder().decode(ClaudeChatResponse.self, from: data)
            let text = (decoded.content ?? [])
                .filter { $0.type == "text" }
                .compactMap { $0.text }
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else {
                print("[Claude/Watch] 200 but no text content. stop_reason=\(decoded.stopReason ?? "nil")")
                return nil
            }
            return text
        } catch {
            print("[Claude/Watch] request failed: \(error.localizedDescription)")
            return nil
        }
    }

    // API key

    /// Reads ANTHROPIC_API_KEY from the bundled Secrets.plist (written at build
    /// time by scripts/generate-secrets.sh from the repo-root .env).
    private static func anthropicAPIKey() -> String? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let key = plist["ANTHROPIC_API_KEY"] as? String else { return nil }
        return key
    }

    // System prompt with verified panic-attack knowledge

    private static func buildSystemBlocks() -> [ClaudeSystemBlock] {
        let persona = """
        You are Iremia, a calm, compassionate companion for panic attacks and anxiety. \
        Your replies are shown on an Apple Watch and are sometimes read aloud.

        Rules:
        - Reply in at most 2 short sentences.
        - Always reply in English, regardless of the language the user wrote in.
        - Base factual statements only on the provided, verified knowledge. Do not invent medical facts.
        - No diagnoses, no medication recommendations.
        - Use the prior conversation: gently refer back to earlier details (e.g. recurring symptoms or moods) when it helps.
        - During acute panic: validate briefly, then name exactly one concrete, immediately actionable technique.
        - For thoughts of suicide or self-harm: point to the Telefonseelsorge 0800 111 0 111 (free, around the clock).
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
            print("[Claude/Watch] iremia_rag.json missing — answering without knowledge base")
            return nil
        }
        let body = entries
            .map { "## \($0.title) (\($0.category))\n\($0.text)" }
            .joined(separator: "\n\n")
        return "Verified knowledge about panic attacks and coping techniques (source content may be in German; always answer in English):\n\n" + body
    }
}

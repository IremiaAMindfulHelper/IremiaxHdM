import Foundation

struct CohereDocument: Encodable {
    let id: String
    let data: CohereDocumentData

    struct CohereDocumentData: Encodable {
        let title: String
        let text: String
    }
}

private struct CohereV2Message: Encodable {
    let role: String
    let content: String
}

private struct CohereChatRequest: Encodable {
    let model: String
    let messages: [CohereV2Message]
    let documents: [CohereDocument]
    let max_tokens: Int
    let temperature: Double
}

private struct CohereChatResponse: Decodable {
    struct Message: Decodable {
        struct Content: Decodable {
            let type: String?
            let text: String?
        }
        let role: String?
        let content: [Content]?
    }
    let message: Message?
}

private struct RAGEntry: Decodable {
    let id: String
    let category: String
    let title: String
    let text: String
}

final class CohereRAGService: EmergencyResponder {
    private let endpoint = URL(string: "https://api.cohere.com/v2/chat")!
    private let model = "command-r-08-2024"
    private let systemPrompt =
        "Du bist Iremia, ein ruhiger Begleiter bei Panikattacken. Antworte auf Deutsch. " +
        "Maximal 2 kurze Sätze. Nutze ausschließlich die bereitgestellten Dokumente. Keine Diagnosen."
    private let timeoutSeconds: TimeInterval = 12
    private let documents: [CohereDocument]

    init() {
        self.documents = Self.loadDocuments()
    }

    func respond(to input: String) async -> String {
        guard let apiKey = KeychainHelper.get(KeychainHelper.cohereAPIKeyService),
              !apiKey.isEmpty else {
            print("[Voice] Cohere: no API key in Keychain → fallback. Did .env get read at build time?")
            return EmergencyFallback.random()
        }
        print("[Voice] Cohere: api key length=\(apiKey.count), documents=\(documents.count)")
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return EmergencyFallback.random()
        }

        let body = CohereChatRequest(
            model: model,
            messages: [
                CohereV2Message(role: "system", content: systemPrompt),
                CohereV2Message(role: "user", content: input)
            ],
            documents: documents,
            max_tokens: 120,
            temperature: 0.2
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutSeconds
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                print("[Voice] Cohere: non-HTTP response → fallback")
                return EmergencyFallback.random()
            }
            guard http.statusCode == 200 else {
                let bodyPreview = String(data: data, encoding: .utf8)?.prefix(300) ?? ""
                print("[Voice] Cohere HTTP \(http.statusCode): \(bodyPreview)")
                return EmergencyFallback.random()
            }
            let decoded = try JSONDecoder().decode(CohereChatResponse.self, from: data)
            let text = decoded.message?.content?.compactMap { $0.text }.joined() ?? ""
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                let bodyPreview = String(data: data, encoding: .utf8)?.prefix(400) ?? ""
                print("[Voice] Cohere 200 but empty text. body=\(bodyPreview)")
                return EmergencyFallback.random()
            }
            return trimmed
        } catch {
            print("[Voice] Cohere request failed: \(error.localizedDescription)")
            return EmergencyFallback.random()
        }
    }

    private static func loadDocuments() -> [CohereDocument] {
        guard let url = Bundle.main.url(forResource: "iremia_rag", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([RAGEntry].self, from: data) else {
            return []
        }
        return entries.map {
            CohereDocument(
                id: $0.id,
                data: CohereDocument.CohereDocumentData(title: $0.title, text: $0.text)
            )
        }
    }
}

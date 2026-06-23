import SwiftUI

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mood: String
    var category: String?
    var detail: String?
    var transcript: String?
    var response: String?

    var moodLevel: MoodLevel? { MoodLevel(rawValue: mood) }
}

class JourneyStore: ObservableObject {
    static let shared = JourneyStore()

    @Published private(set) var entries: [JournalEntry] = []

    private let key = "iremia_journal_entries"

    private init() {
        load()
    }

    func add(mood: MoodLevel) {
        let entry = JournalEntry(id: UUID(), date: Date(), mood: mood.rawValue)
        entries.insert(entry, at: 0)
        save()
    }

    func attachMoodContext(category: String, detail: String, response: String = "") {
        guard !entries.isEmpty else { return }
        entries[0].category = category
        entries[0].detail = detail
        if !response.isEmpty { entries[0].response = response }
        save()
    }

    func attachResponse(_ response: String) {
        guard !entries.isEmpty, !response.isEmpty else { return }
        entries[0].response = response
        save()
    }

    func attachVoiceSession(transcript: String, response: String) {
        guard !entries.isEmpty else { return }
        if !transcript.isEmpty { entries[0].transcript = transcript }
        if !response.isEmpty { entries[0].response = response }
        guard entries[0].transcript != nil || entries[0].response != nil else { return }
        save()
    }

    /// A compact, human-readable digest of the most recent entries for Claude
    /// to ground the message of the day in. Returns a sentinel when empty so
    /// the model still produces a generic, welcoming line.
    func journeySummary(limit: Int = 7) -> String {
        let recent = entries.prefix(limit)
        guard !recent.isEmpty else { return "No entries yet." }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.unitsStyle = .full
        return recent.map { entry -> String in
            var parts = ["\(formatter.localizedString(for: entry.date, relativeTo: Date())): mood \(entry.mood)"]
            if let category = entry.category, !category.isEmpty { parts.append("area \(category)") }
            if let detail = entry.detail, !detail.isEmpty { parts.append("details: \(detail)") }
            if let transcript = entry.transcript, !transcript.isEmpty { parts.append("said: \(transcript)") }
            return "- " + parts.joined(separator: ", ")
        }.joined(separator: "\n")
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

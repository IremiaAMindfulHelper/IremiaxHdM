import SwiftUI

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mood: String
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

    func attachVoiceSession(transcript: String, response: String) {
        guard !entries.isEmpty else { return }
        if !transcript.isEmpty { entries[0].transcript = transcript }
        if !response.isEmpty { entries[0].response = response }
        guard entries[0].transcript != nil || entries[0].response != nil else { return }
        save()
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

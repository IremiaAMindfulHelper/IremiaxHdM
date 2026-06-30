import Foundation
import Shared

/// Lightweight UI model used on iOS to avoid direct dependency on
/// Kotlin/Native-exported types.
struct NoteUI: Identifiable, Equatable {
    let id: Int64
    let content: String
    let createdAt: Int64
}

/// ObservableObject that bridges the shared KMP NotesController state
/// into SwiftUI-friendly properties. Subscribes to the state flow
/// and maps items to `NoteUI` for UI consumption.
final class NotesObservable: ObservableObject {
    @Published var items: [NoteUI] = []
    @Published var isLoading = false
    @Published var entryCount = 0
    @Published var gardenEntries: [Int] = []

    private let controller: NotesController
    private var cancelable: KmpCancelable?

    init() {
        controller = SharedFactory.shared.createNotesController(
            driverFactory: DriverFactory()
        )

        cancelable = Interop.shared.observeState(flow: controller.state) { anyValue in
            guard let s = anyValue as? NotesState else { return }

            let raw = (s.items as? [Any]) ?? []
            let uiItems = raw.compactMap { NotesObservable.toUI($0) }
            
            let rawGarden = (s.gardenEntries as? [Int])
                ?? (s.gardenEntries as? [NSNumber])?.map { $0.intValue }
                ?? []

            DispatchQueue.main.async {
                self.items = uiItems
                self.isLoading = s.isLoading
                self.entryCount = Int(s.entryCount)
                self.gardenEntries = rawGarden
            }
        }
    }

    deinit {
        cancelable?.cancel()
        controller.clear()
    }

    /// Adds a new note via the shared controller (async wrapper).
    func add(content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        controller.addAsync(content: trimmed, createdAt: nowMs) { _ in }
    }

    /// Adds a full episode with captured metadata via the shared controller.
    func addEpisode(_ draft: EpisodeDraftData) {
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        controller.addEpisodeAsync(
            content: draft.content.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: nowMs,
            strength: draft.strength.map { KotlinInt(int: Int32($0)) },
            places: draft.places,
            activities: draft.activities,
            bodySignals: draft.bodySignals,
            moodBefore: draft.moodBefore.map { KotlinInt(int: Int32($0)) },
            moodAfter: draft.moodAfter.map { KotlinInt(int: Int32($0)) }
        ) { _ in }
    }

    /// Updates an episode and its metadata via the shared controller.
    func updateEpisode(id: Int64, _ draft: EpisodeDraftData) {
        controller.updateEpisodeAsync(
            id: id,
            content: draft.content.trimmingCharacters(in: .whitespacesAndNewlines),
            strength: draft.strength.map { KotlinInt(int: Int32($0)) },
            places: draft.places,
            activities: draft.activities,
            bodySignals: draft.bodySignals,
            moodBefore: draft.moodBefore.map { KotlinInt(int: Int32($0)) },
            moodAfter: draft.moodAfter.map { KotlinInt(int: Int32($0)) }
        ) { _ in }
    }

    /// Deletes a note by ID via the shared controller (async wrapper).
    func delete(id: Int64) {
        controller.deleteAsync(id: id) { _ in }
    }

    // MARK: - Mapping Helpers

    /// Converts an arbitrary KMP-exported Note object to `NoteUI`.
    /// Uses KVC/Mirror to read properties, making the bridge resilient to renames.
    private static func toUI(_ any: Any) -> NoteUI? {
        let obj = any as AnyObject

        // content
        let content = (obj.value(forKey: "content") as? String)
            ?? Mirror(reflecting: any).children.first(where: { $0.label == "content" })?.value as? String
            ?? ""

        // id (Int64 | NSNumber | KotlinLong.int64Value)
        var id: Int64 = 0
        if let n = obj.value(forKey: "id") as? NSNumber {
            id = n.int64Value
        } else if let kl = obj.value(forKey: "id") {
            if let n = (kl as AnyObject).value(forKey: "int64Value") as? Int64 { id = n }
        } else {
            let mir = Mirror(reflecting: any)
            if let child = mir.children.first(where: { $0.label == "id" }) {
                if let n = child.value as? Int64 { id = n }
                else if let num = child.value as? NSNumber { id = num.int64Value }
                else if let n = (child.value as AnyObject).value(forKey: "int64Value") as? Int64 { id = n }
            }
        }

        // createdAt (Int64 | NSNumber | KotlinLong.int64Value)
        var createdAt: Int64 = 0
        if let n = obj.value(forKey: "createdAt") as? NSNumber {
            createdAt = n.int64Value
        } else if let kl = obj.value(forKey: "createdAt") {
            if let n = (kl as AnyObject).value(forKey: "int64Value") as? Int64 { createdAt = n }
        } else {
            let mir = Mirror(reflecting: any)
            if let child = mir.children.first(where: { $0.label == "createdAt" }) {
                if let n = child.value as? Int64 { createdAt = n }
                else if let num = child.value as? NSNumber { createdAt = num.int64Value }
                else if let n = (child.value as AnyObject).value(forKey: "int64Value") as? Int64 { createdAt = n }
            }
        }

        return NoteUI(id: id, content: content, createdAt: createdAt)
    }
}

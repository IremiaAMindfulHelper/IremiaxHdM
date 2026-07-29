import Foundation
import shared

/// Lightweight UI model used on iOS to avoid direct dependency on
/// Kotlin/Native-exported types.
struct NoteUI: Identifiable, Equatable {
    let id: Int64
    let content: String
    let createdAt: Int64
    /// Entry type as its storage token ("panic" / "journal").
    var type: String = "panic"
    /// User-set title, or nil to derive one from `content`.
    var title: String? = nil
    var strength: Int? = nil
    var places: [String] = []
    var activities: [String] = []
    var bodySignals: [String] = []
    var moodBefore: Int? = nil
    var moodAfter: Int? = nil

    /// True for journal entries (hide panic-only intensity/mood in the UI).
    var isJournal: Bool { type == "journal" }

    /// Title shown in lists/detail: user title when set, else derived from text.
    var displayTitle: String {
        if let t = title, !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return t }
        let firstLine = content
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first(where: { !$0.isEmpty }) ?? ""
        if firstLine.count <= 40 { return firstLine }
        let cut = String(firstLine.prefix(40))
        if let lastSpace = cut.lastIndex(of: " ") {
            return String(cut[..<lastSpace]) + "…"
        }
        return cut + "…"
    }
}

/// ObservableObject that bridges the shared KMP NotesController state
/// into SwiftUI-friendly properties. Subscribes to the state flow
/// and maps items to `NoteUI` for UI consumption.
final class NotesObservable: ObservableObject {
    @Published var items: [NoteUI] = []
    @Published var isLoading = false
    @Published var entryCount = 0
    @Published var gardenEntries: [Int] = []
    /// Result of the most recent plant attempt, for the saved screen (Block 3 / 6.2).
    @Published var lastPlantResult: PlantResult?

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
        controller.addAsync(content: trimmed, createdAt: nowMs) { _, _ in }
    }

    /// Adds an entry (panic or journal) from a captured draft via the shared
    /// controller. Plants a linked garden item and publishes the plant result so
    /// the saved screen can adapt its text.
    func addEntry(_ draft: EpisodeDraftData) {
        controller.addDraftAsync(draft: draft.toShared()) { [weak self] result, _ in
            DispatchQueue.main.async { self?.lastPlantResult = result }
        }
    }

    /// Reset the plant result when a new capture flow starts.
    func clearPlantResult() {
        lastPlantResult = nil
    }

    /// Updates an entry from a captured draft via the shared controller.
    func updateEntry(id: Int64, _ draft: EpisodeDraftData) {
        controller.updateDraftAsync(id: id, draft: draft.toShared()) { _ in }
    }

    /// Deletes a note by ID via the shared controller (async wrapper).
    func delete(id: Int64) {
        controller.deleteAsync(id: id) { _ in }
    }

    // MARK: - Mapping Helpers

    private static func stringArray(from value: Any?) -> [String] {
        if let strings = value as? [String] { return strings }
        if let string = value as? String {
            return string
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        return []
    }

    private static func stringArray(from any: Any, key: String) -> [String] {
        let mirrorValue = Mirror(reflecting: any).children.first(where: { $0.label == key })?.value
        return stringArray(from: mirrorValue)
    }

    /// Converts an arbitrary KMP-exported Note object to `NoteUI`.
    /// Uses KVC/Mirror to read properties, making the bridge resilient to renames.
    private static func toUI(_ any: Any) -> NoteUI? {
        // Fast path: the shared domain model. Obj-C export renames it to `Note_`
        // because the SQLDelight row type already claims the `Note` Swift name.
        if let note = any as? Note_ {
            return NoteUI(
                id: note.id,
                content: note.content,
                createdAt: note.createdAt,
                type: note.type.storageValue,
                title: note.title,
                strength: note.strength?.intValue,
                places: note.places,
                activities: note.activities,
                bodySignals: note.bodySignals,
                moodBefore: note.moodBefore?.intValue,
                moodAfter: note.moodAfter?.intValue
            )
        }

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

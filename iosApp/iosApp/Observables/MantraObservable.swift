import Foundation
import Shared

/// Lightweight UI model used on iOS to avoid direct dependency on
/// Kotlin/Native-exported types (names can vary across builds).
struct MantraUI: Identifiable, Equatable {
    let id: Int64
    let text: String
}

/// ObservableObject that bridges the shared KMP MantrasController state
/// into SwiftUI-friendly properties. Subscribes to a Kotlin StateFlow and
/// maps items to `MantraUI` to keep the iOS layer stable.
///
/// - Design:
///   - Uses `SharedFactory` to construct the controller (single entry point).
///   - Observes `controller.state` via `Interop.observeState(...)`.
///   - Maps arbitrary KMP item objects to `MantraUI` (tolerant to K/N type names).
final class MantrasObservable: ObservableObject {
    /// UI-facing items (decoupled from KMP types).
    @Published var items: [MantraUI] = []
    @Published var isLoading = false
    @Published var inputText = ""

    private let controller: MantrasController
    private var cancelable: KmpCancelable?

    /// Builds the shared controller and subscribes to its StateFlow.
    /// Mapping to `MantraUI` avoids crashes when Kotlin/Native type
    /// names differ between builds.
    init() {
        controller = SharedFactory.shared.createMantrasController(
            driverFactory: DriverFactory()
        )

        cancelable = Interop.shared.observeState(flow: controller.state) { anyValue in
            guard let s = anyValue as? MantrasState else { return }

            // NOTE: `s.items` is an NSArray of KMP objects; map to stable Swift structs.
            let raw = (s.items as? [Any]) ?? []
            let uiItems = raw.compactMap { MantrasObservable.toUI($0) }

            DispatchQueue.main.async {
                self.items = uiItems
                self.isLoading = s.isLoading
            }
        }
    }

    deinit { cancelable?.cancel() }

    /// Adds a new mantra through the shared controller (async wrapper).
    func add() {
        let t = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        controller.addAsync(text: t) { _ in }
        inputText = ""
    }

    /// Removes a mantra by id via the shared controller (async wrapper).
    func remove(id: Int64) {
        controller.removeAsync(id: id) { _ in }
    }

    // MARK: - Mapping Helpers

    /// Converts an arbitrary KMP-exported mantra object to `MantraUI`.
    /// Uses KVC/Mirror to read `text` and `id` (which may be Int64, NSNumber,
    /// or KotlinLong with `int64Value`), making the bridge resilient to K/N renames.
    private static func toUI(_ any: Any) -> MantraUI? {
        let obj = any as AnyObject

        // text
        let text = (obj.value(forKey: "text") as? String)
            ?? Mirror(reflecting: any).children.first(where: { $0.label == "text" })?.value as? String
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

        return MantraUI(id: id, text: text)
    }
}

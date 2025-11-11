import Foundation
import Shared

struct MantraUI: Identifiable, Equatable {
    let id: Int64
    let text: String
}

final class MantrasObservable: ObservableObject {
    @Published var items: [MantraUI] = []
    @Published var isLoading = false
    @Published var inputText = ""

    private let controller: MantrasController
    private var cancelable: KmpCancelable?

    init() {
        controller = SharedFactory.shared.createMantrasController(
            driverFactory: DriverFactory()
        )

        cancelable = Interop.shared.observeState(flow: controller.state) { anyValue in
            guard let s = anyValue as? MantrasState else { return }

            // Robust: beliebige KMP-Objekte -> Swift-Struct mappen
            let raw = (s.items as? [Any]) ?? []
            let uiItems = raw.compactMap { MantrasObservable.toUI($0) }

            DispatchQueue.main.async {
                self.items = uiItems
                self.isLoading = s.isLoading
            }
        }
    }

    deinit { cancelable?.cancel() }

    func add() {
        let t = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        controller.addAsync(text: t) { _ in }
        inputText = ""
    }

    func remove(id: Int64) {
        controller.removeAsync(id: id) { _ in }
    }

    // MARK: - Mapping Helpers

    private static func toUI(_ any: Any) -> MantraUI? {
        let obj = any as AnyObject

        // text
        let text = (obj.value(forKey: "text") as? String)
            ?? Mirror(reflecting: any).children.first(where: { $0.label == "text" })?.value as? String
            ?? ""

        // id (kann Int64, NSNumber oder KotlinLong sein)
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

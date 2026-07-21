import Foundation
import shared

/// Bridges the shared `MotivationController` state into SwiftUI. Drives the home
/// screen's blue insight card. Follows the same pattern as `GardenObservable`.
final class MotivationObservable: ObservableObject {
    @Published var insight: MotivationInsight = MotivationInsight.companion.placeholder
    @Published var isLoading = true

    private var controller: MotivationController?
    private var cancelable: KmpCancelable?
    private var hasStarted = false

    init() {}

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            let controller = SharedFactory.shared.createMotivationController(
                driverFactory: DriverFactory()
            )

            let cancelable = Interop.shared.observeState(flow: controller.state) { anyValue in
                guard let s = anyValue as? MotivationState else { return }
                DispatchQueue.main.async {
                    self.insight = s.insight
                    self.isLoading = s.isLoading
                }
            }

            DispatchQueue.main.async {
                self.controller = controller
                self.cancelable = cancelable
            }
        }
    }

    deinit {
        cancelable?.cancel()
        controller?.clear()
    }
}

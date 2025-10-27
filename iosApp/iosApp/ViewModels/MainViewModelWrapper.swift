import SwiftUI
import Shared

/// A SwiftUI-compatible wrapper around the shared Kotlin `MainViewModel`.
///
/// `MainViewModelWrapper` bridges the Kotlin Multiplatform `MainViewModel` to SwiftUI by
/// observing its `NavigationTarget` flow and exposing it as a `@Published` property.
/// This allows SwiftUI views to reactively update their state when navigation changes occur
/// in the shared Kotlin logic.
///
/// The wrapper uses a `FlowObserver` to collect state updates from Kotlin's `StateFlow`
/// and forwards them to the main thread for UI updates.
///
/// - Properties:
///   - currentTarget: The currently active navigation target, published for SwiftUI bindings.
/// - Methods:
///   - onTabSelected(_:): Notifies the shared view model when a tab is selected.
/// - Note:
///   - The observer is automatically closed on deinitialization to prevent memory leaks.
class MainViewModelWrapper: ObservableObject {
    private let viewModel = MainViewModel()
    private var observer: FlowObserver?

    @Published var currentTarget: NavigationTarget = NavigationTarget.Home()

    init() {
        observer = FlowObserver()
        observer?.observeNavigationTarget(flow: viewModel.navigation.currentTarget) { target in
            DispatchQueue.main.async {
                self.currentTarget = target
            }
        }
    }

    func onTabSelected(_ target: NavigationTarget) {
        viewModel.onTabSelected(target: target)
    }

    deinit {
        observer?.close()
    }
}

import SwiftUI
import Shared

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

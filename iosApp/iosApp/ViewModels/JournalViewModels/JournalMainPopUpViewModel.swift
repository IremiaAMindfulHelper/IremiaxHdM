//
//  JournalMainPopUpViewModel.swift
//  iosApp
//
//  Created by Anke Raab on 23.02.26.
//

import Foundation

final class JournalMainPopUpViewModel: ObservableObject {

    @Published var dragOffset: CGFloat = 0

    let dismissDragThreshold: CGFloat

    init(dismissDragThreshold: CGFloat = 120) {
        self.dismissDragThreshold = dismissDragThreshold
    }

    func onDragChanged(translationY: CGFloat) {
        dragOffset = max(0, translationY)
    }

    func shouldDismiss(translationY: CGFloat) -> Bool {
        translationY > dismissDragThreshold
    }

    func resetDragOffset() {
        dragOffset = 0
    }
}

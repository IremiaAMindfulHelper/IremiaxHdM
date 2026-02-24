//
//  JournalMainPopUpViewModel.swift
//  iosApp
//

import Foundation

/// ViewModel für ein Popup im Journal-Bereich.
/// Verwaltet die Drag-Bewegung nach unten und entscheidet,
/// ob das Popup geschlossen werden soll.
final class JournalMainPopUpViewModel: ObservableObject {

    // Aktuelle vertikale Verschiebung des Popups während des Draggens
    @Published var dragOffset: CGFloat = 0

    // Schwellenwert, ab dem das Popup beim Loslassen geschlossen wird
    let dismissDragThreshold: CGFloat

    // Initialisiert das ViewModel mit einem optionalen Schwellenwert
    // Standardwert: 120 Punkte
    init(dismissDragThreshold: CGFloat = 120) {
        self.dismissDragThreshold = dismissDragThreshold
    }

    // Wird während der Drag-Geste aufgerufen.
    // Speichert nur positive Werte, damit das Popup
    // nur nach unten gezogen werden kann.
    func onDragChanged(translationY: CGFloat) {
        dragOffset = max(0, translationY)
    }

    // Prüft, ob die Drag-Bewegung groß genug ist,
    // um das Popup zu schließen.
    func shouldDismiss(translationY: CGFloat) -> Bool {
        translationY > dismissDragThreshold
    }

    // Setzt die Verschiebung zurück,
    // z. B. wenn das Popup wieder in seine Ausgangsposition springt.
    func resetDragOffset() {
        dragOffset = 0
    }
}

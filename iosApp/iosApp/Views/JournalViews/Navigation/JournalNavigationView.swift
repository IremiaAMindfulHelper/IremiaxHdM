import SwiftUI

// Diese View steuert die komplette Navigation im Journal-Bereich.
// Sie verwaltet den NavigationStack, entscheidet welche Seite angezeigt wird
// und kümmert sich um das Öffnen von Popups (Sheets).

struct JournalNavigationView: View {
    
    // Speichert den aktuellen Navigationsverlauf
    @State private var navigationPath = NavigationPath()
    
    // Bestimmt, welcher Hauptmodus im Journal angezeigt wird (z.B. Emotionen oder Panik)
    @State private var rootMode: JournalRootMode = .emotions

    // Optionales Popup-Element. Wenn gesetzt, wird ein Sheet angezeigt.
    @State private var popupItem: JournalPopupItem?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            rootContent
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .sheet(item: $popupItem) { item in
            popupSheet(for: item)
        }
    }

    // Hauptinhalt des NavigationStacks.
    // Es gibt nur eine Kalenderansicht, der Modus wird intern umgeschaltet.
    private var rootContent: some View {
        JournalMainView(
            rootMode: $rootMode,

            // Wird aufgerufen, wenn bei Stimmung ein Gradient-Tag gedrückt wird.
            // Öffnet das passende Mood-Popup.
            onPlusButtonTappedMood: { date, mark in
                let kind: JournalPopupKind = (mark == .moodGradientA) ? .moodA : .moodB
                popupItem = JournalPopupItem(date: date, kind: kind)
            },

            // Wird aufgerufen, wenn ein Panic-Tag gedrückt wird.
            // Öffnet das Panic-Popup.
            onPlusButtonTappedPanic: { date in
                popupItem = JournalPopupItem(date: date, kind: .panic)
            },

            // Wird aufgerufen, wenn ein neuer Eintrag erstellt oder geöffnet werden soll.
            // Navigiert zur JournalEntryView.
            onCreateEntry: { date in
                navigationPath.append(AppRoute.journalEntry(date: date))
            }
        )
    }

    // Erstellt das Popup-Sheet inklusive Header und Styling.
    private func popupSheet(for item: JournalPopupItem) -> some View {
        
        // Formatiert das Datum für die Anzeige im Header
        let header = JournalPopupStyleProvider.headerFormatter.string(from: item.date).capitalized
        
        // Liefert Texte und Farben passend zum Popup-Typ
        let style = JournalPopupStyleProvider.style(for: item.kind, date: item.date)

        return JournalMainPopUpView(
            
            // Öffnet den Eintrag zur Bearbeitung
            onEintragBearbeiten: {
                let date = item.date
                popupItem = nil
                navigationPath.append(AppRoute.journalEntry(date: date))
            },
            
            // Schließt das Popup
            onDismiss: {
                popupItem = nil
            },
            
            // Übergibt formatierte Inhalte an die Popup-View
            dateHeader: header,
            chipText: style.chipText,
            chipGradient: style.gradient
        )
        // Legt die Höhe des Sheets fest
        .presentationDetents([.fraction(0.4)])
        
        // Versteckt die Standard-Drag-Anzeige
        .presentationDragIndicator(.hidden)
        
        // Setzt den Hintergrund des Sheets
        .presentationBackground(Color.white)
    }

    // Entfernt die letzte Route aus dem NavigationStack, falls möglich.
    private func safePop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    // Gibt abhängig von der Route die passende Ziel-View zurück.
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
            
        // Hauptansicht für einen Journaleintrag
        case .journalEntry(let date):
            JournalEntryView(
                onBack: { safePop() },
                onOpenDiary: { diaryDate in
                    navigationPath.append(AppRoute.journalDiaryView(date: diaryDate))
                },
                onOpenPanicReflexion: { panicDate in
                    navigationPath.append(AppRoute.panicReflection(date: panicDate))
                },
                entryDate: date
            )

        // Tagebuchansicht eines Eintrags
        case .journalDiaryView(let date):
            JournalDiaryView(
                onBack: { safePop() },
                onOpenQuestionCatalog: { navigationPath.append(AppRoute.questionCatalog) },
                entryDate: date
            )

        // Reflexionsansicht für Panik
        case .panicReflection(let date):
            PanicReflexion(
                onBack: { safePop() },
                entryDate: date
            )

        // Fragenkatalog
        case .questionCatalog:
            QuestionCatalog(onBack: { safePop() })
        }
    }
}

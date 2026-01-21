import SwiftUI

enum AppRoute: Hashable {
    case journalEntry
    case journalDiaryView
    case panicReflection
    case questionCatalog
}

// Root-Modus fürs Journal (welche Hauptansicht im Tab angezeigt wird)
enum JournalRootMode: Hashable {
    case emotions
    case panicAttacks
}

struct JournalNavigationView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showJournalPopup = false

    // steuert, welche Root-View im Journal angezeigt wird
    @State private var rootMode: JournalRootMode = .emotions

    var body: some View {
        NavigationStack(path: $navigationPath) {

            Group {
                switch rootMode {
                case .emotions:
                    JournalMainViewEmotions(
                        rootMode: $rootMode,
                        onPlusButtonTapped: {
                            showJournalPopup = true
                        }
                    )

                case .panicAttacks:
                    JournalMainViewPanicAttacks(
                        rootMode: $rootMode,
                        onPlusButtonTapped: {
                            showJournalPopup = true
                        }
                    )
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
            .sheet(isPresented: $showJournalPopup) {
                JournalMainPopUpView(
                    onEintragBearbeiten: {
                        showJournalPopup = false
                        navigationPath.append(AppRoute.journalEntry) // ✅ FIX
                    }
                )
            }
        }
    }

    // ✅ Crash-sicheres Zurück
    private func safePop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .journalEntry:
            JournalEntryView(
                onBack: { safePop() },
                onOpenDiary: { navigationPath.append(AppRoute.journalDiaryView) },        // ✅ FIX
                onOpenPanicReflexion: { navigationPath.append(AppRoute.panicReflection) } // ✅ FIX
            )

        case .journalDiaryView:
            JournalDiaryView(
                onBack: { safePop() }
            )

        case .panicReflection:
            PanicReflexion(
                onBack: { safePop() }
            )

        case .questionCatalog:
            Text("Question Catalog")
        }
    }
}

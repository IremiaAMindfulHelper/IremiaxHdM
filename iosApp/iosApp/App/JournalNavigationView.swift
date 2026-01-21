import SwiftUI

enum AppRoute: Hashable {
    case journalEntry
    case journalDiaryView
    case panicReflection
    case questionCatalog
}

enum JournalRootMode: Hashable {
    case emotions
    case panicAttacks
}

struct JournalNavigationView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showJournalPopup = false
    @State private var rootMode: JournalRootMode = .emotions

    var body: some View {
        NavigationStack(path: $navigationPath) {

            // ✅ Hintergrund: Journal Root Views
            Group {
                switch rootMode {
                case .emotions:
                    JournalMainViewEmotions(
                        rootMode: $rootMode,
                        onPlusButtonTapped: {          // farbiger Kreis -> Popup
                            showJournalPopup = true
                        },
                        onCreateEntry: {               // + -> JournalEntryView
                            navigationPath.append(AppRoute.journalEntry)
                        }
                    )

                case .panicAttacks:
                    JournalMainViewPanicAttacks(
                        rootMode: $rootMode,
                        onPlusButtonTapped: {          // broken heart -> Popup
                            showJournalPopup = true
                        },
                        onCreateEntry: {               // + -> JournalEntryView
                            navigationPath.append(AppRoute.journalEntry)
                        }
                    )
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
        }
        // ✅ Popup als Sheet -> TabBar unten ist weg
        .sheet(isPresented: $showJournalPopup) {
            JournalMainPopUpView(
                onEintragBearbeiten: {
                    showJournalPopup = false
                    navigationPath.append(AppRoute.journalEntry)
                },
                onDismiss: {
                    showJournalPopup = false
                }
            )
            // ✅ 40% Höhe wie vorher
            .presentationDetents([.fraction(0.4)])
            // ✅ eigener Grabber -> System-Grabber verstecken
            .presentationDragIndicator(.hidden)
            // ✅ FIX: grauen Streifen unten entfernen
            .presentationBackground(Color.white)
        }
    }

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
                onOpenDiary: { navigationPath.append(AppRoute.journalDiaryView) },
                onOpenPanicReflexion: { navigationPath.append(AppRoute.panicReflection) }
            )

        case .journalDiaryView:
            JournalDiaryView(onBack: { safePop() })

        case .panicReflection:
            PanicReflexion(onBack: { safePop() })

        case .questionCatalog:
            Text("Question Catalog")
        }
    }
}

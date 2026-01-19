import SwiftUI

enum AppRoute: Hashable {
    case journalEntry
    case journalDiaryView
    case panicReflection
    case questionCatalog
}

struct JournalNavigationView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showJournalPopup = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            JournalMainViewEmotions(
                onPlusButtonTapped: {
                    showJournalPopup = true
                }
            )
            .navigationDestination(for: AppRoute.self) { route in  // ← HIER DRIN!
                destinationView(for: route)
            }
            .sheet(isPresented: $showJournalPopup) {
                JournalMainPopUpView(
                    onEintragBearbeiten: {
                        showJournalPopup = false
                        navigationPath.append(AppRoute.journalEntry)
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .journalEntry:
            JournalEntryView(
                onBack: {
                    navigationPath.removeLast()
                },
                onOpenDiary: {
                    navigationPath.append(AppRoute.journalDiaryView)
                },
                onOpenPanicReflexion: {
                    navigationPath.append(AppRoute.panicReflection)
                }
            )
        case .journalDiaryView:
            JournalDiaryView(
                                onBack: {
                                    navigationPath.removeLast()
                                }
                            )
        case .panicReflection: 
            PanicReflexion(
                onBack: {
                    navigationPath.removeLast()
                }
            )
        case .questionCatalog:
            Text("Question Catalog")
        }
    }
}

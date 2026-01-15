import SwiftUI

enum AppRoute: Hashable {
    case journalEntry
    case journalDiary
    case panicReflexion
    case questionCatalog
}

struct JournalNavigationView: View {
    
    @State private var navigationPath = NavigationPath()
    @State private var showJournalPopup = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            JournalMainViewEmotions()
            .sheet(isPresented: $showJournalPopup) {
                JournalMainPopUpView()
        }
            .navigationDestination(for: AppRoute.self) {
                route in destinationView(for: route)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .journalDiary:
                Text("Journal Diary")
        case .journalEntry:
            Text("Journal Entry")
        case .panicReflexion:
            Text("Panic Reflexion")
        case .questionCatalog:
            Text("Question Catalog")
        }
    }
    
}

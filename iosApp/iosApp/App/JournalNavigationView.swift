import SwiftUI

enum AppRoute: Hashable {
    case journalEntry
    case journalDiary
    case panicReflexion
    case questionCatalog
}

struct JournalNavigationView: View {
    
    @State private var navigationPath: NavigationPath()
    @State private var showJournalPopup = false
    
    var body: some View {
    }
}

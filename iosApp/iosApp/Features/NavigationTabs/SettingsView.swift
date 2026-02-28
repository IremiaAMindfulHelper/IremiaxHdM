import SwiftUI

/// Filler view
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Benutzer")) {
                    Text("Profil bearbeiten")
                    Text("Abonnement")
                }
                
                Section(header: Text("App")) {
                    Toggle("Mitteilungen", isOn: .constant(true))
                    Text("Dunkelmodus")
                }
            }
            .navigationTitle("Einstellungen")
        }
    }
}

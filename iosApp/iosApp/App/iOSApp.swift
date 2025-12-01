import SwiftUI
import Shared

@main
struct iOSApp: App {
    init() {
            // Optional: hart auf Deutsch schalten, falls du die Funktion gebaut hast
            // useGerman()

            // 🔎 App & System
            print("Device langs:", Locale.preferredLanguages)
            print("App Bundle localizations:", Bundle.main.localizations)
            print("App preferred localizations:", Bundle.main.preferredLocalizations)
        }

    
    var body: some Scene {
        WindowGroup {
            MainView()
                .accentColor(Color.primary500)
                .background(Color.background)
        }
    }
}

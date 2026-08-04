# 04 — iOS-Client

SwiftUI-App in `iosApp/`. Bindet das Shared-Modul als `Shared.xcframework` ein.
Geöffnet wird **`iosApp.xcworkspace`**, nicht die `.xcodeproj` (CocoaPods).

## Aufbau

```
iosApp/iosApp/
├── App/
│   ├── iOSApp.swift           Einstieg
│   └── MainView.swift         Shell: Tabs, "+"-Button, Capture-Flow, Garten
├── Observables/               Brücke zu den Kotlin-Controllern
├── Views/
│   ├── Home/                  Startbildschirm
│   ├── JournalViews/          Journal, Kalender, Erfassung, Garten
│   ├── Exercises/             Atem, Memory, Rechnen, Mantra
│   └── SOS/                   Notfall-Flow
├── UI/
│   ├── Theme/                 IremiaDesignTokens
│   └── Components/            wiederverwendete Bausteine
├── ViewModels/
└── Utils/StringProxy.swift    Zugriff auf die geteilten Texte
```

## Observables als Brücke

Für jeden Kotlin-Controller gibt es eine `ObservableObject`-Klasse. Sie abonniert den
`StateFlow` und spiegelt ihn in `@Published`-Werte:

```swift
final class NotesObservable: ObservableObject {
    @Published var items: [NoteUI] = []

    init() {
        cancelable = Interop.shared.observeState(flow: controller.state) { value in
            // auf dem Main-Queue in @Published schreiben
        }
    }

    deinit {
        cancelable?.cancel()   // Flow-Abo beenden
        controller.clear()     // Kotlin-Scope abbrechen
    }
}
```

**Beide Zeilen im `deinit` sind Pflicht.** Fehlt eine, läuft nach dem Schließen des
Screens weiter Kotlin-Code, der in ein `@Published` schreibt, das niemand mehr liest.

## MainView als Shell

Wie auf Android liegen hier die geteilten Zustände (`NotesObservable`,
`GardenObservable`), damit Start und Journal denselben Garten zeigen.

Ein iOS-spezifischer Punkt: **verschachtelte `fullScreenCover` sind heikel.** Als der
Garten noch vom Journal-Tab präsentiert wurde, musste iOS erst den Erfassungs-Flow
schließen und den Journal-Screen zeichnen, bevor der Garten aufgehen konnte — sichtbar
als kurzes Aufblitzen des Journals. Der Garten wird darum aus der Shell heraus im
`onDismiss` des Flows geöffnet.

Merksatz: Wenn ein Vollbild direkt auf ein anderes folgen soll, beide von derselben
Ebene aus präsentieren.

## Texte

Über den `StringProxy`, der auf `SharedRes` zugreift:

```swift
Text(Strings.journal_title)
```

Nicht `.desc()` verwenden — das gibt es nur in Kotlin. Details in
[06 Lokalisierung](06-lokalisierung.md).

## Design-Tokens

`UI/Theme/IremiaDesignTokens.swift` enthält Farben, Schrift und Abstände. Relevante
Abstände am unteren Rand:

| Token | Wert | Bedeutung |
| ----- | ---: | --------- |
| `bottomNavClearance` | 110 | Abstand über der Tab-Leiste |
| `scrollBottomClearance` | 182 | Freiraum am Ende scrollbarer Inhalte, damit sie **auch** am "+"-Button vorbeikommen (110 + 56 Button + Luft) |

## Animationen synchron zu Android halten

Die Pflanz-Choreografie besteht aus vier Schritten, deren Zeiten auf beiden
Plattformen übereinstimmen müssen:

| Schritt | Dauer |
| ------- | ----: |
| Kamera zoomt auf die Zelle | 0,8 s |
| Wachstums-Animation | 1,8 s |
| Überblendung auf das feste Bild | 0,4 s |
| Kamera zoomt zurück | 0,8 s |

**Fallstrick:** Die Wachstums-Datei ist 20 Sekunden lang. Wird sie über einen
Geschwindigkeitsfaktor gesteuert, hängt die gefühlte Dauer an der Länge der Datei —
`speed: 4` ergab 5 Sekunden statt der 1,8 auf Android. Deshalb nimmt
`GrowthLottieView` einen `duration:`-Wert und rechnet die nötige Geschwindigkeit aus
der tatsächlichen Länge aus.

Faustregel: **Dauer vorgeben, nicht Geschwindigkeit** — überall dort, wo iOS und
Android gleich wirken sollen.

## Bauen

```bash
# Shared-Framework erzeugen (nach jeder Kotlin-Änderung)
./gradlew :shared:podPublishDebugXCFramework

# App bauen
cd iosApp
xcodebuild -workspace iosApp.xcworkspace -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build
```

Auslieferung in [07 Build und Auslieferung](07-build-und-auslieferung.md).

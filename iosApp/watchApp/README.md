# Iremia Watch App

Companion-App für Apple Watch zum iOS-Client von **Iremia**. Sie läuft eigenständig auf der Uhr und tauscht Daten über `WatchConnectivity` mit der iPhone-App aus (z. B. für Sprach-Transkription und Claude-Anfragen, die auf der Watch selbst nicht möglich sind).

> Diese Doku beschreibt nur das watchOS-Target (`iosApp/watchApp/`). Details zur Emergency-Voice-Funktion (Claude-Integration, RAG-Wissensbasis) stehen in [`docs/voice-feature.md`](../../docs/voice-feature.md).

## Team

* **Lovis Pangratz**
* **Daniel Gieser**
* **Anton Smirnov**
* **José Viana**
* **Fiona Hirschberg**

## Links

* **Figma (Smartwatch Companion):** https://www.figma.com/design/AcWeD0AGec92pJtKEzZ3r1/Iremia-Smartwatch-companion?node-id=1707-403&t=Dbt6x0D5ovlOjE7M-1
* **Videos, Dokumentation, Folien, Survey-Ergebnisse:** https://cloud.mi.hdm-stuttgart.de/index.php/s/yycFbXgfg8cF2QB

## Einstieg

Entry Point ist `IremiaWatchApp.swift` → lädt `ContentView`, die den kompletten Mood-Check-Flow als State Machine steuert (`MoodFlowStep`: `.initial` → `.category` → `.detail` → `.response` → `.done`).

Um die Watch-App zu bauen:

1. `iosApp.xcworkspace` in Xcode öffnen (siehe Root-README für die vorangehenden Setup-Schritte).
2. Watch-Scheme auswählen und einen watchOS-Simulator (oder gekoppelte Watch) als Ziel wählen.
3. Für Tests mit echter Claude-Anbindung: iPhone-App muss laufen und über WatchConnectivity erreichbar sein (siehe unten).

## Struktur

| Datei/Ordner | Zweck |
|---|---|
| `IremiaWatchApp.swift` | App-Entry-Point |
| `ContentView.swift` | Navigations-/State-Machine für den Mood-Check-Flow |
| `MoodCheckView.swift`, `MoodMicView.swift` | Mood-Buttons (gut/okay/schlecht) + Mikrofon-Check-in mit Waveform |
| `BreathingWatchView.swift` | Atemübung mit Ein-/Halte-/Ausatem-Phasen |
| `JourneyStore.swift`, `JourneyView.swift` | Lokales Tagebuch/Journal auf der Watch |
| `LearnContent.swift`, `LearnView.swift` | Infos zu Panikattacken und Coping-Strategien |
| `DailyMessageStore.swift` | Home-Screen-Grußnachricht, holt bei jedem Öffnen eine neue Claude-Antwort übers iPhone (mit lokalem Fallback) |
| `EmergencyVoice/` | Voice-UI + ViewModel für die Notfall-Sprachfunktion (Watch-Seite) |
| `WatchConnectivityManager.swift` | Zentrale Schnittstelle zur iPhone-App (`WCSession`), inkl. Kontakte, Live-Transkript, Settings |
| `ContactsListView.swift` | Notfallkontakte, synchronisiert vom iPhone |
| `IremiaColors.swift` | Farbpalette der Watch-App |
| `Assets.xcassets` | Icons, Mood-Illustrationen |

## Kommunikation mit dem iPhone

Die Watch macht selbst **keine** Netzwerk- oder Speech-Recognition-Aufrufe. Alles, was Claude-API oder `SFSpeechRecognizer` braucht, geht über `WCSession` ans iPhone (`PhoneConnectivityManager.swift` auf iOS-Seite) und kommt als fertige Antwort zurück. Gründe: watchOS-Limitierungen bei `SFSpeechRecognizer` und Privacy/Akku.

Relevante Settings (in `UserDefaults`, geteilt zwischen Watch-Views und Connectivity-Layer):

- `VoiceSettings.localeIdentifier` – Spracherkennungssprache (`de-DE`/`en-US`)
- `HomeMenuSettings.alternateLayoutKey` – alternatives Home-Menü-Layout (Bubble vs. Pill)

## Bekannte Fallbacks

Wenn das iPhone nicht erreichbar ist oder die Claude-Anfrage fehlschlägt, greifen alle Watch-Views auf lokale, hart codierte Antworten zurück (siehe `DailyMessageStore.fallback` als Beispiel). Die App soll dadurch auch offline nutzbar bleiben.

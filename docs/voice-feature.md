# Iremia – Emergency Voice Feature

## Projektkontext

Iremia ist eine Anti-Panikattacken-App für iOS und watchOS (Kotlin Multiplatform mit iOS-Komponente). Dieses Feature fügt eine Emergency Voice Funktion hinzu: Der Nutzer kann auf der Apple Watch sprechen, die Sprache wird transkribiert, und ein KI-Modell antwortet mit einer kurzen, beruhigenden Antwort basierend auf einem klinischen RAG-Datensatz.

---

## Feature-Übersicht

```
Apple Watch
  └─ Mikrofon (Aufnahme)
       └─ WatchConnectivity (WCSession)
            └─ iPhone
                 ├─ SFSpeechRecognizer (Transkription, on-device)
                 ├─ iremia_rag.json (RAG-Datensatz, im App Bundle)
                 └─ Cohere Command R API (command-r-08-2024)
                      └─ 1-2 Sätze Antwort → Watch (Text + TTS)
```

---

## Technologie-Entscheidungen

| Komponente | Entscheidung | Begründung |
|---|---|---|
| Spracheingabe | SFSpeechRecognizer (on-device) | Privacy, kein API-Call |
| Transkription läuft auf | iPhone (nicht Watch) | watchOS-Limitierung bei SFSpeechRecognizer |
| LLM | Cohere Command R (`command-r-08-2024`) | Nativer `documents[]`-RAG-Parameter, kostenloses Tier |
| RAG-Matching | Cohere übernimmt intern | Kein eigenes Embedding/Vektormatching nötig |
| RAG-Datensatz | `iremia_rag.json` im App Bundle | 40 klinisch geprüfte Einträge zu Angststörungen |
| TTS | AVSpeechSynthesizer | On-device, kein API-Call, Deutsch |
| API Key | iOS Keychain | Niemals hardcoden oder in UserDefaults speichern |
| Fallback | Hardcoded Strings | Funktioniert ohne Internet und bei API-Fehler |

---

## Dateistruktur

```
Iremia/
├── Features/
│   └── EmergencyVoice/
│       ├── EmergencyVoiceCoordinator.swift   # Hauptkoordinator (Phone)
│       ├── CohereRAGService.swift             # Cohere API + RAG
│       ├── SpeechRecognitionService.swift     # SFSpeechRecognizer
│       └── TTSService.swift                   # AVSpeechSynthesizer
├── Watch/
│   └── EmergencyVoice/
│       ├── EmergencyVoiceView.swift           # watchOS UI
│       └── EmergencyWatchViewModel.swift      # WCSession Watch-Seite
├── Shared/
│   ├── WatchSessionHandler.swift              # WCSession Phone-Seite
│   └── KeychainHelper.swift                   # API Key Keychain-Zugriff
└── Resources/
    └── iremia_rag.json                        # RAG-Datensatz (40 Einträge)
```

---

## Cohere API

### Endpunkt
```
POST https://api.cohere.com/v1/chat
```

### Headers
```
Authorization: Bearer {COHERE_API_KEY}
Content-Type: application/json
```

### Request Body
```json
{
  "model": "command-r-08-2024",
  "message": "{transkribierter Text des Nutzers}",
  "documents": [
    { "title": "Derealisation bei Panikattacken", "text": "..." },
    { "title": "Box Breathing", "text": "..." }
  ],
  "preamble": "Du bist Iremia, ein ruhiger Begleiter bei Panikattacken. Antworte auf Deutsch. Maximal 2 kurze Sätze. Nutze ausschließlich die bereitgestellten Dokumente. Keine Diagnosen.",
  "max_tokens": 120,
  "temperature": 0.2
}
```

### Response
```json
{
  "text": "Das unwirkliche Gefühl ist harmlos – dein Gehirn schützt dich gerade. Atme jetzt langsam: 4 Sekunden ein, 6 Sekunden aus."
}
```

### Wichtig
- **Alle** 40 RAG-Einträge aus `iremia_rag.json` werden bei jedem Request als `documents[]` mitgeschickt. Kein eigenes Matching implementieren – Cohere selektiert intern.
- `max_tokens: 120` — Antworten müssen kurz bleiben (watchOS-Display, Panikmoment)
- `temperature: 0.2` — Niedrig für konsistente, ruhige Antworten
- Timeout: 8 Sekunden. Bei Timeout immer Fallback-String zurückgeben, nie einen leeren Zustand anzeigen.

---

## RAG-Datensatz

Die Datei `iremia_rag.json` liegt im App Bundle und enthält 40 Einträge in folgendem Format:

```json
[
  {
    "id": "PA008",
    "category": "Panikattacke – Symptome",
    "title": "Derealisation bei Panikattacken",
    "text": "Derealisation ist das Gefühl, die Umgebung sei unwirklich..."
  }
]
```

Beim Laden alle Einträge in ein `[CohereDocument]`-Array mappen:
```swift
struct CohereDocument: Encodable {
    let title: String
    let text: String
}
```

---

## WatchConnectivity Protokoll

Kommunikation zwischen Watch und Phone über `WCSession.sendMessage(_:replyHandler:)`.

### Watch → Phone
```swift
// Aufnahme starten
session.sendMessage(["action": "startRecording"], replyHandler: nil)

// Aufnahme stoppen + Antwort anfordern
session.sendMessage(["action": "stopRecording"], replyHandler: { reply in
    let response = reply["response"] as? String
})
```

### Phone → Watch (replyHandler)
```swift
replyHandler(["response": "Antworttext von Cohere"])
```

### Fehlerfall
```swift
// Bei jedem Fehler (Netzwerk, API, Transkription):
replyHandler(["response": "Atme tief durch. Du bist in Sicherheit."])
// Niemals replyHandler nicht aufrufen – das lässt die Watch hängen
```

---

## Fallback-Hierarchie

```
1. Cohere API (Normalfall)
2. Hardcoded Fallback-String (bei Netzwerkfehler / Timeout / API-Fehler)
3. Niemals: leerer State, nil, oder Crash
```

Fallback-Strings (immer auf Deutsch):
```swift
let fallbacks = [
    "Du bist in Sicherheit. Atme jetzt langsam: 4 Sekunden ein, 6 Sekunden aus.",
    "Diese Empfindung ist unangenehm aber nicht gefährlich. Sie wird vorbeigehen.",
    "Dein Körper schützt dich. Konzentriere dich auf deinen nächsten Atemzug."
]
```

---

## TTS – Sprachausgabe

```swift
let utterance = AVSpeechUtterance(string: responseText)
utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
utterance.rate = 0.42        // Etwas langsamer als Standard – beruhigender
utterance.pitchMultiplier = 0.95
utterance.volume = 1.0
```

TTS läuft auf dem iPhone. Der Ton wird bei gepairter Watch über Bluetooth auf den Watch-Lautsprecher geroutet – das ist Standard-iOS-Verhalten und muss nicht extra implementiert werden.

---

## watchOS UI

Das UI der Watch muss in Paniksituationen funktionieren:

- **Minimal**: Ein großer Tap-Bereich (Circle Button), kein Text-Input
- **Klarer State**: Idle → Aufnehmen (pulsierend) → Verarbeiten (Spinner) → Antwort
- **Lesbar**: Systemschrift, hoher Kontrast, keine kleinen Elemente
- **Scrollbar**: Die Antwort in einem `ScrollView`, da watchOS-Screens klein sind
- **Keine Fehler-Alerts**: Bei Fehlern still den Fallback-String zeigen

States:
```swift
enum EmergencyState {
    case idle           // "Tippe zum Sprechen"
    case recording      // "Ich höre zu…" + pulsierender Kreis
    case processing     // "Verarbeite…" + ProgressView
    case responding     // Antworttext wird angezeigt
}
```

---

## Sicherheit und Privacy

- **Cohere API Key**: Ausschließlich in der iOS Keychain speichern. Nicht in `UserDefaults`, `Info.plist`, oder im Code.
- **Keychain Service**: `"io.iremia.cohere-api-key"`
- **Sprachdaten**: Verlassen das Gerät ausschließlich als transkribierter Text (String) zum Cohere API-Call. Keine Audioaufnahmen werden übertragen.
- **Notruf-Erkennung**: Wenn der transkribierte Text Keywords wie `"sterben"`, `"suizid"`, `"umbringen"`, `"verletzen"` enthält, vor dem API-Call einen prominenten Hinweis auf die Telefonseelsorge anzeigen: **0800 111 0 111** (kostenlos, 24/7).

---

## Berechtigungen (Info.plist)

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Iremia transkribiert deine Sprache, um dir in Panikmomenten zu helfen.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Iremia benötigt das Mikrofon für die Spracherkennung.</string>
```

Watch App benötigt keine zusätzlichen Berechtigungen – Mikrofon und Spracherkennung laufen auf dem iPhone.

---

## Bekannte Einschränkungen

- `SFSpeechRecognizer` benötigt eine aktive Internetverbindung für Sprachen außer Englisch auf Geräten ohne Neural Engine. Auf neueren iPhones (A12+) ist Deutsch auch offline verfügbar.
- `WCSession.sendMessage` mit `replyHandler` hat ein internes Timeout von ca. 60 Sekunden. Der eigene Timeout (8s für Cohere) muss davor greifen.
- Foundation Models Framework (Apple on-device LLM) ist eine geplante spätere Migration wenn iOS 26 released ist. Die Architektur über das `EmergencyResponder`-Protocol ist darauf vorbereitet.

---

## Migrations-Vorbereitung für Foundation Models (iOS 26+)

Das `CohereRAGService` soll das `EmergencyResponder`-Protocol implementieren, damit später ein `LocalEmergencyResponder` (Foundation Models) ohne Architekturänderung eingesteckt werden kann:

```swift
protocol EmergencyResponder {
    func respond(to input: String) async -> String
}

class CohereRAGService: EmergencyResponder { ... }    // Jetzt
class LocalEmergencyResponder: EmergencyResponder { } // iOS 26+
```

Selektion beim App-Start:
```swift
let responder: EmergencyResponder = LocalEmergencyResponder.isAvailable
    ? LocalEmergencyResponder()
    : CohereRAGService()
```

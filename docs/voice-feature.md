# Iremia – Emergency Voice Feature

## Projektkontext

Iremia ist eine Anti-Panikattacken-App für iOS und watchOS (Kotlin Multiplatform mit iOS-Komponente). Dieses Feature fügt eine Emergency Voice Funktion hinzu: Der Nutzer kann auf der Apple Watch sprechen, die Sprache wird transkribiert, und Claude antwortet mit einer kurzen, beruhigenden Antwort basierend auf einem klinischen Wissensdatensatz. Zusätzlich laufen die Mood-Check-Buttons der Watch (vordefinierte Zustände) über denselben Claude-Dienst, der die **gesamte Eingabe-Historie** der Session mitführt.

---

## Feature-Übersicht

```
Apple Watch
  ├─ Mikrofon (Aufnahme) ───────────────┐
  └─ Mood-Check-Buttons (Good/Okay/Bad  │
     + Kategorie + Detail) ─────────────┤
       └─ WatchConnectivity (WCSession) │
            └─ iPhone                   │
                 ├─ SFSpeechRecognizer (Transkription, on-device)
                 ├─ iremia_rag.json (Wissensbasis, im App Bundle → System-Prompt)
                 └─ Claude API (claude-opus-4-8)
                      └─ 1-2 Sätze Antwort → Watch (Text + TTS)
```

---

## Technologie-Entscheidungen

| Komponente | Entscheidung | Begründung |
|---|---|---|
| Spracheingabe | SFSpeechRecognizer (on-device) | Privacy, kein API-Call |
| Transkription läuft auf | iPhone (nicht Watch) | watchOS-Limitierung bei SFSpeechRecognizer |
| LLM | Claude (`claude-opus-4-8`) | Stärkstes Modell; Wissensbasis als gecachter System-Prompt |
| Wissensbasis | `iremia_rag.json` im App Bundle | 40 klinisch geprüfte Einträge, als System-Prompt-Block mit `cache_control` |
| Historie | Vollständige Session-Historie im `ClaudeAssistantService` (Actor) | Claude kann Zusammenhänge zwischen früheren Angaben herstellen |
| TTS | AVSpeechSynthesizer | On-device, kein API-Call |
| API Key | iOS Keychain | Niemals hardcoden oder in UserDefaults speichern |
| Fallback | Hardcoded Strings (Watch + Phone) | Funktioniert ohne Internet und bei API-Fehler |

---

## Dateistruktur

```
iosApp/
├── Features/
│   └── EmergencyVoice/
│       ├── EmergencyVoiceCoordinator.swift   # Hauptkoordinator (Phone)
│       ├── ClaudeAssistantService.swift      # Claude API + Wissensbasis + Historie
│       ├── EmergencyResponder.swift          # Protocol, Fallbacks, Crisis-Keywords
│       ├── SpeechRecognitionService.swift    # SFSpeechRecognizer
│       └── TTSService.swift                  # AVSpeechSynthesizer
├── Watch/
│   └── PhoneConnectivityManager.swift        # WCSession Phone-Seite (Routing)
├── Shared/
│   └── KeychainHelper.swift                  # API Key Keychain-Zugriff
└── Resources/
    └── iremia_rag.json                       # Wissensbasis (40 Einträge)

watchApp/
├── EmergencyVoice/
│   ├── EmergencyVoiceView.swift              # watchOS Voice-UI
│   └── EmergencyWatchViewModel.swift         # WCSession Watch-Seite
├── MoodCheckView.swift                       # Mood-Buttons → Claude-Antwort
├── MoodMicView.swift                         # Voice-Check-in im Mood-Flow
└── WatchConnectivityManager.swift            # requestMoodResponse(...)
```

---

## Claude API

### Endpunkt
```
POST https://api.anthropic.com/v1/messages
```

### Headers
```
x-api-key: {ANTHROPIC_API_KEY}
anthropic-version: 2023-06-01
Content-Type: application/json
```

### Request Body (Schema)
```json
{
  "model": "claude-opus-4-8",
  "max_tokens": 300,
  "output_config": { "effort": "low" },
  "system": [
    { "type": "text", "text": "{Persona + Regeln (Iremia)}" },
    { "type": "text", "text": "{Wissensbasis aus iremia_rag.json}",
      "cache_control": { "type": "ephemeral" } }
  ],
  "messages": [
    { "role": "user", "content": "{frühere Eingabe 1}" },
    { "role": "assistant", "content": "{frühere Antwort 1}" },
    { "role": "user", "content": "{aktuelle Eingabe (Transkript oder Mood-Buttons)}" }
  ]
}
```

### Wichtig
- **Die gesamte Historie der Session** (Voice-Transkripte, Mood-Button-Auswahlen, Antworten) wird bei jedem Request als `messages[]` mitgeschickt, damit Claude Bezüge zu früheren Angaben herstellen kann.
- Die Wissensbasis steht komplett im System-Prompt; `cache_control: ephemeral` reduziert Kosten/Latenz bei Folge-Requests (Prompt Caching).
- `output_config.effort: "low"` + `max_tokens: 300` — kurze Antworten, niedrige Latenz (Panikmoment, watchOS-Display).
- `temperature`/`top_p` werden **nicht** gesendet (von `claude-opus-4-8` nicht mehr akzeptiert → HTTP 400).
- Timeout: 12 Sekunden. Bei Timeout immer Fallback-String zurückgeben, nie einen leeren Zustand anzeigen.
- Mood-Button-Eingaben werden als strukturierte User-Message formatiert, z. B.: `"Mood check-in via the preset buttons on my watch. Mood: Bad. Area: Mind. Specifically: Anxious."`

---

## Wissensbasis

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

Beim Start werden alle Einträge in einen System-Prompt-Block gerendert (`## Titel (Kategorie)\nText`). Der System-Prompt verpflichtet Claude, fachliche Aussagen ausschließlich auf dieses Wissen zu stützen.

---

## WatchConnectivity Protokoll

Kommunikation zwischen Watch und Phone über `WCSession.sendMessage(_:replyHandler:)`.

### Watch → Phone
```swift
// Aufnahme starten
session.sendMessage(["action": "startRecording"], replyHandler: nil)

// Aufnahme stoppen + Antwort anfordern (speak=false unterdrückt iPhone-TTS)
session.sendMessage(["action": "stopRecording", "speak": false], replyHandler: { reply in
    let response = reply["response"] as? String
})

// Aufnahme verwerfen (Cancel im Mood-Mic-Screen)
session.sendMessage(["action": "cancelRecording"], replyHandler: nil)

// Mood-Check über Buttons
session.sendMessage(
    ["action": "moodCheck", "mood": "Bad", "category": "Mind", "detail": "Anxious"],
    replyHandler: { reply in
        let response = reply["response"] as? String  // nil → lokaler Fallback
    }
)
```

### Phone → Watch (replyHandler)
```swift
replyHandler(["response": "Antworttext von Claude"])
// Mood-Check bei API-Fehler: replyHandler(["error": true]) → Watch nutzt lokale Texte
```

### Fehlerfall
```swift
// Voice: Bei jedem Fehler (Netzwerk, API, Transkription):
replyHandler(["response": EmergencyFallback.random()])
// Niemals replyHandler nicht aufrufen – das lässt die Watch hängen
```

---

## Fallback-Hierarchie

```
1. Claude API (Normalfall)
2. Hardcoded Fallback-String (bei Netzwerkfehler / Timeout / API-Fehler)
   – Voice: EmergencyFallback (Phone)
   – Mood-Buttons: MoodResponses (Watch, pro Mood/Kategorie/Detail)
3. Niemals: leerer State, nil, oder Crash
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

TTS läuft auf dem iPhone (nur Emergency-Voice-Flow; Mood-Flows senden `speak: false`). Der Ton wird bei gepairter Watch über Bluetooth auf den Watch-Lautsprecher geroutet – das ist Standard-iOS-Verhalten und muss nicht extra implementiert werden.

---

## watchOS UI

Das UI der Watch muss in Paniksituationen funktionieren:

- **Minimal**: Ein großer Tap-Bereich (Circle Button), kein Text-Input
- **Klarer State**: Idle → Aufnehmen (pulsierend) → Verarbeiten (Spinner) → Antwort
- **Lesbar**: Systemschrift, hoher Kontrast, keine kleinen Elemente
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

- **Anthropic API Key**: Ausschließlich in der iOS Keychain speichern. Nicht in `UserDefaults`, `Info.plist`, oder im Code. Build-seitig aus `.env` (`ANTHROPIC_API_KEY`) via `scripts/generate-secrets.sh` → `Secrets.plist` → Keychain-Seed beim ersten Start.
- **Keychain Service**: `"io.iremia.anthropic-api-key"`
- **Sprachdaten**: Verlassen das Gerät ausschließlich als transkribierter Text (String) zum Claude API-Call. Keine Audioaufnahmen werden übertragen.
- **Notruf-Erkennung**: Wenn der transkribierte Text Keywords wie `"sterben"`, `"suizid"`, `"umbringen"`, `"verletzen"` enthält, wird **vor** dem API-Call der Hinweis auf die Telefonseelsorge zurückgegeben: **0800 111 0 111** (kostenlos, 24/7). Der Austausch wird trotzdem in die Historie aufgenommen.

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
- `WCSession.sendMessage` mit `replyHandler` hat ein internes Timeout von ca. 60 Sekunden. Der eigene Timeout (12s für Claude) muss davor greifen.
- Die Konversations-Historie lebt im Speicher des `ClaudeAssistantService` und wird beim App-Neustart geleert.
- Foundation Models Framework (Apple on-device LLM) ist eine geplante spätere Migration wenn iOS 26 released ist. Die Architektur über das `EmergencyResponder`-Protocol ist darauf vorbereitet.

---

## Migrations-Vorbereitung für Foundation Models (iOS 26+)

Der `ClaudeAssistantService` implementiert das `EmergencyResponder`-Protocol, damit später ein `LocalEmergencyResponder` (Foundation Models) ohne Architekturänderung eingesteckt werden kann:

```swift
protocol EmergencyResponder {
    func respond(to input: String) async -> String
}

actor ClaudeAssistantService: EmergencyResponder { ... }  // Jetzt
class LocalEmergencyResponder: EmergencyResponder { }     // iOS 26+
```

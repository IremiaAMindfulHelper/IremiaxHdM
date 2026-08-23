# Iremia x HdM

**Iremia** is a mental-health app that supports people during acute psychological distress,
in particular panic attacks. It is developed as an interdisciplinary semester project at
Hochschule der Medien (HdM) Stuttgart, supervised by **Prof. Dr. Ansgar Gerlicher**, and is
continued by a new team each semester.

## Apple Watch Companion (Sommersemester 2026)

This semester's contribution is a **native watchOS companion app** plus the iPhone-side
integration that connects both devices. The idea: a smartwatch is worn on the body and is
usable without unlocking a phone — which matters in an acute stress situation. It offers a
mood check-in with AI feedback, a guided breathing exercise, a voice-based emergency
assistant with live transcription, synced emergency contacts, and a Learn section on panic
attacks.

### Team

| Name | Matrikelnummer |
|---|---|
| Lovis Pangratz | 45292 |
| Daniel Gieser | 44687 |
| Anton Smirnov | 5030235 |
| José Viana | 5030229 |
| Fiona Hirschberg | 45794 |

**Supervision:** Prof. Dr. Ansgar Gerlicher (HdM)

**Iremia team (stakeholders):** Lara Bruder, Maik Bucher, Julia Fellmeth

### Project materials

| Material | Where |
|---|---|
| Documentation, presentation slides, demo video, survey results | [Nextcloud (shared folder)](https://cloud.mi.hdm-stuttgart.de/index.php/s/yycFbXgfg8cF2QB) |
| Design (Smartwatch Companion) | [Figma](https://www.figma.com/design/AcWeD0AGec92pJtKEzZ3r1/Iremia-Smartwatch-companion?node-id=1707-403&t=Dbt6x0D5ovlOjE7M-1) |
| API key for evaluating the AI features | Sent by e-mail (see setup step 2) |

Technical details on architecture and implementation are **not** in this README — they are
covered in the project documentation linked above.

---

## Setup and installation

### Requirements

* **macOS with Xcode** (iOS 17+ / watchOS 10+ SDK). No Apple Developer account needed —
  a signing team is committed, so the project builds out of the box.
* **JDK 21** — required for the Kotlin Multiplatform build. Install e.g. with
  `brew install openjdk@21`.
* No CocoaPods, no Docker, no additional dependencies.

### 1. Clone and switch to the project branch

> **Important:** this semester's work lives on the branch **`watch/basics`**, not on `main`.
> The `main` branch does not contain the watch app.

```bash
git clone -b watch/basics https://github.com/IremiaAMindfulHelper/IremiaxHdM.git
cd IremiaxHdM
```

If you already cloned the repository (or ended up on `main`), switch over and get the latest
state:

```bash
git fetch origin
git checkout watch/basics
git pull origin watch/basics
```

Verify you are on the right branch — the command must print `watch/basics`, and the folder
`iosApp/watchApp/` must exist:

```bash
git branch --show-current
```

### 2. Add the API key (recommended)

The app's AI features use the Anthropic Claude API. **No key is included in this repository.**
The key for evaluation is provided by e-mail; create a `.env` file in the repository root:

```bash
echo 'ANTHROPIC_API_KEY=<key from e-mail>' > .env
```

The build picks it up automatically. **Without a key the project still builds and runs** —
but all AI responses fall back to fixed, pre-written texts, so the voice assistant and the
mood feedback cannot be evaluated properly. See "Running without an API key" below.

### 3. Open the project

Open **`iosApp/iosApp.xcworkspace`** in Xcode — important: not the `.xcodeproj` file.

The shared Kotlin framework is built automatically by an Xcode build phase. The **first build
takes several minutes** (Gradle compiles the Kotlin framework) and may look stalled — this is
expected.

### 4. Run the iPhone app

Select the **`iosApp`** scheme and any iOS simulator (e.g. iPhone 16), then `Cmd + R`.

### 5. Run the watch app

Select the **`IremiaWatch`** scheme and — importantly — an iPhone simulator **with a paired
watch simulator** (e.g. "iPhone 16 + Apple Watch Series 10"). The watch talks to the phone via
`WatchConnectivity`, which does not work without a pairing.

For features that involve the iPhone (voice assistant, mood feedback, contacts), **run the
iPhone app first** and leave it running, then start the watch app.

> **Voice input needs a real Apple Watch.** Microphone capture in the watchOS simulator is
> unreliable — recordings may stay silent or produce no transcript, even with everything else
> set up correctly. Everything else in the app can be evaluated in the simulator, but for the
> emergency voice assistant please use a physical Apple Watch paired with an iPhone, or refer
> to the demo video linked above.

### Running without an API key

Fully usable: breathing exercise, Learn section, journey/history, settings, navigation, and
the emergency contacts UI.

Degraded to fixed fallback texts: mood check-in feedback, daily home-screen message, and the
emergency voice assistant's replies. The app deliberately never breaks when the AI is
unavailable — offline usability is a design goal — but the AI behaviour itself is only
visible with a key.

### Troubleshooting

| Symptom | Fix |
|---|---|
| Build phase "Compile Kotlin Framework" fails | Wrong or missing JDK — JDK 21 is expected |
| Watch app shows only fallback texts | No `.env` / no API key, or the iPhone app is not running |
| Watch cannot reach the phone | Simulator pair without a paired watch, or iPhone app not started |
| Voice input records nothing / no transcript | Expected in the watchOS simulator — use a real Apple Watch |
| Signing errors | Optional: create `iosApp/Configuration/Local.xcconfig` with your own `DEV_TEAM_ID` (template provided next to it) |

The encrypted files under `secrets/` are **not** needed to build or run the project.

### Repository structure

* **`/iosApp/watchApp`** — the watchOS app (Swift/SwiftUI), this semester's main contribution
* **`/iosApp/iosApp`** — the iOS app, including the watch integration
* **`/shared`** — Kotlin Multiplatform core shared by iOS and Android
* **`/composeApp`** — Compose Multiplatform UI (Android)

---

## Iremia Lambda (Wintersemester 2025/26)

*Der folgende Abschnitt dokumentiert das Vorgängerteam und ist bewusst im Original auf
Deutsch belassen.*

**Iremia Lambda** war ein interdisziplinäres Semesterprojekt an der Hochschule der Medien im
**Wintersemester 2025/26**. Im Rahmen der Lehrveranstaltung bei Prof. Dr. Ansgar Gerlicher
wurde die bestehende Gesundheits-App „Iremia" gezielt weiterentwickelt. Der Fokus lag auf der
konzeptionellen und technischen Optimierung der Notfallfunktion für Menschen in akuten
psychischen Belastungssituationen.

### Projektmitglieder

* **Michael Jaufmann** (45045)
* **Manuel Veit** (45260)
* **Anna-Maria Schwoch** (43707)
* **Jan Hübner** (45204)

**Betreuung:** Prof. Dr. Ansgar Gerlicher

### Setup und Installation (Stand Wintersemester 2025/26)

*Unveränderter technischer Stand des Vorgängersemesters. Für den aktuellen Setup-Ablauf
siehe [Setup and installation](#setup-and-installation) weiter oben.*

Da es sich um ein **Kotlin Multiplatform (KMP)** Projekt handelt, ist die Einrichtung für die iOS-Umgebung in zwei Schritte unterteilt: das Bauen der geteilten Logik (Kotlin) und das Installieren der Abhängigkeiten (Swift/CocoaPods).

#### 1. Repository klonen
Öffnen Sie Ihr Terminal, klonen Sie den spezifischen Branch und navigieren Sie in das Verzeichnis.
```bash
git clone -b lambda-branch https://github.com/IremiaAMindfulHelper/IremiaxHdM.git
```

#### 2. Gemeinsamen Code (Shared Logic) bauen
Das KMP-Framework muss generiert werden, damit Xcode darauf zugreifen kann.
```bash
./gradlew :shared:assembleRelease
```

#### 3. iOS Abhängigkeiten installieren (CocoaPods)
Navigieren Sie in den iOS-Ordner (`iosApp`) und installieren Sie die Pods.

```bash
cd iosApp
pod install
```

#### 4. Projekt öffnen und Ausführen
* Öffnen Sie die Datei **`iosApp.xcworkspace`** in Xcode (wichtig: nicht die `.xcodeproj` Datei öffnen!).
* Wählen Sie einen iOS-Simulator (z. B. iPhone 16) aus.
* Starten Sie die App mit `Cmd + R` oder über den "Run"-Button.

### Projektstruktur (Stand Wintersemester 2025/26)

Das Projekt nutzt **Kotlin Multiplatform (KMP)**, um Code zwischen Android und iOS zu teilen.

* **`/shared`**: Enthält die Kernlogik (Business Logic), die auf beiden Plattformen genutzt wird.
    * `commonMain`: Plattformunabhängiger Code (Repositories, Models, Engines).
* **`/iosApp`**: Die native iOS-App. Beinhaltet den Entry Point und SwiftUI-Code, der auf den Shared-Code zugreift.
* **`/composeApp`**: Enthält den Shared-UI-Code (Compose Multiplatform) für Android und potenziell weitere Plattformen.

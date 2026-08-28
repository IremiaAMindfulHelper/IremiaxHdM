# Iremia Insights

**Iremia Insights** ist ein Semesterprojekt an der Hochschule der Medien. Auf Basis der bestehenden Gesundheits-App „Iremia" wurde der Journal-Bereich weiterentwickelt: Einträge lassen sich geführt oder frei erfassen, daraus abgeleitete Insights erscheinen auf dem Startbildschirm, und ein Garten macht den eigenen Verlauf sichtbar, ohne zu bewerten.

Nutzertexte bleiben dabei bewusst emotional neutral und autonomie-wahrend: keine Schuldgefühle, kein Streak-Druck. Diese Zusage ist nicht nur gestalterisch umgesetzt, sondern als Invariante im Insights-Algorithmus verankert und durch Unit-Tests abgesichert.

## Projektmitglieder

| Name | Matrikelnummer | Studiengang |
| --- | --- | --- |
| Kerem Sarica | 45756 | Mobile Medien |
| Semih Akcay | 45852 | Mobile Medien |
| Yusuf Altun | 46082 | Mobile Medien |

**Betreuung:** Prof. Dr. Ansgar Gerlicher

## Projektmaterialien

| Material | Link |
| --- | --- |
| Projektdokumentation (PDF) | *hier Link einsetzen* |
| Demo-Video | *hier Link einsetzen* |
| Finale Präsentation (PDF) | *hier Link einsetzen* |
| Umfrage-Auswertung (PDF) | *hier Nextcloud-Link einsetzen* |
| Figma, Design und Prototyp | *hier Link einsetzen* |
| FigJam, Affinity Map und Nutzer-Cluster | *hier Link einsetzen* |
| Confluence, Projekt-Space | *hier Link einsetzen* |
| Technische Dokumentation | [docs/](docs/) |

Rohdaten aus Umfrage und Nutzertests liegen aus Datenschutzgründen nicht in diesem öffentlichen Repository, sondern in der HdM-Nextcloud.

## Was in diesem Semester entstanden ist

Journal mit zweistufiger Erfassung und zwei Eintragstypen, Monatsgarten mit Baum für belastende Ereignisse und Beet für Journaleinträge, ein lokal rechnender Insights-Algorithmus über ein rollierendes 30-Tage-Fenster, das Design-System als Token-Schicht auf beiden Plattformen und die iOS-Parität in SwiftUI.

Umfang: rund 15.000 Zeilen über 176 Dateien, 15 Unit-Tests, 174 neue lokalisierte Textbausteine.

## Setup und Installation

Da es sich um ein **Kotlin Multiplatform (KMP)** Projekt handelt, ist die Einrichtung für die iOS-Umgebung in zwei Schritte unterteilt: das Bauen der geteilten Logik (Kotlin) und das Installieren der Abhängigkeiten (Swift/CocoaPods).

### 1. Repository klonen

Der Abgabestand liegt auf dem Branch `insights-integration/base`.

```bash
git clone https://github.com/IremiaAMindfulHelper/IremiaxHdM.git
cd IremiaxHdM
git checkout insights-integration/base
```

### 2. Gemeinsamen Code (Shared Logic) bauen

Das KMP-Framework muss generiert werden, damit Xcode darauf zugreifen kann.

```bash
./gradlew :shared:podPublishDebugXCFramework
```

### 3. iOS Abhängigkeiten installieren (CocoaPods)

Navigieren Sie in den iOS-Ordner (`iosApp`) und installieren Sie die Pods.

```bash
cd iosApp
pod install
```

### 4. Projekt öffnen und Ausführen

* Öffnen Sie die Datei `iosApp.xcworkspace` in Xcode (wichtig: nicht die `.xcodeproj` Datei öffnen!).
* Wählen Sie einen iOS-Simulator aus.
* Starten Sie die App mit `Cmd + R` oder über den "Run"-Button.

### Android

```bash
./gradlew :composeApp:assembleDebug
```

Die fertige APK liegt unter `composeApp/build/outputs/apk/debug/`.

### Bekannte Limitationen beim Setup

Ein Build auf einem physischen iPhone braucht ein eigenes Apple-Developer-Team in den Signing-Einstellungen des Targets. Im Simulator ist das nicht nötig. Ein vollautomatisches One-Click-Setup ist damit nicht möglich.

Die Dateien unter `secrets/` sind mit git-crypt verschlüsselt, weil das Repository öffentlich ist. Ohne Schlüssel sind sie nicht lesbar, für einen Debug-Build werden sie aber nicht gebraucht.

Das erste Gradle-Sync dauert mehrere Minuten, weil dabei das XCFramework erzeugt wird.

Docker beziehungsweise `docker-compose` gibt es nicht, das ist bei einer mobilen KMP-App nicht sinnvoll.

## Projektstruktur

Das Projekt nutzt **Kotlin Multiplatform (KMP)**, um Code zwischen Android und iOS zu teilen.

* **`/shared`**: Enthält die Kernlogik (Business Logic), die auf beiden Plattformen genutzt wird.
  * `commonMain`: Plattformunabhängiger Code (Repositories, Models, Engines).
  * Hier liegen auch alle Texte (moko-resources), damit sie nur an einer Stelle gepflegt werden.
* **`/iosApp`**: Die native iOS-App. Beinhaltet den Entry Point und SwiftUI-Code, der auf den Shared-Code zugreift.
* **`/composeApp`**: Die native Android-App mit Jetpack Compose.
* **`/docs`**: Technische Dokumentation für die Weiterentwicklung.

`composeApp/` und `iosApp/` kennen `shared/`, aber `shared/` kennt keines der beiden. Diese Abhängigkeitsrichtung ist die zentrale Regel des Projekts.

## Hinweise zur Entwicklung

* Nach Änderungen an Texten: `./gradlew :shared:generateMR` (nicht nur `generateMRcommonMain`, sonst bleiben die Android-Ressourcen alt).
* Nach Änderungen an `.sq`-Dateien: `./gradlew :shared:generateSqlDelightInterface`.
* Nach Kotlin-Änderungen für iOS: XCFramework neu bauen (siehe Schritt 2).
* Tests ausführen: `./gradlew :shared:allTests`.

## Technische Dokumentation

Unter [`docs/`](docs/) liegen acht Dokumente für alle, die das Projekt fortführen:

| Dokument | Inhalt |
| --- | --- |
| [01-architektur.md](docs/01-architektur.md) | Schichten, Datenfluss, Modulgrenzen |
| [02-shared-modul.md](docs/02-shared-modul.md) | DAO, Repository, Controller, SQLDelight |
| [03-android.md](docs/03-android.md) | Compose-Aufbau, ViewModels, Theme |
| [04-ios.md](docs/04-ios.md) | SwiftUI, Observables, Flow-Interop |
| [05-feature-hinzufuegen.md](docs/05-feature-hinzufuegen.md) | Anleitung von der Tabelle bis zur Oberfläche |
| [06-lokalisierung.md](docs/06-lokalisierung.md) | moko-resources, Basissprache |
| [07-build-und-auslieferung.md](docs/07-build-und-auslieferung.md) | CI, TestFlight, Play Store |
| [08-codequalitaet.md](docs/08-codequalitaet.md) | bekannte technische Schulden, Übergabe |

## Lizenz

Siehe [LICENSE](LICENSE).

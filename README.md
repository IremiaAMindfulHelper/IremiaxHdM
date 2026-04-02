# Iremia Lambda 

**Iremia Lambda** ist ein interdisziplinäres Semesterprojekt an der Hochschule der Medien (Wintersemester 2025/26). Im Rahmen der Lehrveranstaltung bei Prof. Dr. Ansgar Gerlicher wurde die bestehende Gesundheits-App „Iremia“ gezielt weiterentwickelt. Der Fokus lag auf der konzeptionellen und technischen Optimierung der Notfallfunktion für Menschen in akuten psychischen Belastungssituationen.

##  Projektmitglieder
* **Michael Jaufmann** (45045)
* **Manuel Veit** (45260)
* **Anna-Maria Schwoch** (43707)
* **Jan Hübner** (45204)

**Betreuung:** Prof. Dr. Ansgar Gerlicher


##  Setup und Installation

Da es sich um ein **Kotlin Multiplatform (KMP)** Projekt handelt, ist die Einrichtung für die iOS-Umgebung in zwei Schritte unterteilt: das Bauen der geteilten Logik (Kotlin) und das Installieren der Abhängigkeiten (Swift/CocoaPods).

### 1. Repository klonen
Öffnen Sie Ihr Terminal, klonen Sie den spezifischen Branch und navigieren Sie in das Verzeichnis.
```bash
git clone -b lambda-branch https://github.com/IremiaAMindfulHelper/IremiaxHdM.git
```

### 2. Gemeinsamen Code (Shared Logic) bauen
Das KMP-Framework muss generiert werden, damit Xcode darauf zugreifen kann.
```bash
./gradlew :shared:assembleRelease
```

### 3. iOS Abhängigkeiten installieren (CocoaPods)
Navigieren Sie in den iOS-Ordner (`iosApp`) und installieren Sie die Pods.

```bash
cd iosApp
pod install
```

### 4. Projekt öffnen und Ausführen
* Öffnen Sie die Datei **`iosApp.xcworkspace`** in Xcode (wichtig: nicht die `.xcodeproj` Datei öffnen!).
* Wählen Sie einen iOS-Simulator (z. B. iPhone 16) aus.
* Starten Sie die App mit `Cmd + R` oder über den "Run"-Button.


##  Projektstruktur

Das Projekt nutzt **Kotlin Multiplatform (KMP)**, um Code zwischen Android und iOS zu teilen.

* **`/shared`**: Enthält die Kernlogik (Business Logic), die auf beiden Plattformen genutzt wird.
    * `commonMain`: Plattformunabhängiger Code (Repositories, Models, Engines).
* **`/iosApp`**: Die native iOS-App. Beinhaltet den Entry Point und SwiftUI-Code, der auf den Shared-Code zugreift.
* **`/composeApp`**: Enthält den Shared-UI-Code (Compose Multiplatform) für Android und potenziell weitere Plattformen.

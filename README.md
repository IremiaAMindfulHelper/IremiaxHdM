# Iremia Insights

**Iremia Insights** ist ein Semesterprojekt an der Hochschule der Medien. Auf Basis der bestehenden Gesundheits-App „Iremia“ wurde der Journal-Bereich weiterentwickelt: Einträge lassen sich geführt oder frei erfassen, daraus abgeleitete Insights erscheinen auf dem Startbildschirm, und ein Garten macht den eigenen Verlauf sichtbar, ohne zu bewerten.

Nutzertexte bleiben dabei bewusst emotional neutral und autonomie-wahrend: keine Schuldgefühle, kein Streak-Druck.

##  Projektmitglieder
* **Kerem Sarica**
* **Semih Akcay**
* **Yusuf Altun** 

**Betreuung:** Prof. Dr. Ansgar Gerlicher


##  Setup und Installation

Da es sich um ein **Kotlin Multiplatform (KMP)** Projekt handelt, ist die Einrichtung für die iOS-Umgebung in zwei Schritte unterteilt: das Bauen der geteilten Logik (Kotlin) und das Installieren der Abhängigkeiten (Swift/CocoaPods).

### 1. Repository klonen
```bash
git clone https://github.com/IremiaAMindfulHelper/IremiaxHdM.git
cd IremiaxHdM
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
* Öffnen Sie die Datei **`iosApp.xcworkspace`** in Xcode (wichtig: nicht die `.xcodeproj` Datei öffnen!).
* Wählen Sie einen iOS-Simulator aus.
* Starten Sie die App mit `Cmd + R` oder über den "Run"-Button.

### Android

```bash
./gradlew :composeApp:assembleDebug
```

Die fertige APK liegt unter `composeApp/build/outputs/apk/debug/`.


##  Projektstruktur

Das Projekt nutzt **Kotlin Multiplatform (KMP)**, um Code zwischen Android und iOS zu teilen.

* **`/shared`**: Enthält die Kernlogik (Business Logic), die auf beiden Plattformen genutzt wird.
    * `commonMain`: Plattformunabhängiger Code (Repositories, Models, Engines).
    * Hier liegen auch alle Texte (moko-resources), damit sie nur an einer Stelle gepflegt werden.
* **`/iosApp`**: Die native iOS-App. Beinhaltet den Entry Point und SwiftUI-Code, der auf den Shared-Code zugreift.
* **`/composeApp`**: Die native Android-App mit Jetpack Compose.


##  Hinweise zur Entwicklung

* Nach Änderungen an Texten: `./gradlew :shared:generateMR` (nicht nur `generateMRcommonMain`, sonst bleiben die Android-Ressourcen alt).
* Nach Änderungen an `.sq`-Dateien: `./gradlew :shared:generateSqlDelightInterface`.
* Nach Kotlin-Änderungen für iOS: XCFramework neu bauen (siehe Schritt 2).

# 07 — Build und Auslieferung

## Werkzeuge

- **IntelliJ IDEA 2025.2.x** — nicht 2025.3 oder neuer (bekannte Probleme)
- **Xcode** (aktuell), geöffnet wird `iosApp.xcworkspace`
- JDK 11-kompatibles Setup (Gradle-Ziel ist JVM 11)

## Häufige Befehle

```bash
# Android + shared bauen
./gradlew assemble

# nur Android-Debug
./gradlew :composeApp:assembleDebug

# nach Änderungen an .sq-Dateien
./gradlew :shared:generateSqlDelightInterface

# nach Änderungen an Texten/Ressourcen (ALLE Ziele)
./gradlew :shared:generateMR

# iOS-Framework
./gradlew :shared:podPublishDebugXCFramework      # Debug
./gradlew :shared:podPublishReleaseXCFramework    # Release
```

Ausgabe des Frameworks: `shared/build/cocoapods/publish/<debug|release>/Shared.xcframework`

## Tests

```bash
./gradlew :shared:allTests
./gradlew :composeApp:testDebugUnitTest
```

Getestet ist die Logik, die ohne UI läuft: `MotivationAlgorithmTest`,
`GardenRandomizerTest`.

## iOS lokal bauen und starten

```bash
cd iosApp
xcodebuild -workspace iosApp.xcworkspace -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build

# im laufenden Simulator installieren
xcrun simctl install booted <Pfad>/IreamiaApp.app
xcrun simctl launch booted org.iremia.app.kerem
```

Die App heißt im Bundle `IreamiaApp.app` (so geschrieben), die Bundle-ID ist
`org.iremia.app.kerem`.

---

# Abgabe

## Android: APK

```bash
./gradlew :composeApp:assembleDebug
# → composeApp/build/outputs/apk/debug/composeApp-debug.apk
```

Diese Debug-APK lässt sich direkt weitergeben und installieren (auf dem Gerät müssen
„unbekannte Quellen“ erlaubt sein). Für eine reine Projektabgabe genügt das.

**Für eine Release-APK fehlt derzeit die Signierung.** In `composeApp/build.gradle.kts`
gibt es einen `release`-Block ohne `signingConfig`, und im Projekt liegt kein
Keystore. `./gradlew :composeApp:assembleRelease` erzeugt daher ein **unsigniertes**
Paket, das sich nicht installieren lässt.

Falls eine signierte Release-Version gebraucht wird:

```bash
keytool -genkey -v -keystore iremia.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias iremia
```

Danach in `composeApp/build.gradle.kts` eine `signingConfigs`-Sektion ergänzen und im
`release`-Block referenzieren. Den Keystore und die Passwörter **nicht** einchecken
(z. B. über `local.properties` oder Umgebungsvariablen einlesen).

Für den Play Store wäre statt der APK ein **AAB** nötig:
`./gradlew :composeApp:bundleRelease`.

## iOS: Es gibt kein „APK“

Das ist der wichtigste Unterschied. Eine iOS-App lässt sich nicht als Datei
weiterreichen, die andere einfach anklicken. Apple verlangt, dass jede installierbare
App signiert ist und die Zielgeräte erfasst sind. Vier realistische Wege:

### 1. Xcode-Projekt abgeben (für eine Hochschulabgabe meist das Richtige)

Das Repository mit Anleitung übergeben; die prüfende Person baut selbst:

```bash
./gradlew :shared:podPublishDebugXCFramework
cd iosApp && pod install     # falls Pods nicht eingecheckt sind
open iosApp.xcworkspace      # in Xcode auf Simulator starten
```

Kein Entwickler-Konto nötig, solange nur im Simulator gestartet wird. Zusätzlich
lässt sich eine Bildschirmaufnahme beilegen, damit die App auch ohne Bauen sichtbar ist.

### 2. Simulator-Build als `.app`

```bash
xcodebuild -workspace iosApp.xcworkspace -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build
```

Der entstehende `IreamiaApp.app`-Ordner läuft per `xcrun simctl install` auf jedem
Mac mit Simulator — **nicht** auf echten iPhones.

### 3. TestFlight (bis zu 100 Tester)

Braucht ein **Apple Developer Program**-Konto (99 USD/Jahr). Ablauf: In Xcode
*Product → Archive*, dann *Distribute App → App Store Connect → Upload*. Tester
bekommen einen Link und installieren über die TestFlight-App. Das ist der übliche Weg,
um eine iOS-App vor der Veröffentlichung an andere zu geben.

### 4. Ad-hoc-IPA

Ebenfalls Developer-Konto. Beim Archivieren *Ad Hoc* wählen; die IPA läuft nur auf
Geräten, deren UDID vorher im Profil registriert wurde. Nur sinnvoll bei einem festen,
kleinen Gerätekreis.

### Aktueller Signierungs-Stand

```
CODE_SIGN_STYLE = Automatic
PRODUCT_BUNDLE_IDENTIFIER = org.iremia.app.kerem
```

Automatische Signierung ist eingestellt. Für Weg 3 oder 4 muss in Xcode unter
*Signing & Capabilities* ein Team mit gültiger Mitgliedschaft ausgewählt sein.

### Empfehlung

Für eine Projektabgabe: **Android-APK + iOS-Quellcode mit Bauanleitung**, ergänzt um
eine kurze Bildschirmaufnahme der iOS-App. Das kostet nichts und zeigt alles. Ein
Developer-Konto lohnt erst, wenn die App wirklich an fremde iPhones verteilt werden soll.

## Vor der Abgabe prüfen

- [ ] `./gradlew :composeApp:assembleDebug` läuft durch
- [ ] iOS baut in Xcode ohne Fehler
- [ ] Texte auf beiden Plattformen deutsch ([06](06-lokalisierung.md))
- [ ] `./gradlew :shared:allTests` grün
- [ ] `local.properties`, Keystores, Passwörter **nicht** eingecheckt
- [ ] README und `docs/` auf aktuellem Stand

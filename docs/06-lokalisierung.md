# 06 — Texte und Lokalisierung

Alle Nutzertexte liegen **einmal** im Shared-Modul und werden von beiden Plattformen
gelesen. Ein Text wird nie in Swift oder Kotlin fest eingetippt.

## Wo die Texte liegen

```
shared/src/commonMain/moko-resources/
├── base/strings.xml    Deutsch — auch die Rückfallebene
└── de/strings.xml      Deutsch
```

Generierte Klasse: `SharedRes` (Paket `org.iremia.library`).

## Warum Deutsch in `base/` steht

`base/` ist das, was ein Gerät bekommt, dessen Sprache **nicht** ausdrücklich
unterstützt wird. Stand früher Englisch darin, zeigte ein englisch eingestelltes
Android-Telefon Englisch, während ein deutsches iPhone Deutsch zeigte — dieselbe App,
zwei Sprachen.

Da die App durchgehend deutsch sein soll, steht Deutsch in `base/`. Eine `en/`-Datei
gibt es bewusst nicht: Sonst würde ein englisch eingestelltes Gerät wieder Englisch
wählen.

Passend dazu in `shared/build.gradle.kts`:

```kotlin
iosBaseLocalizationRegion.set("de")
```

Dieser Wert **muss** zur Sprache in `base/` passen, sonst beschriftet iOS die
Rückfallebene falsch.

## Verwendung

**Android**

```kotlin
localized(SharedRes.strings.journal_title).toString(context)
```

**iOS**

```swift
Text(Strings.journal_title)
```

`Strings` ist der Proxy aus `Utils/StringProxy.swift`, der auf `SharedRes` zugreift.

## Nach jeder Textänderung

```bash
./gradlew :shared:generateMR
```

**Nicht** `:shared:generateMRcommonMain` allein verwenden. Der Task erzeugt nur die
Kotlin-Klasse, nicht die Android-XML-Ressourcen. Wer nur ihn laufen lässt, sieht auf
Android weiterhin die alten Texte und sucht den Fehler an der falschen Stelle.

Für iOS zusätzlich das XCFramework neu bauen.

## Neue Sprache aufnehmen

1. Ordner anlegen, z. B. `moko-resources/en/strings.xml`.
2. **Alle** Schlüssel aus `base/` übernehmen und übersetzen.
3. `./gradlew :shared:generateMR`.

Ab dann folgt die App wieder der Gerätesprache: Passt sie zu einem Ordner, gewinnt
dieser; sonst greift `base/`.

Prüfen, ob beide Dateien dieselben Schlüssel haben:

```bash
cd shared/src/commonMain/moko-resources
diff <(grep -o 'name="[^"]*"' base/strings.xml | sort) \
     <(grep -o 'name="[^"]*"' de/strings.xml  | sort)
```

Keine Ausgabe heißt: deckungsgleich.

## Prüfen, was wirklich in der App landet

Der zuverlässigste Test ist die gebaute APK, nicht der Quelltext:

```bash
AAPT=$(find ~/Library/Android/sdk/build-tools -name aapt2 | sort -V | tail -1)
"$AAPT" dump resources composeApp/build/outputs/apk/debug/composeApp-debug.apk \
  | grep -A3 "string/welcome_title"
```

Erwartet wird für jeden Schlüssel eine Zeile `()` (Rückfallebene) mit deutschem Text.
Taucht dort `(en)` mit englischem Text auf, existiert wieder eine englische Variante.

## Inhaltsregel

Texte bleiben emotional neutral und autonomie-wahrend: keine Schuldgefühle, kein
Streak-Druck, keine Bewertung. Formulierungen wie „Leere Tage sind völlig okay, dein
Garten wächst in deinem Tempo“ sind der Maßstab.

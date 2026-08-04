# 01 — Architektur

## Grundidee

Ein Feature wird **einmal** gedacht und **zweimal** gezeichnet. Alles, was kein
Pixel ist (Datenbank, Regeln, Zustand, Texte), liegt in `shared/`. Nur die
Darstellung ist pro Plattform eigen.

Das hat einen konkreten Grund: Wenn die Garten-Logik entscheidet, ob eine Pflanze
wächst, darf diese Entscheidung nicht zweimal existieren. Sonst driften Android und
iOS auseinander, und genau solche Unterschiede fallen erst beim Nutzer auf.

## Die drei Module

```
IremiaxHdM/
├── shared/       Kotlin Multiplatform — Daten, Logik, Zustand, Texte
├── composeApp/   Android — Jetpack Compose
└── iosApp/       iOS — SwiftUI, bindet shared als Shared.xcframework ein
```

`composeApp/` und `iosApp/` kennen `shared/`. `shared/` kennt keine der beiden.
Diese Richtung ist die wichtigste Regel im Projekt.

## Schichten im Shared-Modul

Daten fließen von unten nach oben:

```
SQLDelight (.sq)      Tabellen und Queries
      ↓
Domain                reine Datenklassen, keine DB, keine UI
      ↓
DAO                   kapselt Queries, mappt Zeilen auf Domain-Modelle
      ↓
Repository            Fachlogik, Schreibzugriffe über withContext(io)
      ↓
Controller            StateFlow<XxxState> für beide Plattformen
      ↓
UI (Android / iOS)    stellt nur dar
```

Jede Schicht kennt nur die direkt darunter. Ein Screen greift nie direkt auf ein
DAO zu, ein DAO nie auf einen Controller.

### Warum diese Trennung

- **Domain ohne Abhängigkeiten** heißt: Regeln sind testbar, ohne Datenbank oder
  Emulator. Siehe `MotivationAlgorithmTest` und `GardenRandomizerTest`.
- **Repository als Fassade** heißt: Die UI weiß nicht, ob ein Wert aus der DB, dem
  Cache oder einer Berechnung kommt.
- **Controller als einzige UI-Schnittstelle** heißt: Beide Plattformen sehen
  denselben Zustand zur selben Zeit.

## Der Controller als Brücke

Der Controller ist die Stelle, an der zwei Welten aufeinandertreffen. Kotlin kann
`suspend`-Funktionen, Swift nicht. Deshalb hat jeder Controller beides:

```kotlin
// Für Android: idiomatisch mit Coroutines
suspend fun add(content: String, createdAt: Long): PlantResult

// Für iOS: Callback, weil Swift kein suspend versteht
fun addAsync(content: String, createdAt: Long, onDone: (PlantResult?, Throwable?) -> Unit)
```

Feste Regeln für jeden Controller:

1. Zustand ist **eine** unveränderliche Datenklasse plus `StateFlow`.
2. `@ObjCName(..., exact = true)` an Zustand und Controller, damit die Namen in
   Swift stabil bleiben.
3. Immer ein `clear()`, das den Scope abbricht. Android ruft es in `onCleared()`,
   iOS in `deinit`. Ohne das laufen Coroutines weiter, wenn der Screen weg ist.

Vorhandene Controller: `NotesController`, `GardenController`, `MantrasController`,
`MotivationController`, `JournalCalendarController`.

## Wie iOS an den Zustand kommt

Swift kann `StateFlow` nicht direkt beobachten. Dafür gibt es `interop/FlowInterop.kt`
mit `observeState(...)`, das ein `Cancelable` zurückgibt. Auf iOS-Seite hält eine
`ObservableObject`-Klasse dieses Handle und gibt es im `deinit` wieder frei.

Ein vergessenes `cancel()` ist hier der klassische Fehler: Der Screen ist zu, der
Kotlin-Job läuft weiter und schreibt in ein `@Published`, das niemand mehr liest.

## Zusammengesetzt wird in der SharedFactory

`bridge/SharedFactory.kt` baut pro Feature die ganze Kette:

```
DriverFactory → UserData (DB) → DAO → Repository → Controller
```

Die UI ruft nur `SharedFactory.createNotesController(driverFactory)` und bekommt
etwas Fertiges. Sie muss nicht wissen, wie viele Schichten darunter liegen.

**Bekannte Einschränkung:** Jeder `create…`-Aufruf legt aktuell seinen eigenen
Datenbank-Treiber an. Für die Größe der App ist das unkritisch, aber es ist der
Punkt, an dem man ansetzt, wenn es später mehr Features werden. Siehe
[08 Codequalität](08-codequalitaet.md).

## Feature-Überblick

| Feature | Shared | Persistenz |
| ------- | ------ | ---------- |
| Journal-Einträge | `domain/note`, `data/note`, `NotesController` | `Note.sq` |
| Garten | `domain/garden`, `data/garden`, `GardenController` | `GardenPlant.sq` |
| Mantras | `domain/mantra`, `data/mantra`, `MantrasController` | `mantra.sq` |
| Motivations-Insights | `domain/insights`, `MotivationController` | abgeleitet aus Einträgen |
| Übungen (Atem, Memory, Rechnen, SOS) | `domain/engines`, `domain/models` | zustandslos |

Die Übungs-Engines sind bewusst reine Logik ohne Speicher: Sie berechnen Schritte
und Zustände, halten aber nichts fest.

## Weiterlesen

- [02 Shared-Modul](02-shared-modul.md) — die Schichten im Detail
- [05 Feature hinzufügen](05-feature-hinzufuegen.md) — die Kette einmal durchgespielt

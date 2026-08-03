# 03 — Android-Client

Modul `composeApp/`, Jetpack Compose. Der Einstieg ist `MainActivity` → `MainScreen`.

## Aufbau

```
composeApp/src/androidMain/kotlin/org/iremia/iremia/
├── MainActivity.kt
├── ui/
│   ├── MainScreen.kt          Shell: Tabs, "+"-Button, Capture-Flow
│   ├── home/                  Startbildschirm
│   ├── journal/               Journal, Kalender, Einträge
│   │   └── episode/           Erfassungs-Flow (mehrstufig)
│   ├── garden/                Garten-Ansicht und Pflanz-Animation
│   ├── navigation/            Tab-Leiste
│   ├── components/            wiederverwendete Bausteine
│   └── theme/                 Farben, Typografie, Abstände, Formen
├── routes/
└── viewModels/
```

## MainScreen als Shell

`MainScreen` hält das zusammen, was über allen Tabs liegt:

- die Tab-Leiste
- den schwebenden **"+"**-Button (in jedem Tab erreichbar)
- den Erfassungs-Flow als Dialog
- die geteilten ViewModels für Notizen und Garten

Dass Notizen- und Garten-ViewModel **hier** leben und nicht im jeweiligen Tab, ist
Absicht: Startbildschirm und Journal zeigen denselben Garten. Zwei Instanzen würden
zwei Wahrheiten bedeuten.

## Drei Rollen pro Screen

| Rolle | Aufgabe |
| ----- | ------- |
| **ViewModel** | hält den Controller, leitet Aufrufe über `viewModelScope` weiter, ruft `controller.clear()` in `onCleared()` |
| **Route** | baut den Controller über die `SharedFactory`, sammelt den Zustand ein |
| **Screen** | zustandslos, bekommt Daten und Callbacks, stellt nur dar |

Der Screen ist bewusst dumm. Er lässt sich in einer Preview darstellen, ohne dass
eine Datenbank existiert.

> **Hinweis:** Dieses Dreigespann ist im Mantra-Feature sauber ausgeprägt
> (`MantraRoute`, `MantraViewModel`). Die Prototyp-Screens (Journal, Garten, Home)
> sind teils direkter verdrahtet, weil sie zuerst als Prototyp entstanden sind. Siehe
> [08 Codequalität](08-codequalitaet.md).

## Design-Tokens

In `ui/theme/`. Farben, Schriftgrößen, Abstände und Formen kommen aus
`IremiaColor`, `IremiaType`, `IremiaDimens`, `IremiaShape` — nicht als lose Zahlen
im Screen.

Bei Änderungen am Erscheinungsbild also zuerst prüfen, ob ein Token existiert.

## Texte

Nie fest eintippen. Immer:

```kotlin
localized(SharedRes.strings.journal_title).toString(context)
```

Details in [06 Lokalisierung](06-lokalisierung.md).

## Tastatur-Verhalten

Zwei Wege, die Tastatur zu schließen, beide bereits umgesetzt:

1. **Tippen außerhalb** — ein `detectTapGestures` am `Scaffold` in `MainScreen`
   räumt den Fokus. Der Erfassungs-Flow liegt in einem eigenen `Dialog`-Fenster und
   braucht deshalb denselben Handler ein zweites Mal.
2. **Bestätigung auf der Tastatur** — einzeilige Felder nutzen `ImeAction.Done`.
   Mehrzeilige Felder **nicht**: dort bliebe sonst kein Zeilenumbruch übrig. Sie
   zeigen stattdessen einen kleinen „Fertig“-Text über dem Feld, solange er fokussiert ist.

## Platz für den "+"-Button

Der Button schwebt über dem Inhalt und zählt nicht zum `Scaffold`-Padding. Scrollbare
Screens brauchen darum unten zusätzlichen Freiraum, sonst endet die letzte Karte
unter dem Button.

## Bauen

```bash
./gradlew :composeApp:assembleDebug
```

Weitere Befehle in [07 Build und Auslieferung](07-build-und-auslieferung.md).

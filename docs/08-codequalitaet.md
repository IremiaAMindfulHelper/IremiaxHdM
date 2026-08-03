# 08 — Codequalität und offene Punkte

Ehrliche Bestandsaufnahme. Gedacht als Arbeitsliste, nicht als Kritik: Vieles davon
ist normaler Prototyp-Rest, den man vor einer Weiterentwicklung aufräumt.

## Was gut trägt

**Die Schichtentrennung wird eingehalten.** Domain-Klassen sind frei von DB- und
UI-Abhängigkeiten, DAOs mappen innerhalb der Query-Lambda, Repositories schreiben über
`withContext(io)`. Die Richtung „UI kennt Shared, Shared kennt keine UI“ ist nirgends
verletzt.

**Das Controller-Muster ist durchgehalten.** Alle fünf Controller haben `@ObjCName`,
beide API-Varianten und ein `clear()`. Dass es das Muster überhaupt gibt, ist der
Grund, warum ein Feature nicht zweimal gedacht werden muss.

**Ressourcen liegen zentral.** Texte, Farben und Lottie-Dateien kommen aus `shared/`,
also sehen beide Plattformen dasselbe.

**Die Logik mit echtem Risiko ist getestet.** `GardenRandomizer` (deterministische
Platzierung) und `MotivationAlgorithm` sind durch Unit-Tests abgedeckt — genau die
Stellen, an denen ein stiller Fehler lange unbemerkt bliebe.

**Design-Tokens statt Streuzahlen.** Farben und Abstände sind benannt.

## Offene Punkte

### 1. Toter Code auf iOS

Diese Views sind von nirgendwo erreichbar:

- `Views/HomeView.swift` (ersetzt durch `Home/InsightHomeView.swift`)
- `Views/ContactView.swift`, `Views/ProfileView.swift`, `Views/SosView.swift`
- `Views/JournalViews/Navigation/JournalNavigationView.swift` samt der nur von dort
  genutzten Diary-Views
- `Views/JournalViews/Prototype/JournalPrototypeStrings.swift` (leer, nur noch ein Kommentar)

Auf Android entsprechend: `ui/SosScreen.kt`, `ui/ContactScreen.kt`.

**Warum das stört:** Wer den Code liest, kann nicht unterscheiden, was noch zählt.
Bei einer Textänderung sucht man in Dateien, die nie ausgeführt werden.

**Vorschlag:** Löschen. Die Git-Historie hebt alles auf.

### 2. Fest eingetippte Texte in Alt-Screens

Die Content-Regel ist in den aktiven Screens sauber umgesetzt, in den älteren nicht:

- `ui/ReflectionScreen.kt` — „Noch keine Mantras“, „Delete“, „Add“
- die unter Punkt 1 genannten Legacy-Views

`ReflectionScreen` hängt an `MantraRoute` und ist über die Tab-Navigation aktuell
**nicht** erreichbar, gehört also faktisch in dieselbe Kategorie.

**Vorschlag:** Beim Wiederbeleben nach `SharedRes` umziehen, sonst mit Punkt 1 löschen.

### 3. Große UI-Dateien

| Datei | Zeilen |
| ----- | -----: |
| `ui/home/HomeScreen.kt` | 741 |
| `ui/journal/episode/EpisodeStepScreens.kt` | 735 |
| `Views/JournalViews/Prototype/Episode/EpisodeStepScreens.swift` | 685 |
| `Views/JournalViews/JournalEntryViews/JournalEntryView.swift` | 640 |

Sie sind intern in kleine private Composables bzw. Views gegliedert und dadurch noch
lesbar. Trotzdem sind das die Dateien, in denen man beim Suchen scrollt.

**Vorschlag:** Bei der nächsten inhaltlichen Änderung pro Abschnitt eine Datei
abspalten (z. B. `HomeGardenCard`, `HomePatternsSection`). Kein Selbstzweck — nur
dort, wo man ohnehin arbeitet.

### 4. Jeder Controller baut seine eigene Datenbank

`SharedFactory` legt bei jedem `create…`-Aufruf einen neuen Treiber und ein neues
`UserData` an. Bei vier bis fünf Controllern ist das unkritisch; im Code steht dazu
bereits ein `TODO`.

**Vorschlag:** Eine `UserData`-Instanz einmal erzeugen und hineinreichen, sobald ein
weiteres Feature dazukommt.

### 5. Doppelte Textfeld-Farben (Android)

`OutlinedTextFieldDefaults.colors(...)` wird an drei Stellen fast gleich aufgebaut.
In `JournalEntryScreens.kt` gibt es dafür schon `journalFieldColors()`.

**Vorschlag:** Diese Funktion nach `ui/theme/` ziehen und an allen drei Stellen nutzen.

### 6. Verbliebene TODOs

Sieben Stück, alle bewusst gesetzt und harmlos:

- `IremiaType.kt` — echte Inter-Schrift laden (derzeit `FontFamily.Default`)
- `GardenScene` (beide Plattformen) — Drag-and-drop-Modus vorbereitet
- `BreathingExerciseView.swift` — Intro-Dauer noch fest bei 3 Sekunden
- `SharedFactory.kt` — siehe Punkt 4
- `FlowInterop.kt` — Puffern nur bei Bedarf

### 7. Testabdeckung

Getestet ist die reine Logik. Nicht abgedeckt: DAOs und Repositories (bräuchten eine
In-Memory-Datenbank) sowie die UI beider Plattformen.

**Vorschlag:** Falls Tests ausgebaut werden, mit `GardenPlantRepository` beginnen — dort
steckt die meiste Fachlogik (Monatszuordnung, volle Gärten, rückdatierte Einträge).

## Zwei Fallen, die schon zugeschnappt sind

Beide sind behoben, aber lehrreich genug, um sie festzuhalten:

**Rückfallsprache.** Solange Englisch in `base/` stand, zeigte ein englisches
Android-Telefon Englisch und ein deutsches iPhone Deutsch. Der Code war identisch —
der Unterschied lag allein an der Gerätesprache. Siehe [06](06-lokalisierung.md).

**Dauer statt Geschwindigkeit bei Animationen.** Die Wachstums-Datei ist 20 Sekunden
lang. iOS steuerte sie mit `speed: 4` (ergibt 5 s), Android mit festen 1800 ms. Wo
beide Plattformen gleich wirken sollen, muss die **Dauer** vorgegeben werden, nicht ein
Faktor. Siehe [04 iOS](04-ios.md).

## Wenn wenig Zeit ist

1. Toten Code löschen (Punkt 1) — größte Wirkung, geringstes Risiko
2. Textfeld-Farben zusammenführen (Punkt 5) — schnell erledigt
3. Große Dateien nur dort aufteilen, wo ohnehin gearbeitet wird (Punkt 3)

Punkt 4 und 7 lohnen erst, wenn das Projekt weitergeht.

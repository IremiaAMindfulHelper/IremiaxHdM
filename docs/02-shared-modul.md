# 02 — Das Shared-Modul

Alles unter `shared/src/commonMain/`. Dieses Modul enthält keinen UI-Code und darf
keinen enthalten.

## Verzeichnisse

```
shared/src/commonMain/
├── kotlin/org/iremia/iremia/
│   ├── domain/        reine Modelle und Regeln
│   ├── data/          DAOs und Repositories
│   ├── controller/    Zustand für die UI
│   ├── bridge/        SharedFactory
│   ├── interop/       Flow-Brücke für Swift
│   ├── db/            DriverFactory (expect/actual)
│   └── utils/         Hilfsfunktionen, u.a. localized()
├── sqldelight/com/iremia/    Note.sq, GardenPlant.sq, mantra.sq
└── moko-resources/           Texte, Farben, Bilder, Lottie-Dateien
```

## Domain

Reine Kotlin-Datenklassen und Funktionen. Keine Datenbank, keine UI, keine
Plattform-APIs.

```
domain/note/       Note, EpisodeDraft, EntryType, EntryTitle
domain/garden/     GardenModels, PlantType, GardenRandomizer, LottieAsset
domain/insights/   MotivationAlgorithm, MotivationInsight, SentimentAnalyzer
domain/mantra/     Mantra
domain/engines/    BreathingEngine, MemoryEngine, CalculationEngine, SOSFlowData
domain/models/     SOSStep, WellnessModels, QuestionData, MathOperation
```

Zwei Stellen tragen die eigentliche Fachlogik:

- **`GardenRandomizer`** — bestimmt, wo eine Pflanze landet und wie sie aussieht.
  Bewusst **deterministisch**: gesät mit der Eintrags-ID. Derselbe Eintrag ergibt
  immer dieselbe Position. Sonst würde der Garten bei jedem Neuladen anders aussehen.
- **`MotivationAlgorithm`** — leitet aus den Einträgen den Text auf dem Startbildschirm
  ab.

Beide sind durch Unit-Tests abgedeckt, weil sie ohne DB und ohne UI laufen.

## SQLDelight

Tabellen und Queries in `.sq`-Dateien; daraus wird typsicherer Kotlin-Code erzeugt.

```bash
./gradlew :shared:generateSqlDelightInterface
```

Datenbank heißt `UserData`, Paket `com.iremia`.

## DAO

Kapselt Queries und mappt Zeilen **innerhalb** der Query-Lambda auf Domain-Modelle.
Gibt `Flow` zurück:

```kotlin
fun observeAll(): Flow<List<Note>> =
    db.noteQueries
        .selectAll { id, content, createdAt, /* … */ ->
            Note(id = id, content = content, /* … */)
        }
        .asFlow()
        .mapToList(Dispatchers.Default)
```

Das DAO ist auch die Stelle, an der Datenbank-Eigenheiten enden. `Note.sq` speichert
Listen als kommagetrennten Text und Zahlen als `Long?`; `NoteDao` übersetzt das in
`List<String>` und `Int?`. Oberhalb des DAO sieht diese Repräsentation niemand mehr.

## Repository

Fassade über einem oder mehreren DAOs. Schreibzugriffe laufen über `withContext(io)`,
damit nichts den Main-Thread blockiert:

```kotlin
suspend fun add(text: String) = withContext(io) { dao.insert(text) }
```

`GardenPlantRepository` ist das inhaltlich dichteste Beispiel: Es entscheidet, in
welchen Monatsgarten eine Pflanze gehört (auch bei nachträglich datierten Einträgen),
sucht eine freie Zelle und gibt ein `PlantResult` zurück. Ist der Monat voll, wird
`planted = false` gemeldet, ohne dass etwas kaputtgeht.

## Controller

Siehe [01 Architektur](01-architektur.md) für das Muster. Kurz:

```kotlin
@ObjCName("NotesState", exact = true)
data class NotesState(val items: List<Note> = emptyList(), val isLoading: Boolean = false)

@ObjCName("NotesController", exact = true)
class NotesController(private val repo: NoteRepository, /* … */) {
    val state: StateFlow<NotesState>
    suspend fun add(...)                      // Android
    fun addAsync(..., onDone: (…) -> Unit)    // iOS
    fun clear()                               // immer implementieren
}
```

## Ressourcen (moko-resources)

Texte, Farben, Bilder und Lottie-Dateien liegen ebenfalls im Shared-Modul und sind
darum auf beiden Plattformen identisch. Generierte Klasse: `SharedRes`
(Paket `org.iremia.library`).

Details in [06 Lokalisierung](06-lokalisierung.md).

## Nach Änderungen neu generieren

| Geändert | Befehl |
| -------- | ------ |
| `.sq`-Datei | `./gradlew :shared:generateSqlDelightInterface` |
| `strings.xml` u.a. Ressourcen | `./gradlew :shared:generateMR` |
| irgendetwas für iOS | zusätzlich XCFramework neu bauen, siehe [07](07-build-und-auslieferung.md) |

`:shared:generateMR` ist wichtig: `:shared:generateMRcommonMain` erzeugt **nur** die
Kotlin-Klasse, nicht die Android-XML-Ressourcen. Wer nur den `commonMain`-Task
laufen lässt, sieht auf Android weiterhin die alten Texte.

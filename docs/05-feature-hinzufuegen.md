# 05 — Ein neues Feature hinzufügen

Durchgespielt an einem Feature mit eigener Tabelle. Als Vorlage im Code dient das
Notes-Feature: Es hat alle Schichten und ist am vollständigsten.

Reihenfolge nicht vertauschen — jeder Schritt baut auf dem vorigen auf.

## 1. Tabelle

`shared/src/commonMain/sqldelight/com/iremia/<Feature>.sq`:

```sql
CREATE TABLE example (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL
);

selectAll:
SELECT * FROM example ORDER BY id DESC;

insert:
INSERT INTO example(content) VALUES (?);

deleteById:
DELETE FROM example WHERE id = ?;
```

```bash
./gradlew :shared:generateSqlDelightInterface
```

## 2. Domain-Modell

`domain/example/Example.kt` — eine reine Datenklasse, keine DB-Typen:

```kotlin
data class Example(val id: Long, val content: String)
```

## 3. DAO

`data/example/ExampleDao.kt` — mappt Zeilen **in** der Query-Lambda:

```kotlin
class ExampleDao(private val db: UserData) {
    fun observeAll(): Flow<List<Example>> =
        db.exampleQueries
            .selectAll { id, content -> Example(id, content) }
            .asFlow()
            .mapToList(Dispatchers.Default)

    fun insert(content: String) = db.exampleQueries.insert(content)
}
```

## 4. Repository

`data/example/ExampleRepository.kt` — Schreiben immer über `withContext(io)`:

```kotlin
class ExampleRepository(
    private val dao: ExampleDao,
    private val io: CoroutineDispatcher = Dispatchers.Default,
) {
    fun observeAll(): Flow<List<Example>> = dao.observeAll()
    suspend fun add(content: String) = withContext(io) { dao.insert(content) }
}
```

## 5. Controller

`controller/ExampleController.kt` — die drei Pflichtteile: `@ObjCName`, beide
API-Varianten, `clear()`:

```kotlin
@ObjCName("ExampleState", exact = true)
data class ExampleState(
    val items: List<Example> = emptyList(),
    val isLoading: Boolean = false,
)

@ObjCName("ExampleController", exact = true)
class ExampleController(
    private val repo: ExampleRepository,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main),
) {
    private val _state = MutableStateFlow(ExampleState(isLoading = true))
    val state: StateFlow<ExampleState> = _state.asStateFlow()

    init {
        scope.launch {
            repo.observeAll().collect { list ->
                _state.value = ExampleState(items = list, isLoading = false)
            }
        }
    }

    suspend fun add(content: String) = repo.add(content)

    fun addAsync(content: String, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { repo.add(content) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
        }
    }

    fun clear() = scope.cancel()
}
```

## 6. SharedFactory

In `bridge/SharedFactory.kt` die Kette zusammensetzen:

```kotlin
fun createExampleController(driverFactory: DriverFactory): ExampleController {
    val db = createDatabase(driverFactory)
    return ExampleController(ExampleRepository(ExampleDao(db)))
}
```

## 7. Texte

Neue Texte in **beide** Dateien eintragen (`base/` und `de/`), dann:

```bash
./gradlew :shared:generateMR
```

Siehe [06 Lokalisierung](06-lokalisierung.md).

## 8. Android

```kotlin
class ExampleViewModel(private val controller: ExampleController) : ViewModel() {
    val state = controller.state
    fun add(text: String) = viewModelScope.launch { controller.add(text) }
    override fun onCleared() { super.onCleared(); controller.clear() }
}
```

Dazu eine Route, die den Controller über die `SharedFactory` in einem `remember { }`
baut, und einen **zustandslosen** Screen, der nur Daten und Callbacks bekommt.

## 9. iOS

```swift
final class ExampleObservable: ObservableObject {
    @Published var items: [Example] = []
    private let controller = SharedFactory().createExampleController(driverFactory: ...)
    private var cancelable: Cancelable?

    init() {
        cancelable = Interop.shared.observeState(flow: controller.state) { /* … */ }
    }

    deinit {
        cancelable?.cancel()
        controller.clear()
    }
}
```

Danach das XCFramework neu bauen, sonst kennt Swift den neuen Controller nicht:

```bash
./gradlew :shared:podPublishDebugXCFramework
```

## Checkliste

- [ ] `.sq` angelegt, SQLDelight generiert
- [ ] Domain-Modell ohne DB- und UI-Abhängigkeiten
- [ ] DAO gibt `Flow` zurück, mappt in der Query-Lambda
- [ ] Repository schreibt über `withContext(io)`
- [ ] Controller mit `@ObjCName`, `suspend` **und** `…Async`, `clear()`
- [ ] `SharedFactory` erweitert
- [ ] Texte in `base/` **und** `de/`, `generateMR` gelaufen
- [ ] Android: ViewModel ruft `clear()` in `onCleared()`
- [ ] iOS: `deinit` ruft `cancel()` **und** `clear()`
- [ ] XCFramework neu gebaut
- [ ] Beide Plattformen gebaut

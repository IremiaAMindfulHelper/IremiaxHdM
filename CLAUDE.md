CLAUDE.md
Guidance for Claude Code when working in the Iremia mobile app repository.
Project Overview
Iremia is a mobile app that supports users through panic attacks with journal entries, breathing exercises, and relaxation training.
Tech: Kotlin Multiplatform (KMP) with native UIs.

shared/ — KMP module: SQLDelight database, domain models, DAOs, repositories, controllers, moko-resources strings
Android — Jetpack Compose UI (androidMain / app module)
iOS — SwiftUI app in iosApp/, consumes the shared module as Shared.xcframework

Repository: https://github.com/IremiaAMindfulHelper/IremiaxHdM.git
Content rule: user-facing texts stay emotionally neutral and autonomy-preserving. No guilt-inducing or streak-pressure language.
Common Commands
bash# Build Android + shared
./gradlew assemble

# Regenerate SQLDelight code after editing .sq files
./gradlew :shared:generateSqlDelightInterface

# Regenerate moko-resources after editing strings.xml
./gradlew :shared:generateMRcommonMain

# Build the iOS framework
./gradlew :shared:podPublishDebugXCFramework      # Debug
./gradlew :shared:podPublishReleaseXCFramework    # Release
# Output: shared/build/cocoapods/publish/<debug|release>/Shared.xcframework

# Alternative full XCFramework build (see onboarding)
./gradlew assembleXCFramework
Architecture
We use MVVM + Clean Architecture in a modular setup. Data flows bottom-up through these layers:

SQLDelight — tables and queries in shared/src/commonMain/sqldelight/<feature>.sq
Domain — plain data class models, no DB/UI/platform dependencies
(shared/src/commonMain/kotlin/org/iremia/iremia/domain/<feature>/)
DAO — wraps SQLDelight queries, maps rows to domain models
(shared/src/commonMain/kotlin/org/iremia/iremia/data/<feature>/)
Repository — facade for business logic; all writes run via withContext(io)
Controller — exposes StateFlow<XxxState> to both platforms
(shared/src/commonMain/kotlin/org/iremia/iremia/controller/)
SharedFactory — builds controllers per feature
(shared/src/commonMain/kotlin/org/iremia/iremia/bridge/SharedFactory.kt)
Android UI — ViewModel wraps the controller; Route wires everything; Screen is a stateless composable
iOS UI — ObservableObject watches the controller state; SwiftUI view holds it as @StateObject

Core principles

Separation of concerns: keep UI, business logic, and data clearly separated.
Single source of truth: shared models and strings are defined once in shared/ and reused on both platforms.
Modularity: each feature lives in its own module to reduce coupling.
Explicit dependencies: no hidden dependencies; use dependency injection where possible.
Shared code stays UI-agnostic and testable. Keep platform APIs minimal and abstracted behind interfaces.
Favor composable functions, small view models, and reusable UI components.

Shared layer patterns
DAO: map rows to domain inside the query lambda, expose a Flow:
kotlinfun observeAll(): Flow<List<Note>> =
    db.noteQueries
        .selectAllNotes { id, text -> Note(id = id, text = text) }
        .asFlow()
        .mapToList(Dispatchers.Default)
Repository: wrap the DAO, push writes off the main thread:
kotlinsuspend fun add(text: String) = withContext(io) { dao.insert(text) }
Controller: one immutable state class + StateFlow, suspend APIs for Android, callback APIs for iOS:
kotlin@ObjCName("NotesState", exact = true)
data class NotesState(
    val items: List<Note> = emptyList(),
    val isLoading: Boolean = false
)

@ObjCName("NotesController", exact = true)
class NotesController(
    private val repo: NoteRepository,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
) {
    private val _state = MutableStateFlow(NotesState(isLoading = true))
    val state: StateFlow<NotesState> = _state.asStateFlow()

    init {
        scope.launch {
            repo.observeAll().collect { list ->
                _state.value = NotesState(items = list, isLoading = false)
            }
        }
    }

    suspend fun add(text: String) = repo.add(text)

    // iOS-friendly callback variant
    fun addAsync(text: String, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { repo.add(text) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
        }
    }

    fun clear() = scope.cancel()
}
Controller rules:

Annotate state and controller with @ObjCName(..., exact = true).
Provide both suspend functions and xxxAsync(..., onDone: (Throwable?) -> Unit) variants for iOS.
Always provide clear() that cancels the scope. Android calls it in onCleared(), iOS in deinit.

Adding a new feature with a table (checklist)
Use the Notes feature as the reference implementation. Steps:

SQLDelight: create shared/src/commonMain/sqldelight/<feature>.sq with CREATE TABLE and CRUD queries (selectAll…, insert…, deleteById…, updateById…). Regenerate via Gradle sync + build, or ./gradlew :shared:generateSqlDelightInterface.
Domain: data class with the table fields (e.g. Note(val id: Long, val text: String)).
DAO: XxxDao(db: UserData) with observeAll(): Flow<List<Xxx>>, insert, delete, update.
Repository: XxxRepository(dao, io = Dispatchers.Default); writes wrapped in withContext(io).
Controller: XxxState(items, isLoading) + StateFlow, suspend + Async APIs, clear().
SharedFactory: add createXxxController(driverFactory: DriverFactory): XxxController — creates driver, UserData, DAO, repository, controller.
Android:

XxxViewModel(controller) delegates calls via viewModelScope, calls controller.clear() in onCleared().
XxxRoute builds the controller with SharedFactory.createXxxController(DriverFactory(context)) inside remember { } and collects state with vm.state.collectAsState(...).
XxxScreen(state, onAdd, onDelete, ...) is stateless and only renders.


iOS:

XxxObservable: ObservableObject with @Published var state, subscribes via controller.state.watch { ... } and updates on the main queue. Cancel the watch handle and call controller.clear() in deinit.
SwiftUI view holds it as @StateObject and builds the controller via SharedFactory().createXxxController(driverFactory:).



Naming Conventions
English for all names and comments. Descriptive over short: calculateStressScore(), not calcScore(). Widely understood abbreviations (UI, ID, URL) are fine.
Kotlin / shared:
ElementConventionExamplePackageslowercase, dot-separatedorg.iremia.shared.feature.sessionClasses / InterfacesPascalCaseUserProfileViewModel, HealthRepositoryFunctionscamelCaseloadUserData(), calculateAverage()ConstantsUPPER_SNAKE_CASEDEFAULT_TIMEOUT_MSResources (strings, colors, icons)lowercase_with_underscoreswelcome_title, primary_color
Swift / iOS:
ElementConventionExampleClasses / Structs / EnumsPascalCaseSessionView, StressScoreCalculatorVariables / FunctionscamelCaseuserProfile, fetchSessionData()ConstantscamelCase (UPPER_SNAKE_CASE for globals)let maxRetries = 3UI identifiersPascalCase / design system tokensPrimaryButton, IremiaAccentColor
Comments & Documentation

Docstrings for public functions, classes, and modules: /** ... */ in Kotlin, /// in Swift. Document parameters, return values, and side effects.
Inline comments explain why, not what. The code already says what.
Keep comments short, in English, and up to date. Remove outdated comments immediately.
Avoid block comments (/* ... */) unless really needed.

Comment prefixes (searchable in IntelliJ / Xcode):
PrefixMeaningExampleTODO:Open task or improvement// TODO: handle null case for iOSFIXME:Known issue or workaround// FIXME: workaround for API timeoutNOTE:Important reasoning or design decision// NOTE: runs on main thread intentionallyOPTIMIZE:Possible performance improvement// OPTIMIZE: avoid recomposition in SwiftUI
Localization (moko-resources)
Never hardcode user-facing strings. All strings live in the shared module:
shared/src/commonMain/moko-resources/
├── base/strings.xml   # English (Base)
└── de/strings.xml     # German

Generated class: SharedRes (package org.iremia.library).
After any string change: ./gradlew :shared:generateMRcommonMain. For iOS, also rebuild the XCFramework.
iosBaseLocalizationRegion is set to "en" and must match the language in base/.
iOS resolves strings through the shared wrapper in Strings.kt:

kotlinfun localized(res: StringResource): StringDesc = StringDesc.Resource(res)
swiftText(StringsKt.localized(res: SharedRes.strings().welcome_title).localized())

An Xcode build phase ("Copy moko-resources bundle") copies the …shared.bundle into the app. If translations are missing, check that Base.lproj and de.lproj exist inside the built .app.

Common issues:
SymptomCauseFixStringResource(... not yet loaded)Wrong API (description)Use StringsKt.localized(...).localized()has no member 'desc'.desc() is Kotlin-onlyUse the wrapperBundle only in ENWrong iosBaseLocalizationRegionSet to "en" in GradleTask not foundXCFramework vs. Pods mixed upUse the correct run script
Git Workflow
Branches:
BranchPurposemainReleases only (stable, production-ready, protected)stagingBundles completed increments from developdevelopActive integration branch

Ticket branches are created via the Jira dev panel, based on develop.
Naming: develop/IRM-123-short-description.
Lifecycle: branch from develop → implement → PR back to develop → merge after review.
Hotfixes: branch from develop, apply fix, merge back into develop (and the feature branch if needed).

Pull Requests

Must be reviewed and approved by Maik, Julia, or Lara.
When opening a PR, set the Jira ticket to "In Review".
Keep PRs small (~max 400 lines diff). Use Draft PRs for early feedback.
Title always includes the Jira key: [IRM-123] Short title.
Template: Goal/Context · Scope (what is in / out) · Screenshots (for UI changes) · Manual Testing steps · Risks/Notes.

Merge strategy:
Source → TargetStrategydevelop/* → developSquash & Mergedevelop → featureMerge Commitfeature → mainMerge Commit (releases)
Commit messages
Simplified Conventional Commits:

Subject: max 50 characters, imperative form ("add", "fix", "update"), no trailing period.
Body: explains why the change was made, wrapped at ~72 characters.
Reference the ticket: Resolves: IRM-123.

Types: feat, fix, docs, chore, refactor, perf, build/ci, revert.
Example:
fix(watchkit): avoid null HKHealthStore on cold start

On first launch after install, HKHealthStore could be nil before
authorization had completed. Add guard + retry to prevent crash.

Resolves: IRM-204
Code Review Checklist

Naming follows the conventions above
Clear separation of concerns (UI / logic / data)
Shared resources used correctly (strings via SharedRes, models from shared/)
Architecture guidelines respected (layer order, controller pattern, threading)

Dev Environment

IntelliJ IDEA 2025.2.x — do not use 2025.3+ (known breaking issues).
IntelliJ plugins: Android, Android Design Tools, Jetpack Compose, Kotlin Multiplatform, Makefile Language, Native Debugging Support, SQLDelight, Gradle. Optional: GitHub Copilot.
Latest Xcode. Open iosApp.xcworkspace.
iOS setup: run ./gradlew assemble, then assembleXCFramework (or :shared:podPublishDebugXCFramework). Copy the XCFramework into iosApp/, add it under "Frameworks, Libraries and Embedded Content" with Embed & Sign, then build in Xcode.
@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.bridge

import kotlin.native.ObjCName
import com.iremia.UserData
import org.iremia.iremia.controller.GardenController
import org.iremia.iremia.controller.MantrasController
import org.iremia.iremia.controller.MotivationController
import org.iremia.iremia.controller.NotesController
import org.iremia.iremia.db.DriverFactory
import org.iremia.iremia.data.garden.GardenPlantDao
import org.iremia.iremia.data.garden.GardenPlantRepository
import org.iremia.iremia.data.mantra.MantraDao
import org.iremia.iremia.data.mantra.MantraRepository
import org.iremia.iremia.data.note.NoteDao
import org.iremia.iremia.data.note.NoteRepository

/**
 * Bridge entry points for iOS/Swift.
 *
 * WHY
 * - Keeps Swift call sites simple and stable (no package plumbing on iOS).
 * - Central place to assemble feature stacks (DAO → Repository → Controller).
 *
 * HOW
 * - Expose a universal database builder (`createDatabase`).
 * - Provide tiny factory methods per feature (e.g., `createMantrasController`).
 *
 * EXTENSIBILITY
 * - Adding new tables/queries in SQLDelight: **no change needed here**.
 *   The generated `UserData` grows automatically and this factory keeps working.
 * - Adding a new feature (e.g., Episodes): add a sibling
 *   `createEpisodesController(...)` that wires its DAO/Repository the same way.
 *
 * PERFORMANCE/USAGE NOTES
 * - `dbName` defaults to "iremia.db"; override for testing/multi-profile setups.
 * - Each factory method currently creates its own DB instance.
 *   // TODO: Accept a shared `UserData` to reuse a single DB across controllers,
 *   //       if you wire multiple features in one screen on iOS.
 */
@ObjCName("SharedFactory", exact = true)
object SharedFactory {

    private var cachedDatabase: UserData? = null

    /**
     * Builds the platform-specific SQLDelight driver and returns the generated database.
     * Caches the database instance so multiple controllers share the same connection.
     *
     * @param driverFactory Platform driver provider (Android/iOS actuals).
     * @param dbName Optional database filename, defaults to "iremia.db".
     * @return The generated SQLDelight database (`UserData`).
     */
    fun createDatabase(
        driverFactory: DriverFactory,
        dbName: String = "iremia.db"
    ): UserData {
        val existing = cachedDatabase
        if (existing != null) return existing
        val newDb = UserData(driverFactory.createDriver(dbName))
        cachedDatabase = newDb
        return newDb
    }

    /**
     * Assembles the Mantras feature (DAO → Repository → Controller) for Swift.
     *
     * WHY
     * - Give Swift a one-liner to obtain a ready-to-use controller.
     * - Hide Kotlin package details and wiring from iOS code.
     *
     * @param driverFactory Platform driver provider (creates the SQLDelight driver).
     * @return A `MantrasController` ready to observe/add/remove mantras.
     *
     * NOTE: When you introduce a new feature (e.g., Episodes), add a
     *       `createEpisodesController(...)` method beside this one. Database
     *       creation remains unchanged.
     */
    fun createMantrasController(driverFactory: DriverFactory): MantrasController {
        // NOTE: Build DB for this controller. Consider passing a shared DB if you
        // use multiple controllers concurrently on iOS.
        val db = createDatabase(driverFactory)

        // Wire feature data layer
        val dao = MantraDao(db)
        val repo = MantraRepository(dao)

        // Return controller consumed by Swift
        return MantrasController(repo)
    }

    /**
     * Assembles the Notes feature (DAO → Repository → Controller) for Swift.
     *
     * @param driverFactory Platform driver provider.
     * @return A `NotesController` ready to manage journal notes.
     */
    fun createNotesController(driverFactory: DriverFactory): NotesController {
        val db = createDatabase(driverFactory)
        val repo = NoteRepository(NoteDao(db))
        // Adding a note also plants a persistent garden item via this repo.
        val gardenRepo = GardenPlantRepository(GardenPlantDao(db))
        return NotesController(repo, gardenRepo)
    }

    /**
     * Assembles the Garden feature (DAO → Repository → Controller) for Swift.
     *
     * Tiles come from the persistent `gardenPlant` table (via [GardenPlantRepository]),
     * so plants survive deletion of their source journal entry. The [NoteRepository]
     * is still passed in to resolve a tapped plant back to its originating entry.
     * The shared, cached `UserData` means plants added through the notes flow appear
     * here automatically.
     *
     * @param driverFactory Platform driver provider.
     * @return A `GardenController` ready to manage the garden overview state.
     */
    fun createGardenController(driverFactory: DriverFactory): GardenController {
        val db = createDatabase(driverFactory)
        val gardenRepo = GardenPlantRepository(GardenPlantDao(db))
        val noteRepo = NoteRepository(NoteDao(db))
        return GardenController(gardenRepo, noteRepo)
    }

    /**
     * Assembles the Motivation feature for the home screen's blue insight card.
     *
     * Reads real journal entries via [NoteRepository]; the algorithm fills missing
     * signals with deterministic dummy generators until exercise tracking lands.
     *
     * @param driverFactory Platform driver provider.
     * @return A `MotivationController` exposing the computed insight state.
     */
    fun createMotivationController(driverFactory: DriverFactory): MotivationController {
        val db = createDatabase(driverFactory)
        val noteRepo = NoteRepository(NoteDao(db))
        return MotivationController(noteRepo)
    }

    // Example sketch for future features (keep for reference):
    // fun createEpisodesController(driverFactory: DriverFactory): EpisodesController { ... }
}
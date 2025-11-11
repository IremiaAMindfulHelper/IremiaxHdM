package org.iremia.iremia.db

import app.cash.sqldelight.db.SqlDriver
import com.iremia.UserData

/**
 * Platform-agnostic factory for creating a SQLDelight [SqlDriver].
 *
 * KMP expect/actual:
 * - Android actual returns an AndroidSqliteDriver
 * - iOS actual returns a NativeSqliteDriver (links system `sqlite3`)
 *
 * @param dbName Name of the on-device database file. Defaults to "iremia.db".
 * @return A ready-to-use [SqlDriver] instance for SQLDelight.
 *
 * NOTE: No at-rest encryption by default. If you need DB encryption later,
 * replace the platform actuals with SQLCipher-backed drivers and keep this
 * expect API stable.
 */
expect class DriverFactory {
    /**
     * Creates a platform-specific SQLDelight driver for the given database name.
     */
    fun createDriver(dbName: String = "iremia.db"): SqlDriver
}

/**
 * Thin composition root that wires the generated SQLDelight database.
 *
 * Why: Keeps shared code independent from platform driver creation and
 * keeps a single place to apply future cross-platform DB init (PRAGMAs,
 * seeds, migrations checks).
 *
 * Usage:
 * val db = DatabaseProvider.createDatabase(driverFactory)
 */
object DatabaseProvider {
    fun createDatabase(driverFactory: DriverFactory): UserData =
        UserData(driverFactory.createDriver())
}
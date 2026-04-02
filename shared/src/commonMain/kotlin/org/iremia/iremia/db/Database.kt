package org.iremia.iremia.db

import com.iremia.UserData

/**
 * Convenience database provider used by factories/tests.
 *
 * This isolates the driver creation from call sites, returning the
 * SQLDelight-generated `UserData` instance ready for queries.
 *
 * Security/Regulatory:
 * - SQLDelight stores plaintext by default. For medical data at-rest
 *   encryption (e.g., SQLCipher) should be evaluated and integrated
 *   with secure key management (Keychain/Keystore).
 */
object Database {

    /**
     * Create the SQLDelight database with the platform driver.
     *
     * @param driverFactory Platform-provided driver factory.
     * @return SQLDelight `UserData` database instance.
     */
    fun create(driverFactory: DriverFactory): UserData {
        val driver = driverFactory.createDriver()
        return UserData(driver)
    }
}
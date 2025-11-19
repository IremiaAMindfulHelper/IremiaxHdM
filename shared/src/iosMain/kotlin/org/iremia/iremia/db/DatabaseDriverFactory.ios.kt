package org.iremia.iremia.db


import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver
import com.iremia.UserData

actual class DriverFactory {
    actual fun createDriver(dbName: String): SqlDriver =
        NativeSqliteDriver(UserData.Schema, dbName)
}
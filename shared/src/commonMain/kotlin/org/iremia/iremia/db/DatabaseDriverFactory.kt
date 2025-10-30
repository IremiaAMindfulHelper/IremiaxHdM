package org.iremia.iremia.db

import app.cash.sqldelight.db.SqlDriver
import com.iremia.UserData

expect class DriverFactory {
    fun createDriver(dbName: String = "iremia.db"): SqlDriver
}

object DatabaseProvider {
    fun createDatabase(driverFactory: DriverFactory): UserData =
        UserData(driverFactory.createDriver())
}
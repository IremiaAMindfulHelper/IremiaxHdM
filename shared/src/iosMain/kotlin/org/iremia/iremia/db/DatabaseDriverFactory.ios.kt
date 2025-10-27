package org.iremia.iremia.db


import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver
import com.iremia.UserData

class DatabaseDriverFactory {
    fun createDriver(): SqlDriver =
        NativeSqliteDriver(UserData.Schema, "UserData.db")
}
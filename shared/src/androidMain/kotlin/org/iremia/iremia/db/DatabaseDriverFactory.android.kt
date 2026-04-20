package org.iremia.iremia.db

import android.content.Context
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import com.iremia.UserData


 actual class DriverFactory(private val context: Context) {
    actual fun createDriver(dbName: String): SqlDriver =
        AndroidSqliteDriver(UserData.Schema, context, dbName)
}
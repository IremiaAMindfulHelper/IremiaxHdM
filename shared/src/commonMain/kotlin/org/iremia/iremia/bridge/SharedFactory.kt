@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.bridge

import kotlin.native.ObjCName
import com.iremia.UserData
import org.iremia.iremia.controller.MantrasController
import org.iremia.iremia.db.DriverFactory
import org.iremia.iremia.data.mantra.MantraDao
import org.iremia.iremia.data.mantra.MantraRepository

@ObjCName("SharedFactory", exact = true)
object SharedFactory {
    fun createDatabase(driverFactory: DriverFactory, dbName: String = "iremia.db"): UserData =
        UserData(driverFactory.createDriver(dbName))

    fun createMantrasController(driverFactory: DriverFactory): MantrasController {
        val db = createDatabase(driverFactory)
        val dao = MantraDao(db)
        val repo = MantraRepository(dao)
        return MantrasController(repo)
    }
}
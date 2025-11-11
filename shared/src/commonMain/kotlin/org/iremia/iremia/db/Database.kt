package org.iremia.iremia.db

import com.iremia.UserData // <— WICHTIG: Deine aktuell generierte DB-Klasse

object Database {
    fun create(driverFactory: DriverFactory): UserData {
        val driver = driverFactory.createDriver()
        return UserData(driver)
    }
}
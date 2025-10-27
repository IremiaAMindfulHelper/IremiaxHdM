import android.content.Context
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import com.iremia.UserData
import app.cash.sqldelight.db.SqlDriver

class DatabaseDriverFactory(private val context: Context) {
    fun createDriver(): SqlDriver =
        AndroidSqliteDriver(UserData.Schema, context, "UserData.db")
}
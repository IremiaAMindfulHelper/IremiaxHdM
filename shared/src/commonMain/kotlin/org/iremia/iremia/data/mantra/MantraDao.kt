package org.iremia.iremia.data.mantra

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import org.iremia.iremia.domain.mantra.Mantra
import com.iremia.UserData

class MantraDao(private val db: UserData) {

    fun observeAll(): Flow<List<Mantra>> =
        db.mantraQueries
            .selectAll { id: Long, text: String -> Mantra(id = id, text = text) }
            .asFlow()
            .mapToList(Dispatchers.Default)

    fun insert(text: String) {
        db.mantraQueries.insertOne(text)   // returns QueryResult<Long> → ignorieren
    }

    fun delete(id: Long) {
        db.mantraQueries.deleteById(id)    // returns QueryResult<Long> → ignorieren
    }
}
package org.iremia.iremia.features.mantra

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import com.iremia.UserData

class MantraRepository(
    private val db: UserData,
    private val io: CoroutineDispatcher = Dispatchers.Default
) {
    fun observeAll(): Flow<List<Mantra>> =
        db.mantraQueries.selectAll(::map)
            .asFlow()
            .mapToList(io)

    suspend fun insert(text: String): Unit = withContext(io) {
        db.mantraQueries.insertOne(text)
    }

    suspend fun delete(id: Long): Unit = withContext(io) {
        db.mantraQueries.deleteById(id)
    }

    private fun map(id: Long, text: String) = Mantra(id = id, text = text)
}
package org.iremia.iremia.features.mantra

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.flow.Flow

class MantraDao(
    private val queries: MantraQueries,
    private val ioDispatcher: CoroutineDispatcher
) {
    fun observeAll(): Flow<List<Mantra>> =
        queries.selectAll()
            .asFlow()
            .mapToList(ioDispatcher)
            .transformToDomain()

    suspend fun add(text: String) {
        queries.insertOne(text)
    }

    suspend fun remove(id: Long) {
        queries.deleteById(id)
    }

    private fun Flow<List<SelectAll>>.transformToDomain(): Flow<List<Mantra>> =
        kotlinx.coroutines.flow.map { rows ->
            rows.map { Mantra(id = it.id, text = it.text) }
        }
}
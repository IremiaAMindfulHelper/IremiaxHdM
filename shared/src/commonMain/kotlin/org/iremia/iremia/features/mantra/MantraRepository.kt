package org.iremia.iremia.features.mantra

import kotlinx.coroutines.flow.Flow

class MantraRepository(
    private val dao: MantraDao
) {
    fun observeAll(): Flow<List<Mantra>> = dao.observeAll()
    suspend fun add(text: String) = dao.add(text)
    suspend fun remove(id: Long) = dao.remove(id)
}
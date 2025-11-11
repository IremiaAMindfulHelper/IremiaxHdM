package org.iremia.iremia.data.mantra

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import org.iremia.iremia.domain.mantra.Mantra

class MantraRepository(
    private val dao: MantraDao,
    private val io: CoroutineDispatcher = Dispatchers.Default
) {
    fun observeAll(): Flow<List<Mantra>> = dao.observeAll()

    suspend fun add(text: String) = withContext(io) { dao.insert(text) }

    suspend fun remove(id: Long)  = withContext(io) { dao.delete(id) }
}
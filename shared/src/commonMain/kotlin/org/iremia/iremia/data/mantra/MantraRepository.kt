package org.iremia.iremia.data.mantra

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import org.iremia.iremia.domain.mantra.Mantra

/**
 * Repository coordinating access to the mantra data source(s).
 *
 * Responsibilities:
 * - Delegates reads/writes to the DAO.
 * - Ensures blocking writes run off the Main thread.
 *
 * NOTE: Add cross-table joins or simple business rules here (not in DAO).
 */
class MantraRepository(
    private val dao: MantraDao,
    private val io: CoroutineDispatcher = Dispatchers.Default
) {
    /** Stream of all mantras for UI consumption. */
    fun observeAll(): Flow<List<Mantra>> = dao.observeAll()

    /** Add a mantra on a background dispatcher (non-blocking for UI). */
    suspend fun add(text: String) = withContext(io) { dao.insert(text) }

    /** Remove by id on a background dispatcher. */
    suspend fun remove(id: Long)  = withContext(io) { dao.delete(id) }
}
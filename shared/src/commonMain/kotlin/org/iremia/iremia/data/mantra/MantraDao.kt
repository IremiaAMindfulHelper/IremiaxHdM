package org.iremia.iremia.data.mantra

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import org.iremia.iremia.domain.mantra.Mantra
import com.iremia.UserData

/**
 * Thin data access layer for the `mantra` table.
 *
 * Responsibility:
 * - Wrap SQLDelight queries and map rows to domain types.
 * - Provide reactive access via `Flow`.
 *
 * Threading:
 * - `mapToList(Dispatchers.Default)` offloads result mapping to a background
 *   dispatcher. Callers observe/collect on their preferred thread.
 *
 * Notes:
 * - We map rows in the query lambda to avoid extra allocations.
 * - SQLDelight `QueryResult` from `insert`/`delete` is not used here. If you
 *   need affected-row counts or last IDs later, adjust the return types.
 */
class MantraDao(private val db: UserData) {

    /**
     * Observe all mantras, emitting on each table change.
     *
     * @return `Flow<List<Mantra>>` that updates whenever `mantra` mutates.
     */
    fun observeAll(): Flow<List<Mantra>> =
        db.mantraQueries
            // Explicit mapper keeps Kotlin type inference predictable across KMP.
            .selectAll { id: Long, text: String -> Mantra(id = id, text = text) }
            .asFlow()
            .mapToList(Dispatchers.Default)

    /**
     * Insert a single mantra text.
     *
     * NOTE: We ignore the SQLDelight `QueryResult` here; callers only care that
     * the change is observed via `observeAll()`. Return types can be extended
     * later (e.g., to return new row ID).
     */
    fun insert(text: String) {
        db.mantraQueries.insertOne(text)   // returns QueryResult<Long> → ignored intentionally
    }

    /**
     * Delete a mantra by its primary key.
     *
     * NOTE: See `insert` for remarks on return values.
     */
    fun delete(id: Long) {
        db.mantraQueries.deleteById(id)    // returns QueryResult<Long> → ignored intentionally
    }
}
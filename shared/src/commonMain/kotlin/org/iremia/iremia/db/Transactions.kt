package org.iremia.iremia.db

import app.cash.sqldelight.TransactionWithReturn
import com.iremia.UserData

/**
 * Runs a SQLDelight transaction on [UserData] and returns the result of [block].
 *
 * Mirrors SQLDelight's `transactionWithResult { ... }` but provides a concise
 * extension on the generated database type.
 *
 * @param R Return type of the transactional block.
 * @param block Transaction body; use the receiver to call `afterCommit {}` or
 * `afterRollback {}` if needed.
 * @return Whatever [block] returns.
 *
 * NOTE: This executes on the caller's coroutine context. For heavy work,
 * call it from an IO-friendly dispatcher.
 */
inline fun <R> UserData.transaction(crossinline block: TransactionWithReturn<R>.() -> R): R =
    this.transactionWithResult { block() }
package org.iremia.iremia.db


import app.cash.sqldelight.TransactionWithReturn
import app.cash.sqldelight.db.SqlDriver
import com.iremia.UserData

inline fun <R> UserData.transaction(crossinline block: TransactionWithReturn<R>.() -> R): R =
    this.transactionWithResult { block() }
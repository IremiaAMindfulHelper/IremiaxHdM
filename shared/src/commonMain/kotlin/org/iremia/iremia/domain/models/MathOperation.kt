package org.iremia.iremia.domain.models

enum class MathOperation(val symbol: String) {
    PLUS("+"),
    MINUS("−");

    fun compute(a: Int, b: Int): Int = when (this) {
        PLUS -> a + b
        MINUS -> a - b
    }

    companion object {
        fun random() = entries.random()
    }
}
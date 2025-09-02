package org.iremia.iremia

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform
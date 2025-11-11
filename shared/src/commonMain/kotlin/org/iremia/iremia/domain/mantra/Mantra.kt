@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.mantra

import kotlin.native.ObjCName

@ObjCName("Mantra", exact = true)
data class Mantra(val id: Long, val text: String)
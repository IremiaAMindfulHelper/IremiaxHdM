@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.mantra

import kotlin.native.ObjCName

/**
 * Domain model for a user-defined mantra.
 *
 * This is the canonical representation of a mantra across layers
 * (DAO → Repository → Controller → UI). The type is deliberately small
 * and immutable to make reasoning and testing straightforward.
 *
 * Interop:
 * - Exported to Swift with a stable Obj-C name so it can be consumed
 *   from SwiftUI without long, package-prefixed type names.
 *
 * Persistence:
 * - Backed by the SQLDelight table `mantra (id INTEGER PRIMARY KEY, text TEXT NOT NULL)`.
 *
 * @property id   Auto-incrementing database primary key (stable identifier).
 * @property text The visible mantra text shown in the UI and used by features
 *                like the Rescue-Loop.
 */
@ObjCName("Mantra", exact = true)
data class Mantra(
    val id: Long,
    val text: String
)
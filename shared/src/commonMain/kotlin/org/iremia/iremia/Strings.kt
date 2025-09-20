package org.iremia.iremia

import dev.icerock.moko.resources.StringResource
import dev.icerock.moko.resources.desc.Resource
import dev.icerock.moko.resources.desc.StringDesc

// Generische Hilfsfunktion
fun localized(res: StringResource): StringDesc =
    StringDesc.Resource(res)
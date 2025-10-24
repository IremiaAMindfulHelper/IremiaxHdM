package org.iremia.iremia.utils

import dev.icerock.moko.resources.StringResource
import dev.icerock.moko.resources.desc.Resource
import dev.icerock.moko.resources.desc.StringDesc

// Generic helper function
fun localized(res: StringResource): StringDesc =
    StringDesc.Resource(res)
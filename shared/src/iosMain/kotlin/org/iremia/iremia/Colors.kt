package org.iremia.iremia

import org.iremia.library.SharedRes
import dev.icerock.moko.resources.ColorResource
import dev.icerock.moko.resources.getUIColor
import platform.UIKit.UIColor

object SharedColors {
    fun primary(): UIColor = SharedRes.colors.primary.getUIColor()
    fun secondary(): UIColor = SharedRes.colors.secondary.getUIColor()
    fun background(): UIColor = SharedRes.colors.background.getUIColor()
    fun error(): UIColor = SharedRes.colors.error.getUIColor()
}
//
//  StringProxy.swift
//  iosApp
//
//  Created by Maik on 09.12.25.
//

import Shared

/// Lightweight dynamic lookup wrapper for shared string resources.
///
/// WHY
/// - On iOS we want a very short and ergonomic way to access localized
///   strings coming from the KMP `SharedRes.strings()` bundle.
/// - Avoids repeating the boilerplate to convert `ResourcesStringResource`
///   into a localized `String` in every view.
///
/// HOW
/// - Wraps a `Root` (typically `SharedRes.strings()`).
/// - Uses `@dynamicMemberLookup` so each key path resolves to a localized
///   `String` via `StringsKt.localized(...).localized()`.
/// - Compile-time safety is preserved because we still use `KeyPath`
///   to refer to generated properties on `Root`.
@dynamicMemberLookup
struct StringProxy<Root> {
    let root: Root

    /// Resolves a string resource on `root` and returns a localized `String`.
    ///
    /// Example:
    /// ```swift
    /// let title = Strings.home_tab_exercises
    /// ```
    ///
    /// - Parameter keyPath: Key path to a `ResourcesStringResource` on `root`.
    /// - Returns: Localized Swift `String` for the current system locale.
    subscript(dynamicMember keyPath: KeyPath<Root, StringResource>) -> String {
        let res = root[keyPath: keyPath]
        let desc = StringsKt.localized(res: res)
        return desc.localized()
    }
}

/// Global convenience instance for accessing shared string resources.
///
/// WHY
/// - Gives us a single, short entry point in SwiftUI views.
///
/// HOW
/// - Wraps `SharedRes.strings()` in a `StringProxy`.
/// - Usage in views: `Strings.home`, `Strings.profile`, `Strings.home_tab_exercises`, etc.
let Strings = StringProxy(root: SharedRes.strings())

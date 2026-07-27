import Foundation

// =============================================================================
// Block 7: the hardcoded German prototype string dictionary (PS) has been removed.
//
// All user-facing text in the journal/garden prototype now resolves through the
// shared moko-resources via the `Strings` proxy (see Utils/StringProxy.swift), so
// Android and iOS draw from a single source and stay in sync. This file is kept
// (empty) only to avoid touching the Xcode project references; it can be deleted
// from the project navigator when convenient.
// =============================================================================

import Foundation
import shared

// =============================================================================
// Dummy data for the Journal prototype (SIC-24).
// 1:1 translation of JournalModels.kt.
// =============================================================================

/// A single recent journal note shown in the "Letzte Notizen" list.
struct JournalNote: Identifiable {
    let id = UUID()
    let date: String
    let time: String
    let title: String
    let preview: String
}

/// Sample notes for the recent-notes section (prototype data).
let sampleNotes: [JournalNote] = [
    JournalNote(
        date: "13. Apr", time: "14:30",
        title: "Atem beruhigt",
        preview: "Kurze Notiz zu einer ruhigen Phase am Nachmittag."
    ),
    JournalNote(
        date: "11. Apr", time: "09:15",
        title: "Morgenroutine",
        preview: "Ein paar Minuten Bewegung haben beim Start geholfen."
    ),
    JournalNote(
        date: "8. Apr", time: "21:40",
        title: "Abendlicher Check-in",
        preview: "Gedanken sortiert und die wichtigsten Ausloeser festgehalten."
    ),
]

/// Entry counts per day for the last 30 days, oldest -> newest.
/// 0 = empty day, higher = more entries (denser/greener dot).
let sampleGardenDays: [Int] = [
    1, 0, 0, 1, 1, 0, 2, 0, 1, 0, 1, 1, 0, 0, 1,
    0, 1, 2, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1,
]

/// Total trees planted (derived sample value).
let sampleTreesPlanted: Int = sampleGardenDays.filter { $0 > 0 }.count

/// Context options for step 2 of the episode flow.
var placeOptions: [String] {
    [Strings.episode_place_home, Strings.episode_place_work,
     Strings.episode_place_public, Strings.episode_place_outside,
     Strings.episode_place_commute]
}

var activityOptions: [String] {
    [Strings.episode_activity_sleeping, Strings.episode_activity_working,
     Strings.episode_activity_sports, Strings.episode_activity_social,
     Strings.episode_activity_eating, Strings.episode_activity_traveling]
}

var bodySignalOptions: [String] {
    [Strings.episode_body_heart, Strings.episode_body_dizzy,
     Strings.episode_body_breathless, Strings.episode_body_shaking]
}

/// Mood faces (worst -> best).
let moodFaces: [String] = ["😣", "🙁", "😐", "🙂", "😄"]

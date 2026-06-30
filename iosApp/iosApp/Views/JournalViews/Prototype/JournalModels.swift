import Foundation
import Shared

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
    [PS.episode_place_home, PS.episode_place_work,
     PS.episode_place_public, PS.episode_place_outside,
     PS.episode_place_commute]
}

var activityOptions: [String] {
    [PS.episode_activity_sleeping, PS.episode_activity_working,
     PS.episode_activity_sports, PS.episode_activity_social,
     PS.episode_activity_eating, PS.episode_activity_traveling]
}

var bodySignalOptions: [String] {
    [PS.episode_body_heart, PS.episode_body_dizzy,
     PS.episode_body_breathless, PS.episode_body_shaking]
}

/// Mood faces (worst -> best).
let moodFaces: [String] = ["😣", "🙁", "😐", "🙂", "😄"]

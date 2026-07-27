import SwiftUI
import shared

// =============================================================================
// Capture flow — 1:1 translation of EpisodeCaptureFlow.kt.
// Opens on the entry-type chooser (panic vs journal), then branches.
// =============================================================================

/// The stages of the capture flow. The type chooser comes first, then a branch.
private enum CaptureStage {
    case typeChooser, panicIntensity, panicContext, panicReflection, journal, saved
}

/// Goal for the insights dataset.
private let insightsGoal = 30

/// The metadata the wizard collects for one entry before saving. Works for both
/// entry types: a panic entry fills the context/mood fields, a journal entry
/// usually only carries `content` and an optional `title`.
struct EpisodeDraftData {
    let content: String
    var type: String = "panic"
    var title: String? = nil
    let strength: Int?
    let places: [String]
    let activities: [String]
    let bodySignals: [String]
    let moodBefore: Int?
    let moodAfter: Int?
    /// When the entry happened (epoch millis).
    let createdAt: Int64

    /// A journal draft: text + optional title, no panic metadata.
    static func journal(content: String, title: String?, createdAt: Int64) -> EpisodeDraftData {
        EpisodeDraftData(
            content: content,
            type: "journal",
            title: title,
            strength: nil,
            places: [],
            activities: [],
            bodySignals: [],
            moodBefore: nil,
            moodAfter: nil,
            createdAt: createdAt
        )
    }

    /// Bridges to the shared `EpisodeDraft` KMP model for the controller.
    func toShared() -> EpisodeDraft {
        EpisodeDraft(
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type == "journal" ? .journal : .panic,
            title: title?.trimmingCharacters(in: .whitespacesAndNewlines),
            strength: strength.map { KotlinInt(int: Int32($0)) },
            places: places,
            activities: activities,
            bodySignals: bodySignals,
            moodBefore: moodBefore.map { KotlinInt(int: Int32($0)) },
            moodAfter: moodAfter.map { KotlinInt(int: Int32($0)) },
            createdAt: KotlinLong(longLong: createdAt)
        )
    }
}

/// Self-contained "Episode festhalten" wizard.
///
/// Holds the in-progress draft in UI state and saves the note to the database
/// on step 3. Returns the locked initial entry count + 1 on the confirmation screen.
struct EpisodeCaptureFlow: View {
    let entryCount: Int
    let onClose: () -> Void
    let onFinished: () -> Void
    let onViewGarden: () -> Void
    let onSaveEpisode: (EpisodeDraftData) -> Void
    /// Result of the just-saved entry's plant attempt, for the saved screen's
    /// conditional text (Block 3). Nil until planting completes.
    var plantResult: PlantResult?

    @State private var stage: CaptureStage = .typeChooser
    // The type + strength of the entry being saved, for the saved screen's impulse.
    @State private var savedIsJournal = false
    @State private var savedStrength: Int? = nil
    // The day the episode happened; defaults to today, past dates allowed.
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var hour: Int = Calendar.current.component(.hour, from: Date())
    @State private var minute: Int = Calendar.current.component(.minute, from: Date())
    @State private var strength: Float = 6
    @State private var places: [String] = []
    @State private var activities: [String] = []
    @State private var bodySignals: [String] = []
    @State private var note: String = ""
    @State private var moodBefore: Int = -1
    @State private var moodAfter: Int = -1

    @State private var finalEntryCount: Int

    init(entryCount: Int, onClose: @escaping () -> Void, onFinished: @escaping () -> Void, onViewGarden: @escaping () -> Void, onSaveEpisode: @escaping (EpisodeDraftData) -> Void, plantResult: PlantResult? = nil) {
        self.entryCount = entryCount
        self.onClose = onClose
        self.onFinished = onFinished
        self.onViewGarden = onViewGarden
        self.onSaveEpisode = onSaveEpisode
        self.plantResult = plantResult
        // Lock final entry count at init time to avoid double increments on DB sync
        _finalEntryCount = State(initialValue: entryCount + 1)
    }

    var body: some View {
        ZStack {
            IremiaColors.white.ignoresSafeArea()

            switch stage {
            case .typeChooser:
                EntryTypeChooserView(
                    onBack: onClose,
                    onPickPanic: { stage = .panicIntensity },
                    onPickJournal: { stage = .journal }
                )

            case .panicIntensity:
                EpisodeIntensityStepView(
                    selectedDate: $selectedDate,
                    hour: $hour,
                    minute: $minute,
                    strength: $strength,
                    onBack: { stage = .typeChooser },
                    onNext: { stage = .panicContext },
                    onSkip: { stage = .panicContext }
                )

            case .panicContext:
                EpisodeContextStepView(
                    places: $places,
                    activities: $activities,
                    bodySignals: $bodySignals,
                    onBack: { stage = .panicIntensity },
                    onNext: { stage = .panicReflection },
                    onSkip: { stage = .panicReflection }
                )

            case .panicReflection:
                EpisodeReflectionStepView(
                    note: $note,
                    moodBefore: $moodBefore,
                    moodAfter: $moodAfter,
                    onBack: { stage = .panicContext },
                    onSave: {
                        savedIsJournal = false
                        savedStrength = Int(strength)
                        onSaveEpisode(
                            EpisodeDraftData(
                                content: note,
                                type: "panic",
                                title: nil,
                                strength: Int(strength),
                                places: places,
                                activities: activities,
                                bodySignals: bodySignals,
                                moodBefore: moodBefore >= 0 ? moodBefore : nil,
                                moodAfter: moodAfter >= 0 ? moodAfter : nil,
                                createdAt: episodeTimestampMs(date: selectedDate, hour: hour, minute: minute)
                            )
                        )
                        stage = .saved
                    }
                )

            case .journal:
                JournalEntryView(
                    onBack: { stage = .typeChooser },
                    onSave: { title, content in
                        savedIsJournal = true
                        savedStrength = nil
                        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
                        onSaveEpisode(
                            EpisodeDraftData.journal(
                                content: content,
                                title: title.isEmpty ? nil : title,
                                createdAt: nowMs
                            )
                        )
                        stage = .saved
                    }
                )

            case .saved:
                EpisodeSavedScreenView(
                    entryCount: finalEntryCount,
                    goal: insightsGoal,
                    isJournal: savedIsJournal,
                    strength: savedStrength,
                    plantResult: plantResult,
                    onInsights: onFinished,
                    onHome: onFinished,
                    onViewGarden: onViewGarden
                )
            }
        }
    }
}

/// Combines a chosen day with an hour/minute into an epoch-millis timestamp in the
/// device's zone, so the entry lands on the chosen calendar day at the chosen time.
func episodeTimestampMs(date: Date, hour: Int, minute: Int) -> Int64 {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
    comps.hour = hour
    comps.minute = minute
    comps.second = 0
    let combined = Calendar.current.date(from: comps) ?? date
    return Int64(combined.timeIntervalSince1970 * 1000)
}

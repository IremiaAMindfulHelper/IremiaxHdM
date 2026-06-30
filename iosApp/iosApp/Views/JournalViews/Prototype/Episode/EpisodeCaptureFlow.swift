import SwiftUI

// =============================================================================
// "Episode festhalten" wizard — 1:1 translation of EpisodeCaptureFlow.kt.
// =============================================================================

/// The four stages of the wizard.
private enum EpisodeStep {
    case intensity, context, reflection, saved
}

/// Goal for the insights dataset.
private let insightsGoal = 30

/// The metadata the wizard collects for one episode before saving.
struct EpisodeDraftData {
    let content: String
    let strength: Int?
    let places: [String]
    let activities: [String]
    let bodySignals: [String]
    let moodBefore: Int?
    let moodAfter: Int?
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

    @State private var step: EpisodeStep = .intensity
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

    init(entryCount: Int, onClose: @escaping () -> Void, onFinished: @escaping () -> Void, onViewGarden: @escaping () -> Void, onSaveEpisode: @escaping (EpisodeDraftData) -> Void) {
        self.entryCount = entryCount
        self.onClose = onClose
        self.onFinished = onFinished
        self.onViewGarden = onViewGarden
        self.onSaveEpisode = onSaveEpisode
        // Lock final entry count at init time to avoid double increments on DB sync
        _finalEntryCount = State(initialValue: entryCount + 1)
    }

    var body: some View {
        ZStack {
            IremiaColors.white.ignoresSafeArea()

            switch step {
            case .intensity:
                EpisodeIntensityStepView(
                    hour: $hour,
                    minute: $minute,
                    strength: $strength,
                    onBack: onClose,
                    onNext: { step = .context },
                    onSkip: { step = .context }
                )

            case .context:
                EpisodeContextStepView(
                    places: $places,
                    activities: $activities,
                    bodySignals: $bodySignals,
                    onBack: { step = .intensity },
                    onNext: { step = .reflection },
                    onSkip: { step = .reflection }
                )

            case .reflection:
                EpisodeReflectionStepView(
                    note: $note,
                    moodBefore: $moodBefore,
                    moodAfter: $moodAfter,
                    onBack: { step = .context },
                    onSave: {
                        onSaveEpisode(
                            EpisodeDraftData(
                                content: note,
                                strength: Int(strength),
                                places: places,
                                activities: activities,
                                bodySignals: bodySignals,
                                moodBefore: moodBefore >= 0 ? moodBefore : nil,
                                moodAfter: moodAfter >= 0 ? moodAfter : nil
                            )
                        )
                        step = .saved
                    }
                )

            case .saved:
                EpisodeSavedScreenView(
                    entryCount: finalEntryCount,
                    goal: insightsGoal,
                    onInsights: onFinished,
                    onHome: onFinished,
                    onViewGarden: onViewGarden
                )
            }
        }
    }
}

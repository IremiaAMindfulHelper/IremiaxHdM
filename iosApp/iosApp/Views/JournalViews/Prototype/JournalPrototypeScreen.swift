import SwiftUI
import Shared

// =============================================================================
// Main Journal screen — 1:1 translation of JournalScreen.kt.
// Assembles the calendar, tree overview, recent notes, CTA, and modal sheets.
// =============================================================================

struct JournalPrototypeScreen: View {
    @StateObject private var notesObservable = NotesObservable()
    @StateObject private var gardenObservable = GardenObservable()
    @State private var selectedDate = Date()
    @State private var showCaptureFlow = false
    @State private var showGarden = false
    @State private var detailNote: NoteUI?

    private let today = Date()

    /// Map real database entry dates for the calendar dots.
    private var entryDates: Set<DateComponents> {
        let cal = Calendar(identifier: .iso8601)
        var dates: Set<DateComponents> = []
        for note in notesObservable.items {
            let date = Date(timeIntervalSince1970: Double(note.createdAt) / 1000.0)
            let comps = cal.dateComponents([.year, .month, .day], from: date)
            dates.insert(comps)
        }
        return dates
    }

    /// Map real entries to 25 tiles for the garden scene (one tree per entry).
    private var gardenEntries: [Int] {
        notesObservable.gardenEntries
    }

    private var treesPlanted: Int {
        notesObservable.entryCount
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Calendar
                    JournalCalendarView(
                        selectedDate: selectedDate,
                        today: today,
                        entryDates: entryDates,
                        onDateSelected: { selectedDate = $0 },
                        onTodayClick: { selectedDate = today }
                    )

                    VStack(spacing: 0) {
                        // Tree Overview
                        TreeOverviewCardView(
                            treesPlanted: gardenObservable.totalPlants,
                            tiles: gardenObservable.tiles,
                            onClick: { showGarden = true }
                        )

                        Spacer().frame(height: IremiaSpacing.sectionGap)

                        // Recent Notes
                        RecentNotesSectionView(
                            notes: notesObservable.items,
                            onAdd: { showCaptureFlow = true },
                            onNoteClick: { note in detailNote = note },
                            onDelete: { id in
                                notesObservable.delete(id: id)
                            }
                        )
                    }
                    .padding(.horizontal, IremiaSpacing.screenGutter)
                    .padding(.top, IremiaSpacing.s5)

                    Spacer().frame(height: IremiaSpacing.bottomNavClearance)
                }
            }
        }
        .background(IremiaColors.gray100.ignoresSafeArea())
        .fullScreenCover(isPresented: $showCaptureFlow) {
            EpisodeCaptureFlow(
                entryCount: notesObservable.entryCount,
                onClose: { showCaptureFlow = false },
                onFinished: { showCaptureFlow = false },
                onViewGarden: {
                    showCaptureFlow = false
                    showGarden = true
                },
                onSaveEpisode: { draft in
                    notesObservable.addEpisode(draft)
                }
            )
        }
        .fullScreenCover(isPresented: $showGarden) {
            GardenOverviewScreen(
                garden: gardenObservable,
                onClose: { showGarden = false }
            )
        }
        .sheet(item: $detailNote) { note in
            EpisodeDetailView(
                note: note,
                onClose: { detailNote = nil },
                onSave: { draft in
                    notesObservable.updateEpisode(id: note.id, draft)
                    detailNote = nil
                }
            )
        }
    }
}

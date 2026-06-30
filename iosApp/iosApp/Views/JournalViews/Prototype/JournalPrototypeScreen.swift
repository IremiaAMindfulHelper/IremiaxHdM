import SwiftUI
import Shared

// =============================================================================
// Main Journal screen — 1:1 translation of JournalScreen.kt.
// Assembles the calendar, tree overview, recent notes, CTA, and modal sheets.
// =============================================================================

struct JournalPrototypeScreen: View {
    @StateObject private var notesObservable = NotesObservable()
    @State private var selectedDate = Date()
    @State private var showCaptureFlow = false
    @State private var showGarden = false

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
                            treesPlanted: treesPlanted,
                            days: gardenEntries,
                            onClick: { showGarden = true }
                        )

                        Spacer().frame(height: IremiaSpacing.sectionGap)

                        // Recent Notes
                        RecentNotesSectionView(
                            notes: notesObservable.items,
                            onAdd: { showCaptureFlow = true },
                            onNoteClick: { _ in /* TODO: open note detail */ },
                            onDelete: { id in
                                notesObservable.delete(id: id)
                            }
                        )
                    }
                    .padding(.horizontal, IremiaSpacing.screenGutter)
                    .padding(.top, IremiaSpacing.s5)

                    Spacer().frame(height: IremiaSpacing.bottomNavClearance + 80)
                }
            }

            // Sticky CTA button
            VStack(spacing: 0) {
                PrimaryButton(
                    text: PS.journal_capture_cta,
                    action: { showCaptureFlow = true }
                )
                .padding(.horizontal, IremiaSpacing.screenGutter)
                .padding(.top, IremiaSpacing.s6)
                .padding(.bottom, IremiaSpacing.s4)
            }
            .background(
                IremiaColors.white
                    .opacity(0.95)
                    .ignoresSafeArea(.container, edges: .bottom)
            )
        }
        .background(IremiaColors.gray100.ignoresSafeArea())
        .fullScreenCover(isPresented: $showCaptureFlow) {
            EpisodeCaptureFlow(
                entryCount: notesObservable.entryCount,
                onClose: { showCaptureFlow = false },
                onFinished: { showCaptureFlow = false },
                onSaveNote: { content in
                    notesObservable.add(content: content)
                }
            )
        }
        .fullScreenCover(isPresented: $showGarden) {
            let cal = Calendar(identifier: .iso8601)
            GardenOverviewScreen(
                initialYear: cal.component(.year, from: selectedDate),
                initialMonth: cal.component(.month, from: selectedDate),
                entryCounts: gardenEntries,
                onClose: { showGarden = false }
            )
        }
    }
}

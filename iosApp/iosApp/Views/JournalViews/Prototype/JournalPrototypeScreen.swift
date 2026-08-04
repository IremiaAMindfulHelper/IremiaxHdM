import SwiftUI
import shared

// =============================================================================
// Main Journal screen — 1:1 translation of JournalScreen.kt.
// Assembles the calendar, tree overview, recent notes, CTA, and modal sheets.
// The notes observable and the capture flow are hosted by MainView (shell level),
// so the "+" FAB works on every tab and both share one controller instance.
// =============================================================================

struct JournalPrototypeScreen: View {
    /// Shared notes state, owned by MainView so FAB + journal use one instance.
    @ObservedObject var notesObservable: NotesObservable
    /// Shared garden state, owned by MainView so home + journal use one instance.
    @ObservedObject var gardenObservable: GardenObservable
    /// Opens the capture flow hosted at the shell level.
    var openCaptureFlow: () -> Void = {}
    /// Set true by MainView to open the garden from elsewhere in the app; this screen
    /// resets it after opening.
    ///
    /// NOTE: The capture flow's "view garden" no longer routes through here. It is
    /// presented directly from MainView so the garden appears in the same transition
    /// instead of briefly showing this screen first.
    @Binding var openGardenSignal: Bool

    @State private var selectedDate = Date()
    @State private var showGarden = false
    @State private var detailNote: NoteUI?
    // Entry pending deletion; drives the confirmation dialog (Block 1.4).
    @State private var pendingDelete: NoteUI?

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
                            onAdd: openCaptureFlow,
                            onNoteClick: { note in detailNote = note },
                            onDelete: { id in
                                // Ask before deleting (Block 1.4).
                                pendingDelete = notesObservable.items.first(where: { $0.id == id })
                            }
                        )
                    }
                    .padding(.horizontal, IremiaSpacing.screenGutter)
                    .padding(.top, IremiaSpacing.s5)

                    // Clears the tab bar *and* the "+" FAB above it, so the last
                    // entry can scroll past the button instead of stopping under it.
                    Spacer().frame(height: IremiaSpacing.scrollBottomClearance)
                }
            }
            // The "+" FAB now lives at the shell level (MainView), so it shows on
            // every tab; it opens the same capture flow via [openCaptureFlow].
        }
        .background(IremiaColors.gray100.ignoresSafeArea())
        // Open the garden when MainView signals it (from "view garden" in the flow).
        .onChange(of: openGardenSignal) { signal in
            if signal {
                showGarden = true
                openGardenSignal = false
            }
        }
        .fullScreenCover(isPresented: $showGarden) {
            GardenOverviewScreen(
                garden: gardenObservable,
                onClose: { showGarden = false },
                onOpenEntry: { entryId in
                    // Close the garden first, then open the entry for editing.
                    showGarden = false
                    detailNote = notesObservable.items.first(where: { $0.id == entryId })
                }
            )
        }
        .sheet(item: $detailNote) { note in
            EpisodeDetailView(
                note: note,
                onClose: { detailNote = nil },
                onSave: { draft in
                    notesObservable.updateEntry(id: note.id, draft)
                    detailNote = nil
                }
            )
        }
        // Delete confirmation (Block 1.4): nothing is removed until confirmed.
        .confirmationDialog(
            Strings.entry_delete_title,
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { note in
            Button(Strings.entry_delete_confirm, role: .destructive) {
                notesObservable.delete(id: note.id)
                pendingDelete = nil
            }
            Button(Strings.entry_delete_cancel, role: .cancel) {
                pendingDelete = nil
            }
        } message: { _ in
            Text(Strings.entry_delete_message)
        }
    }
}

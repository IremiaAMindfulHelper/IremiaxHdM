import Foundation

// Diese Klasse verwaltet den Zustand des Tagebuchs.
// Sie speichert alle Antworten, die ausgewählten Stimmungen,
// den Zustand der auf- und zugeklappten Bereiche sowie die Logik für das Anzeigen eines Tooltips.

final class JournalDiaryViewModel: ObservableObject {

    // Steuert, ob der Stift-Tooltip angezeigt wird.
    @Published var showPencilTooltip: Bool = false
    
    // Merkt sich intern, ob der Tooltip bereits einmal angezeigt wurde.
    private var didShowPencilTooltip: Bool = false

    // Speichert für jede Sektion, ob sie aufgeklappt (true) oder zugeklappt (false) ist.
    @Published var expanded: [Bool]

    // Antworten auf die einzelnen Tagebuchfragen.
    @Published var answer1: String = ""
    @Published var answer2: String = ""
    @Published var answer3: String = ""
    @Published var answer4: String = ""
    @Published var answer6: String = ""
    @Published var answer7: String = ""

    // Speichert die ausgewählte Stimmung für vier Tageszeiten.
    @Published var moodSelections: [String] = Array(repeating: "", count: 4)

    // Enthält alle Tagebuchfragen als feste Liste.
    let diaryQuestions: [String] = [
        "Gab es heute schwierige Momente für dich?",
        "Was ist gut gelaufen?",
        "Welche Sorgen möchtest du heute loslassen?",
        "Wie kannst du die Situation verbessern?",
        "Wie hat sich deine Stimmung im Laufe des Tages verändert?",
        "Wofür bist du heute dankbar?",
        "Gibt es etwas, das du morgen anders machen möchtest?"
    ]

    // Enthält die verfügbaren Emojis zur Auswahl für die Stimmung.
    let moodEmojis: [String] = ["😢", "🙁", "😐", "😊", "😄"]

    // Initialisiert das ViewModel und legt fest,
    // wie viele Sektionen es gibt und dass alle zu Beginn eingeklappt sind.
    init(sectionCount: Int = 7) {
        self.expanded = Array(repeating: false, count: sectionCount)
    }

    // Zeigt den Tooltip nur einmal an.
    // Wenn er bereits angezeigt wurde, passiert nichts.
    // Die Anzeige erfolgt leicht verzögert.
    func showTooltipOnce() {
        guard didShowPencilTooltip == false else { return }
        didShowPencilTooltip = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.showPencilTooltip = true
        }
    }

    // Blendet den Tooltip aus.
    func hideTooltip() {
        showPencilTooltip = false
    }
}

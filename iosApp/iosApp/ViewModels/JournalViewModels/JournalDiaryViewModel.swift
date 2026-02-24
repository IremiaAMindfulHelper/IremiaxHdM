import Foundation

final class JournalDiaryViewModel: ObservableObject {

    // Tooltip
    @Published var showPencilTooltip: Bool = false
    private var didShowPencilTooltip: Bool = false

    // Cards expanded/collapsed
    @Published var expanded: [Bool]

    // Antworten
    @Published var answer1: String = ""
    @Published var answer2: String = ""
    @Published var answer3: String = ""
    @Published var answer4: String = ""
    @Published var answer6: String = ""
    @Published var answer7: String = ""

    // Mood (4 Tageszeiten)
    @Published var moodSelections: [String] = Array(repeating: "", count: 4)

    // Fragen + Emojis (Konstanten im VM)
    let diaryQuestions: [String] = [
        "Gab es heute schwierige Momente für dich?",
        "Was ist gut gelaufen?",
        "Welche Sorgen möchtest du heute loslassen?",
        "Wie kannst du die Situation verbessern?",
        "Wie hat sich deine Stimmung im Laufe des Tages verändert?",
        "Wofür bist du heute dankbar?",
        "Gibt es etwas, das du morgen anders machen möchtest?"
    ]

    let moodEmojis: [String] = ["😢", "🙁", "😐", "😊", "😄"]

    init(sectionCount: Int = 7) {
        // ✅ Start: alle Karten eingeklappt
        self.expanded = Array(repeating: false, count: sectionCount)
    }

    func showTooltipOnce() {
        guard didShowPencilTooltip == false else { return }
        didShowPencilTooltip = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.showPencilTooltip = true
        }
    }

    func hideTooltip() {
        showPencilTooltip = false
    }
}

import SwiftUI

//-MARK: Variables & States
struct JournalDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var expanded: [Bool] = Array(repeating: true, count: 7)
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    @State private var answer3: String = ""
    @State private var answer4: String = ""
    @State private var answer5: [String] = Array(repeating: "", count: 4)
    @State private var answer6: String = ""
    @State private var answer7: String = ""
    
    private let diaryQuestions = [
        "Were there any difficult moments for you today?",
        "What went well?",
        "What worries do you want to let go of today?",
        "How can you improve the situation?",
        "How has your mood changed throughout the day?", // Emoji Question
        "What are you grateful for today?",
        "Is there anything you would like to do differently tomorrow?"
    ]
    
    private let moodEmojis = ["😢", "🙁", "😐", "😊", "😄"]
    
    var body: some View {  // Temp
        Text("Variablen fertig! 7 Fragen + Emoji-States.")
    }
}

//-MARK: Preview
    #Preview {
        NavigationView {
            JournalDiaryView()
        }
    }


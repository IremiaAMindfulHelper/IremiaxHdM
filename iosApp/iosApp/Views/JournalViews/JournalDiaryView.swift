import SwiftUI

// MARK: - Main View
struct JournalDiaryView: View {
    
    let onBack: () -> Void
    
    
    // MARK: - State Variables
    @State private var expanded: [Bool] = Array(repeating: true, count: 7)
    @State private var answer1: String = ""
    @State private var answer2: String = ""
    @State private var answer3: String = ""
    @State private var answer4: String = ""
    @State private var answer5: [String] = Array(repeating: "", count: 4) // 4 times of day (Morning, Midday, Evening, Night)
    @State private var answer6: String = ""
    @State private var answer7: String = ""
    
    // MARK: - Data
    private let diaryQuestions = [
        "Were there any difficult moments for you today?",
        "What went well?",
        "What worries do you want to let go of today?",
        "How can you improve the situation?",
        "How has your mood changed throughout the day?",
        "What are you grateful for today?",
        "Is there anything you would like to do differently tomorrow?"
    ]
    
    private let moodEmojis = ["😢", "🙁", "😐", "😊", "😄"]
        
    // MARK: - Body
    var body: some View {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 12) {
                        CategoryCard(title: diaryQuestions[0], dateText: nil, isExpanded: $expanded[0]) {
                            DiaryContent(text: $answer1)
                        }
                        
                        CategoryCard(title: diaryQuestions[1], dateText: nil, isExpanded: $expanded[1]) {
                            DiaryContent(text: $answer2)
                        }
                        
                        CategoryCard(title: diaryQuestions[2], dateText: nil, isExpanded: $expanded[2]) {
                            DiaryContent(text: $answer3)
                        }
                        
                        CategoryCard(title: diaryQuestions[3], dateText: nil, isExpanded: $expanded[3]) {
                            DiaryContent(text: $answer4)
                        }
                        
                        // Question 5: Emoji mood picker
                        CategoryCard(title: diaryQuestions[4], dateText: nil, isExpanded: $expanded[4]) {
                            VStack(alignment: .leading, spacing: 14) {
                                MoodPickerRow(title: "Morning ☀️", emojis: moodEmojis, selection: $answer5[0])
                                MoodPickerRow(title: "Midday 🌤", emojis: moodEmojis, selection: $answer5[1])
                                MoodPickerRow(title: "Evening 🌆", emojis: moodEmojis, selection: $answer5[2])
                                MoodPickerRow(title: "Night 🌙", emojis: moodEmojis, selection: $answer5[3])
                            }
                        }
                        
                        CategoryCard(title: diaryQuestions[5], dateText: nil, isExpanded: $expanded[5]) {
                            DiaryContent(text: $answer6)
                        }
                        
                        CategoryCard(title: diaryQuestions[6], dateText: nil, isExpanded: $expanded[6]) {
                            DiaryContent(text: $answer7)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    
                    // MARK: Submit Button
                    VStack(spacing: 10) {
                        Button {
                            onBack()
                        } label: {
                            Text("Eintrag abschließen")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 24)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 80) // Adjust button width here
                    .padding(.top, 6)
                    .padding(.bottom, 18)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .navigationTitle("Tagebuch")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { onBack() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Edit Fragenkatalog") // TODO: Navigate to question catalog editor
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.black)
                            .imageScale(.large)
                    }
                }
            }
        }
    }

// MARK: - Diary Content
private struct DiaryContent: View {
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedTextField(placeholder: "…", text: $text)
        }
        .padding(.top, 8)
    }
}

// MARK: - Mood Picker Row
private struct MoodPickerRow: View {
    let title: String
    let emojis: [String]
    @Binding var selection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            
            HStack(spacing: 10) {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        selection = emoji
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selection == emoji ? Color.black.opacity(0.2) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selection == emoji ? Color.black : Color.clear, lineWidth: 2)
                                )
                                .frame(width: 50, height: 40)
                            
                            Text(emoji)
                                .font(.system(size: 24))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Category Card
private struct CategoryCard<Content: View>: View {
    let title: String
    let dateText: String?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: Content
    
    private let sideInset: CGFloat = 40 // Dark gray panel width
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(.black)
                        
                        if let dateText {
                            Text(dateText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, sideInset + 12)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                content
                    .padding(.trailing, sideInset)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.4, green: 0.4, blue: 0.4))
                .frame(width: sideInset),
            alignment: .trailing
        )
        .overlay(
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
                .padding(.trailing, 12)
                .padding(.top, 12),
            alignment: .topTrailing
        )
    }
}

// MARK: - Rounded Text Field
private struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .lineLimit(1...6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black, lineWidth: 1)
            )
            .background(Color.white)
    }
}

// MARK: - Preview
#Preview {
    JournalDiaryView(onBack: {})
}

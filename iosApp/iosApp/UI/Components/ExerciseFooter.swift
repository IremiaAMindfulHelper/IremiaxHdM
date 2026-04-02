import SwiftUI

/// A standardized footer for exercises.
/// Provides a right-aligned skip button to navigate through the exercise flow.
struct ExerciseFooter: View {
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    /// The action to be executed when the skip button is tapped.
    var action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            
            Button(action: action) {
                HStack(spacing: 4) {
                    Text("Überspringen")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(petrolColor)
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 40)
    }
}

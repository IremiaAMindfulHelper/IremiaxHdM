import SwiftUI
import shared

/// A specialized icon view representing a single step in the SOS workflow.
/// Dynamically adjusts its size, color, and label based on its active or completed state.
struct StepIconView: View {
    /// The step data containing the icon name and display title.
    let step: SOSStep
    /// Indicates if this step is currently being performed by the user.
    let isActive: Bool
    /// Indicates if this step has already been finished.
    let isCompleted: Bool
    /// The primary theme color for the branding.
    let petrolColor: SwiftUI.Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // MARK: - BACKGROUND CIRCLE
                Circle()
                    .fill(isCompleted ? petrolColor : Color.white)
                    .frame(width: isActive ? 60 : 40, height: isActive ? 60 : 40)
                    .shadow(color: .black.opacity(isActive ? 0.15 : 0), radius: isActive ? 10 : 0)
                
                // MARK: - BORDER
                Circle()
                    .stroke(isActive ? petrolColor : (isCompleted ? Color.clear : Color.gray.opacity(0.2)), lineWidth: isActive ? 2.5 : 1)
                    .frame(width: isActive ? 60 : 40, height: isActive ? 60 : 40)
                
                // MARK: - ICON
                Image(systemName: step.icon)
                    .font(.system(size: isActive ? 28 : 18, weight: isActive ? .bold : .medium))
                    .foregroundColor(isCompleted ? .white : (isActive ? petrolColor : .gray))
            }
            .frame(width: 70, height: 70)
            
            // NOTE: We use a placeholder space if not active to keep the horizontal alignment of the progress bar stable.
            if isActive {
                Text(step.name)
                    .font(.caption.bold())
                    .foregroundColor(petrolColor)
                    .transition(.opacity)
            } else {
                Text(" ").font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// A horizontal line connecting two step icons in the progress bar.
/// Animates its filling state based on the progress of the flow.
struct ProgressConnector: View {
    /// Indicates if the step preceding this connector is finished.
    let isCompleted: Bool
    let petrolColor: SwiftUI.Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 25, height: 2)
            
            // Active progress fill
            Rectangle()
                .fill(petrolColor)
                .frame(width: isCompleted ? 25 : 0, height: 2)
        }
        // NOTE: Offset adjustment to align the connector vertically with the center of the circles.
        .padding(.bottom, 24)
    }
}

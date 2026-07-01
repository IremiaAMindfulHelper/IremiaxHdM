import SwiftUI
import Shared

// =============================================================================
// "Episode festhalten" wizard step screens — 1:1 translation of
// EpisodeStepScreens.kt (469 lines). All strings via moko-resources.
// =============================================================================

// MARK: - Step Scaffold

/// Shared chrome for a wizard step: back + progress bar, title, content, actions.
struct EpisodeStepScaffold<Content: View>: View {
    let stepIndex: Int
    let stepCount: Int
    let title: String
    let onBack: () -> Void
    let primaryLabel: String
    let onPrimary: () -> Void
    var subtitle: String? = nil
    var primaryTrailingIcon: String? = nil
    var secondaryLabel: String? = nil
    var onSecondary: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Header: back + progress
            HStack(spacing: 0) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(IremiaColors.ink900)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(PS.nav_back)

                GeometryReader { geo in
                    Capsule()
                        .fill(IremiaColors.gray200)
                        .frame(height: 4)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(IremiaColors.teal700)
                                .frame(width: geo.size.width * CGFloat(stepIndex) / CGFloat(stepCount), height: 4)
                        }
                }
                .frame(height: 4)

                Spacer().frame(width: 12)

                Text("\(stepIndex)/\(stepCount)")
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray500)
            }

            Spacer().frame(height: IremiaSpacing.s5)
            Text(title)
                .font(IremiaText.h1)
                .foregroundColor(IremiaColors.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let sub = subtitle {
                Spacer().frame(height: IremiaSpacing.s2)
                Text(sub)
                    .font(IremiaText.body)
                    .foregroundColor(IremiaColors.gray500)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer().frame(height: IremiaSpacing.s5)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer().frame(height: IremiaSpacing.s3)

            PrimaryButton(
                text: primaryLabel,
                action: onPrimary,
                trailingIcon: primaryTrailingIcon
            )

            if let secLabel = secondaryLabel, let secAction = onSecondary {
                Spacer().frame(height: IremiaSpacing.s1)
                SecondaryTextButton(text: secLabel, action: secAction)
            }
        }
        .padding(.horizontal, IremiaSpacing.screenGutter)
        .padding(.top, IremiaSpacing.s2)
        .padding(.bottom, IremiaSpacing.s3)
    }
}

// MARK: - Step 1: Intensity

struct EpisodeIntensityStepView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var strength: Float
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void

    @State private var showTimePicker = false

    var body: some View {
        EpisodeStepScaffold(
            stepIndex: 1,
            stepCount: 3,
            title: PS.episode_title,
            onBack: onBack,
            primaryLabel: PS.episode_next,
            onPrimary: onNext,
            subtitle: PS.episode_subtitle,
            primaryTrailingIcon: "arrow.right",
            secondaryLabel: PS.episode_skip_step,
            onSecondary: onSkip
        ) {
            Text(PS.episode_when)
                .font(IremiaText.cardTitle)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s2)

            // Time picker trigger
            Button { showTimePicker = true } label: {
                HStack {
                    let timeStr = String(format: "%02d:%02d", hour, minute)
                    Text(PS.episode_today_time.replacingOccurrences(of: "%1$s", with: timeStr))
                        .font(IremiaText.body)
                        .foregroundColor(IremiaColors.ink)
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 20))
                        .foregroundColor(IremiaColors.gray500)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: IremiaShapes.field, style: .continuous)
                        .stroke(IremiaColors.gray300, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showTimePicker) {
                TimePickerSheet(hour: $hour, minute: $minute, isPresented: $showTimePicker)
            }

            Spacer().frame(height: IremiaSpacing.s6)

            HStack {
                Text(PS.episode_strength_label)
                    .font(IremiaText.cardTitle)
                    .foregroundColor(IremiaColors.ink)
                Spacer()
                Text("\(Int(strength))")
                    .font(IremiaText.h1)
                    .foregroundColor(IremiaColors.teal700)
            }

            Slider(value: $strength, in: 1...10, step: 1)
                .tint(IremiaColors.teal700)

            HStack {
                Text(PS.episode_strength_low)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray400)
                Spacer()
                Text(PS.episode_strength_high)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray400)
            }
        }
    }
}

// MARK: - Step 2: Context

struct EpisodeContextStepView: View {
    @Binding var places: [String]
    @Binding var activities: [String]
    @Binding var bodySignals: [String]
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        EpisodeStepScaffold(
            stepIndex: 2,
            stepCount: 3,
            title: PS.episode_context_title,
            onBack: onBack,
            primaryLabel: PS.episode_next,
            onPrimary: onNext,
            primaryTrailingIcon: "arrow.right",
            secondaryLabel: PS.episode_skip_step,
            onSecondary: onSkip
        ) {
            ChipGroupView(title: PS.episode_context_where, options: placeOptions, selected: $places)
            Spacer().frame(height: IremiaSpacing.s5)
            ChipGroupView(title: PS.episode_context_activity, options: activityOptions, selected: $activities)
            Spacer().frame(height: IremiaSpacing.s5)
            ChipGroupView(title: PS.episode_context_body, options: bodySignalOptions, selected: $bodySignals)
        }
    }
}

// MARK: - Step 3: Reflection

struct EpisodeReflectionStepView: View {
    @Binding var note: String
    @Binding var moodBefore: Int
    @Binding var moodAfter: Int
    let onBack: () -> Void
    let onSave: () -> Void

    var body: some View {
        EpisodeStepScaffold(
            stepIndex: 3,
            stepCount: 3,
            title: PS.episode_reflection_title,
            onBack: onBack,
            primaryLabel: PS.episode_reflection_save,
            onPrimary: onSave,
            secondaryLabel: PS.episode_reflection_save_no_note,
            onSecondary: onSave
        ) {
            Text(PS.episode_reflection_prompt)
                .font(IremiaText.cardTitle)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s2)

            TextEditor(text: $note)
                .font(IremiaText.body)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(IremiaColors.white)
                .clipShape(RoundedRectangle(cornerRadius: IremiaShapes.field, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: IremiaShapes.field, style: .continuous)
                        .stroke(IremiaColors.gray300, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if note.isEmpty {
                        Text(PS.episode_reflection_placeholder)
                            .font(IremiaText.body)
                            .foregroundColor(IremiaColors.gray400)
                            .padding(.top, 20)
                            .padding(.leading, 16)
                            .allowsHitTesting(false)
                    }
                }

            Spacer().frame(height: IremiaSpacing.s6)

            Text(PS.episode_mood_title)
                .font(IremiaText.cardTitle)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s3)
            MoodRowView(label: PS.episode_mood_before, selectedIndex: $moodBefore)
            Spacer().frame(height: IremiaSpacing.s3)
            MoodRowView(label: PS.episode_mood_after, selectedIndex: $moodAfter)
        }
    }
}

// MARK: - Saved Screen

struct EpisodeSavedScreenView: View {
    let entryCount: Int
    let goal: Int
    let onInsights: () -> Void
    let onHome: () -> Void
    var onViewGarden: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: IremiaSpacing.s6)

            // Growth animation so the user sees their new tree grow after saving.
            GrowthLottieView(asset: .treeGrow, speed: 4)
                .frame(width: 240, height: 240)

            Spacer().frame(height: IremiaSpacing.s4)

            Text(PS.episode_saved_title)
                .font(IremiaText.h1)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s2)

            Text(PS.episode_saved_body)
                .font(IremiaText.body)
                .foregroundColor(IremiaColors.gray500)
                .multilineTextAlignment(.center)

            Spacer().frame(height: IremiaSpacing.s5)

            // Tree badge
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 18))
                    .foregroundColor(IremiaColors.garden700)
                Text(PS.episode_saved_tree_badge)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.garden900)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(IremiaColors.garden100))

            Spacer().frame(height: IremiaSpacing.s6)

            // Progress card
            IremiaCard {
                VStack(alignment: .leading, spacing: 0) {
                    Text(PS.episode_saved_dataset_title)
                        .font(IremiaText.eyebrow)
                        .foregroundColor(IremiaColors.teal700)
                        .tracking(0.06 * 12)

                    Spacer().frame(height: IremiaSpacing.s2)

                    HStack(alignment: .bottom, spacing: 8) {
                        Text("\(entryCount)")
                            .font(IremiaText.numXl)
                            .foregroundColor(IremiaColors.ink)
                        Text(PS.episode_saved_entries)
                            .font(IremiaText.body)
                            .foregroundColor(IremiaColors.gray600)
                            .padding(.bottom, 6)
                    }

                    Spacer().frame(height: IremiaSpacing.s2)

                    Text(PS.episode_saved_goal_hint.replacingOccurrences(of: "%1$d", with: "\(goal)"))
                        .font(IremiaText.caption)
                        .foregroundColor(IremiaColors.gray500)

                    Spacer().frame(height: IremiaSpacing.s3)

                    ProgressView(value: Double(entryCount), total: Double(goal))
                        .tint(IremiaColors.teal700)
                        .frame(height: 6)

                    Spacer().frame(height: IremiaSpacing.s1)

                    Text("\(entryCount) / \(goal)")
                        .font(IremiaText.caption)
                        .foregroundColor(IremiaColors.gray400)
                }
            }

            Spacer()

            PrimaryButton(
                text: PS.episode_saved_view_garden,
                action: onViewGarden,
                trailingIcon: "leaf.fill"
            )

            Spacer().frame(height: IremiaSpacing.s1)

            SecondaryTextButton(text: PS.episode_saved_insights, action: onInsights)

            Spacer().frame(height: IremiaSpacing.s1)

            SecondaryTextButton(text: PS.episode_saved_home, action: onHome)
        }
        .padding(.horizontal, IremiaSpacing.screenGutter)
        .padding(.vertical, IremiaSpacing.s5)
    }
}

// MARK: - Chip Group

private struct ChipGroupView: View {
    let title: String
    let options: [String]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(IremiaText.cardTitle)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s3)

            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    ChoiceChip(
                        label: option,
                        selected: selected.contains(option)
                    ) {
                        if let idx = selected.firstIndex(of: option) {
                            selected.remove(at: idx)
                        } else {
                            selected.append(option)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Mood Row

private struct MoodRowView: View {
    let label: String
    @Binding var selectedIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(IremiaText.caption)
                .foregroundColor(IremiaColors.gray500)

            Spacer().frame(height: IremiaSpacing.s2)

            HStack(spacing: 8) {
                ForEach(Array(moodFaces.enumerated()), id: \.offset) { index, face in
                    let isSelected = index == selectedIndex
                    Button { selectedIndex = index } label: {
                        Text(face)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: IremiaShapes.cardSm, style: .continuous)
                                    .fill(isSelected ? IremiaColors.teal50 : IremiaColors.gray100)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: IremiaShapes.cardSm, style: .continuous)
                                    .stroke(isSelected ? IremiaColors.teal700 : Color.clear, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Time Picker Sheet

private struct TimePickerSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var isPresented: Bool

    @State private var selectedDate: Date

    init(hour: Binding<Int>, minute: Binding<Int>, isPresented: Binding<Bool>) {
        _hour = hour
        _minute = minute
        _isPresented = isPresented
        var comps = DateComponents()
        comps.hour = hour.wrappedValue
        comps.minute = minute.wrappedValue
        _selectedDate = State(initialValue: Calendar.current.date(from: comps) ?? Date())
    }

    var body: some View {
        NavigationView {
            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(PS.dialog_cancel) { isPresented = false }
                            .foregroundColor(IremiaColors.gray500)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(PS.dialog_ok) {
                            let cal = Calendar.current
                            hour = cal.component(.hour, from: selectedDate)
                            minute = cal.component(.minute, from: selectedDate)
                            isPresented = false
                        }
                        .foregroundColor(IremiaColors.teal700)
                    }
                }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Flow Layout (replacement for FlowRow)

/// Simple wrapping layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, offset) in result.offsets.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }

    private struct LayoutResult {
        var offsets: [CGPoint]
        var size: CGSize
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var offsets: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            offsets.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return LayoutResult(offsets: offsets, size: CGSize(width: maxX, height: y + rowHeight))
    }
}

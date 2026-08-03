import SwiftUI
import shared

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
                .accessibilityLabel(Strings.nav_back)

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
    @Binding var selectedDate: Date
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var strength: Float
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void

    @State private var showDatePicker = false
    @State private var showTimePicker = false

    private var dateLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "d. MMM yyyy"
        return f.string(from: selectedDate)
    }

    var body: some View {
        EpisodeStepScaffold(
            stepIndex: 1,
            stepCount: 3,
            title: Strings.episode_title,
            onBack: onBack,
            primaryLabel: Strings.episode_next,
            onPrimary: onNext,
            subtitle: Strings.episode_subtitle,
            primaryTrailingIcon: "arrow.right",
            secondaryLabel: Strings.episode_skip_step,
            onSecondary: onSkip
        ) {
            Text(Strings.episode_when)
                .font(IremiaText.cardTitle)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s2)

            // Date picker trigger — pick the day (today or past, no future).
            Button { showDatePicker = true } label: {
                fieldRow(text: dateLabel, icon: "calendar")
            }
            .buttonStyle(.plain)

            Spacer().frame(height: IremiaSpacing.s2)

            // Time picker trigger — opens after the date is chosen.
            Button { showTimePicker = true } label: {
                fieldRow(text: String(format: "%02d:%02d", hour, minute), icon: "clock")
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selectedDate: $selectedDate, isPresented: $showDatePicker) {
                    // After choosing the date, prompt for the time next.
                    showTimePicker = true
                }
            }
            .sheet(isPresented: $showTimePicker) {
                TimePickerSheet(hour: $hour, minute: $minute, isPresented: $showTimePicker)
            }

            Spacer().frame(height: IremiaSpacing.s6)

            HStack {
                Text(Strings.episode_strength_label)
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
                Text(Strings.episode_strength_low)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray400)
                Spacer()
                Text(Strings.episode_strength_high)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray400)
            }
        }
    }

    /// A bordered field row with a label and a trailing SF symbol.
    private func fieldRow(text: String, icon: String) -> some View {
        HStack {
            Text(text)
                .font(IremiaText.body)
                .foregroundColor(IremiaColors.ink)
            Spacer()
            Image(systemName: icon)
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
            title: Strings.episode_context_title,
            onBack: onBack,
            primaryLabel: Strings.episode_next,
            onPrimary: onNext,
            primaryTrailingIcon: "arrow.right",
            secondaryLabel: Strings.episode_skip_step,
            onSecondary: onSkip
        ) {
            ChipGroupView(title: Strings.episode_context_where, options: placeOptions, selected: $places)
            Spacer().frame(height: IremiaSpacing.s5)
            ChipGroupView(title: Strings.episode_context_activity, options: activityOptions, selected: $activities)
            Spacer().frame(height: IremiaSpacing.s5)
            ChipGroupView(title: Strings.episode_context_body, options: bodySignalOptions, selected: $bodySignals)
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
            title: Strings.episode_reflection_title,
            onBack: onBack,
            primaryLabel: Strings.episode_reflection_save,
            onPrimary: onSave,
            secondaryLabel: Strings.episode_reflection_save_no_note,
            onSecondary: onSave
        ) {
            Text(Strings.episode_reflection_prompt)
                .font(IremiaText.cardTitle)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s2)

            TextEditor(text: $note)
                .font(IremiaText.body)
                // Explicit ink color so the entered text is always dark — without
                // this the editor inherits a system color that renders white/invisible
                // on-device against the white field background.
                .foregroundColor(IremiaColors.ink)
                .tint(IremiaColors.teal700)
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
                        Text(Strings.episode_reflection_placeholder)
                            .font(IremiaText.body)
                            .foregroundColor(IremiaColors.gray400)
                            .padding(.top, 20)
                            .padding(.leading, 16)
                            .allowsHitTesting(false)
                    }
                }

            Spacer().frame(height: IremiaSpacing.s6)

            Text(Strings.episode_mood_title)
                .font(IremiaText.cardTitle)
                .foregroundColor(IremiaColors.ink)

            Spacer().frame(height: IremiaSpacing.s3)
            MoodRowView(label: Strings.episode_mood_before, selectedIndex: $moodBefore)
            Spacer().frame(height: IremiaSpacing.s3)
            MoodRowView(label: Strings.episode_mood_after, selectedIndex: $moodAfter)
        }
    }
}

// MARK: - Saved Screen

struct EpisodeSavedScreenView: View {
    let entryCount: Int
    let goal: Int
    var isJournal: Bool = false
    var strength: Int? = nil
    var plantResult: PlantResult? = nil
    let onInsights: () -> Void
    let onHome: () -> Void
    var onViewGarden: () -> Void = {}

    /// Growth animation size on this screen. Large enough to be a clear focal
    /// point above the title, while still leaving room for the content below.
    private let treeSize: CGFloat = 150

    /// Badge text: what happened in the garden (conditional on plan 6.2).
    private var badgeText: String {
        let newlyPlanted = plantResult?.planted ?? true
        if !newlyPlanted { return isJournal ? Strings.episode_saved_already_flower : Strings.episode_saved_already_tree }
        return isJournal ? Strings.episode_saved_flower_badge : Strings.episode_saved_tree_badge
    }

    /// Gentle impulse text (placeholder, no real exercise).
    private var impulseText: String {
        if isJournal { return Strings.saved_impulse_journal }
        return (strength ?? 0) >= 7 ? Strings.saved_impulse_panic_high : Strings.saved_impulse_panic_low
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Balances the block vertically instead of letting it cling to the top,
                // and keeps the tree clear of the status bar / Dynamic Island.
                Spacer(minLength: IremiaSpacing.s3)

                // Growth animation in the normal layout flow (its own row), so it sits
                // cleanly above the title with real spacing instead of overlapping it.
                // NOTE: speed 4 matches Android's EpisodeGrowthAnimation (speed = 4f
                // over the same 0.2–1 clip), so the saved screen plays identically.
                GrowthLottieView(asset: .treeGrow, speed: 4)
                    .frame(width: treeSize, height: treeSize)

                // --- Top section: all texts consistently centered, room to breathe.
                Spacer().frame(height: IremiaSpacing.s5)

                Text(Strings.episode_saved_title)
                    .font(IremiaText.h1)
                    .foregroundColor(IremiaColors.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: IremiaSpacing.s3)

                Text(Strings.episode_saved_body)
                    .font(IremiaText.body)
                    .foregroundColor(IremiaColors.gray500)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: IremiaSpacing.s4)

                // Impulse text: a gentle, non-directive suggestion matched to the entry.
                Text(impulseText)
                    .font(IremiaText.body)
                    .foregroundColor(IremiaColors.teal700)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: IremiaSpacing.s5)

                // Garden badge (tree / flower bed / garden full)
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18))
                        .foregroundColor(IremiaColors.garden700)
                    Text(badgeText)
                        .font(IremiaText.caption)
                        .foregroundColor(IremiaColors.garden900)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(IremiaColors.garden100))

                Spacer().frame(height: IremiaSpacing.s6)

                // --- Middle section: the progress tracker as a quiet, clearly
                // bounded card (subtle gray surface + fine border); content stays
                // left-aligned.
                VStack(alignment: .leading, spacing: 0) {
                    Text(Strings.episode_saved_dataset_title)
                        .font(IremiaText.eyebrow)
                        .foregroundColor(IremiaColors.teal700)
                        .tracking(0.06 * 12)

                    Spacer().frame(height: IremiaSpacing.s2)

                    HStack(alignment: .bottom, spacing: 8) {
                        Text("\(entryCount)")
                            .font(IremiaText.numXl)
                            .foregroundColor(IremiaColors.ink)
                        Text(Strings.episode_saved_entries)
                            .font(IremiaText.body)
                            .foregroundColor(IremiaColors.gray600)
                            .padding(.bottom, 6)
                    }

                    Spacer().frame(height: IremiaSpacing.s2)

                    Text(Strings.episode_saved_goal_hint.replacingOccurrences(of: "%1$d", with: "\(goal)"))
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
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: IremiaShapes.card, style: .continuous)
                        .fill(IremiaColors.gray50)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: IremiaShapes.card, style: .continuous)
                        .stroke(IremiaColors.gray200, lineWidth: 1)
                )

                // --- Bottom section: one primary action, one quiet text link.
                Spacer(minLength: IremiaSpacing.s5)

                PrimaryButton(
                    text: Strings.episode_saved_view_garden,
                    action: onViewGarden,
                    trailingIcon: "leaf.fill"
                )

                Spacer().frame(height: IremiaSpacing.s3)

                SecondaryTextButton(text: Strings.episode_saved_insights, action: onInsights)
            }
            .padding(.horizontal, IremiaSpacing.screenGutter)
            .padding(.vertical, IremiaSpacing.s5)

            // Close ("back to home") as an X in the top-right corner instead of a
            // third stacked button, decluttering the action area.
            Button(action: onHome) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(IremiaColors.ink900)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Strings.nav_close)
            .padding(.trailing, IremiaSpacing.s2)
        }
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
                        Button(Strings.dialog_cancel) { isPresented = false }
                            .foregroundColor(IremiaColors.gray500)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(Strings.dialog_ok) {
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

// MARK: - Date Picker Sheet

/// Graphical date picker for the day an episode happened. Only today or earlier
/// dates are selectable; confirming calls [onConfirm] so the caller can chain to
/// the time picker.
private struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    let onConfirm: () -> Void

    @State private var draftDate: Date

    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>, onConfirm: @escaping () -> Void) {
        _selectedDate = selectedDate
        _isPresented = isPresented
        self.onConfirm = onConfirm
        _draftDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        NavigationView {
            DatePicker(
                "",
                selection: $draftDate,
                in: ...Date(), // no future dates
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.dialog_cancel) { isPresented = false }
                        .foregroundColor(IremiaColors.gray500)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.dialog_ok) {
                        selectedDate = Calendar.current.startOfDay(for: draftDate)
                        isPresented = false
                        onConfirm()
                    }
                    .foregroundColor(IremiaColors.teal700)
                }
            }
        }
        .presentationDetents([.medium, .large])
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

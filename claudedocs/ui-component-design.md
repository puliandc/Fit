# iOS Fit App V0.2 - UI Component Design Specification

## Overview

This document defines the complete UI component hierarchy for the iOS Fit app V0.2, focusing on React-level animation smoothness and intuitive workout management interface.

## 1. Component Hierarchy

### 1.1 Main Navigation Structure
```
FitApp
├── MainTabView
│   ├── WorkoutPlansTab
│   │   └── WorkoutPlansView
│   ├── ActiveWorkoutTab
│   │   └── ActiveWorkoutView
│   ├── HistoryTab
│   │   └── WorkoutHistoryView
│   └── SettingsTab
│       └── SettingsView
└── Modal Views
    ├── WorkoutPlanEditorView
    ├── ExerciseEditorView
    ├── SetEditorView
    └── RestTimerView
```

### 1.2 Workout Plans Module
```
WorkoutPlansView
├── HeaderSection
│   ├── Title: "训练计划"
│   └── AddButton (+)
├── WorkoutPlanListView
│   ├── WorkoutPlanCardView (repeated)
│   │   ├── PlanName
│   │   ├── ExerciseCount
│   │   ├── CreatedDate
│   │   └── ActionButtons
│   │       ├── EditButton
│   │       ├── StartButton
│   │       └── DeleteButton
└── EmptyStateView (when no plans)
    ├── Icon: dumbbell
    ├── Title: "开始你的第一个训练计划"
    └── CreateButton
```

### 1.3 Workout Plan Detail Module
```
WorkoutPlanDetailView
├── HeaderSection
│   ├── BackButton
│   ├── PlanName (editable)
│   └── ActionButtons
│       ├── EditButton
│       ├── StartButton
│       └── DeleteButton
├── ExerciseListView
│   ├── ExerciseHeaderView
│   │   ├── "训练动作"
│   │   └── AddExerciseButton
│   └── ExerciseCardView (repeated)
│       ├── DragHandle
│       ├── ExerciseInfo
│       │   ├── ExerciseName
│       │   ├── TotalSets
│       │   └── ExerciseRestTime
│       └── SetListView
│           └── SetRowView (repeated)
│               ├── SetTypeIcon
│               ├── SetTypeInfo
│               │   ├── SetType
│               │   ├── Reps × Weight
│               │   └── SetRestTime
│               └── ActionButtons
│                   ├── EditButton
│                   └── DeleteButton
└── FooterSection
    ├── TotalWorkoutTime
    └── SaveButton
```

### 1.4 Active Workout Module
```
ActiveWorkoutView
├── HeaderSection
│   ├── ProgressIndicator
│   ├── CurrentExerciseName
│   └── PauseButton
├── MainContentArea
│   ├── CurrentSetView
│   │   ├── SetTypeBanner
│   │   ├── ExerciseInfo
│   │   │   ├── ExerciseName
│   │   │   └── SetNumber
│   │   ├── TargetInfo
│   │   │   ├── TargetReps
│   │   │   └── TargetWeight
│   │   └── InputSection
│   │       ├── RepsInput
│   │       ├── WeightInput
│   │       └── CompleteButton
│   └── RestTimerView (when resting)
│       ├── TimerRing
│       ├── TimeRemaining
│       ├── SkipRestButton
│       └── PauseTimerButton
└── BottomSection
    ├── NextExercisePreview
    │   ├── NextExerciseName
    │   └── NextSetInfo
    └── EndWorkoutButton
```

## 2. Component Design Specifications

### 2.1 WorkoutPlanCardView Component

```swift
struct WorkoutPlanCardView: View {
    let workoutPlan: WorkoutPlan
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutPlan.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("\(workoutPlan.exercises.count) 个动作")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(formatDate(workoutPlan.createdDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 12) {
                    ActionButton(
                        icon: "play.fill",
                        color: .green,
                        action: onStart
                    )

                    ActionButton(
                        icon: "pencil",
                        color: .blue,
                        action: onEdit
                    )

                    ActionButton(
                        icon: "trash",
                        color: .red,
                        action: onDelete
                    )
                }
            }
            .padding(16)

            // Exercise preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(workoutPlan.exercises.prefix(3).enumerated()), id: \.offset) { index, exercise in
                        ExercisePreviewChip(exercise: exercise)
                    }

                    if workoutPlan.exercises.count > 3 {
                        Text("+\(workoutPlan.exercises.count - 3)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPressed = false
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExercisePreviewChip: View {
    let exercise: Exercise

    var body: some View {
        VStack(spacing: 2) {
            Text(exercise.name)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)

            Text("\(exercise.sets.count) 组")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.1))
        .clipShape(Capsule())
    }
}
```

### 2.2 CurrentSetView Component

```swift
struct CurrentSetView: View {
    let exercise: Exercise
    let set: ExerciseSet
    let completedReps: Binding<Int>
    let completedWeight: Binding<Float>
    let onComplete: () -> Void

    @State private var repsText = ""
    @State private var weightText = ""
    @State private var isCompleting = false

    var body: some View {
        VStack(spacing: 24) {
            // Set type banner
            SetTypeBanner(setType: set.setType)

            // Exercise info
            VStack(spacing: 8) {
                Text(exercise.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("第 \(getCurrentSetNumber()) 组")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Target info
            VStack(spacing: 4) {
                HStack {
                    Text("目标:")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(set.reps) 次 × \(formatWeight(set.weight))")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                if set.setRestTime > 0 {
                    HStack {
                        Text("休息:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(set.setRestTime) 秒")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Input section
            VStack(spacing: 16) {
                // Reps input
                VStack(alignment: .leading, spacing: 8) {
                    Text("完成次数")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextField("次数", text: $repsText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }

                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("重量 (kg)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    TextField("重量", text: $weightText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Complete button
            Button(action: {
                isCompleting = true
                onComplete()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)

                    Text("完成")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .disabled(isCompleting || repsText.isEmpty || weightText.isEmpty)
            .opacity(isCompleting || repsText.isEmpty || weightText.isEmpty ? 0.6 : 1.0)
            .scaleEffect(isCompleting ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isCompleting)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            repsText = "\(set.reps)"
            weightText = String(format: "%.1f", set.weight)
        }
    }

    private func getCurrentSetNumber() -> Int {
        // Find current set index
        guard let currentIndex = exercise.sets.firstIndex(where: { $0.id == set.id }) else {
            return 1
        }
        return currentIndex + 1
    }

    private func formatWeight(_ weight: Float) -> String {
        return weight == 0 ? "自重" : "\(weight) kg"
    }
}

struct SetTypeBanner: View {
    let setType: SetType

    var body: some View {
        HStack {
            Image(systemName: setType.icon)
                .font(.title3)

            Text(setType.displayName)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            Text(setType.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColorForSetType(setType))
        )
    }

    private func backgroundColorForSetType(_ setType: SetType) -> LinearGradient {
        switch setType {
        case .warmup:
            return LinearGradient(
                colors: [.blue, .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .formal:
            return LinearGradient(
                colors: [.green, .green.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .superSet:
            return LinearGradient(
                colors: [.orange, .orange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
```

### 2.3 RestTimerView Component

```swift
struct RestTimerView: View {
    let totalSeconds: Int
    let onSkip: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    @State private var remainingSeconds: Int
    @State private var isPaused = false
    @State private var progress: Double = 0

    init(totalSeconds: Int, onSkip: @escaping () -> Void, onPause: @escaping () -> Void, onResume: @escaping () -> Void) {
        self.totalSeconds = totalSeconds
        self.remainingSeconds = totalSeconds
        self.onSkip = onSkip
        self.onPause = onPause
        self.onResume = onResume
    }

    var body: some View {
        VStack(spacing: 32) {
            // Timer ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Time display
                VStack(spacing: 4) {
                    Text(formatTime(remainingSeconds))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("休息时间")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }

            // Control buttons
            HStack(spacing: 20) {
                Button(action: onSkip) {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("跳过")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.red)
                    )
                }

                Button(action: {
                    if isPaused {
                        onResume()
                    } else {
                        onPause()
                    }
                    isPaused.toggle()
                }) {
                    HStack {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        Text(isPaused ? "继续" : "暂停")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                    )
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if !isPaused && remainingSeconds > 0 {
                remainingSeconds -= 1
                progress = Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
            } else if remainingSeconds == 0 {
                // Timer completed
                onSkip()
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
```

## 3. Animation Specifications

### 3.1 Animation Timing Curves

```swift
struct AnimationPresets {
    // Smooth transitions
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeInOut(duration: 0.15)
    static let slow = Animation.easeInOut(duration: 0.5)

    // Spring animations
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let gentle = Animation.spring(response: 0.8, dampingFraction: 0.9)

    // Custom timing curves
    static let setCompletion = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.4)
    static let restTimer = Animation.timingCurve(0.4, 0, 0.6, 1, duration: 0.3)
    static let exerciseTransition = Animation.timingCurve(0.3, 0, 0.7, 1, duration: 0.5)
    static let buttonPress = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.1)
}
```

### 3.2 Micro-interactions

```swift
struct MicroInteractions {
    // Button press effect
    static func buttonPressEffect() -> some View {
        return AnyView(
            EmptyView()
                .scaleEffect(0.95)
                .animation(AnimationPresets.buttonPress, value: false)
        )
    }

    // Card hover effect
    static func cardHoverEffect() -> some View {
        return AnyView(
            EmptyView()
                .scaleEffect(1.02)
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                .animation(AnimationPresets.smooth, value: false)
        )
    }

    // Success feedback
    static func successFeedback() -> some View {
        return AnyView(
            EmptyView()
                .scaleEffect(1.1)
                .opacity(0.8)
                .animation(AnimationPresets.bouncy, value: false)
        )
    }
}
```

## 4. Color Scheme and Typography

### 4.1 Color System

```swift
struct AppColors {
    // Primary colors
    static let primary = Color.blue
    static let secondary = Color.gray
    static let accent = Color.orange

    // Set type colors
    static let warmupColor = Color.blue
    static let formalColor = Color.green
    static let superSetColor = Color.orange

    // Status colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // Background colors
    static let primaryBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)

    // Text colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
}
```

### 4.2 Typography System

```swift
struct AppTypography {
    // Headlines
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.bold)
    static let title3 = Font.title3.weight(.semibold)

    // Body text
    static let headline = Font.headline.weight(.semibold)
    static let body = Font.body
    static let callout = Font.callout.weight(.medium)
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2

    // Special text
    static let buttonTitle = Font.headline.weight(.semibold)
    static let tabBarTitle = Font.caption.weight(.medium)
    static let navigationTitle = Font.largeTitle.weight(.bold)
}
```

This comprehensive UI component design provides a solid foundation for building a modern, animated iOS Fit app with React-level smoothness and intuitive user experience.
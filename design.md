# iOS Fit App V0.2 UI-Only Design Documentation

## 1. Project Overview

### 1.1 Version Scope and Objectives

**Fit App V0.2** is a UI-focused prototype designed to replicate the React Figma interface experience without functional backend implementation.

**Core Objectives:**
- Recreate React-level animation performance and visual effects
- Implement complete UI flow without blocking interactions
- Provide seamless screen transitions and micro-interactions
- Maintain visual consistency with Figma design specifications

### 1.2 Technical Specifications

| Specification | Requirement |
|---------------|-------------|
| **Platform** | iOS 26.0+ |
| **Device** | iPhone only |
| **Framework** | SwiftUI |
| **Architecture** | Simple View-Only Structure |
| **Animation** | 60 FPS target |
| **Language** | Swift 5.9+ |
| **Data** | Mock/Static data only |

### 1.3 Performance Requirements

- **Animation Frame Rate**: 60 FPS for all transitions
- **App Launch Time**: < 2 seconds
- **Memory Usage**: < 50MB (UI only)
- **UI Responsiveness**: No blocking operations
- **Visual Quality**: Match React interface smoothness

## 2. UI-Only Architecture

### 2.1 Simplified View Structure

```
App
├── MainScreen (主界面)
│   ├── AnimatedBackground
│   ├── HeaderSection
│   ├── ReadPlanSection
│   └── StartWorkoutSection
└── WorkoutScreen (训练界面)
    ├── WorkoutHeader
    ├── ExerciseDisplay
    ├── TimerSection
    ├── ControlButtons
    └── DialogOverlay
        ├── CompletionDialog
        ├── EditSetDialog
        ├── QuitDialog
        ├── SkipRestDialog
        └── WorkoutCompleteDialog
```

### 2.2 Navigation Flow

```swift
// Simple state-based navigation
enum AppScreen {
    case main
    case workout
    case completion
}

class NavigationManager: ObservableObject {
    @Published var currentScreen: AppScreen = .main

    func navigateToWorkout() {
        currentScreen = .workout
    }

    func navigateToMain() {
        currentScreen = .main
    }
}
```

## 3. UI Components Design

### 3.1 MainScreen Components

#### 3.1.1 AnimatedBackground
```swift
struct AnimatedBackground: View {
    @State private var animationOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.1),
                    Color.pink.opacity(0.1),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Animated blob 1
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(scale)
                .offset(animationOffset)
                .blur(radius: 60)
                .animation(
                    .easeInOut(duration: 20.0)
                    .repeatForever(autoreverses: true),
                    value: animationOffset
                )

            // Animated blob 2
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 250, height: 250)
                .scaleEffect(1.2 - scale)
                .offset(-animationOffset)
                .blur(radius: 60)
                .animation(
                    .easeInOut(duration: 18.0)
                    .repeatForever(autoreverses: true),
                    value: scale
                )
        }
        .onAppear {
            withAnimation {
                animationOffset = CGSize(width: 100, height: 80)
                scale = 1.2
            }
        }
    }
}
```

#### 3.1.2 GlassCard Component
```swift
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
```

#### 3.1.3 ActionButton Component
```swift
struct ActionButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isEnabled {
                            LinearGradient(
                                colors: [Color.orange, Color.pink, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .disabled(!isEnabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
```

### 3.2 WorkoutScreen Components

#### 3.2.1 ExerciseDisplay
```swift
struct ExerciseDisplay: View {
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 20) {
            // Exercise image placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("动作图片")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                )
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                    value: pulseScale
                )

            // Exercise name
            Text("杠铃卧推")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            // Exercise info
            HStack(spacing: 16) {
                InfoCard(title: "组数", value: "4", color: .blue)
                InfoCard(title: "次数", value: "8", color: .green)
                InfoCard(title: "重量", value: "60kg", color: .purple)
            }
        }
        .padding(20)
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}
```

#### 3.2.2 TimerDisplay
```swift
struct TimerDisplay: View {
    @State private var timeLeft: Int = 90
    @State private var isActive: Bool = false
    @State private var progress: Double = 1.0

    var body: some View {
        VStack(spacing: 16) {
            Text("休息时间")
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.orange, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Text(formatTime(timeLeft))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

### 3.3 Dialog Components

#### 3.3.1 DialogOverlay
```swift
struct DialogOverlay<DialogContent: View>: View {
    let isPresented: Bool
    let content: DialogContent

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Handle background tap
                    }

                content
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                    .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}
```

#### 3.3.2 CompletionDialog
```swift
struct CompletionDialog: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("完成记录")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            Text("请输入您实际完成的次数和重量")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Input fields placeholder
            VStack(spacing: 12) {
                HStack {
                    Text("完成次数:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    TextField("8", text: .constant("8"))
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }

                HStack {
                    Text("完成重量:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    TextField("60", text: .constant("60"))
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
            }

            HStack(spacing: 12) {
                Button("取消") {
                    isPresented = false
                }
                .buttonStyle(SecondaryButtonStyle())

                Button("确认") {
                    isPresented = false
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 320)
    }
}
```

## 4. Mock Data Structure

### 4.1 Simple Workout Plan Mock
```swift
struct MockWorkoutPlan {
    static let sample = WorkoutPlan(
        name: "胸部训练计划",
        exercises: [
            Exercise(
                name: "杠铃卧推",
                sets: [
                    WorkoutSet(type: .warmup, reps: 8, rest: 30),
                    WorkoutSet(type: .formal, reps: 8, rest: 90),
                    WorkoutSet(type: .formal, reps: 8, rest: 90),
                    WorkoutSet(type: .formal, reps: 8, rest: 90),
                    WorkoutSet(type: .formal, reps: 8, rest: 90)
                ]
            ),
            Exercise(
                name: "哑铃飞鸟",
                sets: [
                    WorkoutSet(type: .formal, reps: 10, rest: 60),
                    WorkoutSet(type: .formal, reps: 10, rest: 60),
                    WorkoutSet(type: .formal, reps: 10, rest: 60)
                ]
            )
        ]
    )
}

struct WorkoutPlan {
    let name: String
    let exercises: [Exercise]
}

struct Exercise {
    let name: String
    let sets: [WorkoutSet]
}

struct WorkoutSet {
    let type: SetType
    let reps: Int
    let rest: Int // seconds
}

enum SetType: String, CaseIterable {
    case warmup = "热身组"
    case formal = "正式组"
    case super = "超级组"
}
```

## 5. Animation Specifications

### 5.1 Background Animations
- **Duration**: 18-20 seconds continuous loop
- **Type**: Smooth sine wave motion
- **Elements**: 2-3 floating blobs with different colors
- **Performance**: GPU-accelerated with Core Animation

### 5.2 Transition Animations
- **Screen Changes**: 0.3-0.5 seconds ease-in-out
- **Button Interactions**: 0.1-0.2 seconds spring effect
- **Dialog Appearances**: Scale + opacity combined transitions
- **Progress Indicators**: Linear interpolation over duration

### 5.3 Micro-interactions
- **Button Press**: Scale down to 0.95, then back to 1.0
- **Card Hover**: Subtle shadow increase and scale
- **Loading States**: Pulsing or spinning animations
- **Status Changes**: Color transitions with smooth easing

## 6. Color Scheme

### 6.1 Primary Colors
```swift
extension Color {
    static let appOrange = Color(red: 251/255, green: 146/255, blue: 60/255)
    static let appPink = Color(red: 236/255, green: 72/255, blue: 153/255)
    static let appPurple = Color(red: 139/255, green: 92/255, blue: 246/255)
    static let appBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    static let appGreen = Color(red: 34/255, green: 197/255, blue: 94/255)
}
```

### 6.2 Gradient Definitions
```swift
struct AppGradients {
    static let primary = LinearGradient(
        colors: [Color.appOrange, Color.appPink, Color.appPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let background = LinearGradient(
        colors: [
            Color.orange.opacity(0.1),
            Color.pink.opacity(0.1),
            Color.purple.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
```

## 7. Typography

### 7.1 Font System
```swift
extension Font {
    static let appTitle = Font.system(size: 24, weight: .bold)
    static let appHeadline = Font.system(size: 20, weight: .semibold)
    static let appSubheadline = Font.system(size: 18, weight: .medium)
    static let appBody = Font.system(size: 16, weight: .regular)
    static let appCaption = Font.system(size: 14, weight: .regular)
    static let appSmall = Font.system(size: 12, weight: .regular)
}
```

## 8. Implementation Guidelines

### 8.1 Performance Optimization
- Use `@State` for simple UI state only
- Avoid complex computations in view body
- Leverage SwiftUI's built-in animations
- Test on actual device for performance validation

### 8.2 UI State Management
```swift
class UIStateManager: ObservableObject {
    @Published var currentScreen: AppScreen = .main
    @Published var selectedExercise: Int = 0
    @Published var currentSet: Int = 0
    @Published var showDialogs: DialogState = DialogState()

    struct DialogState {
        var completion: Bool = false
        var edit: Bool = false
        var quit: Bool = false
        var skipRest: Bool = false
        var workoutComplete: Bool = false
    }
}
```

### 8.3 Build Configuration
- Target iOS 26.0
- iPhone only deployment
- Debug configuration for development
- No external dependencies required
- Minimal app bundle size (< 10MB)

## 9. Success Criteria

### 9.1 Visual Fidelity
- [ ] React interface smoothness replicated
- [ ] All animations run at 60 FPS
- [ ] Color scheme matches Figma design
- [ ] Typography consistent with design specs

### 9.2 User Experience
- [ ] No UI blocking or freezing
- [ ] Smooth screen transitions
- [ ] Responsive button interactions
- [ ] Dialog animations work correctly

### 9.3 Technical Performance
- [ ] App launches in under 2 seconds
- [ ] Memory usage stays under 50MB
- [ ] No memory leaks during navigation
- [ ] Build succeeds without errors

---

## Summary

This UI-only design focuses exclusively on creating a visual replica of the React Figma interface without functional backend implementation. The architecture is simplified to prioritize visual performance and smooth animations while maintaining the ability to demonstrate the complete user flow without blocking interactions.

The design ensures that V0.2 can be built quickly and successfully while providing an impressive visual demonstration of the intended user experience.
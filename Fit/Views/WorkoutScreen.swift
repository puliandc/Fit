//
//  WorkoutScreen.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-01-10 - 基于Figma设计重新实现训练界面
//

import SwiftUI

struct WorkoutScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var workoutViewModel: WorkoutViewModel
    @State private var timer: Timer?
    @State private var exerciseStartTime: Date = Date()
    @State private var showContent: Bool = false

    init(workoutPlan: WorkoutPlan) {
        print("🐛 DEBUG: WorkoutScreen initializing...")
        print("🐛 DEBUG: Workout plan: \(workoutPlan.name)")
        print("🐛 DEBUG: Exercise count: \(workoutPlan.exercises.count)")

        // 安全验证
        guard !workoutPlan.exercises.isEmpty else {
            print("🚨 ERROR: Cannot initialize WorkoutScreen - no exercises in workout plan")
            // 创建一个安全的默认训练计划
            let safeWorkoutPlan = WorkoutPlan(
                name: "默认训练计划",
                description: "默认训练计划，请联系开发者",
                category: .fullBody,
                difficulty: .beginner,
                duration: 30,
                exercises: [
                    ExerciseSet(
                        exercise: Exercise(
                            name: "默认练习",
                            category: .strength,
                            muscleGroups: [.chest],
                            equipment: .none,
                            difficulty: .beginner,
                            instructions: ["请联系开发者"],
                            imageName: "default"
                        ),
                        targetReps: 1,
                        targetWeight: 0
                    )
                ],
                estimatedCalories: 100
            )
            print("🔄 FALLBACK: Using safe default workout plan")
            _workoutViewModel = StateObject(wrappedValue: WorkoutViewModel(workoutPlan: safeWorkoutPlan))
            return
        }

        _workoutViewModel = StateObject(wrappedValue: WorkoutViewModel(workoutPlan: workoutPlan))
        print("🐛 DEBUG: WorkoutScreen initialization complete")
    }

    var body: some View {
        ZStack {
            // 现代化背景
            ModernWorkoutBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 顶部安全区域
                    Color.clear.frame(height: 12)

                    // 训练头部
                    ModernWorkoutHeader(
                        workoutPlan: workoutViewModel.workoutPlan,
                        progress: workoutViewModel.progress,
                        onBack: {
                            navigationManager.quitWorkout()
                        }
                    )
                    .padding(.horizontal, 20)

                    // 主要内容区域
                    VStack(spacing: 20) {
                        // 休息时间覆盖层（休息时显示）
                        if workoutViewModel.isResting {
                            RestTimerView(
                                timeLeft: workoutViewModel.timeLeft,
                                onSkip: {
                                    workoutViewModel.skipRest()
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        }

                        // 当前运动展示
                        ModernExerciseDisplay(
                            exercise: workoutViewModel.currentExercise,
                            currentSet: workoutViewModel.currentSet,
                            totalSets: workoutViewModel.currentExerciseSet.targetReps,
                            targetReps: workoutViewModel.currentExerciseSet.targetReps,
                            targetWeight: workoutViewModel.currentExerciseSet.targetWeight,
                            elapsedTime: workoutViewModel.exerciseElapsedTime,
                            onEditSet: {
                                navigationManager.presentDialog(.editSet(workoutViewModel.currentExercise, workoutViewModel.currentSet))
                            }
                        )

                        // 运动计时器
                        ModernTimerSection(
                            elapsedTime: workoutViewModel.exerciseElapsedTime,
                            isActive: workoutViewModel.isExerciseActive
                        )

                        // 控制按钮
                        ModernControlButtons(
                            isExerciseActive: workoutViewModel.isExerciseActive,
                            isResting: workoutViewModel.isResting,
                            onCompleteExercise: {
                                workoutViewModel.completeExercise()
                            },
                            onPauseResume: {
                                workoutViewModel.toggleExercise()
                            }
                        )
                    }
                    .padding(.horizontal, 20)

                    // 底部空间
                    Spacer(minLength: 40)
                }
            }
            // .scrollIndicators(.hidden) // 暂时注释，需要iOS 16.0+支持

            // 对话框覆盖层
            if let dialog = navigationManager.presentedDialog {
                DialogOverlay(dialog: dialog, navigationManager: navigationManager)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .onAppear {
            print("🐛 DEBUG: WorkoutScreen appeared")
            print("🐛 DEBUG: About to start exercise...")

            // 安全检查
            if workoutViewModel.workoutPlan.exercises.isEmpty {
                print("🚨 ERROR: Cannot start exercise - no exercises available")
                return
            }

            print("🐛 DEBUG: Starting first exercise...")
            workoutViewModel.startExercise()

            print("🐛 DEBUG: Exercise started, showing content...")
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
            print("🐛 DEBUG: WorkoutScreen onAppear complete")
        }
        .onDisappear {
            workoutViewModel.pauseExercise()
        }
    }
}

// MARK: - Modern Workout Background
struct ModernWorkoutBackground: View {
    @State private var blob1Offset: CGSize = .zero
    @State private var blob1Scale: CGFloat = 1.0
    @State private var blob2Offset: CGSize = .zero
    @State private var blob2Scale: CGFloat = 1.0
    @State private var gradientRotation: Double = 0

    var body: some View {
        ZStack {
            // 主背景渐变 - 训练主题
            LinearGradient(
                colors: [.appBackground, .appSurface, .appSurfaceLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 训练主题渐变叠加
            LinearGradient(
                colors: [
                    .workoutColor.opacity(0.12),
                    .accentGradientStart.opacity(0.08),
                    .primaryGradientEnd.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(gradientRotation))
            .ignoresSafeArea()
            .animation(
                .linear(duration: 40.0).repeatForever(autoreverses: false),
                value: gradientRotation
            )

            // 动态光斑 1 - 训练主题
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.workoutColor.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 60,
                        endRadius: 280
                    )
                )
                .frame(width: 450, height: 450)
                .scaleEffect(blob1Scale)
                .offset(blob1Offset)
                .blur(radius: 90)
                .animation(
                    .easeInOut(duration: 20.0)
                    .repeatForever(autoreverses: true),
                    value: blob1Offset
                )
                .animation(
                    .easeInOut(duration: 25.0)
                    .repeatForever(autoreverses: true),
                    value: blob1Scale
                )

            // 动态光斑 2 - 休息主题
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.restColor.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 220
                    )
                )
                .frame(width: 350, height: 350)
                .scaleEffect(blob2Scale)
                .offset(CGSize(width: -blob2Offset.width, height: -blob2Offset.height))
                .blur(radius: 80)
                .animation(
                    .easeInOut(duration: 18.0)
                    .repeatForever(autoreverses: true),
                    value: blob2Offset
                )
                .animation(
                    .easeInOut(duration: 22.0)
                    .repeatForever(autoreverses: true),
                    value: blob2Scale
                )
        }
        .onAppear {
            withAnimation {
                blob1Offset = CGSize(width: 100, height: 120)
                blob1Scale = 1.2
                blob2Offset = CGSize(width: -120, height: 100)
                blob2Scale = 1.3
                gradientRotation = 360
            }
        }
    }
}

// MARK: - Modern Workout Header
struct ModernWorkoutHeader: View {
    let workoutPlan: WorkoutPlan
    let progress: Double
    let onBack: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // 顶部导航栏
            HStack {
                // 返回按钮
                Button {
            onBack()
        } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.glassBackground)
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )

                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appText)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                // 训练标题
                VStack(spacing: 2) {
                    Text(workoutPlan.name)
                        .sectionTitleStyle()
                        .multilineTextAlignment(.center)

                    Text("训练进度")
                        .captionStyle()
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // 占位符保持对称
                Color.clear
                    .frame(width: 44, height: 44)
            }

            // 进度条
            VStack(spacing: 8) {
                HStack {
                    Text("训练进度")
                        .captionStyle()

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .captionStyle()
                        .foregroundColor(.workoutColor)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景轨道
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.appSurfaceLight)
                            .frame(height: 12)

                        // 进度条
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient.workoutGradient)
                            .frame(width: geometry.size.width * progress, height: 12)
                            .animation(.easeOut(duration: 0.8), value: progress)
                            .shadow(color: Color.workoutColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
                .shadow(color: Color.glassShadowEffect, radius: 15, x: 0, y: 8)
        )
        .scaleEffect(showContent ? 1.0 : 0.95)
        .opacity(showContent ? 1.0 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Modern Exercise Display
struct ModernExerciseDisplay: View {
    let exercise: Exercise
    let currentSet: Int
    let totalSets: Int
    let targetReps: Int
    let targetWeight: Double
    let elapsedTime: Int
    let onEditSet: () -> Void

    @State private var isVisible: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var imageRotation: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            // 运动图片占位符
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.appSurfaceLight)
                    .frame(height: 220)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.glassShadowEffect, radius: 10, x: 0, y: 5)

                VStack(spacing: 12) {
                    // 动态图标
                    ZStack {
                        // 背景光环
                        Circle()
                            .fill(LinearGradient.workoutGradient)
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)
                            .opacity(0.3)
                            .blur(radius: 15)
                            .animation(
                                .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                                value: pulseScale
                            )

                        // 主图标
                        Circle()
                            .fill(LinearGradient.workoutGradient)
                            .frame(width: 64, height: 64)
                            .rotationEffect(.degrees(imageRotation))
                            .animation(
                                .linear(duration: 8.0).repeatForever(autoreverses: false),
                                value: imageRotation
                            )

                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("动作图片")
                        .captionStyle()
                        .foregroundColor(.appTextMuted)
                }
            }

            // 运动名称
            VStack(spacing: 8) {
                Text(exercise.name)
                    .screenTitleStyle()
                    .multilineTextAlignment(.center)

                Text("第 \(currentSet) 组，共 \(totalSets) 组")
                    .bodySecondaryStyle()
                    .multilineTextAlignment(.center)
            }

            // 运动参数信息卡片
            HStack(spacing: 12) {
                // 组数卡片
                ModernInfoCard(
                    title: "组数",
                    value: "\(currentSet)",
                    subtitle: "/ \(totalSets)",
                    color: .workoutColor,
                    icon: "repeat"
                )

                // 次数卡片
                ModernInfoCard(
                    title: "次数",
                    value: "\(targetReps)",
                    subtitle: "次",
                    color: .success,
                    icon: "target"
                )

                // 重量卡片（如果有）
                if targetWeight > 0 {
                    ModernInfoCard(
                        title: "重量",
                        value: "\(Int(targetWeight))",
                        subtitle: "kg",
                        color: .progressColor,
                        icon: "scalemass"
                    )
                }
            }

            // 编辑按钮
            ModernButton(
                text: "编辑参数",
                action: onEditSet,
                style: .secondary,
                isDisabled: false,
                fullWidth: false
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient.surfaceGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
                .shadow(color: Color.glassShadowEffect, radius: 20, x: 0, y: 10)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
                pulseScale = 1.2
                imageRotation = 360
            }
        }
    }
}

// MARK: - Modern Info Card
struct ModernInfoCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String

    @State private var isVisible: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }

            // 数值
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appText)

                HStack(spacing: 2) {
                    Text(title)
                        .captionStyle()
                    Text(subtitle)
                        .captionStyle()
                        .foregroundColor(.appTextMuted)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Info Card
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

// MARK: - Modern Timer Section
struct ModernTimerSection: View {
    let elapsedTime: Int
    let isActive: Bool

    @State private var isVisible: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 20) {
            timerHeaderView
            timerDisplayView
        }
        .padding(20)
        .background(timerBackground)
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 15)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: isVisible)
        .onAppear {
            startAnimations()
        }
        .onChange(of: isActive) { newActive in
            updatePulseScale(newActive)
        }
    }

    private var timerHeaderView: some View {
        HStack {
            Image(systemName: "timer")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.workoutColor)
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: pulseScale
                )

            Text("运动时间")
                .sectionTitleStyle()

            Spacer()
        }
    }

    private var timerDisplayView: some View {
        HStack(spacing: 12) {
            clockIconView
            timeDisplayView
            Spacer()
            statusIndicatorView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(timerContentBackground)
    }

    private var clockIconView: some View {
        ZStack {
            Circle()
                .fill(Color.workoutColor.opacity(0.15))
                .frame(width: 48, height: 48)

            Image(systemName: "clock.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.workoutColor)
                .rotationEffect(.degrees(rotationAngle))
                .animation(
                    isActive ? .linear(duration: 4.0).repeatForever(autoreverses: false) : .none,
                    value: rotationAngle
                )
        }
    }

    private var timeDisplayView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatTime(elapsedTime))
                .timerLargeStyle()

            Text(isActive ? "运动中" : "已暂停")
                .captionStyle()
                .foregroundColor(isActive ? Color.success : Color.appTextMuted)
        }
    }

    private var statusIndicatorView: some View {
        Circle()
            .fill(isActive ? Color.success : Color.appTextMuted)
            .frame(width: 12, height: 12)
            .scaleEffect(pulseScale)
            .animation(
                isActive ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .none,
                value: pulseScale
            )
    }

    private var timerContentBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.workoutColor.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.workoutColor.opacity(0.2), lineWidth: 1)
            )
    }

    private var timerBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(LinearGradient.surfaceGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.glassShadowEffect, radius: 15, x: 0, y: 8)
    }

    private func startAnimations() {
        withAnimation {
            isVisible = true
            rotationAngle = 360
            pulseScale = isActive ? 1.2 : 1.0
        }
    }

    private func updatePulseScale(_ newActive: Bool) {
        withAnimation {
            pulseScale = newActive ? 1.2 : 1.0
            if newActive {
                rotationAngle = 360
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Modern Control Buttons
struct ModernControlButtons: View {
    let isExerciseActive: Bool
    let isResting: Bool
    let onCompleteExercise: () -> Void
    let onPauseResume: () -> Void

    @State private var isVisible: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // 完成这组按钮
            ModernButton(
                text: "完成这组",
                action: onCompleteExercise,
                style: isResting ? .disabled : .primary,
                isDisabled: isResting,
                fullWidth: true
            )
            .disabled(isResting)

            // 暂停/继续按钮
            Button(action: onPauseResume) {
                HStack(spacing: 12) {
                    Image(systemName: isExerciseActive ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24, weight: .semibold))

                    Text(isExerciseActive ? "暂停训练" : "继续训练")
                        .buttonPrimaryStyle()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: isExerciseActive ? [.restColor, .info] : [.success, .successLight],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(
                    color: (isExerciseActive ? Color.restColor : Color.success).opacity(0.4),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isResting)
            .scaleEffect(isVisible ? 1.0 : 0.95)
            .opacity(isVisible ? 1.0 : 0)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Modern Rest Timer View
struct RestTimerView: View {
    let timeLeft: Int
    let onSkip: () -> Void

    @State private var progress: Double = 1.0
    @State private var isVisible: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0

    var body: some View {
        Button {
            onSkip()
        } label: {
            VStack(spacing: 24) {
                // 休息标题
                HStack {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.restColor)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: pulseScale
                        )

                    Text("休息时间")
                        .sectionTitleStyle()
                        .foregroundColor(.restColor)

                    Spacer()
                }

                // 圆形进度计时器
                ZStack {
                    // 背景圆环
                    Circle()
                        .stroke(Color.appSurfaceLight.opacity(0.5), lineWidth: 12)
                        .frame(width: 160, height: 160)

                    // 进度圆环
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient.restGradient,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                        .shadow(color: .restColor.opacity(0.4), radius: 8, x: 0, y: 4)

                    // 时间显示
                    VStack(spacing: 4) {
                        Text(formatTime(timeLeft))
                            .timerLargeStyle()
                            .foregroundColor(.restColor)

                        Text("剩余")
                            .captionStyle()
                            .foregroundColor(.restColor.opacity(0.8))
                    }

                    // 旋转装饰
                    Circle()
                        .stroke(Color.restColor.opacity(0.2), lineWidth: 1)
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            .linear(duration: 20.0).repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                }

                // 跳过提示
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextMuted)

                    Text("点击跳过休息")
                        .captionStyle()
                        .foregroundColor(.appTextMuted)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.glassBackground, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.glassShadowEffect, radius: 25, x: 0, y: 12)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
                pulseScale = 1.2
                rotationAngle = 360
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Dialog Overlay
struct DialogOverlay: View {
    let dialog: DialogType
    let navigationManager: NavigationManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    navigationManager.dismissDialog()
                }

            switch dialog {
            case .editSet(let exercise, let setIndex):
                EditSetDialog(
                    exercise: exercise,
                    setIndex: setIndex,
                    onDismiss: {
                        navigationManager.dismissDialog()
                    }
                )
            case .completion:
                CompletionDialog(onDismiss: {
                    navigationManager.dismissDialog()
                })
            case .quitWorkout:
                QuitDialog(
                    onConfirm: {
                        navigationManager.popToRoot()
                    },
                    onCancel: {
                        navigationManager.dismissDialog()
                    }
                )
            case .workoutComplete:
                WorkoutCompleteDialog(
                    onDismiss: {
                        navigationManager.popToRoot()
                    }
                )
            }
        }
        .zIndex(1000)
    }
}

// MARK: - Preview
#Preview {
    WorkoutScreen(workoutPlan: MockDataProvider.previewWorkout)
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
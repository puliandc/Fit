//
//  WorkoutScreen.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-01-12 - 移除图片组件，基于Figma设计优化信息卡片布局
//  Architecture: 单一信息卡片设计，垂直布局，模块化组件
//

import SwiftUI

struct WorkoutScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dialogManager: DialogManager
    @EnvironmentObject var workoutSessionManager: WorkoutSessionManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var showContent: Bool = false

    // 保持init方法用于接收workoutPlan参数，但不创建WorkoutViewModel
    init(workoutPlan: WorkoutPlan) {
        // 这个init方法现在只用于确保workoutPlan的有效性
        // WorkoutViewModel现在由环境提供
    }

    var body: some View {
        ZStack {
            // 动画背景层 - 与 MainScreen 保持一致
            AnimatedBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部标题栏 - 基于Figma设计
                CompactWorkoutHeader(
                    workoutPlan: workoutViewModel.workoutPlan,
                    progress: workoutViewModel.progress,
                    onBack: {
                        dialogManager.presentDialog(.quitWorkout)
                    }
                )

                // 主要内容区域 - 移除滚动属性
                VStack(spacing: 16) {
                    // 统一时间模块显示（始终显示，根据状态切换内容）
                CompactTimerView(
                    isResting: workoutViewModel.isResting,
                    elapsedTime: workoutViewModel.exerciseElapsedTime,
                    timeLeft: workoutViewModel.timeLeft,
                    isExerciseActive: workoutViewModel.isExerciseActive,
                    onCompleteAction: {
                        // 动作时间模式下点击"动作完成"
                        dialogManager.presentDialog(.editSet(workoutViewModel.currentExercise, workoutViewModel.currentSet, workoutViewModel))
                    },
                    onSkipRest: {
                        // 休息时间模式下点击"跳过休息"
                        workoutViewModel.skipRest()
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))


                    // 运动信息卡片 - 基于Figma设计，移除滚动和编辑按钮
                    CompactExerciseInfoCard(
                        exercise: workoutViewModel.currentExercise,
                        currentSet: workoutViewModel.currentSet,
                        totalSets: workoutViewModel.getCurrentExerciseTotalSets(),
                        targetReps: workoutViewModel.currentExerciseSet.targetReps,
                        targetWeight: workoutViewModel.currentExerciseSet.targetWeight,
                        elapsedTime: workoutViewModel.exerciseElapsedTime
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                // 底部固定按钮区域 - 只保留放弃按钮并居中
                ModernButton(
                    text: "放弃动作",
                    action: {
                        dialogManager.presentDialog(.quitWorkout)
                    },
                    style: .secondary,
                    isDisabled: false,
                    fullWidth: true
                )
                .accessibilityLabel("放弃当前动作")
                .accessibilityHint("点击这里可以放弃当前的动作并返回主界面")
                .accessibilityAddTraits(.isButton)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            // Dialog Overlay for workout-related dialogs
            if let dialog = dialogManager.presentedDialog {
                switch dialog {
                case .quitWorkout, .quitCurrentExercise, .quitRemainingExercises:
                    // Background overlay
                    Color.appBackground.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dialogManager.dismissDialog()
                        }

                    // Enhanced Quit Dialog
                    EnhancedQuitDialog(
                        onQuitCurrentExercise: {
                            workoutViewModel.skipCurrentExerciseCompletely()
                            dialogManager.dismissDialog()
                        },
                        onQuitAll: {
                            workoutViewModel.skipAllRemainingExercises()
                            dialogManager.dismissDialog()
                            // 延迟触发训练完成对话框，确保状态更新完成
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                _ = workoutSessionManager.completeWorkout()
                                dialogManager.presentDialog(.workoutComplete)
                            }
                        },
                        onCancel: {
                            dialogManager.dismissDialog()
                        },
                        currentExerciseName: workoutViewModel.currentExercise.name
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                case .editSet(let exercise, let setIndex, let workoutViewModel):
                    // Background overlay
                    Color.appBackground.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dialogManager.dismissDialog()
                        }

                    // Edit Set Dialog - 动作完成对话框
                    EditSetDialog(
                        exercise: exercise,
                        setIndex: setIndex,
                        onDismiss: {
                            dialogManager.dismissDialog()
                        },
                        workoutViewModel: workoutViewModel
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                case .workoutComplete:
                    // Background overlay
                    Color.appBackground.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dialogManager.dismissDialog()
                        }

                    // Workout Complete Dialog - 训练完成对话框
                    WorkoutCompleteDialog(
                        onDismiss: {
                            dialogManager.dismissDialog()
                            // 返回主界面
                            navigationManager.popToRoot()
                        },
                        workoutViewModel: workoutViewModel
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                default:
                    EmptyView()
                }
            }
          }
        .animation(.easeInOut(duration: 0.3), value: dialogManager.presentedDialog)
        .onAppear {
            // 安全检查
            guard !workoutViewModel.workoutPlan.exercises.isEmpty else { return }

            // 简化计时方案：重置计时器（处理应用恢复）
            workoutViewModel.resetTimerIfNeeded()
            workoutViewModel.startExercise()

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
        }
        .onDisappear {
            workoutViewModel.pauseExercise()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutCompleted)) { _ in
            // 监听训练完成通知
            print("🎉 DEBUG: Workout completed notification received!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                _ = workoutSessionManager.completeWorkout()
                dialogManager.presentDialog(.workoutComplete)
            }
        }
        .onChange(of: workoutViewModel.progress) {
            // 保留原有的进度监听作为备用机制
            if workoutViewModel.progress >= 1.0 {
                print("🎉 DEBUG: Workout completed! Progress reached 100%")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    _ = workoutSessionManager.completeWorkout()
                    dialogManager.presentDialog(.workoutComplete)
                }
            }
    }
}


// MARK: - Compact Workout Header
struct CompactWorkoutHeader: View {
    let workoutPlan: WorkoutPlan
    let progress: Double
    let onBack: () -> Void

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    private var progressTextColor: Color {
        colorScheme == .light ? .warningLight : .warningDark
    }

    private var primaryTextColor: Color {
        colorScheme == .light ? Color(UIColor.darkText) : Color.white // text-gray-900 dark:text-white
    }

    var body: some View {
        VStack(spacing: 16) {
            // 顶部导航栏
            HStack(spacing: 12) {
                // 返回按钮
                Button(action: onBack) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(primaryTextColor) // text-gray-900 dark:text-white
                        )
                        .shadow(color: .appBackground.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())

                // 标题和百分比
                HStack(spacing: 8) {
                    Text(workoutPlan.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(primaryTextColor) // text-gray-900 dark:text-white
                        .lineLimit(1)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(progressTextColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 简化的进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景轨道
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appTextMuted.opacity(0.2))
                        .frame(height: 6)

                    // 进度条 - 单色
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.warning)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.easeOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            // Tailwind CSS风格毛玻璃背景效果
            // bg-white/80 dark:bg-gray-800/80 + backdrop-blur-xl
            Rectangle()
                .fill(colorScheme == .light ? Color.white.opacity(0.8) : Color.gray.opacity(0.8))
                .background(.ultraThinMaterial) // backdrop-blur-xl 效果
                .overlay(
                    // border-b border-gray-200/50 dark:border-gray-700/50
                    Rectangle()
                        .fill(colorScheme == .light ? Color.gray.opacity(0.2) : Color.gray.opacity(0.3))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1) // shadow-sm
        }
    }
}


// MARK: - Compact Exercise Info Card (版本1.3增强)
struct CompactExerciseInfoCard: View {
    let exercise: Exercise
    let currentSet: Int
    let totalSets: Int
    let targetReps: Int
    let targetWeight: Double
    let elapsedTime: Int

    @State private var isVisible: Bool = false
    @State private var shimmerOffset: CGFloat = -200

    private var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // 版本1.3: 计算整个训练计划的总时长
    private var formattedTotalTime: String {
        let totalTime = workoutViewModel.totalWorkoutTime
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // 版本1.3: 从workoutViewModel获取当前练习的所有组数信息
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

    private var allExerciseSets: [ExerciseSet] {
        workoutViewModel.workoutPlan.exercises.filter { $0.exercise.name == exercise.name }
    }

    // 统一的重量格式化函数
    private func formatWeight(_ weight: Double) -> String {
        if weight == 0 {
            return "自重"
        } else if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }

    private var nextSetInfo: String? {
        // 使用ViewModel的当前状态，确保数据一致性
        let currentExerciseIndex = workoutViewModel.currentExerciseIndex
        let _ = workoutViewModel.currentSet
        let allExercises = workoutViewModel.workoutPlan.exercises

        // 确保索引有效
        guard currentExerciseIndex < allExercises.count else {
            return nil
        }

        let currentExercise = allExercises[currentExerciseIndex].exercise
        let exerciseSets = allExercises.filter { $0.exercise.id == currentExercise.id }

        // 找到当前ExerciseSet在相同练习中的位置
        guard let currentPositionInExercise = exerciseSets.firstIndex(where: { $0.id == allExercises[currentExerciseIndex].id }) else {
            return nil
        }

        // 检查是否还有下一组（相同练习）
        if currentPositionInExercise < exerciseSets.count - 1 {
            let nextSet = exerciseSets[currentPositionInExercise + 1]
            let weightText = formatWeight(nextSet.targetWeight)
            return "下一组: \(currentExercise.name) \(nextSet.targetReps)次 * \(weightText)公斤"
        }

        // 检查是否还有下一个练习
        // 找到下一个不同练习的第一个ExerciseSet
        var nextIndex = currentExerciseIndex + 1
        while nextIndex < allExercises.count {
            let nextExerciseSet = allExercises[nextIndex]
            if nextExerciseSet.exercise.id != currentExercise.id {
                let weightText = formatWeight(nextExerciseSet.targetWeight)
                return "下一组: \(nextExerciseSet.exercise.name) \(nextExerciseSet.targetReps)次 * \(weightText)公斤"
            }
            nextIndex += 1
        }

        return nil
    }

    var body: some View {
        VStack(spacing: 16) {
            // 运动名称
            Text(exercise.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.warning, Color.appAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity)

  
            // 组数、次数和重量模块 - 增强版本
            VStack(spacing: 12) {
                // 当前组数模块 - 蓝色背景
                HStack {
                    Image(systemName: "number")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.appPrimary)

                    Text("当前组数：")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)

                    Text("\(currentSet) / \(totalSets)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appPrimary)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.94, green: 0.96, blue: 1.0),
                                    Color(red: 0.93, green: 1.0, blue: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                        )
                )

                // 版本1.3: 本轮训练进度
                ProgressView(value: max(0, min(1, Double(currentSet) / Double(totalSets))))
                    .progressViewStyle(LinearProgressViewStyle(tint: .appPrimary))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 16)

                // 次数和重量模块 - 水平排列，基于Figma设计
                HStack(spacing: 12) {
                    // 次数模块 - 绿色主题
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "target")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.success)
                        }

                        Text("目标次数")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextSecondary)

                        Text("\(targetReps)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.success)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.success.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.success.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // 重量模块 - 紫色主题
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "scalemass.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.info)
                        }

                        Text("目标重量 (kg)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appTextSecondary)

                        // 使用统一的重量格式化函数
                        Text(formatWeight(targetWeight))
                            .font(.system(size: targetWeight == 0 ? 16 : 20, weight: .bold))
                            .foregroundColor(.info)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.info.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.info.opacity(0.3), lineWidth: 1)
                            )
                    )
                }

                // 版本1.3: 下一组提示
                if let nextInfo = nextSetInfo {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.info)

                        Text(nextInfo)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.info)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.info.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }

            // 版本1.3: 训练计时
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                Text("训练总计时: \(formattedTotalTime)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.98, blue: 1.0),
                            Color(red: 0.95, green: 0.96, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    // 光泽动画覆盖层
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black,
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .animation(
                            .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                )
                .shadow(color: .appBackground.opacity(0.12), radius: 25, x: 0, y: 10)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
                // 启动光泽动画
                shimmerOffset = 200
            }
        }
        .onTapGesture {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Compact Complete Button


// MARK: - Compact Timer View (Unified Time Module)
struct CompactTimerView: View {
    let isResting: Bool
    let elapsedTime: Int
    let timeLeft: Int
    let isExerciseActive: Bool
    let onCompleteAction: () -> Void
    let onSkipRest: () -> Void

    @State private var isVisible: Bool = false
    @State private var shimmerOffset: CGFloat = -200

    private var formattedTime: String {
        if isResting {
            // 休息时间：显示倒计时
            let minutes = timeLeft / 60
            let seconds = timeLeft % 60
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            // 动作时间：显示正计时
            let minutes = elapsedTime / 60
            let seconds = elapsedTime % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    
    private var buttonTitle: String {
        if isResting {
            return "跳过休息"
        } else {
            return "动作完成"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // 标题区域 - 固定高度
            HStack {
                if isResting {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.appPrimary)

                    Text("休息时间")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                } else {
                    Image(systemName: "figure.run")
                        .font(.system(size: 18))
                        .foregroundColor(.success)

                    Text("动作时间")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.success)
                }

                Spacer()
            }
            .frame(height: 24) // 固定标题区域高度

            // 时间显示 - 固定高度
            Text(formattedTime)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(isResting ? .appPrimary : .success)
                .frame(height: 36) // 固定时间显示区域高度

            // 按钮 - 使用ModernButton统一样式
            ModernButton(
                text: buttonTitle,
                action: {
                    if isResting {
                        print("🔚 DEBUG: User clicked skip rest - timeLeft: \(timeLeft)")
                        onSkipRest()
                    } else {
                        print("✅ DEBUG: User clicked complete exercise - elapsedTime: \(elapsedTime)")
                        onCompleteAction()
                    }
                },
                style: .primary,
                isDisabled: !isExerciseActive && !isResting,
                fullWidth: true
            )
            .accessibilityLabel(isResting ? "跳过休息时间" : "完成当前动作")
            .accessibilityHint(isResting ? "点击这里可以跳过剩余的休息时间，直接开始下一个动作" : "点击这里记录当前动作的完成并打开参数编辑对话框")
            .accessibilityAddTraits(.isButton)
        }
        .frame(minHeight: 140) // 设置整体最小高度，确保UI稳定
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.98, blue: 1.0),
                            Color(red: 0.95, green: 0.96, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    // 光泽动画覆盖层
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black,
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .animation(
                            .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                )
                .shadow(color: .appBackground.opacity(0.12), radius: 25, x: 0, y: 10)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
                // 启动光泽动画
                shimmerOffset = 200
            }
        }
        .onTapGesture {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isResting ? "休息时间模块" : "动作时间模块")
    }
}

// MARK: - Preview
#Preview {
    WorkoutScreen(workoutPlan: MockDataProvider.previewWorkout)
        .environmentObject(NavigationManager.preview)
        .environmentObject(WorkoutViewModel(workoutPlan: MockDataProvider.previewWorkout))
        .preferredColorScheme(.dark)
}
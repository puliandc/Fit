//
//  WorkoutScreen.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 09:00:00 10/20/2025 by Jason Lu - 修复Header和Footer背景延伸到安全区域
//  Architecture: 单一信息卡片设计，垂直布局，模块化组件，优化安全区域背景
//

import SwiftUI

struct WorkoutScreen: View
{
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dialogManager: DialogManager
    @EnvironmentObject var workoutSessionManager: WorkoutSessionManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var showContent: Bool = false
    @State private var viewID: UUID = .init() // 用于强制视图更新
    @State private var hasShownCompletionDialog: Bool = false // 防止重复弹出完成对话框

    // 保持init方法用于接收workoutPlan参数，但不创建WorkoutViewModel
    init(workoutPlan _: WorkoutPlan)
    {
        // 这个init方法现在只用于确保workoutPlan的有效性
        // WorkoutViewModel现在由环境提供
    }

    var body: some View
    {
        ZStack
        {
            // 基础安全区域背景 - 使用与AnimatedBackground协调的颜色
            SafeAreaBackground()
                .ignoresSafeArea(.all)

            // 动画背景层 - 完全覆盖安全区域
            AnimatedBackground()
                .ignoresSafeArea(.all) // 移除clipped()，让背景延伸到安全区域

            VStack(spacing: 0)
            {
                // 顶部标题栏 - 基于Figma设计
                CompactWorkoutHeader(
                    workoutPlan: workoutViewModel.workoutPlan,
                    progress: workoutViewModel.progress,
                    onBack: {
                        dialogManager.presentDialog(.quitWorkout)
                    }
                )

                // 主要内容区域 - 移除滚动属性
                VStack(spacing: 16)
                {
                    // 统一时间模块显示（仅在休息时间显示，动作时间由ActionTimerView显示）
                    if workoutViewModel.isResting
                    {
                        CompactTimerView(
                            isResting: workoutViewModel.isResting,
                            elapsedTime: workoutViewModel.exerciseElapsedTime,
                            timeLeft: workoutViewModel.timeLeft,
                            isExerciseActive: workoutViewModel.isExerciseActive,
                            onCompleteAction: {
                                // 动作时间模式下点击"动作完成"（现在由底部按钮处理）
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
                    }

                    // 运动信息卡片 - 基于Figma设计，移除滚动和编辑按钮
                    CompactExerciseInfoCard(
                        exercise: workoutViewModel.currentExercise,
                        currentSet: workoutViewModel.currentSet,
                        totalSets: workoutViewModel.getCurrentExerciseTotalSets(),
                        targetReps: workoutViewModel.currentExerciseSet.targetReps,
                        targetWeight: workoutViewModel.currentExerciseSet.targetWeight,
                        targetNotes: workoutViewModel.currentExerciseSet.notes,
                        elapsedTime: workoutViewModel.exerciseElapsedTime,
                        isResting: workoutViewModel.isResting
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                // FooterBox容器 - 动作完成和放弃按钮
                VStack(spacing: 10)
                { // space-y-2.5 ≈ 10pt
                    // 动作完成按钮 - Primary样式，仅在非休息状态显示
                    if !workoutViewModel.isResting
                    {
                        ModernButton(
                            text: "动作完成",
                            action: {
                                dialogManager.presentDialog(.editSet(workoutViewModel.currentExercise, workoutViewModel.currentSet, workoutViewModel))
                            },
                            style: .primary,
                            isDisabled: false,
                            fullWidth: true
                        )
                        .accessibilityLabel("完成当前动作")
                        .accessibilityHint("点击这里记录当前动作的完成并打开参数编辑对话框")
                        .accessibilityAddTraits(.isButton)
                    }

                    // 放弃按钮 - Secondary样式，始终显示
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
                }
                .padding(.horizontal, 24) // px-6
                .padding(.vertical, 12) // py-3 pt-3 pb-5
                .background(
                    // 使用新的扩展背景，确保延伸到底部安全区域，边框已集成在组件内
                    ExtendedFooterBackground(showTopBorder: true)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2) // 增强阴影效果
                .zIndex(1) // 确保Footer在背景之上
            }

            // Dialog Overlay for workout-related dialogs
            if let dialog = dialogManager.presentedDialog
            {
                switch dialog
                {
                case .quitWorkout, .quitCurrentExercise, .quitRemainingExercises:
                    // Background overlay - 白色半透明现代化设计
                    Color.white.opacity(0.9)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture
                        {
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                            {
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

                case let .editSet(exercise, setIndex, workoutViewModel):
                    // Background overlay - 白色半透明现代化设计
                    Color.white.opacity(0.9)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture
                        {
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
                    // Background overlay - 白色半透明现代化设计
                    Color.white.opacity(0.9)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture
                        {
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
        .onAppear
        {
            // 安全检查
            guard !workoutViewModel.workoutPlan.exercises.isEmpty else { return }

            // 简化计时方案：重置计时器（处理应用恢复）
            workoutViewModel.resetTimerIfNeeded()
            workoutViewModel.startExercise()

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2))
            {
                showContent = true
            }
        }
        .onChange(of: workoutViewModel.currentExercise.id)
        { _, _ in
            // 当练习切换时，重新触发内容动画
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1))
            {
                showContent = true
            }
        }
        .onDisappear
        {
            workoutViewModel.pauseExercise()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutCompleted))
        { _ in
            handleWorkoutComplete()
        }
        .onChange(of: workoutViewModel.progress)
        {
            // 保留原有的进度监听作为备用机制
            if workoutViewModel.progress >= 1.0
            {
                handleWorkoutComplete()
            }
        }
    }

    // 统一处理训练完成弹窗，防止重复触发
    private func handleWorkoutComplete()
    {
        guard !hasShownCompletionDialog else { return }
        hasShownCompletionDialog = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            _ = workoutSessionManager.completeWorkout()
            dialogManager.presentDialog(.workoutComplete)
        }
    }
}

// MARK: - Compact Workout Header

struct CompactWorkoutHeader: View
{
    let workoutPlan: WorkoutPlan
    let progress: Double
    let onBack: () -> Void

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    private var progressTextColor: Color
    {
        colorScheme == .light ? .warningLight : .warningDark
    }

    private var primaryTextColor: Color
    {
        // 由于现在使用白色半透明背景，文本颜色应该始终为深色以确保可读性
        Color.appTextSecondary
    }

    var body: some View
    {
        VStack(spacing: 16)
        {
            // 顶部导航栏
            HStack(spacing: 12)
            {
                // 返回按钮
                Button(action: onBack)
                {
                    RoundedRectangle(cornerRadius: 18) // w-9 h-9 = 36px rounded-full
                        .fill(Color.white.opacity(0.8))
                        .background(.ultraThinMaterial)
                        .frame(width: 36, height: 36) // 36x36像素尺寸
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(primaryTextColor) // text-gray-900 dark:text-white
                        )
                        .shadow(color: .appBackground.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())

                // 标题和百分比
                HStack(spacing: 8)
                {
                    Text(workoutPlan.name)
                        .font(.system(size: 24, weight: .semibold))
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
            GeometryReader
            { geometry in
                ZStack(alignment: .leading)
                {
                    // 背景轨道
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appTextMuted.opacity(0.2))
                        .frame(height: 6)

                    // 进度条 - 渐变色填充 (#f97316 → #ec4899 → #a855f7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.97, green: 0.45, blue: 0.09), // #f97316
                                    Color(red: 0.93, green: 0.28, blue: 0.60), // #ec4899
                                    Color(red: 0.66, green: 0.33, blue: 0.97) // #a855f7
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.easeOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            // 使用新的扩展背景，确保延伸到顶部安全区域，边框已集成在组件内
            ExtendedHeaderBackground(showBottomBorder: true)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2) // 增强阴影效果
        .zIndex(1) // 确保Header在背景之上
        .overlay(
            // 临时调试标识 - 确认背景修复生效
            Text("v2.0")
                .font(.caption2)
                .foregroundColor(.green)
                .opacity(0.7)
                .offset(x: -10, y: -10)
        )
    }
}

// MARK: - Action Timer View (新设计)

struct ActionTimerView: View
{
    let elapsedTime: Int
    @Binding var isVisible: Bool
    @State private var rotationAngle: Double = 0
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // 时间格式化逻辑 - 复用CompactTimerView的实现
    private var formattedTime: String
    {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View
    {
        HStack(spacing: 10)
        { // gap-2.5 ≈ 10pt
            // 旋转时钟图标
            Image(systemName: "timer")
                .font(.system(size: 20)) // w-5 h-5
                .foregroundColor(.orange)
                .rotationEffect(.degrees(reduceMotion ? 0 : rotationAngle))
                .animation(
                    reduceMotion ? nil : .linear(duration: 2).repeatForever(autoreverses: false),
                    value: rotationAngle
                )

            VStack(spacing: 4)
            {
                Text("动作时间")
                    .font(.system(size: 12, weight: .medium)) // text-xs font-medium
                    .foregroundColor(colorScheme == .light ? Color.gray.opacity(0.7) : Color.gray.opacity(0.3)) // gray-700 / gray-300

                Text(formattedTime)
                    .font(.system(size: 20, weight: .bold, design: .monospaced)) // text-xl font-mono font-bold
                    .foregroundColor(colorScheme == .light ? Color.orange.opacity(0.8) : Color.orange.opacity(0.6)) // orange-600 / orange-400
            }

            Spacer() // 添加Spacer确保与当前组数模块布局一致
        }
        .frame(maxWidth: .infinity) // 填充可用宽度，与当前组数模块保持一致
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            // Tailwind CSS背景: from-orange-500/10 to-pink-500/10 (浅色) → from-orange-500/20 to-pink-500/20 (深色)
            RoundedRectangle(cornerRadius: 14) // 与当前组数模块保持一致
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .light ? Color.orange.opacity(0.1) : Color.orange.opacity(0.2),
                            colorScheme == .light ? Color.pink.opacity(0.1) : Color.pink.opacity(0.2)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    // 边框: orange-200 (浅色) → orange-800/50 (深色)
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            colorScheme == .light ? Color.orange.opacity(0.2) : Color.orange.opacity(0.5),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(reduceMotion ? 1.0 : (isVisible ? 1.0 : 0.95)) // 入场动画: scale: 0.95 → 1.0
        .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: isVisible) // 0.3s弹回正常大小
        .onAppear
        {
            // 启动图标旋转动画
            if !reduceMotion
            {
                rotationAngle = 360
            }
        }
        .onChange(of: elapsedTime)
        { _, newValue in
            // 当时间重置为0或接近0时（通常表示新练习开始），重新触发微动画
            if newValue <= 3 && !reduceMotion
            {
                withAnimation(.easeOut(duration: 0.3))
                {
                    // 重新触发微妙的scale动画
                    rotationAngle = 360
                }
            }
        }
    }
}

// MARK: - Compact Exercise Info Card (版本1.3增强)

struct CompactExerciseInfoCard: View
{
    let exercise: Exercise
    let currentSet: Int
    let totalSets: Int
    let targetReps: Int
    let targetWeight: Double
    let targetNotes: String?
    let elapsedTime: Int
    let isResting: Bool

    @State private var isVisible: Bool = false
    @State private var shimmerOffset: CGFloat = -200

    private var formattedTime: String
    {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // 版本1.3: 计算整个训练计划的总时长
    private var formattedTotalTime: String
    {
        let totalTime = workoutViewModel.totalWorkoutTime
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // 版本1.3: 从workoutViewModel获取当前练习的所有组数信息
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var allExerciseSets: [ExerciseSet]
    {
        workoutViewModel.workoutPlan.exercises.filter { $0.exercise.name == exercise.name }
    }

    // 统一的重量格式化函数
    private func formatWeight(_ weight: Double) -> String
    {
        if weight == 0
        {
            return "自重"
        }
        else if weight.truncatingRemainder(dividingBy: 1) == 0
        {
            return String(format: "%.0f", weight)
        }
        else
        {
            return String(format: "%.1f", weight)
        }
    }

    private var nextSetInfo: String?
    {
        // 使用ViewModel的当前状态，确保数据一致性
        let currentExerciseIndex = workoutViewModel.currentExerciseIndex
        _ = workoutViewModel.currentSet
        let allExercises = workoutViewModel.workoutPlan.exercises

        // 确保索引有效
        guard currentExerciseIndex < allExercises.count
        else
        {
            return nil
        }

        let currentExercise = allExercises[currentExerciseIndex].exercise
        let exerciseSets = allExercises.filter { $0.exercise.id == currentExercise.id }

        // 找到当前ExerciseSet在相同练习中的位置
        guard let currentPositionInExercise = exerciseSets.firstIndex(where: { $0.id == allExercises[currentExerciseIndex].id })
        else
        {
            return nil
        }

        // 检查是否还有下一组（相同练习）
        if currentPositionInExercise < exerciseSets.count - 1
        {
            let nextSet = exerciseSets[currentPositionInExercise + 1]
            let weightText = formatWeight(nextSet.targetWeight)
            return "下一组: \(currentExercise.name) \(nextSet.targetReps)次 * \(weightText)公斤"
        }

        // 检查是否还有下一个练习
        // 找到下一个不同练习的第一个ExerciseSet
        var nextIndex = currentExerciseIndex + 1
        while nextIndex < allExercises.count
        {
            let nextExerciseSet = allExercises[nextIndex]
            if nextExerciseSet.exercise.id != currentExercise.id
            {
                let weightText = formatWeight(nextExerciseSet.targetWeight)
                return "下一组: \(nextExerciseSet.exercise.name) \(nextExerciseSet.targetReps)次 * \(weightText)公斤"
            }
            nextIndex += 1
        }

        return nil
    }

    private var displayNotes: String?
    {
        guard let targetNotes = targetNotes
        else
        {
            return nil
        }

        let trimmedNotes = targetNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedNotes.isEmpty ? nil : trimmedNotes
    }

    // 限制卡片最大高度，超出后在卡片内部滚动
    private var cardMaxHeight: CGFloat
    {
        let screenHeight = UIScreen.main.bounds.height
        let heightRatio: CGFloat = isResting ? 0.50 : 0.62
        return max(320, screenHeight * heightRatio)
    }

    var body: some View
    {
        ScrollView(.vertical, showsIndicators: true)
        {
            VStack(spacing: 12)
            { // space-y-3 ≈ 12pt
                // 运动名称
                Text(exercise.name)
                    .font(.system(size: 32, weight: .bold)) // text-2xl font-bold
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.warning, Color.appAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center) // 居中对齐

                // 动作时间计时器 - 根据isResting状态决定是否显示
                if !isResting
                {
                    ActionTimerView(
                        elapsedTime: elapsedTime,
                        isVisible: $isVisible
                    )
                    .id("action-timer-\(elapsedTime)") // 强制更新ID
                    .scaleEffect(isVisible ? 1.0 : 0.95) // 入场动画
                    .animation(.easeOut(duration: 0.3), value: isVisible)
                }

                // 组数、次数和重量模块 - 增强版本
                VStack(spacing: 12)
                {
                    // 当前组数模块 - 蓝色背景
                    HStack
                    {
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

                    // 次数和重量模块 - 水平排列，基于Figma设计
                    HStack(spacing: 12)
                    {
                        // 次数模块 - 绿色主题
                        VStack(spacing: 8)
                        {
                            HStack(spacing: 6)
                            {
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
                        VStack(spacing: 8)
                        {
                            HStack(spacing: 6)
                            {
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
                    if let nextInfo = nextSetInfo
                    {
                        HStack
                        {
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

                    if let notes = displayNotes
                    {
                        HStack(alignment: .top, spacing: 8)
                        {
                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.warning)
                                .padding(.top, 1)

                            Text(notes)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.warning.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                    }
                }

                // 版本1.3: 训练计时
                HStack
                {
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
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxHeight: cardMaxHeight, alignment: .top)
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
                            reduceMotion ? nil :
                                .easeInOut(duration: 2.5)
                                .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                )
                .shadow(color: .appBackground.opacity(0.12), radius: 25, x: 0, y: 10)
        )
        .scaleEffect(reduceMotion ? 1.0 : (isVisible ? 1.0 : 0.95))
        .opacity(reduceMotion ? 1.0 : (isVisible ? 1.0 : 0))
        .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 20))
        .animation(
            reduceMotion ? nil : .spring(response: 0.8, dampingFraction: 0.8).delay(0.2),
            value: isVisible
        )
        .onAppear
        {
            if reduceMotion
            {
                isVisible = true
                shimmerOffset = 0
            }
            else
            {
                withAnimation
                {
                    isVisible = true
                    // 启动光泽动画
                    shimmerOffset = 200
                }
            }
        }
        .onChange(of: exercise.id)
        { _, _ in
            // 当练习切换时，重新触发入场动画
            if reduceMotion
            {
                isVisible = true
                shimmerOffset = 0
            }
            else
            {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2))
                {
                    isVisible = true
                    // 重新启动光泽动画
                    shimmerOffset = 200
                }
            }
        }
        .onTapGesture
        {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Compact Complete Button

// MARK: - Compact Timer View (Unified Time Module)

struct CompactTimerView: View
{
    let isResting: Bool
    let elapsedTime: Int
    let timeLeft: Int
    let isExerciseActive: Bool
    let onCompleteAction: () -> Void
    let onSkipRest: () -> Void

    @State private var isVisible: Bool = false
    @State private var shimmerOffset: CGFloat = -200
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var formattedTime: String
    {
        if isResting
        {
            // 休息时间：显示倒计时
            let minutes = timeLeft / 60
            let seconds = timeLeft % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        else
        {
            // 动作时间：显示正计时
            let minutes = elapsedTime / 60
            let seconds = elapsedTime % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    private var buttonTitle: String
    {
        if isResting
        {
            return "跳过休息"
        }
        else
        {
            return "动作完成"
        }
    }

    var body: some View
    {
        VStack(spacing: 16)
        {
            // 标题区域 - 固定高度
            HStack
            {
                if isResting
                {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.appPrimary)

                    Text("休息时间")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
                else
                {
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
                    if isResting
                    {
                        print("🔚 DEBUG: User clicked skip rest - timeLeft: \(timeLeft)")
                        onSkipRest()
                    }
                    else
                    {
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
                            reduceMotion ? nil :
                                .easeInOut(duration: 2.5)
                                .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                )
                .shadow(color: .appBackground.opacity(0.12), radius: 25, x: 0, y: 10)
        )
        .scaleEffect(reduceMotion ? 1.0 : (isVisible ? 1.0 : 0.95))
        .opacity(reduceMotion ? 1.0 : (isVisible ? 1.0 : 0))
        .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 20))
        .animation(
            reduceMotion ? nil : .spring(response: 0.8, dampingFraction: 0.8).delay(0.3),
            value: isVisible
        )
        .onAppear
        {
            if reduceMotion
            {
                isVisible = true
                shimmerOffset = 0
            }
            else
            {
                withAnimation
                {
                    isVisible = true
                    // 启动光泽动画
                    shimmerOffset = 200
                }
            }
        }
        .onTapGesture
        {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isResting ? "休息时间模块" : "动作时间模块")
    }
}

// MARK: - Preview

#Preview
{
    WorkoutScreen(workoutPlan: MockDataProvider.previewWorkout)
        .environmentObject(NavigationManager.preview)
        .environmentObject(WorkoutViewModel(workoutPlan: MockDataProvider.previewWorkout))
        .preferredColorScheme(.dark)
}

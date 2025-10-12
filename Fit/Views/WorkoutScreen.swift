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
    @StateObject private var workoutViewModel: WorkoutViewModel
    @State private var showContent: Bool = false

    init(workoutPlan: WorkoutPlan) {
        // 安全验证
        guard !workoutPlan.exercises.isEmpty else {
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
            _workoutViewModel = StateObject(wrappedValue: WorkoutViewModel(workoutPlan: safeWorkoutPlan))
            return
        }

        _workoutViewModel = StateObject(wrappedValue: WorkoutViewModel(workoutPlan: workoutPlan))
    }

    var body: some View {
        ZStack {
            // 简化背景 - 基于Figma设计
            CompactWorkoutBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部标题栏 - 基于Figma设计
                CompactWorkoutHeader(
                    workoutPlan: workoutViewModel.workoutPlan,
                    progress: workoutViewModel.progress,
                    onBack: {
                        navigationManager.quitWorkout()
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
                        navigationManager.presentDialog(.editSet(workoutViewModel.currentExercise, workoutViewModel.currentSet, workoutViewModel))
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
                        totalSets: workoutViewModel.getCompletedSetsCount(for: workoutViewModel.currentExercise) + workoutViewModel.getRemainingSetsCount(for: workoutViewModel.currentExercise),
                        targetReps: workoutViewModel.currentExerciseSet.targetReps,
                        targetWeight: workoutViewModel.currentExerciseSet.targetWeight,
                        elapsedTime: workoutViewModel.exerciseElapsedTime
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                // 底部固定按钮区域 - 只保留放弃按钮并居中
                CompactQuitButton(
                    onQuit: {
                        navigationManager.quitWorkout()
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            // 对话框覆盖层
            if let dialog = navigationManager.presentedDialog {
                CompactDialogOverlay(dialog: dialog, navigationManager: navigationManager)
                    .environmentObject(workoutViewModel)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .onAppear {
            // 安全检查
            guard !workoutViewModel.workoutPlan.exercises.isEmpty else { return }

            workoutViewModel.startExercise()

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
        }
        .onDisappear {
            workoutViewModel.pauseExercise()
        }
        .onChange(of: workoutViewModel.progress) { newValue in
            // 监听进度变化，当达到100%时触发训练完成对话框
            if newValue >= 1.0 {
                print("🎉 DEBUG: Workout completed! Progress reached 100%")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigationManager.completeWorkout()
                }
            }
        }
    }
}

// MARK: - Compact Workout Background
struct CompactWorkoutBackground: View {
    var body: some View {
        ZStack {
            // 基于Figma设计的渐变背景
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.93), // rgba(255, 247, 237, 1)
                    Color(red: 1.0, green: 0.95, blue: 0.98), // rgba(253, 242, 248, 1)
                    Color(red: 0.95, green: 0.91, blue: 1.0)  // rgba(243, 232, 255, 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 模糊光斑效果
            Circle()
                .fill(Color.orange.opacity(0.1))
                .frame(width: 384, height: 384)
                .offset(x: 180, y: 132)
                .blur(radius: 100)

            Circle()
                .fill(Color.pink.opacity(0.08))
                .frame(width: 320, height: 320)
                .offset(x: -74, y: 407)
                .blur(radius: 80)
        }
    }
}

// MARK: - Compact Workout Header
struct CompactWorkoutHeader: View {
    let workoutPlan: WorkoutPlan
    let progress: Double
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // 顶部导航栏
            HStack(spacing: 12) {
                // 返回按钮
                Button(action: onBack) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 36, height: 32)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                // 标题和百分比
                HStack(spacing: 8) {
                    Text("快速训练计划")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景轨道
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)

                    // 进度条
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 17)
        .padding(.top, 13)
        .background(
            // 基于Figma设计的半透明背景
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.08), radius: 32, x: 0, y: 8)
        )
    }
}


// MARK: - Compact Exercise Info Card
struct CompactExerciseInfoCard: View {
    let exercise: Exercise
    let currentSet: Int
    let totalSets: Int
    let targetReps: Int
    let targetWeight: Double
    let elapsedTime: Int

    private var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 16) {
            // 运动名称
            Text(exercise.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity)


            // 组数、次数和重量模块 - 基于Figma设计的优化布局，移除编辑按钮
            VStack(spacing: 12) {
                // 当前组数模块 - 蓝色背景
                HStack {
                    Image(systemName: "number")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)

                    Text("当前组数：")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    Text("\(currentSet) / \(totalSets)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)

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
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )

                // 次数和重量模块 - 水平排列，基于Figma设计
                HStack(spacing: 12) {
                    // 次数模块 - 绿色主题
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "target")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.green)
                        }

                        Text("次数")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)

                        Text("\(targetReps)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // 重量模块 - 紫色主题
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "scalemass.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.purple)
                        }

                        Text("重量 (kg)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)

                        if targetWeight > 0 {
                            Text("\(Int(targetWeight))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.purple)
                        } else {
                            Text("自重")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.purple)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.purple.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }

          }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.08), radius: 32, x: 0, y: 8)
        )
    }
}

// MARK: - Compact Complete Button
struct CompactCompleteButton: View {
    let isDisabled: Bool
    let onComplete: () -> Void

    var body: some View {
        Button(action: onComplete) {
            Text("动作完成")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48) // 减少高度
                .background(
                    LinearGradient(
                        colors: [Color.green, Color(red: 0, green: 0.6, blue: 0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14)) // 稍微减小圆角
                .shadow(color: .green.opacity(0.3), radius: 15, x: 0, y: 6) // 减小阴影
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Compact Quit Button
struct CompactQuitButton: View {
    let onQuit: () -> Void

    var body: some View {
        Button(action: onQuit) {
            Text("放弃动作")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 48) // 与完成按钮保持一致高度
                .background(Color.white.opacity(0.6)) // 稍微增加透明度
                .clipShape(RoundedRectangle(cornerRadius: 14)) // 与完成按钮保持一致圆角
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4) // 减小阴影
        }
    }
}

// MARK: - Compact Timer View (Unified Time Module)
struct CompactTimerView: View {
    let isResting: Bool
    let elapsedTime: Int
    let timeLeft: Int
    let isExerciseActive: Bool
    let onCompleteAction: () -> Void
    let onSkipRest: () -> Void

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

    private var buttonColor: Color {
        if isResting {
            return .gray
        } else {
            return .green
        }
    }

    private var buttonTextColor: Color {
        if isResting {
            return .white
        } else {
            return .white
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
            // 标题区域
            HStack {
                if isResting {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)

                    Text("休息时间")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "figure.run")
                        .font(.system(size: 18))
                        .foregroundColor(.green)

                    Text("动作时间")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                }

                Spacer()
            }

            // 时间显示
            Text(formattedTime)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(isResting ? .blue : .green)

            // 按钮 - 动态颜色和标题
            Button(action: {
                if isResting {
                    print("🔚 DEBUG: User clicked skip rest - timeLeft: \(timeLeft)")
                    onSkipRest()
                } else {
                    print("✅ DEBUG: User clicked complete exercise - elapsedTime: \(elapsedTime)")
                    onCompleteAction()
                }
            }) {
                Text(buttonTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(buttonColor, in: RoundedRectangle(cornerRadius: 14))
                    .shadow(color: buttonColor.opacity(0.3), radius: 15, x: 0, y: 6)
            }
            .disabled(!isExerciseActive && !isResting)
            .opacity(!isExerciseActive && !isResting ? 0.5 : 1.0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
    }
}

// MARK: - Compact Dialog Overlay
struct CompactDialogOverlay: View {
    let dialog: DialogType
    let navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

    var body: some View {
        ZStack {
            switch dialog {
            case .editSet(let exercise, let setIndex, _):
                CompactEditSetDialog(
                    exercise: exercise,
                    setIndex: setIndex,
                    onDismiss: {
                        navigationManager.dismissDialog()
                    }
                )
            case .completion:
                CompactCompletionDialog(onDismiss: {
                    navigationManager.dismissDialog()
                })
            case .quitWorkout:
                EnhancedQuitDialog(
                    onQuitCurrentExercise: {
                        print("🏃 DEBUG: User chose to skip current exercise")
                        workoutViewModel.moveToNextExercise()
                        navigationManager.dismissDialog()
                    },
                    onQuitAll: {
                        print("❌ DEBUG: User chose to quit all exercises")
                        navigationManager.popToRoot()
                    },
                    onCancel: {
                        print("🔄 DEBUG: User chose to continue training")
                        navigationManager.dismissDialog()
                    },
                    currentExerciseName: workoutViewModel.currentExercise.name
                )
            case .quitCurrentExercise:
                EnhancedQuitDialog(
                    onQuitCurrentExercise: {
                        print("🏃 DEBUG: User chose to skip current exercise")
                        workoutViewModel.moveToNextExercise()
                        navigationManager.dismissDialog()
                    },
                    onQuitAll: {
                        print("❌ DEBUG: User chose to quit all exercises")
                        navigationManager.popToRoot()
                    },
                    onCancel: {
                        print("🔄 DEBUG: User chose to continue training")
                        navigationManager.dismissDialog()
                    },
                    currentExerciseName: workoutViewModel.currentExercise.name
                )
            case .quitRemainingExercises:
                EnhancedQuitDialog(
                    onQuitCurrentExercise: {
                        print("🏃 DEBUG: User chose to skip current exercise")
                        workoutViewModel.moveToNextExercise()
                        navigationManager.dismissDialog()
                    },
                    onQuitAll: {
                        print("❌ DEBUG: User chose to quit all exercises")
                        navigationManager.popToRoot()
                    },
                    onCancel: {
                        print("🔄 DEBUG: User chose to continue training")
                        navigationManager.dismissDialog()
                    },
                    currentExerciseName: workoutViewModel.currentExercise.name
                )
            case .workoutComplete:
                CompactWorkoutCompleteDialog(
                    onDismiss: {
                        navigationManager.popToRoot()
                    }
                )
            }
        }
        .zIndex(1000)
    }
}

// MARK: - Edit Set Dialog with Parameter Input
struct CompactEditSetDialog: View {
    let exercise: Exercise
    let setIndex: Int
    let onDismiss: () -> Void
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var navigationManager: NavigationManager

    @State private var reps: String = ""
    @State private var weight: String = ""

    init(exercise: Exercise, setIndex: Int, onDismiss: @escaping () -> Void) {
        self.exercise = exercise
        self.setIndex = setIndex
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("动作完成")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            Text("完成 \(exercise.name) 第\(setIndex)组")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            // 输入区域
            VStack(spacing: 16) {
                // 次数输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("次数")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("请输入完成的次数", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                }

                // 重量输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("重量 (kg)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("请输入使用的重量", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                }
            }

            // 按钮区域
            HStack(spacing: 12) {
                // 取消按钮
                Button("取消") {
                    onDismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.primary)

                // 保存按钮
                Button("保存") {
                    saveParameters()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green, in: RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.white)
                .disabled(reps.isEmpty || weight.isEmpty)
                .opacity(reps.isEmpty || weight.isEmpty ? 0.5 : 1.0)
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 320)
        .onAppear {
            loadDefaultParameters()
        }
    }

    private func loadDefaultParameters() {
        let defaultParams = workoutViewModel.getDefaultParametersForCurrentExercise()
        reps = String(defaultParams.reps)
        weight = defaultParams.weight > 0 ? String(defaultParams.weight) : "自重"
    }

    private func saveParameters() {
        guard let actualReps = Int(reps) else {
            print("❌ ERROR: Invalid reps input: \(reps)")
            return
        }

        let actualWeight: Double
        if weight.lowercased() == "自重" {
            actualWeight = 0.0
        } else {
            guard let weightValue = Double(weight) else {
                print("❌ ERROR: Invalid weight input: \(weight)")
                return
            }
            actualWeight = weightValue
        }

        print("💾 DEBUG: saveParameters called - reps: \(actualReps), weight: \(actualWeight)")

        // 添加按钮禁用状态，防止重复点击
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let saveButton = window.rootViewController?.view.subviews.compactMap { $0 as? UIButton }.first
            saveButton?.isEnabled = false
        }

        // 使用新的方法保存参数并完成练习
        workoutViewModel.completeExerciseWith(actualReps: actualReps, actualWeight: actualWeight)

        // 延迟关闭对话框，确保状态更新完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("🔚 DEBUG: Dialog dismissed after delay")
            onDismiss()

            // 重新启用按钮
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let saveButton = window.rootViewController?.view.subviews.compactMap { $0 as? UIButton }.first
                saveButton?.isEnabled = true
            }
        }
    }
}

struct CompactCompletionDialog: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("训练完成")
                .font(.system(size: 18, weight: .semibold))

            Button("确定") {
                onDismiss()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.green, in: RoundedRectangle(cornerRadius: 8))
            .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 300)
    }
}

struct CompactQuitDialog: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("放弃训练")
                .font(.system(size: 18, weight: .semibold))

            Text("确定要放弃当前训练吗？")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Button("取消") {
                    onCancel()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))

                Button("放弃") {
                    onConfirm()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.red, in: RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 300)
    }
}

struct CompactWorkoutCompleteDialog: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 训练完成！")
                .font(.system(size: 18, weight: .semibold))

            Text("恭喜你完成了今天的训练")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Button("完成") {
                onDismiss()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.green, in: RoundedRectangle(cornerRadius: 8))
            .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 300)
    }
}

// MARK: - Preview
#Preview {
    WorkoutScreen(workoutPlan: MockDataProvider.previewWorkout)
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
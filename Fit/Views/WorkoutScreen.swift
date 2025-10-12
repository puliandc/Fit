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

                // 主要内容区域 - 滚动视图
                ScrollView {
                    VStack(spacing: 16) {
                        // 休息时间覆盖层（休息时显示）
                        if workoutViewModel.isResting {
                            CompactRestTimerView(
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

  
                        // 运动信息卡片 - 基于Figma设计
                        CompactExerciseInfoCard(
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
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                // 底部固定按钮区域 - 基于Figma设计
                VStack(spacing: 12) {
                    CompactCompleteButton(
                        isDisabled: workoutViewModel.isResting,
                        onComplete: {
                            workoutViewModel.completeExercise()
                        }
                    )

                    CompactQuitButton(
                        onQuit: {
                            navigationManager.quitWorkout()
                        }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    // 按钮区域背景
                    LinearGradient(
                        colors: [Color.appBackground.opacity(0.9), Color.appBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // 对话框覆盖层
            if let dialog = navigationManager.presentedDialog {
                CompactDialogOverlay(dialog: dialog, navigationManager: navigationManager)
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
                            Image("back-icon")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.orange)
                                .frame(width: 16, height: 16)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                // 标题
                Text("快速训练计划")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 进度条
            HStack {
                Text("训练进度")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
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
    let onEditSet: () -> Void

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

  
            // 组数、次数和重量模块 - 基于Figma设计的优化布局
            VStack(spacing: 12) {
                // 运动时间模块 - 橙色背景
                HStack {
                    Image("time-icon")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.orange)

                    Text("动作时间：")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    Text(formattedTime)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.97, blue: 0.93),
                                    Color(red: 1.0, green: 0.95, blue: 0.98)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )

                // 当前组数模块 - 蓝色背景
                HStack {
                    Image("sets-icon")
                        .resizable()
                        .frame(width: 20, height: 20)
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

                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12))
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
                            Image("weight-icon")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.purple)

                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12))
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
                            Text("0")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.purple.opacity(0.5))
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

                // 编辑按钮 - 如果有重量显示编辑，否则显示添加重量
                HStack {
                    Spacer()

                    Button(action: onEditSet) {
                        HStack(spacing: 6) {
                            if targetWeight > 0 {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.purple)

                                Text("编辑")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.purple.opacity(0.7))
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)

                                Text("添加重量")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(targetWeight > 0 ? Color.purple.opacity(0.1) : Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(targetWeight > 0 ? Color.purple.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }

                    Spacer()
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
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.green, Color(red: 0, green: 0.6, blue: 0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .green.opacity(0.3), radius: 25, x: 0, y: 12)
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
                .frame(height: 48)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
        }
    }
}

// MARK: - Compact Rest Timer View
struct CompactRestTimerView: View {
    let timeLeft: Int
    let onSkip: () -> Void

    private var formattedTime: String {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        Button(action: onSkip) {
            VStack(spacing: 16) {
                // 休息标题
                HStack {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)

                    Text("休息时间")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)

                    Spacer()
                }

                // 时间显示
                Text(formattedTime)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue)

                // 跳过提示
                HStack {
                    Text("点击跳过休息")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.7))
                    .shadow(color: .black.opacity(0.08), radius: 25, x: 0, y: 12)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Dialog Overlay
struct CompactDialogOverlay: View {
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
                CompactQuitDialog(
                    onConfirm: {
                        navigationManager.popToRoot()
                    },
                    onCancel: {
                        navigationManager.dismissDialog()
                    }
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

// MARK: - Simple Dialog Components (placeholder)
struct CompactEditSetDialog: View {
    let exercise: Exercise
    let setIndex: Int
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("编辑参数")
                .font(.system(size: 18, weight: .semibold))

            Text("编辑 \(exercise.name) 第\(setIndex)组")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Button("取消") {
                onDismiss()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 300)
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
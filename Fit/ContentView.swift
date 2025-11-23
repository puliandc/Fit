//
//  ContentView.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

// MARK: - Weight Formatting Helper

extension ContentView
{
    private func formatWeight(_ weight: Double) -> String
    {
        if weight == 0
        {
            return "自重"
        }
        else if abs(weight.truncatingRemainder(dividingBy: 1)) < 0.0001
        {
            return String(format: "%.0f", weight)
        }
        else
        {
            return String(format: "%.1f", weight)
        }
    }
}

struct ContentView: View
{
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dialogManager: DialogManager
    @EnvironmentObject var workoutSessionManager: WorkoutSessionManager

    // Helper function to format time
    private func formatTime(_ seconds: Int) -> String
    {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    var body: some View
    {
        ZStack
        {
            switch navigationManager.currentScreen
            {
            case .main:
                MainScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    ))

            case let .workout(workoutPlan):
                if let workoutViewModel = workoutSessionManager.currentWorkoutViewModel
                {
                    WorkoutScreen(workoutPlan: workoutPlan)
                        .environmentObject(workoutViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
                else
                {
                    // Fallback if no WorkoutViewModel exists
                    Text("训练数据加载中...")
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.appBackground)
                }

            case .settings:
                SettingsScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .history:
                HistoryScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }

            // Dialog Overlay
            if let dialog = dialogManager.presentedDialog
            {
                // Only show background overlay for non-workout dialogs
                // Workout dialogs (quit, editSet, etc.) are handled by WorkoutScreen's CompactDialogOverlay
                switch dialog
                {
                case .quitWorkout, .quitCurrentExercise, .quitRemainingExercises, .editSet:
                    // 训练相关的对话框不显示遮罩，由WorkoutScreen自己处理
                    EmptyView()
                default:
                    // 其他对话框显示背景遮罩
                    Color.appBackground.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture
                        {
                            dialogManager.dismissDialog()
                        }
                }

                switch dialog
                {
                case let .editSet(_, _, workoutViewModel):
                    let defaults = workoutViewModel.getDefaultParametersForCurrentExercise()
                    UniversalDialog(
                        type: .input(
                            title: "动作完成",
                            subtitle: "请输入实际完成次数和重量",
                            defaultReps: String(defaults.reps),
                            defaultWeight: formatWeight(defaults.weight),
                            onConfirm: { reps, weight, notes in
                                guard let actualReps = Int(reps)
                                else
                                {
                                    return
                                }

                                // 处理重量输入：如果是"自重"或空字符串，则设为0
                                let actualWeight: Double
                                if weight.lowercased() == "自重" || weight.isEmpty
                                {
                                    actualWeight = 0.0
                                }
                                else
                                {
                                    guard let weightValue = Double(weight)
                                    else
                                    {
                                        return
                                    }
                                    actualWeight = weightValue
                                }

                                workoutViewModel.completeExerciseWith(actualReps: actualReps, actualWeight: actualWeight, notes: notes)
                            }
                        ),
                        onDismiss: {
                            dialogManager.dismissDialog()
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                case .completion:
                    UniversalDialog(
                        type: .input(
                            title: "完成记录",
                            subtitle: "请输入您实际完成的次数和重量",
                            defaultReps: "",
                            defaultWeight: "",
                            onConfirm: { _, _, _ in }
                        ),
                        onDismiss: {
                            dialogManager.dismissDialog()
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                case .quitWorkout, .quitCurrentExercise, .quitRemainingExercises:
                    // 所有训练相关的对话框都应该由WorkoutScreen的CompactDialogOverlay处理
                    // 这样可以避免双层弹窗冲突，确保用户看到的是增强版对话框
                    EmptyView()

                case .workoutComplete:
                    Group
                    {
                        if let workoutViewModel = workoutSessionManager.currentWorkoutViewModel
                        {
                            UniversalDialog(
                                type: .completion(
                                    title: "训练完成!",
                                    message: "恭喜您完成了今天的训练！",
                                    stats: [
                                        ("总时长:", formatTime(workoutViewModel.totalWorkoutTime)),
                                        ("完成组数:", "\(workoutViewModel.completedSets.count) 组")
                                    ]
                                ),
                                onDismiss: {
                                    dialogManager.dismissDialog()
                                    // 在弹窗关闭后才清理WorkoutViewModel
                                    workoutSessionManager.cleanupAfterWorkoutComplete()
                                    navigationManager.popToRoot()
                                }
                            )
                        }
                        else
                        {
                            EmptyView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: navigationManager.currentScreen)
        .animation(.easeInOut(duration: 0.3), value: dialogManager.presentedDialog)
        .onAppear
        {
            // ContentView loaded successfully
        }
    }
}

struct SettingsScreen: View
{
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View
    {
        VStack(spacing: 20)
        {
            Text("设置")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.appText)
                .padding(.top, 40)

            Button("返回主页")
            {
                navigationManager.popToRoot()
            }
            .buttonStyle(SettingsButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

struct HistoryScreen: View
{
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View
    {
        VStack(spacing: 20)
        {
            Text("历史记录")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.appText)
                .padding(.top, 40)

            Button("返回主页")
            {
                navigationManager.popToRoot()
            }
            .buttonStyle(SettingsButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

// MARK: - Settings Button Style

struct SettingsButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        configuration.label
            .foregroundColor(.appText)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.appPrimary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// NOTE: WorkoutCategory extension removed as WorkoutCategory enum was deleted during model refactoring

// MARK: - Preview

#Preview
{
    ContentView()
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}

//
//  ContentView.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack {
            switch navigationManager.currentScreen {
            case .main:
                MainScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    ))

            case .workout(let workoutPlan):
                if let workoutViewModel = navigationManager.currentWorkoutViewModel {
                    WorkoutScreen(workoutPlan: workoutPlan)
                        .environmentObject(workoutViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    // Fallback if no WorkoutViewModel exists
                    Text("训练数据加载中...")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
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
            if let dialog = navigationManager.presentedDialog {
                // Only show background overlay for non-workout dialogs
                // Workout dialogs (quit, editSet, etc.) are handled by WorkoutScreen's CompactDialogOverlay
                switch dialog {
                case .quitWorkout, .quitCurrentExercise, .quitRemainingExercises, .editSet:
                    // 训练相关的对话框不显示遮罩，由WorkoutScreen自己处理
                    EmptyView()
                default:
                    // 其他对话框显示背景遮罩
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            navigationManager.dismissDialog()
                        }
                }

                switch dialog {
                case .editSet(let exercise, let setIndex, let workoutViewModel):
                    EditSetDialog(
                        exercise: exercise,
                        setIndex: setIndex,
                        onDismiss: {
                            navigationManager.dismissDialog()
                        },
                        workoutViewModel: workoutViewModel
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                case .completion:
                    CompletionDialog(onDismiss: {
                        navigationManager.dismissDialog()
                    })
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                case .quitWorkout, .quitCurrentExercise, .quitRemainingExercises:
                    // 所有训练相关的对话框都应该由WorkoutScreen的CompactDialogOverlay处理
                    // 这样可以避免双层弹窗冲突，确保用户看到的是增强版对话框
                    EmptyView()

                case .workoutComplete:
                    Group {
                        if let workoutViewModel = navigationManager.currentWorkoutViewModel {
                            WorkoutCompleteDialog(
                                onDismiss: {
                                    navigationManager.dismissDialog()
                                    navigationManager.popToRoot()
                                },
                                workoutViewModel: workoutViewModel
                            )
                        } else {
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
        .animation(.easeInOut(duration: 0.3), value: navigationManager.presentedDialog)
        .onAppear {
            // ContentView loaded successfully
        }
    }
}

struct SettingsScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            Text("设置")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)

            Button("返回主页") {
                navigationManager.popToRoot()
            }
            .buttonStyle(SettingsButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct HistoryScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            Text("历史记录")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)

            Button("返回主页") {
                navigationManager.popToRoot()
            }
            .buttonStyle(SettingsButtonStyle())

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Settings Button Style
struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Extensions for WorkoutCategory (keeping existing code)
extension WorkoutCategory {
    var systemImage: String {
        switch self {
        case .fullBody:
            return "figure.walk"
        case .upperBody:
            return "figure.arms.open"
        case .lowerBody:
            return "figure.run"
        case .core:
            return "circle.circle" // iOS 15.0+ compatible alternative
        case .cardio:
            return "heart.fill"
        case .hiit:
            return "flame.fill"
        case .yoga:
            return "figure.yoga"
        case .strength:
            return "dumbbell.fill"
        case .endurance:
            return "timer"
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
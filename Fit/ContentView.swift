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
                WorkoutScreen(workoutPlan: workoutPlan)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

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

                case .quitWorkout:
                    QuitDialog(
                        onConfirm: {
                            navigationManager.popToRoot()
                        },
                        onCancel: {
                            navigationManager.dismissDialog()
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

                case .workoutComplete:
                    WorkoutCompleteDialog(
                        onDismiss: {
                            navigationManager.popToRoot()
                        }
                    )
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
            print("🚀 ContentView appeared successfully!")
            print("📱 NavigationManager state: \(navigationManager.currentScreen)")
        }
    }
}

// MARK: - Settings Screen (Placeholder)
struct SettingsScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack {
            Text("设置")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()

            Button("返回主页") {
                navigationManager.popToRoot()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - History Screen (Placeholder)
struct HistoryScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack {
            Text("历史记录")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()

            Button("返回主页") {
                navigationManager.popToRoot()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
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
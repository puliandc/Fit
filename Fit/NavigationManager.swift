//
//  NavigationManager.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    @Published var currentScreen: AppScreen = .main
    @Published var navigationStack: [AppScreen] = []  // iOS 15.0 compatible navigation stack
    @Published var presentedDialog: DialogType?

    // 版本1.3: WorkoutViewModel管理
    @Published var currentWorkoutViewModel: WorkoutViewModel?

    init() {
        print("🎯 NavigationManager initialized with currentScreen: \(currentScreen)")
    }

    // MARK: - Navigation Methods (iOS 15.0+ Compatible)
    func navigate(to screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
            navigationStack.append(screen)
        }
    }

    func goBack() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
            if let previousScreen = navigationStack.last {
                currentScreen = previousScreen
            } else {
                currentScreen = .main
            }
        } else {
            navigate(to: .main)
        }
    }

    func popToRoot() {
        navigationStack.removeAll()
        currentScreen = .main
    }

    // MARK: - Dialog Methods
    func presentDialog(_ dialog: DialogType) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            presentedDialog = dialog
        }
    }

    func dismissDialog() {
        withAnimation(.easeInOut(duration: 0.2)) {
            presentedDialog = nil
        }
    }

    // MARK: - Workout Navigation (iOS 15.0+ Compatible)
    func startWorkout(_ plan: WorkoutPlan) {
        print("🐛 DEBUG: NavigationManager.startWorkout called")
        print("🐛 DEBUG: Workout plan: \(plan.name)")
        print("🐛 DEBUG: Exercise count: \(plan.exercises.count)")
        print("🐛 DEBUG: Current screen before navigation: \(currentScreen)")
        print("🐛 DEBUG: Navigation stack depth: \(navigationStack.count)")

        // 安全验证
        guard !plan.exercises.isEmpty else {
            print("🚨 ERROR: Cannot start workout - no exercises available")
            return
        }

        // 每次都创建全新的WorkoutViewModel，确保状态完全重置
        print("🐛 DEBUG: Creating fresh WorkoutViewModel for plan: \(plan.name)")
        currentWorkoutViewModel = WorkoutViewModel(workoutPlan: plan)

        print("🐛 DEBUG: Navigating to workout screen...")
        navigate(to: .workout(plan))
        print("🐛 DEBUG: Navigation complete. Current screen: \(currentScreen)")
    }

    func pauseWorkout() {
        // Handle workout pause logic
    }

    func resumeWorkout() {
        // Handle workout resume logic
    }

    func completeWorkout() {
        presentDialog(.workoutComplete)
    }

    func quitWorkout() {
        presentDialog(.quitWorkout)
    }

    func quitCurrentExercise() {
        presentDialog(.quitCurrentExercise)
    }

    func quitRemainingExercises() {
        presentDialog(.quitRemainingExercises)
    }

    // MARK: - iOS 15.0+ Compatibility Methods
    func canGoBack() -> Bool {
        return !navigationStack.isEmpty
    }

    func getNavigationDepth() -> Int {
        return navigationStack.count
    }

    func resetToMain() {
        navigationStack.removeAll()
        currentScreen = .main
        dismissDialog()
    }
}

// MARK: - App Screen Enum
enum AppScreen: Hashable, Codable {
    case main
    case workout(WorkoutPlan)
    case settings
    case history

    var id: String {
        switch self {
        case .main:
            return "main"
        case .workout(let plan):
            return "workout_\(plan.id)"
        case .settings:
            return "settings"
        case .history:
            return "history"
        }
    }

    var title: String {
        switch self {
        case .main:
            return "Fit"
        case .workout:
            return "Workout"
        case .settings:
            return "Settings"
        case .history:
            return "History"
        }
    }
}

// MARK: - Dialog Type Enum
enum DialogType: Identifiable, Equatable {
    case editSet(Exercise, Int, WorkoutViewModel)
    case completion
    case quitWorkout
    case quitCurrentExercise
    case quitRemainingExercises
    case workoutComplete

    var id: String {
        switch self {
        case .editSet(let exercise, let setIndex, _):
            return "edit_set_\(exercise.id)_\(setIndex)"
        case .completion:
            return "completion"
        case .quitWorkout:
            return "quit_workout"
        case .quitCurrentExercise:
            return "quit_current_exercise"
        case .quitRemainingExercises:
            return "quit_remaining_exercises"
        case .workoutComplete:
            return "workout_complete"
        }
    }

    static func == (lhs: DialogType, rhs: DialogType) -> Bool {
        switch (lhs, rhs) {
        case (.editSet(let lhsExercise, let lhsSetIndex, let lhsViewModel),
             .editSet(let rhsExercise, let rhsSetIndex, let rhsViewModel)):
            return lhsExercise.id == rhsExercise.id &&
                   lhsSetIndex == rhsSetIndex &&
                   lhsViewModel.workoutPlan.id == rhsViewModel.workoutPlan.id
        case (.completion, .completion):
            return true
        case (.quitWorkout, .quitWorkout):
            return true
        case (.quitCurrentExercise, .quitCurrentExercise):
            return true
        case (.quitRemainingExercises, .quitRemainingExercises):
            return true
        case (.workoutComplete, .workoutComplete):
            return true
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .editSet(let exercise, let setIndex, let viewModel):
            hasher.combine("editSet")
            hasher.combine(exercise.id)
            hasher.combine(setIndex)
            hasher.combine(viewModel.workoutPlan.id)
        case .completion:
            hasher.combine("completion")
        case .quitWorkout:
            hasher.combine("quitWorkout")
        case .quitCurrentExercise:
            hasher.combine("quitCurrentExercise")
        case .quitRemainingExercises:
            hasher.combine("quitRemainingExercises")
        case .workoutComplete:
            hasher.combine("workoutComplete")
        }
    }
}

// MARK: - Workout State
enum WorkoutState {
    case notStarted
    case inProgress
    case paused
    case completed
    case quit
}

// MARK: - Navigation Manager Extension for Preview
extension NavigationManager {
    static var preview: NavigationManager {
        let manager = NavigationManager()
        manager.currentScreen = .main
        return manager
    }
}
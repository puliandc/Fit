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

    // DEPRECATED: NavigationManager不应该管理对话框状态 (已移至DialogManager)
    // TODO: 在下一版本中移除这些属性，使用DialogManager替代
    @Published var presentedDialog: DialogType?

    // DEPRECATED: NavigationManager不应该管理训练状态 (已移至WorkoutSessionManager)
    // TODO: 在下一版本中移除这些属性，使用WorkoutSessionManager替代
    @Published var currentWorkoutViewModel: WorkoutViewModel?

    init() {
        print("🎯 NavigationManager initialized with currentScreen: \(currentScreen)")
        print("⚠️ WARNING: NavigationManager contains deprecated functionality")
        print("⚠️ Plan to refactor: DialogManager + WorkoutSessionManager separation")
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

    // MARK: - Dialog Methods (DEPRECATED - 将移至DialogManager)
    func presentDialog(_ dialog: DialogType) {
        print("⚠️ DEPRECATED: Use DialogManager.presentDialog() instead")
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            presentedDialog = dialog
        }
    }

    func dismissDialog() {
        print("⚠️ DEPRECATED: Use DialogManager.dismissDialog() instead")
        withAnimation(.easeInOut(duration: 0.2)) {
            presentedDialog = nil
        }
    }

    // MARK: - Workout Navigation (DEPRECATED - 将移至WorkoutSessionManager)
    func startWorkout(_ plan: WorkoutPlan) {
        print("⚠️ DEPRECATED: Use WorkoutSessionManager.startWorkout() instead")
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
        print("⚠️ DEPRECATED: Use WorkoutSessionManager.pauseWorkout() instead")
        // Handle workout pause logic
    }

    func resumeWorkout() {
        print("⚠️ DEPRECATED: Use WorkoutSessionManager.resumeWorkout() instead")
        // Handle workout resume logic
    }

    func completeWorkout() {
        print("⚠️ DEPRECATED: Use WorkoutSessionManager.completeWorkout() instead")
        // 保存训练日志
        if let viewModel = currentWorkoutViewModel {
            let logSaved = viewModel.finishWorkoutAndSaveLog()

            if logSaved {
                print("✅ Workout completed and log saved successfully")
            } else {
                print("❌ Workout completed but log saving failed")
            }
        }

        presentDialog(.workoutComplete)
    }

    func quitWorkout() {
        print("⚠️ DEPRECATED: Use WorkoutSessionManager.quitWorkout() instead")
        presentDialog(.quitWorkout)
    }

    func quitCurrentExercise() {
        print("⚠️ DEPRECATED: Use WorkoutSessionManager.quitCurrentExercise() instead")
        presentDialog(.quitCurrentExercise)
    }

    func quitRemainingExercises() {
        print("⚠️ DEPRECATED: Use WorkoutSessionManager.quitRemainingExercises() instead")
        presentDialog(.quitRemainingExercises)
    }

    // MARK: - Simple Navigation Methods (推荐使用的纯导航功能)
    func navigateToWorkout(plan: WorkoutPlan) {
        // 纯导航功能，不管理训练状态
        navigate(to: .workout(plan))
        print("🎯 Navigating to workout screen for plan: \(plan.name)")
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
        print("🎯 Reset navigation to main screen")
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

// MARK: - Dialog Type Enum (DEPRECATED - 已移至DialogManager.swift)
// TODO: 在下一版本中删除此枚举，使用DialogManager.swift中的定义
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
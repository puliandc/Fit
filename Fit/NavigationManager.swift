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
        navigate(to: .workout(plan))
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
enum DialogType: Identifiable, Hashable {
    case editSet(Exercise, Int)
    case completion
    case quitWorkout
    case workoutComplete

    var id: String {
        switch self {
        case .editSet(let exercise, let setIndex):
            return "edit_set_\(exercise.id)_\(setIndex)"
        case .completion:
            return "completion"
        case .quitWorkout:
            return "quit_workout"
        case .workoutComplete:
            return "workout_complete"
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
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

    // MARK: - Removed Deprecated Methods
    // Dialog functionality has been moved to DialogManager
    // Workout session management has been moved to WorkoutSessionManager

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
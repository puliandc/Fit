//
//  DialogManager.swift
//  Fit
//
//  Created by Jason Lu on 15:10:00 10/14/2025.
//

import SwiftUI
import Combine

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
}

// MARK: - Dialog Manager
// 专门负责对话框状态管理，从NavigationManager中分离出来
class DialogManager: ObservableObject {
    @Published var presentedDialog: DialogType?

    init() {
        print("🎯 DialogManager initialized")
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
}
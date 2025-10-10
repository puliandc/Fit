//
//  WorkoutViewModel.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var exerciseElapsedTime: Int = 0
    @Published var isExerciseActive: Bool = false
    @Published var isResting: Bool = false
    @Published var timeLeft: Int = 0
    @Published var completedSets: [CompletedSet] = []

    let workoutPlan: WorkoutPlan
    private var exerciseTimer: Timer?
    private var restTimer: Timer?

    init(workoutPlan: WorkoutPlan) {
        self.workoutPlan = workoutPlan
    }

    // MARK: - Computed Properties
    var currentExercise: Exercise {
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            return workoutPlan.exercises.first!.exercise
        }
        return workoutPlan.exercises[currentExerciseIndex].exercise
    }

    var currentExerciseSet: ExerciseSet {
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            return workoutPlan.exercises.first!
        }
        return workoutPlan.exercises[currentExerciseIndex]
    }

    var progress: Double {
        let totalExercises = workoutPlan.exercises.count
        let completedExercises = currentExerciseIndex
        return Double(completedExercises) / Double(totalExercises)
    }

    var isWorkoutComplete: Bool {
        return currentExerciseIndex >= workoutPlan.exercises.count
    }

    // MARK: - Exercise Management
    func startExercise() {
        exerciseElapsedTime = 0
        isExerciseActive = true
        isResting = false

        startExerciseTimer()
    }

    func pauseExercise() {
        isExerciseActive = false
        exerciseTimer?.invalidate()
    }

    func toggleExercise() {
        if isExerciseActive {
            pauseExercise()
        } else {
            startExercise()
        }
    }

    func completeExercise() {
        pauseExercise()

        // Record completed set
        let completedSet = CompletedSet(
            exerciseSetId: currentExerciseSet.id,
            actualReps: currentExerciseSet.targetReps,
            actualWeight: currentExerciseSet.targetWeight,
            completedAt: Date()
        )
        completedSets.append(completedSet)

        // Check if current exercise is complete
        if currentSet >= currentExerciseSet.targetReps {
            // Move to next exercise
            if currentExerciseIndex < workoutPlan.exercises.count - 1 {
                currentExerciseIndex += 1
                currentSet = 1
                startRest()
            } else {
                // Workout complete
                pauseExercise()
            }
        } else {
            // Move to next set
            currentSet += 1
            startRest()
        }
    }

    func startRest() {
        isResting = true
        isExerciseActive = false
        timeLeft = currentExerciseSet.restTime

        startRestTimer()
    }

    func skipRest() {
        restTimer?.invalidate()
        isResting = false
        startExercise()
    }

    // MARK: - Timer Management
    private func startExerciseTimer() {
        exerciseTimer?.invalidate()

        exerciseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.exerciseElapsedTime += 1
        }
    }

    private func startRestTimer() {
        restTimer?.invalidate()

        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                self.restTimer?.invalidate()
                self.isResting = false
                self.startExercise()
            }
        }
    }

    // MARK: - Cleanup
    deinit {
        exerciseTimer?.invalidate()
        restTimer?.invalidate()
    }
}

// MARK: - Preview Helper
extension WorkoutViewModel {
    static var preview: WorkoutViewModel {
        return WorkoutViewModel(workoutPlan: MockDataProvider.previewWorkout)
    }
}
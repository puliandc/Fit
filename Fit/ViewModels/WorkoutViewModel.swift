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
        print("🐛 DEBUG: WorkoutViewModel initializing...")
        print("🐛 DEBUG: Workout plan: \(workoutPlan.name)")
        print("🐛 DEBUG: Exercise count: \(workoutPlan.exercises.count)")
        print("🐛 DEBUG: Exercise details: \(workoutPlan.exercises.map { $0.exercise.name })")

        self.workoutPlan = workoutPlan

        print("🐛 DEBUG: WorkoutViewModel initialization complete")
    }

    // MARK: - Computed Properties
    var currentExercise: Exercise {
        print("🐛 DEBUG: currentExerciseIndex = \(currentExerciseIndex), exercises.count = \(workoutPlan.exercises.count)")

        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: currentExerciseIndex (\(currentExerciseIndex)) >= exercises.count (\(workoutPlan.exercises.count))")
            if let firstExercise = workoutPlan.exercises.first {
                print("🔄 FALLBACK: Using first exercise")
                return firstExercise.exercise
            } else {
                print("💥 CRITICAL: No exercises available!")
                // 创建一个安全的默认练习
                return Exercise(
                    name: "默认练习",
                    category: .strength,
                    muscleGroups: [.chest],
                    equipment: .none,
                    difficulty: .beginner,
                    instructions: ["请联系开发者"],
                    imageName: "default"
                )
            }
        }
        return workoutPlan.exercises[currentExerciseIndex].exercise
    }

    var currentExerciseSet: ExerciseSet {
        print("🐛 DEBUG: currentExerciseIndex = \(currentExerciseIndex), exercises.count = \(workoutPlan.exercises.count)")

        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: currentExerciseIndex (\(currentExerciseIndex)) >= exercises.count (\(workoutPlan.exercises.count))")
            if let firstExercise = workoutPlan.exercises.first {
                print("🔄 FALLBACK: Using first exercise set")
                return firstExercise
            } else {
                print("💥 CRITICAL: No exercise sets available!")
                // 创建一个安全的默认练习组
                let defaultExercise = Exercise(
                    name: "默认练习",
                    category: .strength,
                    muscleGroups: [.chest],
                    equipment: .none,
                    difficulty: .beginner,
                    instructions: ["请联系开发者"],
                    imageName: "default"
                )
                return ExerciseSet(
                    exercise: defaultExercise,
                    targetReps: 1,
                    targetWeight: 0,
                    restTime: 60
                )
            }
        }
        return workoutPlan.exercises[currentExerciseIndex]
    }

    var progress: Double {
        let totalExercises = workoutPlan.exercises.count
        let completedExercises = currentExerciseIndex
        let progressValue = totalExercises > 0 ? Double(completedExercises) / Double(totalExercises) : 0.0

        print("🐛 DEBUG: Progress calculation - Completed: \(completedExercises)/\(totalExercises) = \(progressValue)")
        return progressValue
    }

    var isWorkoutComplete: Bool {
        return currentExerciseIndex >= workoutPlan.exercises.count
    }

    // MARK: - Exercise Management
    func startExercise() {
        print("🐛 DEBUG: WorkoutViewModel.startExercise called")
        print("🐛 DEBUG: currentExerciseIndex = \(currentExerciseIndex)")
        print("🐛 DEBUG: exercises.count = \(workoutPlan.exercises.count)")

        // 安全检查
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: Cannot start exercise - invalid exercise index")
            return
        }

        print("🐛 DEBUG: Starting exercise: \(currentExercise.name)")
        exerciseElapsedTime = 0
        isExerciseActive = true
        isResting = false

        print("🐛 DEBUG: Starting exercise timer...")
        startExerciseTimer()
        print("🐛 DEBUG: Exercise started successfully")
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

        // 触发参数编辑对话框，而不是直接完成
        // 这将通过WorkoutScreen中的NavigationManager来处理
    }

    // 新增：完成指定参数的练习
    func completeExerciseWith(actualReps: Int, actualWeight: Double) {
        pauseExercise()

        // Record completed set with user-specified parameters
        let completedSet = CompletedSet(
            exerciseSetId: currentExerciseSet.id,
            actualReps: actualReps,
            actualWeight: actualWeight,
            completedAt: Date()
        )
        completedSets.append(completedSet)

        // Check if current exercise is complete
        if currentSet >= getTargetSetsForCurrentExercise() {
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

    // 新增：获取当前练习的目标组数（基于实际的训练计划逻辑）
    private func getTargetSetsForCurrentExercise() -> Int {
        // 这里根据实际的训练计划逻辑来确定组数
        // 从MockData看，每个ExerciseSet代表一组，所以需要统计同一个练习的组数
        let currentExerciseId = currentExercise.id
        return workoutPlan.exercises.filter { $0.exercise.id == currentExerciseId }.count
    }

    // 新增：获取当前练习的默认次数和重量
    func getDefaultParametersForCurrentExercise() -> (reps: Int, weight: Double) {
        return (currentExerciseSet.targetReps, currentExerciseSet.targetWeight)
    }

    // 新增：获取指定练习的已完成组数
    func getCompletedSetsCount(for exercise: Exercise) -> Int {
        let exerciseSetIds = workoutPlan.exercises.filter { $0.exercise.id == exercise.id }.map { $0.id }
        return completedSets.filter { exerciseSetIds.contains($0.exerciseSetId) }.count
    }

    // 新增：获取指定练习的剩余组数
    func getRemainingSetsCount(for exercise: Exercise) -> Int {
        let totalSets = workoutPlan.exercises.filter { $0.exercise.id == exercise.id }.count
        let completedSets = getCompletedSetsCount(for: exercise)
        return max(0, totalSets - completedSets)
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
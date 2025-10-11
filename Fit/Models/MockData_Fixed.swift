//
//  MockData_Fixed.swift
//  Fit
//
//  Created by System Architect on 10/11/2025.
//  Architectural fix for initialization issues
//

import SwiftUI
import Foundation

// MARK: - Fixed Mock Data Provider
class MockDataProviderFixed {
    static let shared = MockDataProviderFixed()

    // 延迟初始化属性，避免循环依赖
    private var _exercises: [Exercise]?
    private var _workoutPlans: [WorkoutPlan]?

    private init() {
        print("🔧 MockDataProviderFixed: Initializing...")
        initializeData()
        print("✅ MockDataProviderFixed: Initialization complete")
    }

    private func initializeData() {
        // 分步初始化，避免循环引用
        _exercises = createSampleExercises()
        _workoutPlans = createSampleWorkoutPlans()

        print("📊 MockDataProviderFixed: \(_exercises?.count ?? 0) exercises, \(_workoutPlans?.count ?? 0) workout plans")
    }

    // MARK: - Safe Property Accessors
    var sampleExercises: [Exercise] {
        guard let exercises = _exercises else {
            print("🚨 CRITICAL: sampleExercises accessed before initialization!")
            return []
        }
        return exercises
    }

    var sampleWorkoutPlans: [WorkoutPlan] {
        guard let plans = _workoutPlans else {
            print("🚨 CRITICAL: sampleWorkoutPlans accessed before initialization!")
            return []
        }
        return plans
    }

    // MARK: - Data Creation Methods
    private func createSampleExercises() -> [Exercise] {
        return [
            Exercise(
                name: "Push-ups",
                category: .strength,
                muscleGroups: [.chest, .triceps, .shoulders],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Start in a plank position with hands shoulder-width apart",
                    "Lower your body until your chest nearly touches the floor",
                    "Push back up to the starting position"
                ],
                tips: [
                    "Keep your body in a straight line from head to heels",
                    "Engage your core throughout the movement"
                ],
                imageName: "pushup"
            ),
            Exercise(
                name: "Squats",
                category: .strength,
                muscleGroups: [.legs, .glutes, .abs],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Stand with feet shoulder-width apart",
                    "Lower your body as if sitting in a chair",
                    "Return to the starting position"
                ],
                tips: [
                    "Keep your chest up and back straight",
                    "Don't let your knees go past your toes"
                ],
                imageName: "squat"
            ),
            Exercise(
                name: "Dumbbell Bench Press",
                category: .strength,
                muscleGroups: [.chest, .triceps, .shoulders],
                equipment: .dumbbells,
                difficulty: .intermediate,
                instructions: [
                    "Lie on a bench with dumbbells in your hands",
                    "Lower the dumbbells to your chest level",
                    "Press the dumbbells back up to the starting position"
                ],
                tips: [
                    "Control the movement on the way down",
                    "Keep your elbows at a 45-degree angle"
                ],
                imageName: "dumbbell_press"
            ),
            Exercise(
                name: "Plank",
                category: .strength,
                muscleGroups: [.abs, .shoulders],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Start in a push-up position",
                    "Hold your body in a straight line",
                    "Engage your core and hold the position"
                ],
                tips: [
                    "Don't let your hips sag",
                    "Keep breathing throughout the exercise"
                ],
                imageName: "plank"
            ),
            Exercise(
                name: "Jumping Jacks",
                category: .cardio,
                muscleGroups: [.legs, .abs],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Start with feet together and arms at your sides",
                    "Jump while spreading your legs and raising your arms",
                    "Jump back to the starting position"
                ],
                tips: [
                    "Land softly to protect your joints",
                    "Maintain a steady rhythm"
                ],
                imageName: "jumping_jacks"
            )
        ]
    }

    private func createSampleWorkoutPlans() -> [WorkoutPlan] {
        guard let exercises = _exercises else {
            print("🚨 ERROR: Cannot create workout plans - exercises not initialized")
            return []
        }

        return [
            WorkoutPlan(
                name: "Full Body Beginner",
                description: "A comprehensive full-body workout perfect for beginners",
                category: .fullBody,
                difficulty: .beginner,
                duration: 30,
                exercises: [
                    ExerciseSet(exercise: exercises[0], targetReps: 10, targetWeight: 0),
                    ExerciseSet(exercise: exercises[1], targetReps: 15, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 8, targetWeight: 0),
                    ExerciseSet(exercise: exercises[1], targetReps: 12, targetWeight: 0),
                    ExerciseSet(exercise: exercises[3], targetReps: 30, targetWeight: 0, restTime: 0)
                ],
                estimatedCalories: 200
            ),
            WorkoutPlan(
                name: "Upper Body Strength",
                description: "Build upper body strength with targeted exercises",
                category: .upperBody,
                difficulty: .intermediate,
                duration: 45,
                exercises: [
                    ExerciseSet(exercise: exercises[2], targetReps: 12, targetWeight: 20),
                    ExerciseSet(exercise: exercises[2], targetReps: 10, targetWeight: 22.5),
                    ExerciseSet(exercise: exercises[2], targetReps: 8, targetWeight: 25),
                    ExerciseSet(exercise: exercises[0], targetReps: 15, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 12, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 10, targetWeight: 0)
                ],
                estimatedCalories: 300
            ),
            WorkoutPlan(
                name: "HIIT Cardio Blast",
                description: "High-intensity interval training for maximum calorie burn",
                category: .hiit,
                difficulty: .advanced,
                duration: 20,
                exercises: [
                    ExerciseSet(exercise: exercises[4], targetReps: 30, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[0], targetReps: 20, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[1], targetReps: 25, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[4], targetReps: 30, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[0], targetReps: 15, targetWeight: 0, restTime: 10)
                ],
                estimatedCalories: 250
            )
        ]
    }

    // MARK: - Validation Methods
    func validateInitialization() -> Bool {
        guard _exercises != nil, _workoutPlans != nil else {
            print("🚨 MockDataProviderFixed: Not properly initialized")
            return false
        }

        guard !_exercises!.isEmpty, !_workoutPlans!.isEmpty else {
            print("🚨 MockDataProviderFixed: Empty data arrays")
            return false
        }

        print("✅ MockDataProviderFixed: Validation passed")
        return true
    }

    // MARK: - Helper Methods (保持原有接口兼容)
    func getExercise(byName name: String) -> Exercise? {
        return sampleExercises.first { $0.name == name }
    }

    func getWorkoutPlan(byName name: String) -> WorkoutPlan? {
        return sampleWorkoutPlans.first { $0.name == name }
    }

    func getExercisesByCategory(_ category: ExerciseCategory) -> [Exercise] {
        return sampleExercises.filter { $0.category == category }
    }

    func getExercisesByMuscleGroup(_ muscleGroup: MuscleGroup) -> [Exercise] {
        return sampleExercises.filter { $0.muscleGroups.contains(muscleGroup) }
    }

    func getWorkoutPlansByDifficulty(_ difficulty: Difficulty) -> [WorkoutPlan] {
        return sampleWorkoutPlans.filter { $0.difficulty == difficulty }
    }
}

// MARK: - Preview Helpers (保持兼容性)
extension MockDataProviderFixed {
    static var previewWorkout: WorkoutPlan {
        guard let plan = shared.sampleWorkoutPlans.first else {
            // 创建一个安全的默认训练计划
            return WorkoutPlan(
                name: "Preview Workout",
                description: "Default preview workout",
                category: .fullBody,
                difficulty: .beginner,
                duration: 30,
                exercises: [ExerciseSet(exercise: shared.sampleExercises.first ?? Exercise(name: "Default", category: .strength, muscleGroups: [.chest], equipment: .none, difficulty: .beginner, instructions: [], imageName: "default"), targetReps: 10, targetWeight: 0)],
                estimatedCalories: 200
            )
        }
        return plan
    }

    static var previewExercises: [Exercise] {
        return Array(shared.sampleExercises.prefix(3))
    }

    static var previewExercise: Exercise {
        return shared.sampleExercises.first ?? Exercise(name: "Default", category: .strength, muscleGroups: [.chest], equipment: .none, difficulty: .beginner, instructions: [], imageName: "default")
    }
}
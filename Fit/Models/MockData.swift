//
//  MockData.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import Foundation
import SwiftUI

// MARK: - Exercise Model

struct Exercise: Identifiable, Codable, Hashable
{
    let id: UUID
    let name: String

    init(
        id: UUID = UUID(),
        name: String
    )
    {
        self.id = id
        self.name = name
    }
}

// MARK: - Exercise Set Model

struct ExerciseSet: Identifiable, Codable, Hashable
{
    let id: UUID
    let exercise: Exercise
    let targetReps: Int // Number of sets for this exercise
    let targetWeight: Double
    let restTime: Int // in seconds
    var notes: String?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        targetReps: Int,
        targetWeight: Double,
        restTime: Int = 60,
        notes: String? = nil
    )
    {
        self.id = id
        self.exercise = exercise
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.restTime = restTime
        self.notes = notes
    }
}

// MARK: - Workout Plan Model

struct WorkoutPlan: Identifiable, Codable, Hashable, Equatable
{
    let id: UUID
    let name: String
    let duration: Int // in minutes
    let exercises: [ExerciseSet]

    init(
        id: UUID = UUID(),
        name: String,
        duration: Int,
        exercises: [ExerciseSet]
    )
    {
        self.id = id
        self.name = name
        self.duration = duration
        self.exercises = exercises
    }
}

// MARK: - Equatable Conformance

extension WorkoutPlan
{
    static func == (lhs: WorkoutPlan, rhs: WorkoutPlan) -> Bool
    {
        return lhs.id == rhs.id
    }
}

// MARK: - Mock Data Provider

class MockDataProvider
{
    static let shared = MockDataProvider()

    // 修复循环依赖问题 - 延迟初始化
    private var _sampleExercises: [Exercise]?
    private var _sampleWorkoutPlans: [WorkoutPlan]?

    private init()
    {
        initializeData()
    }

    // 延迟初始化的示例练习数据
    var sampleExercises: [Exercise]
    {
        if let exercises = _sampleExercises
        {
            return exercises
        }

        let exercises = [
            Exercise(name: "Push-ups"),
            Exercise(name: "Squats"),
            Exercise(name: "Dumbbell Bench Press"),
            Exercise(name: "Plank"),
            Exercise(name: "Jumping Jacks")
        ]

        _sampleExercises = exercises
        return exercises
    }

    // 延迟初始化的示例训练计划数据
    var sampleWorkoutPlans: [WorkoutPlan]
    {
        if let plans = _sampleWorkoutPlans
        {
            return plans
        }

        let exercises = sampleExercises // 使用已经初始化的练习数据
        let plans = [
            WorkoutPlan(
                name: "Full Body Beginner",
                duration: 30,
                exercises: [
                    ExerciseSet(exercise: exercises[0], targetReps: 10, targetWeight: 0),
                    ExerciseSet(exercise: exercises[1], targetReps: 15, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 8, targetWeight: 0),
                    ExerciseSet(exercise: exercises[1], targetReps: 12, targetWeight: 0),
                    ExerciseSet(exercise: exercises[3], targetReps: 30, targetWeight: 0, restTime: 0)
                ]
            ),
            WorkoutPlan(
                name: "Upper Body Strength",
                duration: 45,
                exercises: [
                    ExerciseSet(exercise: exercises[2], targetReps: 12, targetWeight: 15),
                    ExerciseSet(exercise: exercises[2], targetReps: 10, targetWeight: 17.5),
                    ExerciseSet(exercise: exercises[2], targetReps: 8, targetWeight: 20),
                    ExerciseSet(exercise: exercises[0], targetReps: 15, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 12, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 10, targetWeight: 0)
                ]
            ),
            WorkoutPlan(
                name: "HIIT Cardio Blast",
                duration: 20,
                exercises: [
                    ExerciseSet(exercise: exercises[4], targetReps: 30, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[0], targetReps: 20, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[1], targetReps: 25, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[4], targetReps: 30, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[0], targetReps: 15, targetWeight: 0, restTime: 10)
                ]
            )
        ]

        _sampleWorkoutPlans = plans
        return plans
    }

    // 安全初始化方法
    private func initializeData()
    {
        // 预先初始化数据以避免循环依赖
        _ = sampleExercises
        _ = sampleWorkoutPlans
    }

    // MARK: - Helper Methods

    func getExercise(byName name: String) -> Exercise?
    {
        return sampleExercises.first { $0.name == name }
    }

    func getWorkoutPlan(byName name: String) -> WorkoutPlan?
    {
        return sampleWorkoutPlans.first { $0.name == name }
    }

    // NOTE: Methods getExercisesByCategory, getExercisesByMuscleGroup, and getWorkoutPlansByDifficulty
    // have been removed as their referenced enums (ExerciseCategory, MuscleGroup, Difficulty)
    // were deleted during model refactoring to simplify the data structure
}

// MARK: - Preview Helpers

extension MockDataProvider
{
    static var previewWorkout: WorkoutPlan
    {
        return shared.sampleWorkoutPlans[0]
    }

    static var previewExercises: [Exercise]
    {
        return Array(shared.sampleExercises.prefix(3))
    }

    static var previewExercise: Exercise
    {
        return shared.sampleExercises[0]
    }
}

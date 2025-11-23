//
//  WorkoutSessionModels.swift
//  Fit
//
//  Created by Jason Lu on 14/10/2025.
//

import Foundation

// MARK: - Completed Set (for backward compatibility)

// 简化的完成组记录，用于WorkoutViewModel的completedSets数组
struct CompletedSet: Identifiable, Codable
{
    let id: UUID
    let exerciseSetId: UUID
    let actualReps: Int
    let actualWeight: Double
    let completedAt: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        exerciseSetId: UUID,
        actualReps: Int,
        actualWeight: Double,
        completedAt: Date = Date(),
        notes: String? = nil
    )
    {
        self.id = id
        self.exerciseSetId = exerciseSetId
        self.actualReps = actualReps
        self.actualWeight = actualWeight
        self.completedAt = completedAt
        self.notes = notes
    }
}

// MARK: - Prebuilt Workout Session Data Structure

// 预建立的训练会话数据结构，包含完整的训练信息
class PrebuiltWorkoutSession
{
    let id: UUID
    let workoutPlan: WorkoutPlan
    let sessionDate: Date
    var exerciseSessions: [ExerciseSession]

    // 计算属性
    var totalSets: Int
    {
        exerciseSessions.reduce(0) { $0 + $1.sets.count }
    }

    var completedSets: Int
    {
        exerciseSessions.reduce(0) { $0 + $1.sets.filter { $0.isCompleted }.count }
    }

    var currentExerciseSession: ExerciseSession?
    {
        exerciseSessions.first { !$0.isFullyCompleted }
    }

    init(workoutPlan: WorkoutPlan)
    {
        id = UUID()
        self.workoutPlan = workoutPlan
        sessionDate = Date()
        exerciseSessions = []
    }
}

// MARK: - Exercise Session

// 单个练习的会话数据，包含该练习的所有组
class ExerciseSession
{
    let id: UUID
    let exercise: Exercise
    var sets: [WorkoutSet]
    var isFullyCompleted: Bool
    {
        sets.allSatisfy { $0.isCompleted }
    }

    init(exercise: Exercise, exerciseSets: [ExerciseSet])
    {
        id = UUID()
        self.exercise = exercise
        sets = exerciseSets.enumerated().map
        { index, exerciseSet in
            WorkoutSet(
                id: UUID(),
                exerciseSet: exerciseSet,
                setOrder: index + 1,
                exerciseName: exercise.name,
                targetWeight: exerciseSet.targetWeight,
                targetReps: exerciseSet.targetReps,
                restTime: exerciseSet.restTime,
                actualWeight: nil,
                actualReps: nil,
                notes: "",
                isCompleted: false,
                completedAt: nil
            )
        }
    }
}

// MARK: - Workout Set

// 单个训练组的数据，包含所有必要字段
struct WorkoutSet: Identifiable
{
    let id: UUID
    let exerciseSet: ExerciseSet
    let setOrder: Int
    let exerciseName: String
    let targetWeight: Double
    let targetReps: Int
    let restTime: Int

    // 实际完成的数据
    var actualWeight: Double?
    var actualReps: Int?
    var notes: String
    var isCompleted: Bool
    var completedAt: Date?

    // 计算属性
    var displayWeight: String
    {
        if let actualWeight = actualWeight
        {
            return actualWeight > 0 ? String(format: "%.1f", actualWeight) : "自重"
        }
        else
        {
            return targetWeight > 0 ? String(format: "%.1f", targetWeight) : "自重"
        }
    }

    var displayReps: String
    {
        if let actualReps = actualReps
        {
            return String(actualReps)
        }
        else
        {
            return String(targetReps)
        }
    }

    var setStatus: SetStatus
    {
        if isCompleted
        {
            return .completed
        }
        else if actualReps == 0 && actualWeight == 0
        {
            return .skipped
        }
        else
        {
            return .pending
        }
    }
}

// MARK: - Set Status

enum SetStatus: String, CaseIterable
{
    case pending = "待完成"
    case completed = "已完成"
    case skipped = "已跳过"

    var color: String
    {
        switch self
        {
        case .pending:
            return "gray"
        case .completed:
            return "green"
        case .skipped:
            return "orange"
        }
    }
}

// MARK: - Prebuilt Workout Session Prebuilder

// DEPRECATED: This class is overly complex and should be simplified
// Consider using direct WorkoutSession creation instead
class PrebuiltWorkoutSessionPrebuilder
{
    func buildSession(from workoutPlan: WorkoutPlan) -> PrebuiltWorkoutSession
    {
        let session = PrebuiltWorkoutSession(workoutPlan: workoutPlan)

        // 按练习分组，为每个练习创建 ExerciseSession
        let groupedExercises = Dictionary(grouping: workoutPlan.exercises) { $0.exercise.id }

        for (_, exerciseSets) in groupedExercises
        {
            guard let firstSet = exerciseSets.first else { continue }
            let exercise = firstSet.exercise

            let exerciseSession = ExerciseSession(
                exercise: exercise,
                exerciseSets: exerciseSets.sorted { $0.id < $1.id }
            )

            session.exerciseSessions.append(exerciseSession)
        }

        // 按照原始计划的顺序重新排序
        session.exerciseSessions.sort
        { session1, session2 in
            let firstSet1 = workoutPlan.exercises.first { $0.exercise.id == session1.exercise.id }
            let firstSet2 = workoutPlan.exercises.first { $0.exercise.id == session2.exercise.id }
            guard let index1 = firstSet1?.id, let index2 = firstSet2?.id else { return false }
            return index1 < index2
        }

        return session
    }

    func validateSession(_ session: PrebuiltWorkoutSession) -> Bool
    {
        guard !session.exerciseSessions.isEmpty
        else
        {
            return false
        }

        for exerciseSession in session.exerciseSessions
        {
            if exerciseSession.sets.isEmpty
            {
                return false
            }

            for (index, set) in exerciseSession.sets.enumerated()
            {
                if set.setOrder != index + 1
                {
                    return false
                }
            }
        }

        return true
    }
}

// MARK: - Prebuilt Workout Session Extensions

extension PrebuiltWorkoutSession
{
    func getCurrentSet() -> WorkoutSet?
    {
        // 找到第一个未完成的练习的第一个未完成的组
        for exerciseSession in exerciseSessions
        {
            if let firstIncompleteSet = exerciseSession.sets.first(where: { !$0.isCompleted })
            {
                return firstIncompleteSet
            }
        }
        return nil
    }

    func markSetCompleted(_ set: WorkoutSet, actualWeight: Double, actualReps: Int, notes: String = "")
    {
        if let index = exerciseSessions.firstIndex(where: { $0.sets.contains(where: { $0.id == set.id }) })
        {
            if let setIndex = exerciseSessions[index].sets.firstIndex(where: { $0.id == set.id })
            {
                exerciseSessions[index].sets[setIndex].actualWeight = actualWeight
                exerciseSessions[index].sets[setIndex].actualReps = actualReps
                exerciseSessions[index].sets[setIndex].notes = notes
                exerciseSessions[index].sets[setIndex].isCompleted = true
                exerciseSessions[index].sets[setIndex].completedAt = Date()
            }
        }
    }

    func skipRemainingSetsInExercise(_ exercise: Exercise)
    {
        if let exerciseSessionIndex = exerciseSessions.firstIndex(where: { $0.exercise.id == exercise.id })
        {
            let exerciseSession = exerciseSessions[exerciseSessionIndex]

            for setIndex in exerciseSession.sets.indices
            {
                if !exerciseSession.sets[setIndex].isCompleted
                {
                    exerciseSessions[exerciseSessionIndex].sets[setIndex].actualWeight = 0
                    exerciseSessions[exerciseSessionIndex].sets[setIndex].actualReps = 0
                    exerciseSessions[exerciseSessionIndex].sets[setIndex].notes = "跳过"
                    exerciseSessions[exerciseSessionIndex].sets[setIndex].isCompleted = true
                    exerciseSessions[exerciseSessionIndex].sets[setIndex].completedAt = Date()
                }
            }
        }
    }
}

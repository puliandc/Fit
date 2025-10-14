//
//  WorkoutSessionModels.swift
//  Fit
//
//  Created by Jason Lu on 14/10/2025.
//

import Foundation

// MARK: - Prebuilt Workout Session Data Structure
// 预建立的训练会话数据结构，包含完整的训练信息
class PrebuiltWorkoutSession {
    let id: UUID
    let workoutPlan: WorkoutPlan
    let sessionDate: Date
    var exerciseSessions: [ExerciseSession]

    // 计算属性
    var totalSets: Int {
        exerciseSessions.reduce(0) { $0 + $1.sets.count }
    }

    var completedSets: Int {
        exerciseSessions.reduce(0) { $0 + $1.sets.filter { $0.isCompleted }.count }
    }

    var currentExerciseSession: ExerciseSession? {
        exerciseSessions.first { !$0.isFullyCompleted }
    }

    init(workoutPlan: WorkoutPlan) {
        self.id = UUID()
        self.workoutPlan = workoutPlan
        self.sessionDate = Date()
        self.exerciseSessions = []
    }
}

// MARK: - Exercise Session
// 单个练习的会话数据，包含该练习的所有组
class ExerciseSession {
    let id: UUID
    let exercise: Exercise
    var sets: [WorkoutSet]
    var isFullyCompleted: Bool {
        sets.allSatisfy { $0.isCompleted }
    }

    init(exercise: Exercise, exerciseSets: [ExerciseSet]) {
        self.id = UUID()
        self.exercise = exercise
        self.sets = exerciseSets.enumerated().map { index, exerciseSet in
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
struct WorkoutSet: Identifiable {
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
    var displayWeight: String {
        if let actualWeight = actualWeight {
            return actualWeight > 0 ? String(format: "%.1f", actualWeight) : "自重"
        } else {
            return targetWeight > 0 ? String(format: "%.1f", targetWeight) : "自重"
        }
    }

    var displayReps: String {
        if let actualReps = actualReps {
            return String(actualReps)
        } else {
            return String(targetReps)
        }
    }

    var setStatus: SetStatus {
        if isCompleted {
            return .completed
        } else if actualReps == 0 && actualWeight == 0 {
            return .skipped
        } else {
            return .pending
        }
    }
}

// MARK: - Set Status
enum SetStatus: String, CaseIterable {
    case pending = "待完成"
    case completed = "已完成"
    case skipped = "已跳过"

    var color: String {
        switch self {
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
// 负责根据 WorkoutPlan 预建立完整的训练会话数据结构
class PrebuiltWorkoutSessionPrebuilder {

    func buildSession(from workoutPlan: WorkoutPlan) -> PrebuiltWorkoutSession {
        print("🏗️ DEBUG: 开始预建立训练会话数据结构...")
        print("🏗️ DEBUG: 训练计划: \(workoutPlan.name), 练习数量: \(workoutPlan.exercises.count)")

        var session = PrebuiltWorkoutSession(workoutPlan: workoutPlan)

        // 按练习分组，为每个练习创建 ExerciseSession
        let groupedExercises = Dictionary(grouping: workoutPlan.exercises) { $0.exercise.id }

        for (exerciseId, exerciseSets) in groupedExercises {
            guard let firstSet = exerciseSets.first else { continue }
            let exercise = firstSet.exercise

            print("🏗️ DEBUG: 创建练习会话 - \(exercise.name), 组数: \(exerciseSets.count)")

            let exerciseSession = ExerciseSession(
                exercise: exercise,
                exerciseSets: exerciseSets.sorted { $0.id < $1.id } // 确保顺序正确
            )

            session.exerciseSessions.append(exerciseSession)
        }

        // 按照原始计划的顺序重新排序
        session.exerciseSessions.sort { session1, session2 in
            let firstSet1 = workoutPlan.exercises.first { $0.exercise.id == session1.exercise.id }
            let firstSet2 = workoutPlan.exercises.first { $0.exercise.id == session2.exercise.id }
            guard let index1 = firstSet1?.id, let index2 = firstSet2?.id else { return false }
            return index1 < index2
        }

        print("🏗️ DEBUG: 训练会话预建立完成 - 总练习数: \(session.exerciseSessions.count), 总组数: \(session.totalSets)")

        return session
    }

    func validateSession(_ session: PrebuiltWorkoutSession) -> Bool {
        // 验证会话数据的完整性
        guard !session.exerciseSessions.isEmpty else {
            print("❌ ERROR: 训练会话没有练习数据")
            return false
        }

        for exerciseSession in session.exerciseSessions {
            if exerciseSession.sets.isEmpty {
                print("❌ ERROR: 练习 \(exerciseSession.exercise.name) 没有组数据")
                return false
            }

            for (index, set) in exerciseSession.sets.enumerated() {
                if set.setOrder != index + 1 {
                    print("❌ ERROR: 组顺序不正确 - 期望: \(index + 1), 实际: \(set.setOrder)")
                    return false
                }
            }
        }

        print("✅ DEBUG: 训练会话数据验证通过")
        return true
    }
}

// MARK: - Prebuilt Workout Session Extensions
extension PrebuiltWorkoutSession {
    func getCurrentSet() -> WorkoutSet? {
        // 找到第一个未完成的练习的第一个未完成的组
        for exerciseSession in exerciseSessions {
            if let firstIncompleteSet = exerciseSession.sets.first(where: { !$0.isCompleted }) {
                return firstIncompleteSet
            }
        }
        return nil
    }

    func markSetCompleted(_ set: WorkoutSet, actualWeight: Double, actualReps: Int, notes: String = "") {
        if let index = exerciseSessions.firstIndex(where: { $0.sets.contains(where: { $0.id == set.id }) }) {
            if let setIndex = exerciseSessions[index].sets.firstIndex(where: { $0.id == set.id }) {
                exerciseSessions[index].sets[setIndex].actualWeight = actualWeight
                exerciseSessions[index].sets[setIndex].actualReps = actualReps
                exerciseSessions[index].sets[setIndex].notes = notes
                exerciseSessions[index].sets[setIndex].isCompleted = true
                exerciseSessions[index].sets[setIndex].completedAt = Date()

                print("✅ DEBUG: 标记组完成 - \(set.exerciseName) 组\(set.setOrder)")
            }
        }
    }

    func skipRemainingSetsInExercise(_ exercise: Exercise) {
        if let exerciseSessionIndex = exerciseSessions.firstIndex(where: { $0.exercise.id == exercise.id }) {
            var exerciseSession = exerciseSessions[exerciseSessionIndex]

            for setIndex in exerciseSession.sets.indices {
                if !exerciseSession.sets[setIndex].isCompleted {
                    exerciseSession.sets[setIndex].actualWeight = 0
                    exerciseSession.sets[setIndex].actualReps = 0
                    exerciseSession.sets[setIndex].notes = "跳过"
                    exerciseSession.sets[setIndex].isCompleted = true
                    exerciseSession.sets[setIndex].completedAt = Date()

                    print("⏭️ DEBUG: 标记组跳过 - \(exerciseSession.sets[setIndex].exerciseName) 组\(exerciseSession.sets[setIndex].setOrder)")
                }
            }

            // 更新数组中的元素
            exerciseSessions[exerciseSessionIndex] = exerciseSession
        }
    }
}
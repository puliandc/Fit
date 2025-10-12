//
//  WorkoutBusinessLogic.swift
//  Fit
//
//  Created by Jason Lu on 09:15:00 10/12/2025.
//

import Foundation

// MARK: - Training Progress Calculator
class TrainingProgressCalculator {

    /// 计算训练进度（基于练习数量）
    static func calculateProgress(for session: TrainingSession, in plan: TrainingPlan) -> Double {
        let totalExercises = plan.exercises.count
        guard totalExercises > 0 else { return 0.0 }

        let completedExercises = session.setRecords
            .filter { !$0.notes.contains("放弃") }
            .map { $0.exerciseName }
            .removingDuplicates()
            .count

        return Double(completedExercises) / Double(totalExercises)
    }

    /// 检查训练是否完成
    static func isTrainingComplete(for session: TrainingSession, in plan: TrainingPlan) -> Bool {
        let progress = calculateProgress(for: session, in: plan)
        return progress >= 1.0
    }

    /// 检查训练是否可以结束（用户放弃或完成）
    static func canEndTraining(for session: TrainingSession, in plan: TrainingPlan) -> Bool {
        return isTrainingComplete(for: session, in: plan) || session.endTime != nil
    }
}

// MARK: - Workout Session Manager
class WorkoutSessionManager {

    /// 创建新的训练会话
    static func createSession(from plan: TrainingPlan) -> TrainingSession {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"

        return TrainingSession(
            planName: plan.name,
            date: dateFormatter.string(from: Date()),
            startTime: Date()
        )
    }

    /// 完成一个组
    static func completeSet(
        exerciseName: String,
        targetWeight: Double,
        targetReps: Int,
        setOrder: Int,
        actualWeight: Double,
        actualReps: Int,
        notes: String = "",
        in session: inout TrainingSession
    ) {
        let setRecord = SetRecord(
            exerciseName: exerciseName,
            targetWeight: targetWeight,
            targetReps: targetReps,
            setOrder: setOrder,
            actualWeight: actualWeight,
            actualReps: actualReps,
            notes: notes
        )

        session.setRecords.append(setRecord)
    }

    /// 放弃一个练习（保留已完成组数据）
    static func skipExercise(
        _ exerciseName: String,
        exerciseSets: [TrainingSet],
        reason: String? = nil,
        in session: inout TrainingSession
    ) {
        let completedSetOrders = session.setRecords
            .filter { $0.exerciseName == exerciseName }
            .map { $0.setOrder }

        for (index, set) in exerciseSets.enumerated() {
            if !completedSetOrders.contains(index + 1) {
                let skippedRecord = SetRecord(
                    exerciseName: exerciseName,
                    targetWeight: set.targetWeight,
                    targetReps: set.targetReps,
                    setOrder: index + 1,
                    actualWeight: 0,
                    actualReps: 0,
                    notes: "放弃"
                )
                session.setRecords.append(skippedRecord)
            }
        }
    }

    /// 结束训练会话
    static func endSession(_ session: inout TrainingSession) {
        session.endTime = Date()
    }

    /// 放弃训练会话
    static func abandonSession(_ session: inout TrainingSession, reason: String? = nil) {
        session.endTime = Date()
        if let reason = reason {
            session.notes = reason
        }
    }
}

// MARK: - Training Plan Validator
class TrainingPlanValidator {

    /// 验证训练计划的有效性
    static func validate(_ plan: TrainingPlan) -> ValidationResult {
        var errors: [String] = []
        let warnings: [String] = []

        // 基本验证
        if plan.name.isEmpty {
            errors.append("训练计划名称不能为空")
        }

        if plan.exercises.isEmpty {
            errors.append("训练计划必须包含至少一个练习")
        }

        // 练习验证
        for (index, exercise) in plan.exercises.enumerated() {
            if exercise.sets.isEmpty {
                errors.append("练习 \(index + 1) 必须包含至少一组")
            }

            for (setIndex, set) in exercise.sets.enumerated() {
                // 验证组的参数
                if set.targetReps <= 0 {
                    errors.append("练习 \(index + 1) 的第 \(setIndex + 1) 组的目标次数必须大于0")
                }

                if set.targetWeight < 0 {
                    errors.append("练习 \(index + 1) 的第 \(setIndex + 1) 组的目标重量不能为负数")
                }

                if set.restTime < 0 {
                    errors.append("练习 \(index + 1) 的第 \(setIndex + 1) 组的休息时间不能为负数")
                }
            }
        }

        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
}

// MARK: - Workout Statistics Calculator
class WorkoutStatisticsCalculator {

    /// 计算训练总量
    static func calculateTotalVolume(for session: TrainingSession) -> Double {
        return session.setRecords
            .filter { !$0.notes.contains("放弃") }
            .map { Double($0.actualReps) * $0.actualWeight }
            .reduce(0, +)
    }

    /// 计算训练时长
    static func calculateDuration(for session: TrainingSession) -> TimeInterval {
        guard let endTime = session.endTime else { return 0 }
        return endTime.timeIntervalSince(session.startTime)
    }

    /// 获取完成的组数
    static func getCompletedSetsCount(for session: TrainingSession) -> Int {
        return session.setRecords.filter { !$0.notes.contains("放弃") }.count
    }

    /// 获取总组数
    static func getTotalSetsCount(for session: TrainingSession) -> Int {
        return session.setRecords.count
    }
}

// MARK: - Supporting Types
struct ValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
}

// MARK: - Extensions for Business Logic
extension TrainingPlan {

    /// 获取下一个练习
    func getNextExercise(after currentIndex: Int? = nil) -> TrainingExercise? {
        guard let index = currentIndex else {
            return exercises.first
        }

        if index + 1 < exercises.count {
            return exercises[index + 1]
        }

        return nil
    }

    /// 计算预估总时长
    func calculateEstimatedDuration() -> Int {
        var totalDuration = 0

        for exercise in exercises {
            for set in exercise.sets {
                // 估算每组完成时间（简单估算）
                let estimatedSetTime: Int = 60 // 默认60秒完成一组
                totalDuration += estimatedSetTime + set.restTime
            }
        }

        return totalDuration / 60 // 转换为分钟
    }
}

extension TrainingSession {

    /// 获取已完成练习的数量
    var completedExerciseCount: Int {
        return setRecords
            .filter { !$0.notes.contains("放弃") }
            .map { $0.exerciseName }
            .removingDuplicates()
            .count
    }

    /// 获取总练习数量
    var totalExerciseCount: Int {
        return setRecords
            .map { $0.exerciseName }
            .removingDuplicates()
            .count
    }
}

// MARK: - Array Extension for Removing Duplicates
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
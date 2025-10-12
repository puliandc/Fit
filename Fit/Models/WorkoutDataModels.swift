//
//  WorkoutDataModels.swift
//  Fit
//
//  Created by Jason Lu on 09:00:00 10/12/2025.
//

import Foundation

// MARK: - 简化架构数据模型
// 基于用户反馈的简化四层结构：训练计划 → 练习 → 组 → 记录

// MARK: - Training Plan (训练计划)
/// 简化的训练计划，只包含基本信息
struct TrainingPlan: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var exercises: [TrainingExercise] // 简化的练习列表
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        exercises: [TrainingExercise] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
        self.createdAt = createdAt
    }
}

// MARK: - Training Exercise (训练练习)
/// 简化的训练练习，包含练习名称和组配置
struct TrainingExercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String // 练习名称
    var sets: [TrainingSet] // 组配置

    init(
        id: UUID = UUID(),
        name: String,
        sets: [TrainingSet] = []
    ) {
        self.id = id
        self.name = name
        self.sets = sets
    }
}

// MARK: - Training Set (训练组)
/// 简化的训练组配置
struct TrainingSet: Identifiable, Codable, Hashable {
    let id: UUID
    var setType: SetType // 组类型（热身、正式）
    var targetReps: Int // 目标次数
    var targetWeight: Double // 目标重量
    var restTime: Int // 休息时间（秒）

    init(
        id: UUID = UUID(),
        setType: SetType = .working,
        targetReps: Int,
        targetWeight: Double,
        restTime: Int = 60
    ) {
        self.id = id
        self.setType = setType
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.restTime = restTime
    }
}

// MARK: - Training Session (训练会话)
/// 简化的训练会话记录
struct TrainingSession: Identifiable, Codable {
    let id: UUID
    let planName: String // 关联的训练计划名称
    let date: String // 格式: "2025年10月2日"
    let startTime: Date
    var endTime: Date?
    var setRecords: [SetRecord] // 完成的组记录
    var notes: String?

    // 计算属性
    var duration: TimeInterval {
        endTime?.timeIntervalSince(startTime) ?? 0
    }

    var totalSets: Int {
        setRecords.count
    }

    var completedSets: Int {
        setRecords.filter { !$0.notes.contains("放弃") }.count
    }

    init(
        id: UUID = UUID(),
        planName: String,
        date: String,
        startTime: Date = Date(),
        endTime: Date? = nil,
        setRecords: [SetRecord] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.planName = planName
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.setRecords = setRecords
        self.notes = notes
    }
}

// MARK: - Set Record (组记录)
/// 简化的组完成记录
struct SetRecord: Identifiable, Codable {
    let id: UUID
    let exerciseName: String // 练习名称
    let targetWeight: Double // 目标重量
    let targetReps: Int // 目标次数
    let setOrder: Int // 组顺序
    let actualWeight: Double // 实际重量
    let actualReps: Int // 实际次数
    let notes: String // 放弃时填写"放弃"，其他情况可为空
    let completedAt: Date

    init(
        id: UUID = UUID(),
        exerciseName: String,
        targetWeight: Double,
        targetReps: Int,
        setOrder: Int,
        actualWeight: Double,
        actualReps: Int,
        notes: String = "",
        completedAt: Date = Date()
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.targetWeight = targetWeight
        self.targetReps = targetReps
        self.setOrder = setOrder
        self.actualWeight = actualWeight
        self.actualReps = actualReps
        self.notes = notes
        self.completedAt = completedAt
    }
}

// MARK: - Supporting Enums

enum SetType: String, Codable, CaseIterable {
    case warmup = "warmup"        // 热身组
    case working = "working"      // 正式组

    var displayName: String {
        switch self {
        case .warmup: return "热身组"
        case .working: return "正式组"
        }
    }

    var defaultRestTime: Int {
        switch self {
        case .warmup: return 30
        case .working: return 90
        }
    }
}

enum SessionStatus: String, Codable, CaseIterable {
    case planned = "planned"
    case inProgress = "inProgress"
    case paused = "paused"
    case completed = "completed"
    case abandoned = "abandoned"

    var displayName: String {
        switch self {
        case .planned: return "计划中"
        case .inProgress: return "进行中"
        case .paused: return "已暂停"
        case .completed: return "已完成"
        case .abandoned: return "已放弃"
        }
    }
}
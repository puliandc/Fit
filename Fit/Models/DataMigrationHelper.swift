//
//  DataMigrationHelper.swift
//  Fit
//
//  Created by Jason Lu on 10:00:00 10/12/2025.
//

import Foundation

// MARK: - Data Migration Helper
class DataMigrationHelper {

    /// 简化的数据迁移，从现有MockData创建简化版训练计划
    static func createSimpleTrainingPlans() -> [TrainingPlan] {
        let mockData = MockDataProvider.shared
        var plans: [TrainingPlan] = []

        for mockPlan in mockData.sampleWorkoutPlans {
            // 转换MockData中的ExerciseSet为TrainingExercise
            let exercises = convertMockPlanToTrainingPlan(mockPlan)

            let simplePlan = TrainingPlan(
                name: mockPlan.name,
                description: mockPlan.description,
                exercises: exercises
            )

            plans.append(simplePlan)
        }

        print("✅ 简化版训练计划创建完成")
        print("📊 创建了 \(plans.count) 个训练计划")

        return plans
    }

    /// 转换MockData的WorkoutPlan为简化版TrainingPlan
    private static func convertMockPlanToTrainingPlan(_ mockPlan: WorkoutPlan) -> [TrainingExercise] {
        // 按练习名称分组
        let groupedSets = Dictionary(grouping: mockPlan.exercises) { $0.exercise.name }
        var exercises: [TrainingExercise] = []

        for (exerciseName, sets) in groupedSets {
            // 将ExerciseSet转换为TrainingSet
            let trainingSets = sets.enumerated().map { index, mockSet in
                TrainingSet(
                    setType: determineSetType(for: index, totalSets: sets.count),
                    targetReps: mockSet.targetReps,
                    targetWeight: mockSet.targetWeight,
                    restTime: mockSet.restTime
                )
            }

            let exercise = TrainingExercise(
                name: exerciseName,
                sets: trainingSets
            )

            exercises.append(exercise)
        }

        return exercises.sorted { $0.name < $1.name }
    }

    /// 确定组类型
    private static func determineSetType(for index: Int, totalSets: Int) -> SetType {
        if index == 0 && totalSets > 1 {
            return .warmup
        } else {
            return .working
        }
    }
}
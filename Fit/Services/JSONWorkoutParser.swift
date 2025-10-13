//created by Jason Lu on 09:46:00 10/13/2025
// FIT应用JSON训练计划解析器 - 版本1.2基础JSON解析实现

import Foundation

// MARK: - JSON训练计划解析器
class JSONWorkoutParser {

    // 解析器初始化
    init() {
        print("📖 JSONWorkoutParser初始化完成 - 版本1.2基础JSON解析实现")
    }

    // 版本1.2: 实现基础JSON解析功能
    func parseWorkoutPlan(from data: Data) throws -> WorkoutPlan {
        print("🔄 版本1.2: 开始解析JSON训练计划")
        print("📊 数据大小: \(data.count) 字节")

        // 1. JSON格式验证
        guard basicJSONValidation(data) else {
            print("❌ JSON格式验证失败")
            throw JSONParseError.invalidFormat
        }
        print("✅ JSON格式验证通过")

        // 2. 解析JSON数据
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ JSON数据结构解析失败")
            throw JSONParseError.invalidStructure
        }
        print("✅ JSON数据结构解析成功")

        // 3. 提取训练计划名称
        guard let planName = json["训练计划名称"] as? String else {
            print("❌ 未找到训练计划名称字段")
            throw JSONParseError.missingPlanName
        }
        print("🏷️ 提取训练计划名称: \(planName)")

        // 4. 提取练习项目（版本1.2暂时不完整解析，只验证存在性）
        guard let exercises = json["练习项目"] as? [[String: Any]] else {
            print("❌ 未找到练习项目字段")
            throw JSONParseError.missingExercises
        }
        print("📋 找到 \(exercises.count) 个练习项目")

        // 版本1.2: 创建基础的WorkoutPlan对象
        let workoutPlan = createBasicWorkoutPlan(name: planName, exercises: exercises)
        print("🎯 训练计划名称解析成功")

        return workoutPlan
    }

    // 版本1.2: 增强的JSON格式验证
    func basicJSONValidation(_ data: Data) -> Bool {
        print("🔍 版本1.2: 增强JSON格式验证")

        // 检查数据是否为空
        guard data.count > 0 else {
            print("❌ 数据为空")
            return false
        }

        // 尝试解析JSON格式
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            guard let dict = json as? [String: Any] else {
                print("❌ JSON不是有效的对象格式")
                return false
            }

            // 验证必要字段存在
            guard dict["训练计划名称"] != nil else {
                print("❌ 缺少训练计划名称字段")
                return false
            }

            guard dict["练习项目"] != nil else {
                print("❌ 缺少练习项目字段")
                return false
            }

            print("✅ JSON格式验证通过")
            return true
        } catch {
            print("❌ JSON解析错误: \(error.localizedDescription)")
            return false
        }
    }

    // 版本1.2: 创建基础的WorkoutPlan对象
    private func createBasicWorkoutPlan(name: String, exercises: [[String: Any]]) -> WorkoutPlan {
        print("🏗️ 创建基础WorkoutPlan对象")

        // 版本1.2: 创建简化版的ExerciseSet列表
        var exerciseSets: [ExerciseSet] = []

        for (index, exerciseDict) in exercises.enumerated() {
            if let exerciseName = exerciseDict["练习名称"] as? String {
                // 创建一个基础的Exercise对象（使用默认值）
                let exercise = Exercise(
                    name: exerciseName,
                    category: .strength, // 默认为力量训练
                    muscleGroups: [.chest], // 默认肌肉群
                    equipment: .barbell, // 默认器械
                    difficulty: .intermediate, // 默认难度
                    instructions: ["请根据个人情况调整重量和次数"],
                    imageName: "default_exercise"
                )

                // 创建第一个组的信息（简化处理）
                let targetReps = 10 // 默认次数
                let targetWeight = 20.0 // 默认重量
                let restTime = 90 // 默认休息时间

                let exerciseSet = ExerciseSet(
                    exercise: exercise,
                    targetReps: targetReps,
                    targetWeight: targetWeight,
                    restTime: restTime
                )

                exerciseSets.append(exerciseSet)
                print("  📝 添加练习: \(exerciseName) - \(targetReps)次 x \(targetWeight)kg")
            }
        }

        // 创建WorkoutPlan对象
        let workoutPlan = WorkoutPlan(
            name: name,
            description: "从外部JSON文件导入的训练计划 - \(exercises.count)个练习项目",
            category: .strength,
            difficulty: .intermediate,
            duration: exerciseSets.count * 5, // 估算时长（每个练习5分钟）
            exercises: exerciseSets,
            estimatedCalories: exerciseSets.count * 50, // 估算热量
            createdBy: "外部JSON文件"
        )

        print("✅ WorkoutPlan创建完成: \(workoutPlan.name)")
        return workoutPlan
    }
}

// MARK: - 解析错误类型（版本1.2增强）
enum JSONParseError: LocalizedError {
    case notImplemented
    case invalidFormat
    case invalidStructure
    case missingPlanName
    case missingExercises

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "JSON解析功能正在开发中，将在版本1.2中实现"
        case .invalidFormat:
            return "JSON格式无效，请检查文件格式"
        case .invalidStructure:
            return "JSON数据结构不正确，请按照标准格式编写"
        case .missingPlanName:
            return "缺少训练计划名称字段"
        case .missingExercises:
            return "缺少练习项目字段"
        }
    }
}
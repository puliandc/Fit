// created by Jason Lu on 09:46:00 10/13/2025
// updated by Jason Lu on 15:45:00 10/15/2025 - 简化版JSON训练计划解析器

import Foundation

// MARK: - JSON训练计划解析器

class JSONWorkoutParser
{
    // 解析器初始化
    init()
    { }

    // 解析JSON训练计划
    func parseWorkoutPlan(from data: Data) throws -> WorkoutPlan
    {
        // 1. JSON格式验证
        guard basicJSONValidation(data)
        else
        {
            throw JSONParseError.invalidFormat
        }

        // 2. 解析JSON数据
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else
        {
            throw JSONParseError.invalidStructure
        }

        // 3. 提取训练计划名称
        guard let planName = json["训练计划名称"] as? String
        else
        {
            throw JSONParseError.missingPlanName
        }

        // 4. 解析练习项目和组数配置
        guard let exerciseItems = json["练习项目"] as? [[String: Any]]
        else
        {
            throw JSONParseError.missingExercises
        }

        // 5. 解析训练项目数据
        let exerciseSets = try parseExerciseItems(exerciseItems)

        // 6. 创建WorkoutPlan对象
        let workoutPlan = createCompleteWorkoutPlan(name: planName, exerciseSets: exerciseSets)

        return workoutPlan
    }

    // JSON格式验证
    func basicJSONValidation(_ data: Data) -> Bool
    {
        // 检查数据是否为空
        guard data.count > 0
        else
        {
            return false
        }

        // 尝试解析JSON格式
        do
        {
            let json = try JSONSerialization.jsonObject(with: data)
            guard let dict = json as? [String: Any]
            else
            {
                return false
            }

            // 验证必要字段存在
            guard dict["训练计划名称"] != nil
            else
            {
                return false
            }

            guard dict["练习项目"] != nil
            else
            {
                return false
            }

            return true
        }
        catch
        {
            return false
        }
    }

    // 解析练习项目和组数配置
    private func parseExerciseItems(_ exerciseItems: [[String: Any]]) throws -> [ExerciseSet]
    {
        var exerciseSets: [ExerciseSet] = []

        for (exerciseIndex, exerciseDict) in exerciseItems.enumerated()
        {
            guard let exerciseName = exerciseDict["练习名称"] as? String
            else
            {
                throw JSONParseError.missingExerciseName(exerciseIndex + 1)
            }

            // 创建Exercise对象
            let exercise = createExerciseFromName(exerciseName)

            // 解析组数设置
            guard let setConfigs = exerciseDict["组数设置"] as? [[String: Any]]
            else
            {
                throw JSONParseError.missingSetConfig(exerciseName)
            }

            // 为每个组数设置创建ExerciseSet
            for (setIndex, setConfig) in setConfigs.enumerated()
            {
                if
                    let exerciseSet = createExerciseSet(
                        from: setConfig,
                        exercise: exercise,
                        exerciseName: exerciseName,
                        setIndex: setIndex + 1
                    )
                {
                    exerciseSets.append(exerciseSet)
                }
            }
        }

        return exerciseSets
    }

    // 创建基础Exercise对象（简化版）
    private func createExerciseFromName(_ exerciseName: String) -> Exercise
    {
        return Exercise(name: exerciseName)
    }

    // 创建ExerciseSet对象
    private func createExerciseSet(
        from setConfig: [String: Any],
        exercise: Exercise,
        exerciseName _: String,
        setIndex _: Int
    ) -> ExerciseSet?
    {
        guard
            let targetReps = setConfig["目标次数"] as? Int,
            let targetWeight = setConfig["目标重量"] as? Double
        else
        {
            return nil
        }

        let restTime = setConfig["休息时间"] as? Int ?? 90 // 默认90秒休息

        return ExerciseSet(
            exercise: exercise,
            targetReps: targetReps,
            targetWeight: targetWeight,
            restTime: restTime
        )
    }

    // 创建WorkoutPlan对象（简化版）
    private func createCompleteWorkoutPlan(name: String, exerciseSets: [ExerciseSet]) -> WorkoutPlan
    {
        // 计算训练时长 - 基于实际组数和休息时间
        let totalEstimatedTime = exerciseSets.reduce(0)
        { total, _ in
            total + 60 // 每组大约60秒
        } + exerciseSets.dropLast().reduce(0)
        { total, set in
            total + set.restTime // 休息时间
        }

        let workoutPlan = WorkoutPlan(
            name: name,
            duration: Int(totalEstimatedTime / 60), // 基于实际计算
            exercises: exerciseSets
        )

        return workoutPlan
    }
}

// MARK: - 解析错误类型

enum JSONParseError: LocalizedError
{
    case invalidFormat
    case invalidStructure
    case missingPlanName
    case missingExercises
    case missingExerciseName(Int)
    case missingSetConfig(String)

    var errorDescription: String?
    {
        switch self
        {
        case .invalidFormat:
            return "JSON格式无效，请检查文件格式"
        case .invalidStructure:
            return "JSON数据结构不正确，请按照标准格式编写"
        case .missingPlanName:
            return "缺少训练计划名称字段"
        case .missingExercises:
            return "缺少练习项目字段"
        case let .missingExerciseName(index):
            return "第\(index)个练习项目缺少练习名称字段"
        case let .missingSetConfig(exerciseName):
            return "练习 '\(exerciseName)' 缺少组数设置字段"
        }
    }
}

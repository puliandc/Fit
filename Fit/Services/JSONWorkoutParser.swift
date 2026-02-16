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

            guard !setConfigs.isEmpty
            else
            {
                throw JSONParseError.invalidSetConfig(
                    exerciseName: exerciseName,
                    setIndex: 0,
                    reason: "组数设置不能为空"
                )
            }

            // 为每个组数设置创建ExerciseSet
            for (setIndex, setConfig) in setConfigs.enumerated()
            {
                let exerciseSet = try createExerciseSet(
                    from: setConfig,
                    exercise: exercise,
                    exerciseName: exerciseName,
                    setIndex: setIndex + 1
                )
                exerciseSets.append(exerciseSet)
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
        exerciseName: String,
        setIndex: Int
    ) throws -> ExerciseSet
    {
        guard let targetReps = setConfig["目标次数"] as? Int
        else
        {
            throw JSONParseError.invalidSetConfig(
                exerciseName: exerciseName,
                setIndex: setIndex,
                reason: "目标次数必须是整数"
            )
        }

        let targetWeight = try parseTargetWeight(
            from: setConfig,
            exerciseName: exerciseName,
            setIndex: setIndex
        )

        let restTime: Int
        if let rawRestTime = setConfig["休息时间"]
        {
            guard let parsedRestTime = rawRestTime as? Int
            else
            {
                throw JSONParseError.invalidSetConfig(
                    exerciseName: exerciseName,
                    setIndex: setIndex,
                    reason: "休息时间必须是整数"
                )
            }
            restTime = parsedRestTime
        }
        else
        {
            restTime = 90
        }

        let notes = try parseNotes(
            from: setConfig,
            exerciseName: exerciseName,
            setIndex: setIndex
        )

        return ExerciseSet(
            exercise: exercise,
            targetReps: targetReps,
            targetWeight: targetWeight,
            restTime: restTime,
            notes: notes
        )
    }

    private func parseTargetWeight(
        from setConfig: [String: Any],
        exerciseName: String,
        setIndex: Int
    ) throws -> Double
    {
        guard let rawTargetWeight = setConfig["目标重量"]
        else
        {
            throw JSONParseError.invalidSetConfig(
                exerciseName: exerciseName,
                setIndex: setIndex,
                reason: "缺少目标重量字段"
            )
        }

        if let targetWeight = rawTargetWeight as? Double
        {
            return targetWeight
        }

        if let targetWeight = rawTargetWeight as? Int
        {
            return Double(targetWeight)
        }

        throw JSONParseError.invalidSetConfig(
            exerciseName: exerciseName,
            setIndex: setIndex,
            reason: "目标重量必须是数字（支持整数和小数）"
        )
    }

    private func parseNotes(
        from setConfig: [String: Any],
        exerciseName: String,
        setIndex: Int
    ) throws -> String?
    {
        guard let rawNotes = setConfig["备注"]
        else
        {
            return nil
        }

        guard let notes = rawNotes as? String
        else
        {
            throw JSONParseError.invalidSetConfig(
                exerciseName: exerciseName,
                setIndex: setIndex,
                reason: "备注必须是字符串"
            )
        }

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedNotes.isEmpty ? nil : trimmedNotes
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
    case invalidSetConfig(exerciseName: String, setIndex: Int, reason: String)

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
        case let .invalidSetConfig(exerciseName, setIndex, reason):
            if setIndex > 0
            {
                return "练习 '\(exerciseName)' 第\(setIndex)组配置错误：\(reason)"
            }
            else
            {
                return "练习 '\(exerciseName)' 组数配置错误：\(reason)"
            }
        }
    }
}

//created by Jason Lu on 09:46:00 10/13/2025
// FIT应用JSON训练计划解析器 - 版本1.3完整训练计划解析实现

import Foundation

// MARK: - JSON训练计划解析器
class JSONWorkoutParser {

    // 解析器初始化
    init() {
        print("📖 JSONWorkoutParser初始化完成 - 版本1.3完整训练计划解析实现")
    }

    // 版本1.3: 实现完整JSON解析功能
    func parseWorkoutPlan(from data: Data) throws -> WorkoutPlan {
        print("🔄 版本1.3: 开始解析JSON训练计划")
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

        // 4. 版本1.3: 完整解析练习项目和组数配置
        guard let exerciseItems = json["练习项目"] as? [[String: Any]] else {
            print("❌ 未找到练习项目字段")
            throw JSONParseError.missingExercises
        }
        print("📋 找到 \(exerciseItems.count) 个练习项目")

        // 版本1.3: 解析完整的练习项目数据
        let exerciseSets = try parseExerciseItems(exerciseItems)
        print("🎯 完整训练计划解析成功")

        // 5. 版本1.3: 创建包含完整数据的WorkoutPlan对象
        let workoutPlan = createCompleteWorkoutPlan(name: planName, exerciseSets: exerciseSets)

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

    // 版本1.3: 完整解析练习项目和组数配置
    private func parseExerciseItems(_ exerciseItems: [[String: Any]]) throws -> [ExerciseSet] {
        print("🏋️ 正在解析训练计划中的练习项目")
        var exerciseSets: [ExerciseSet] = []

        for (exerciseIndex, exerciseDict) in exerciseItems.enumerated() {
            guard let exerciseName = exerciseDict["练习名称"] as? String else {
                print("❌ 练习项目 \(exerciseIndex + 1) 缺少练习名称字段")
                throw JSONParseError.missingExerciseName(exerciseIndex + 1)
            }

            print("📝 解析练习: \(exerciseName)")

            // 创建Exercise对象（使用智能推断的属性）
            let exercise = createExerciseFromName(exerciseName)

            // 解析组数设置
            guard let setConfigs = exerciseDict["组数设置"] as? [[String: Any]] else {
                print("❌ 练习 '\(exerciseName)' 缺少组数设置字段")
                throw JSONParseError.missingSetConfig(exerciseName)
            }

            print("  📊 找到 \(setConfigs.count) 个组数设置")

            // 为每个组数设置创建ExerciseSet
            for (setIndex, setConfig) in setConfigs.enumerated() {
                if let exerciseSet = createExerciseSet(
                    from: setConfig,
                    exercise: exercise,
                    exerciseName: exerciseName,
                    setIndex: setIndex + 1
                ) {
                    exerciseSets.append(exerciseSet)
                    print("    ✅ 添加组 \(setIndex + 1): \(exerciseSet.targetReps)次 x \(exerciseSet.targetWeight)kg，休息\(exerciseSet.restTime)秒")
                }
            }

            print("✅ 练习项目解析完成: \(exerciseName) (\(setConfigs.count)组)")
        }

        print("🎉 完整训练计划加载成功 - 共 \(exerciseSets.count) 个训练组")
        return exerciseSets
    }

    // 版本1.3: 根据练习名称智能创建Exercise对象
    private func createExerciseFromName(_ exerciseName: String) -> Exercise {
        // 根据练习名称智能推断属性
        let category = determineExerciseCategory(exerciseName)
        let muscleGroups = determineMuscleGroups(exerciseName)
        let equipment = determineEquipment(exerciseName)
        let difficulty = determineDifficulty(exerciseName)

        return Exercise(
            name: exerciseName,
            category: category,
            muscleGroups: muscleGroups,
            equipment: equipment,
            difficulty: difficulty,
            instructions: generateInstructions(for: exerciseName, equipment: equipment),
            tips: generateTips(for: exerciseName),
            imageName: exerciseName.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "_")
        )
    }

    // 版本1.3: 创建ExerciseSet对象
    private func createExerciseSet(
        from setConfig: [String: Any],
        exercise: Exercise,
        exerciseName: String,
        setIndex: Int
    ) -> ExerciseSet? {
        guard let targetReps = setConfig["目标次数"] as? Int,
              let targetWeight = setConfig["目标重量"] as? Double else {
            print("❌ 练习 '\(exerciseName)' 第\(setIndex)组缺少必要字段")
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

    // 版本1.3: 创建包含完整数据的WorkoutPlan对象
    private func createCompleteWorkoutPlan(name: String, exerciseSets: [ExerciseSet]) -> WorkoutPlan {
        print("🏗️ 创建包含完整数据的WorkoutPlan对象")

        // 计算训练计划属性
        let totalEstimatedTime = exerciseSets.reduce(0) { total, set in
            total + 60 // 每组大约60秒
        } + exerciseSets.dropLast().reduce(0) { total, set in
            total + set.restTime // 休息时间
        }

        let estimatedCalories = exerciseSets.count * 35 // 每组大约35卡路里

        let workoutPlan = WorkoutPlan(
            name: name,
            description: "从外部JSON文件导入的完整训练计划 - 包含\(exerciseSets.count)个训练组",
            category: .strength,
            difficulty: .intermediate,
            duration: Int(totalEstimatedTime / 60), // 转换为分钟
            exercises: exerciseSets,
            estimatedCalories: estimatedCalories,
            createdBy: "外部JSON文件"
        )

        print("✅ 完整WorkoutPlan创建完成: \(workoutPlan.name)")
        print("📊 总时长: \(workoutPlan.duration)分钟，预估热量: \(workoutPlan.estimatedCalories)卡路里")
        return workoutPlan
    }
}

// MARK: - 智能推断方法
extension JSONWorkoutParser {

    // 根据练习名称推断运动类别
    private func determineExerciseCategory(_ exerciseName: String) -> ExerciseCategory {
        let lowercasedName = exerciseName.lowercased()

        if lowercasedName.contains("深蹲") || lowercasedName.contains("卧推") ||
           lowercasedName.contains("硬拉") || lowercasedName.contains("推举") {
            return .strength
        } else if lowercasedName.contains("跑步") || lowercasedName.contains("跳绳") {
            return .cardio
        } else if lowercasedName.contains("拉伸") || lowercasedName.contains("瑜伽") {
            return .flexibility
        } else {
            return .strength // 默认为力量训练
        }
    }

    // 根据练习名称推断主要肌肉群
    private func determineMuscleGroups(_ exerciseName: String) -> [MuscleGroup] {
        let lowercasedName = exerciseName.lowercased()

        if lowercasedName.contains("卧推") || lowercasedName.contains("飞鸟") {
            return [.chest, .triceps, .shoulders]
        } else if lowercasedName.contains("深蹲") || lowercasedName.contains("腿举") {
            return [.legs, .glutes]
        } else if lowercasedName.contains("下拉") || lowercasedName.contains("划船") {
            return [.back, .biceps]
        } else if lowercasedName.contains("弯举") {
            return [.biceps]
        } else if lowercasedName.contains("臂屈伸") || lowercasedName.contains("钻石俯卧撑") {
            return [.triceps]
        } else if lowercasedName.contains("推举") || lowercasedName.contains("肩推") {
            return [.shoulders]
        } else if lowercasedName.contains("卷腹") || lowercasedName.contains("平板") {
            return [.core, .abs]
        } else {
            return [.chest] // 默认胸部
        }
    }

    // 根据练习名称推断器械类型
    private func determineEquipment(_ exerciseName: String) -> Equipment {
        let lowercasedName = exerciseName.lowercased()

        if lowercasedName.contains("杠铃") {
            return .barbell
        } else if lowercasedName.contains("哑铃") {
            return .dumbbells
        } else if lowercasedName.contains("壶铃") {
            return .kettlebell
        } else if lowercasedName.contains("龙门架") || lowercasedName.contains("缆绳") {
            return .cable
        } else if lowercasedName.contains("拉力器") {
            return .resistanceBands
        } else if lowercasedName.contains("单杠") || lowercasedName.contains("引体向上") {
            return .pullUpBar
        } else if lowercasedName.contains("凳") {
            return .bench
        } else if lowercasedName.contains("器械") {
            return .machine
        } else {
            return .none // 默认自重
        }
    }

    // 根据练习名称推断难度
    private func determineDifficulty(_ exerciseName: String) -> Difficulty {
        let lowercasedName = exerciseName.lowercased()

        if lowercasedName.contains("深蹲") || lowercasedName.contains("硬拉") ||
           lowercasedName.contains("卧推") {
            return .advanced
        } else if lowercasedName.contains("推举") || lowercasedName.contains("下拉") {
            return .intermediate
        } else {
            return .beginner // 默认初级
        }
    }

    // 生成练习指导
    private func generateInstructions(for exerciseName: String, equipment: Equipment) -> [String] {
        let lowercasedName = exerciseName.lowercased()

        if lowercasedName.contains("深蹲") {
            return [
                "双脚与肩同宽站立",
                "臀部向后坐，如同坐在椅子上",
                "保持背部挺直，下蹲至大腿与地面平行",
                "通过脚跟发力返回起始位置"
            ]
        } else if lowercasedName.contains("卧推") {
            return [
                "躺在平板凳上，双手握住杠铃",
                "将杠铃下降至胸部位置",
                "用力将杠铃推起至手臂完全伸直",
                "控制动作速度，保持稳定"
            ]
        } else if lowercasedName.contains("下拉") {
            return [
                "坐在下拉器械上，调整护垫",
                "双手握住横杆，比肩略宽",
                "将横杆下拉至上胸部位置",
                "缓慢返回起始位置，感受背部拉伸"
            ]
        } else {
            return [
                "保持正确的姿势",
                "控制动作节奏",
                "注意呼吸配合",
                "根据个人能力调整重量"
            ]
        }
    }

    // 生成练习提示
    private func generateTips(for exerciseName: String) -> [String] {
        let lowercasedName = exerciseName.lowercased()

        if lowercasedName.contains("深蹲") {
            return [
                "膝盖不要超过脚尖",
                "保持核心收紧",
                "下蹲时吸气，起立时呼气"
            ]
        } else if lowercasedName.contains("卧推") {
            return [
                "肩胛骨收紧并下沉",
                "杠铃下降时控制速度",
                "推起时不要锁定肘关节"
            ]
        } else {
            return [
                "循序渐进增加重量",
                "感受目标肌肉的收缩",
                "保持正确的动作形式"
            ]
        }
    }
}

// MARK: - 解析错误类型（版本1.3增强）
enum JSONParseError: LocalizedError {
    case notImplemented
    case invalidFormat
    case invalidStructure
    case missingPlanName
    case missingExercises
    case missingExerciseName(Int)
    case missingSetConfig(String)

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "JSON解析功能正在开发中，将在版本1.3中实现"
        case .invalidFormat:
            return "JSON格式无效，请检查文件格式"
        case .invalidStructure:
            return "JSON数据结构不正确，请按照标准格式编写"
        case .missingPlanName:
            return "缺少训练计划名称字段"
        case .missingExercises:
            return "缺少练习项目字段"
        case .missingExerciseName(let index):
            return "第\(index)个练习项目缺少练习名称字段"
        case .missingSetConfig(let exerciseName):
            return "练习 '\(exerciseName)' 缺少组数设置字段"
        }
    }
}
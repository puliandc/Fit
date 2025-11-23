// created by Jason Lu on 09:45:00 10/13/2025
// FIT应用外部训练计划服务 - 版本1.3完整训练计划解析实现

import Combine
import Foundation
import SwiftUI

// MARK: - 外部训练计划服务

@MainActor
class ExternalTrainingPlanService: ObservableObject
{
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentWorkoutPlan: WorkoutPlan?

    // 依赖的辅助服务
    private let fileValidator = FileSecurityValidator()
    private let jsonParser = JSONWorkoutParser()

    // 版本1.0: 架构准备状态
    @Published var architectureReady = false

    // 服务初始化
    init()
    {
        print("🚀 版本1.3: ExternalTrainingPlanService完整训练计划解析服务初始化")
        print("📁 建立外部文件处理架构")
        print("🔒 文件验证器已集成")
        print("📖 JSON解析器已集成 - 支持完整训练数据解析")
        print("🏗️ 版本1.3目标: 实现完整训练计划显示功能")

        // 标记架构准备就绪
        architectureReady = true

        print("✅ 版本1.3: 完整训练计划解析服务初始化完成")
    }

    // 版本1.3: 完整训练计划文件处理
    func loadWorkoutPlan(from url: URL) async
    {
        print("🔄 版本1.3: 启动完整训练计划处理流程")
        print("📍 文件路径: \(url.lastPathComponent)")
        print("🏗️ 版本1.3: 完整训练计划解析阶段")

        do
        {
            isLoading = true
            errorMessage = nil

            // 1. 文件安全验证
            print("🔍 步骤1: 文件安全验证")
            let validationResult = fileValidator.validateFile(url)
            print("📊 验证结果: \(validationResult.description)")

            // 2. 文件读取
            print("📖 步骤2: 读取文件内容")
            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
            print("📊 文件大小: \(data.count) 字节")

            // 3. 版本1.3: 完整JSON解析
            print("🔍 步骤3: 版本1.3 完整训练计划解析")
            print("📖 开始解析JSON文件: \(url.lastPathComponent)")

            let workoutPlan = try jsonParser.parseWorkoutPlan(from: data)

            // 4. 设置解析结果
            print("🎯 完整训练计划解析成功，设置训练计划")
            currentWorkoutPlan = workoutPlan

            print("✅ 版本1.3: 完整训练计划加载完成")
            print("📝 计划名称: \(workoutPlan.name)")
            print("📝 训练组数: \(workoutPlan.exercises.count)")
            print("📝 预估时长: \(workoutPlan.duration)分钟")
            // NOTE: estimatedCalories field removed during model refactoring to simplify data structure

            // 版本1.3: 显示解析出的练习项目详情
            print("📋 练习项目详情:")
            var currentExerciseName: String? = nil
            var exerciseGroupCount = 0

            for (_, exerciseSet) in workoutPlan.exercises.enumerated()
            {
                let exerciseName = exerciseSet.exercise.name

                if exerciseName != currentExerciseName
                {
                    currentExerciseName = exerciseName
                    exerciseGroupCount = 1
                    print("  🏋️ 练习 \(exerciseName)")
                }
                else
                {
                    exerciseGroupCount += 1
                }

                print("    📊 第\(exerciseGroupCount)组: \(exerciseSet.targetReps)次 × \(exerciseSet.targetWeight)kg，休息\(exerciseSet.restTime)秒")
            }
        }
        catch
        {
            errorMessage = "JSON解析失败 - \(error.localizedDescription)"
            print("❌ 完整训练计划解析过程中出现错误: \(error.localizedDescription)")

            // 版本1.3: 提供更详细的错误信息
            if let parseError = error as? JSONParseError
            {
                print("🚨 解析错误类型: \(parseError.localizedDescription)")
            }
        }

        isLoading = false
        print("✅ 版本1.3: 完整训练计划解析流程完成")
    }

    // 版本1.0: 模拟架构处理流程
    private func simulateArchitectureProcessing() async
    {
        print("🔄 模拟架构处理流程...")

        // 模拟处理时间
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

        print("✅ 文件验证架构: 正常")
        print("✅ 文件读取架构: 正常")
        print("✅ JSON验证架构: 正常")
        print("🏗️ 版本1.0架构验证: 全部通过")
    }

    // 版本1.0: 获取MockData数据（保持现有数据源不变）
    func getMockWorkoutPlan() -> WorkoutPlan?
    {
        print("🔄 版本1.0: 返回MockData数据源")
        return MockDataProvider.shared.sampleWorkoutPlans.first
    }

    // 基础的错误处理（将在版本1.4中完善）
    func clearError()
    {
        errorMessage = nil
        print("🧹 清除错误信息")
    }

    // 基础的重置功能
    func resetWorkoutPlan()
    {
        currentWorkoutPlan = nil
        errorMessage = nil
        print("🔄 重置训练计划状态")
    }

    // 版本1.0: 架构状态检查
    func checkArchitectureStatus() -> Bool
    {
        return architectureReady
    }
}

// MARK: - 版本1.0基础错误类型（将在版本1.4中完善）

enum ExternalTrainingPlanError: LocalizedError
{
    case notImplemented

    var errorDescription: String?
    {
        switch self
        {
        case .notImplemented:
            return "功能正在开发中，将在后续版本中实现"
        }
    }
}

// MARK: - 服务状态

extension ExternalTrainingPlanService
{
    var hasWorkoutPlan: Bool
    {
        return currentWorkoutPlan != nil
    }

    var isProcessing: Bool
    {
        return isLoading
    }
}

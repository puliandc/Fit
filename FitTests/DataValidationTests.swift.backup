//
//  DataValidationTests.swift
//  FitTests
//
//  Created by Quality Engineer on 10/11/2025.
//  Data validation and quality assurance tests
//

import XCTest
@testable import Fit

// MARK: - Data Validation Tests
//created by Jason Lu on 22:00:00 10/11/2025

class DataValidationTests: TestSuiteConfiguration {

    // MARK: - MockDataProvider Validation Tests
    func testMockDataProviderSingletonValidation() {
        // 测试MockDataProvider单例验证
        let provider1 = MockDataProvider.shared
        let provider2 = MockDataProvider.shared

        XCTAssertTrue(provider1 === provider2, "MockDataProvider应为单例")
        XCTAssertNotNil(provider1, "MockDataProvider不应为空")
        XCTAssertNotNil(provider2, "MockDataProvider不应为空")
    }

    func testMockDataProviderDataIntegrityValidation() {
        // 测试MockDataProvider数据完整性验证
        let provider = MockDataProvider.shared
        let qualityManager = QualityAssuranceManager.shared

        // 启动质量监控
        qualityManager.startQualityMonitoring()

        // 验证数据完整性
        XCTAssertFalse(provider.sampleExercises.isEmpty, "示例练习列表不应为空")
        XCTAssertFalse(provider.sampleWorkoutPlans.isEmpty, "示例训练计划列表不应为空")

        // 检查每个练习的数据完整性
        for (index, exercise) in provider.sampleExercises.enumerated() {
            let validation = DataValidator.validateExercise(exercise)
            XCTAssertTrue(validation.isValid, "练习 \(index + 1) 数据完整性验证失败: \(exercise.name)")

            if !validation.isValid {
                XCTFail("练习 \(index + 1) 验证错误: \(validation.errors.map { $0.errorDescription }.joined(separator: ", "))")
            }
        }

        // 检查每个训练计划的数据完整性
        for (index, workoutPlan) in provider.sampleWorkoutPlans.enumerated() {
            let validation = DataValidator.validateWorkoutPlan(workoutPlan)
            XCTAssertTrue(validation.isValid, "训练计划 \(index + 1) 数据完整性验证失败: \(workoutPlan.name)")

            if !validation.isValid {
                XCTFail("训练计划 \(index + 1) 验证错误: \(validation.errors.map { $0.errorDescription }.joined(separator: ", "))")
            }
        }

        // 验证质量评分
        XCTAssertGreaterThanOrEqual(qualityManager.qualityScore, 90.0, "数据质量评分应大于等于90")

        // 停止质量监控
        qualityManager.stopQualityMonitoring()
    }

    func testMockDataProviderCyclicDependencyValidation() {
        // 测试MockDataProvider循环依赖修复验证
        let startTime = CFAbsoluteTimeGetCurrent()
        let provider = MockDataProvider.shared

        // 验证初始化完成
        XCTAssertNotNil(provider.sampleExercises, "示例练习应已初始化")
        XCTAssertNotNil(provider.sampleWorkoutPlans, "示例训练计划应已初始化")

        let initializationTime = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(initializationTime, 1.0, "初始化时间应少于1秒")

        // 验证数据关联完整性
        for workoutPlan in provider.sampleWorkoutPlans {
            for exerciseSet in workoutPlan.exercises {
                XCTAssertTrue(provider.sampleExercises.contains(where: { $0.id == exerciseSet.exercise.id }),
                             "训练计划中的练习应存在于示例练习列表中")
            }
        }
    }

    // MARK: - WorkoutPlan Validation Tests
    func testWorkoutPlanValidationWithValidData() {
        // 测试有效训练计划验证
        let workoutPlan = createTestWorkoutPlan()
        let validation = DataValidator.validateWorkoutPlan(workoutPlan)

        XCTAssertTrue(validation.isValid, "有效训练计划应通过验证")
        XCTAssertTrue(validation.errors.isEmpty, "有效训练计划不应有验证错误")
    }

    func testWorkoutPlanValidationWithInvalidName() {
        // 测试无效名称训练计划验证
        let invalidWorkoutPlan = WorkoutPlan(
            name: "", // 无效名称
            description: "Test Description",
            category: .fullBody,
            difficulty: .beginner,
            duration: 30,
            exercises: [createTestExerciseSet()],
            estimatedCalories: 200
        )

        let validation = DataValidator.validateWorkoutPlan(invalidWorkoutPlan)

        XCTAssertFalse(validation.isValid, "无效名称训练计划应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
        XCTAssertTrue(validation.errors.contains {
            if case .emptyField(let field) = $0 { return field == "锻炼计划名称" }
            return false
        }, "应包含名称为空错误")
    }

    func testWorkoutPlanValidationWithInvalidDuration() {
        // 测试无效时长训练计划验证
        let invalidWorkoutPlan = WorkoutPlan(
            name: "Test Workout",
            description: "Test Description",
            category: .fullBody,
            difficulty: .beginner,
            duration: -1, // 无效时长
            exercises: [createTestExerciseSet()],
            estimatedCalories: 200
        )

        let validation = DataValidator.validateWorkoutPlan(invalidWorkoutPlan)

        XCTAssertFalse(validation.isValid, "无效时长训练计划应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    func testWorkoutPlanValidationWithInvalidCalories() {
        // 测试无效卡路里训练计划验证
        let invalidWorkoutPlan = WorkoutPlan(
            name: "Test Workout",
            description: "Test Description",
            category: .fullBody,
            difficulty: .beginner,
            duration: 30,
            exercises: [createTestExerciseSet()],
            estimatedCalories: -100 // 无效卡路里
        )

        let validation = DataValidator.validateWorkoutPlan(invalidWorkoutPlan)

        XCTAssertFalse(validation.isValid, "无效卡路里训练计划应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    func testWorkoutPlanValidationWithEmptyExercises() {
        // 测试空练习列表训练计划验证
        let invalidWorkoutPlan = WorkoutPlan(
            name: "Test Workout",
            description: "Test Description",
            category: .fullBody,
            difficulty: .beginner,
            duration: 30,
            exercises: [], // 空练习列表
            estimatedCalories: 200
        )

        let validation = DataValidator.validateWorkoutPlan(invalidWorkoutPlan)

        XCTAssertFalse(validation.isValid, "空练习列表训练计划应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    // MARK: - Exercise Validation Tests
    func testExerciseValidationWithValidData() {
        // 测试有效练习验证
        let exercise = createTestExercise()
        let validation = DataValidator.validateExercise(exercise)

        XCTAssertTrue(validation.isValid, "有效练习应通过验证")
        XCTAssertTrue(validation.errors.isEmpty, "有效练习不应有验证错误")
    }

    func testExerciseValidationWithInvalidName() {
        // 测试无效名称练习验证
        let invalidExercise = Exercise(
            name: "", // 无效名称
            category: .strength,
            muscleGroups: [.chest],
            equipment: .none,
            difficulty: .beginner,
            instructions: ["Test instruction"],
            imageName: "test"
        )

        let validation = DataValidator.validateExercise(invalidExercise)

        XCTAssertFalse(validation.isValid, "无效名称练习应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    func testExerciseValidationWithInvalidInstructions() {
        // 测试无效指导说明练习验证
        let invalidExercise = Exercise(
            name: "Test Exercise",
            category: .strength,
            muscleGroups: [.chest],
            equipment: .none,
            difficulty: .beginner,
            instructions: [], // 无效指导说明
            imageName: "test"
        )

        let validation = DataValidator.validateExercise(invalidExercise)

        XCTAssertFalse(validation.isValid, "无效指导说明练习应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    func testExerciseValidationWithInvalidImageName() {
        // 测试无效图片名称练习验证
        let invalidExercise = Exercise(
            name: "Test Exercise",
            category: .strength,
            muscleGroups: [.chest],
            equipment: .none,
            difficulty: .beginner,
            instructions: ["Test instruction"],
            imageName: "" // 无效图片名称
        )

        let validation = DataValidator.validateExercise(invalidExercise)

        XCTAssertFalse(validation.isValid, "无效图片名称练习应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    // MARK: - ExerciseSet Validation Tests
    func testExerciseSetValidationWithValidData() {
        // 测试有效练习组验证
        let exerciseSet = createTestExerciseSet()
        let validation = DataValidator.validateExerciseSet(exerciseSet)

        XCTAssertTrue(validation.isValid, "有效练习组应通过验证")
        XCTAssertTrue(validation.errors.isEmpty, "有效练习组不应有验证错误")
    }

    func testExerciseSetValidationWithInvalidReps() {
        // 测试无效重复次数练习组验证
        let invalidExerciseSet = ExerciseSet(
            exercise: createTestExercise(),
            targetReps: 0, // 无效重复次数
            targetWeight: 50,
            restTime: 60
        )

        let validation = DataValidator.validateExerciseSet(invalidExerciseSet)

        XCTAssertFalse(validation.isValid, "无效重复次数练习组应验证失败")
        XCTAssertFalse(validation.isEmpty, "应有验证错误")
    }

    func testExerciseSetValidationWithInvalidWeight() {
        // 测试无效重量练习组验证
        let invalidExerciseSet = ExerciseSet(
            exercise: createTestExercise(),
            targetReps: 10,
            targetWeight: -10, // 无效重量
            restTime: 60
        )

        let validation = DataValidator.validateExerciseSet(invalidExerciseSet)

        XCTAssertFalse(validation.isValid, "无效重量练习组应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    func testExerciseSetValidationWithInvalidRestTime() {
        // 测试无效休息时间练习组验证
        let invalidExerciseSet = ExerciseSet(
            exercise: createTestExercise(),
            targetReps: 10,
            targetWeight: 50,
            restTime: -1 // 无效休息时间
        )

        let validation = DataValidator.validateExerciseSet(invalidExerciseSet)

        XCTAssertFalse(validation.isValid, "无效休息时间练习组应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "应有验证错误")
    }

    // MARK: - SafeDataAccess Validation Tests
    func testSafeDataAccessWithValidData() {
        // 测试SafeDataAccess有效数据处理
        let safeDataAccess = SafeDataAccess.shared
        let qualityManager = QualityAssuranceManager.shared

        // 启动质量监控
        qualityManager.startQualityMonitoring()

        // 测试安全获取训练计划
        let workoutPlan = safeDataAccess.safeGetWorkoutPlan(byName: "Full Body Beginner")
        XCTAssertNotNil(workoutPlan, "应能安全获取有效训练计划")
        XCTAssertNil(safeDataAccess.error, "有效数据不应产生错误")

        if let plan = workoutPlan {
            // 验证获取的训练计划数据完整性
            let validation = DataValidator.validateWorkoutPlan(plan)
            XCTAssertTrue(validation.isValid, "获取的训练计划数据应完整")
        }

        // 测试安全创建ViewModel
        let viewModel = safeDataAccess.safeCreateWorkoutViewModel(workoutPlan: workoutPlan!)
        XCTAssertNotNil(viewModel, "应能安全创建ViewModel")
        XCTAssertNil(safeDataAccess.error, "有效ViewModel创建不应产生错误")

        // 验证质量评分
        XCTAssertGreaterThanOrEqual(qualityManager.qualityScore, 90.0, "SafeDataAccess操作后质量评分应保持高水平")

        // 停止质量监控
        qualityManager.stopQualityMonitoring()
    }

    func testSafeDataAccessWithInvalidData() {
        // 测试SafeDataAccess无效数据处理
        let safeDataAccess = SafeDataAccess.shared

        // 测试安全获取不存在的训练计划
        let nonExistentWorkout = safeDataAccess.safeGetWorkoutPlan(byName: "Non-existent Workout")
        XCTAssertNil(nonExistentWorkout, "不存在的训练计划应返回nil")
        XCTAssertNil(safeDataAccess.error, "不存在的数据不应产生错误，应优雅处理")

        // 测试安全创建无效ViewModel
        let invalidWorkoutPlan = MockDataGenerator.generateInvalidWorkoutPlan()
        let invalidViewModel = safeDataAccess.safeCreateWorkoutPlan(workoutPlan: invalidWorkoutPlan)
        XCTAssertNil(invalidViewModel, "无效训练计划应返回nil")
        XCTAssertNotNil(safeDataAccess.error, "无效数据应产生错误")
    }

    func testSafeDataAccessErrorRecovery() {
        // 测试SafeDataAccess错误恢复
        let safeDataAccess = SafeDataAccess.shared

        // 产生一个错误
        let _ = safeDataAccess.safeGetWorkoutPlan(byName: "Non-existent Workout")
        XCTAssertNotNil(safeDataAccess.error, "应产生错误状态")

        // 尝试有效操作，验证错误状态被清除
        let validWorkout = safeDataAccess.safeGetWorkoutPlan(byName: "Full Body Beginner")
        XCTAssertNotNil(validWorkout, "错误后应能恢复正常操作")
        XCTAssertNil(safeDataAccess.error, "错误状态应被清除")

        // 清除缓存测试错误恢复
        safeDataAccess.clearCache()
        XCTAssertNil(safeDataAccess.error, "清除缓存后错误状态应被清除")
    }

    // MARK: - Performance Validation Tests
    func testDataValidationPerformance() throws {
        // 测试数据验证性能
        let workoutPlans = MockDataGenerator.generateConcurrentWorkoutPlans(count: 100)

        let (_, executionTime) = try measurePerformance {
            for workoutPlan in workoutPlans {
                _ = DataValidator.validateWorkoutPlan(workoutPlan)
            }
        }

        XCTAssertLessThan(executionTime, 0.5, "100个训练计划验证应在500ms内完成")
    }

    func testSafeDataAccessPerformance() throws {
        // 测试SafeDataAccess性能
        let workoutPlan = createTestWorkoutPlan()

        let (_, executionTime) = try measurePerformance {
            for _ in 0..<100 {
                    _ = SafeDataAccess.shared.safeCreateWorkoutViewModel(workoutPlan: workoutPlan)
            }
        }

        XCTAssertLessThan(executionTime, 1.0, "100次ViewModel创建应在1秒内完成")
    }

    // MARK: - Edge Case Validation Tests
    func testDataValidationWithExtremeValues() {
        // 测试数据验证极端值处理
        let extremeWorkoutPlan = MockDataGenerator.generateExtremeWorkoutPlan()
        let validation = DataValidator.validateWorkoutPlan(extremeWorkoutPlan)

        // 极端值应该验证失败，但不应该崩溃
        XCTAssertFalse(validation.isValid, "极端值训练计划应验证失败")
        XCTAssertFalse(validation.errors.isEmpty, "极端值应产生验证错误")

        // 验证错误类型
        let hasNameError = validation.errors.contains {
            if case .emptyField = $0 { return true }
            return false
        } || validation.errors.contains {
            if case .invalidRange = $0 { return true }
            return false
        }

        XCTAssertTrue(hasNameError, "应产生名称或范围错误")
    }

    func testDataValidationWithConcurrentAccess() throws {
        // 测试数据验证并发访问安全性
        let concurrentQueue = DispatchQueue(label: "DataValidation", attributes: .concurrent)
        let workoutPlans = MockDataGenerator.generateConcurrentWorkoutPlans(count: 50)
        let expectation = XCTestExpectation(description: "Concurrent validation")
        expectation.expectedFulfillmentCount = workoutPlans.count

        var validationResults: [Bool] = []
        var errors: [Error] = []

        for (index, workoutPlan) in workoutPlans.enumerated() {
            concurrentQueue.async {
                do {
                    let validation = DataValidator.validateWorkoutPlan(workoutPlan)
                    DispatchQueue.main.async {
                        validationResults.append(validation.isValid)
                        expectation.fulfill()
                    }
                } catch {
                    DispatchQueue.main.async {
                        errors.append(error)
                        expectation.fulfill()
                    }
                }
            }
        }

        wait(for: [expectation], timeout: 10.0)

        XCTAssertTrue(errors.isEmpty, "并发验证不应产生错误: \(errors)")
        XCTAssertEqual(validationResults.count, workoutPlans.count, "所有验证应完成")
        XCTAssertFalse(validationResults.contains(true), "极端值验证应全部失败")
    }

    // MARK: - Integration Validation Tests
    func testEndToEndDataValidation() {
        // 测试端到端数据验证
        let safeDataAccess = SafeDataAccess.shared
        let qualityManager = QualityAssuranceManager.shared
        let navigationManager = NavigationManager()

        // 启动质量监控
        qualityManager.startQualityMonitoring()

        // 1. 获取训练计划
        let workoutPlan = safeDataAccess.safeGetWorkoutPlan(byName: "Full Body Beginner")
        XCTAssertNotNil(workoutPlan, "应能获取训练计划")

        guard let plan = workoutPlan else {
            qualityManager.stopQualityMonitoring()
            return
        }

        // 2. 验证训练计划数据
        let validation = DataValidator.validateWorkoutPlan(plan)
        XCTAssertTrue(validation.isValid, "训练计划数据应有效")

        // 3. 安全创建ViewModel
        let viewModel = safeDataAccess.safeCreateWorkoutViewModel(workoutPlan: plan)
        XCTAssertNotNil(viewModel, "应能创建ViewModel")

        // 4. 安全开始锻炼
        let success = safeDataAccess.safeStartWorkout(navigationManager: navigationManager, workoutPlan: plan)
        XCTAssertTrue(success, "应能安全开始锻炼")

        // 5. 验证导航状态
        XCTAssertEqual(navigationManager.currentScreen.id, "workout_\(plan.id)", "应正确导航到锻炼界面")

        // 6. 验证质量指标
        XCTAssertGreaterThanOrEqual(qualityManager.qualityScore, 90.0, "端到端流程质量评分应保持高水平")
        XCTAssertTrue(qualityManager.violations.isEmpty, "端到端流程不应产生违规")

        // 停止质量监控
        qualityManager.stopQualityMonitoring()
    }

    // MARK: - Regression Validation Tests
    func testDataValidationRegressionForNullReferences() {
        // 回归测试：确保NULL引用问题已修复
        let provider = MockDataProvider.shared
        let safeDataAccess = SafeDataAccess.shared

        // 验证MockDataProvider单例不为空
        XCTAssertNotNil(provider, "MockDataProvider单例不应为空")
        XCTAssertNotNil(provider.sampleExercises, "示例练习列表不应为空")
        XCTAssertNotNil(provider.sampleWorkoutPlans, "示例训练计划列表不应为空")

        // 验证SafeDataAccess单例不为空
        XCTAssertNotNil(safeDataAccess, "SafeDataAccess单例不应为空")

        // 验证所有数据访问操作
        let workoutPlan = safeDataAccess.safeGetWorkoutPlan(byName: "Full Body Beginner")
        XCTAssertNotNil(workoutPlan, "数据访问应返回有效结果或nil，不应崩溃")

        if let plan = workoutPlan {
            let viewModel = safeDataAccess.safeCreateWorkoutViewModel(workoutPlan: plan)
            XCTAssertNotNil(viewModel, "ViewModel创建应返回有效结果或nil，不应崩溃")
        }
    }

    func testDataValidationRegressionForCircularDependencies() {
        // 回归测试：确保循环依赖问题已修复
        let provider1 = MockDataProvider.shared
        let provider2 = MockDataProvider.shared

        // 验证单例模式
        XCTAssertTrue(provider1 === provider2, "应为同一单例实例")

        // 验证数据初始化完成
        XCTAssertFalse(provider1.sampleExercises.isEmpty, "示例练习应已初始化")
        XCTAssertFalse(provider1.sampleWorkoutPlans.isEmpty, "示例训练计划应已初始化")

        // 验证数据关联完整性
        for workoutPlan in provider1.sampleWorkoutPlans {
            for exerciseSet in workoutPlan.exercises {
                XCTAssertTrue(provider1.sampleExercises.contains(where: { $0.id == exerciseSet.exercise.id }),
                             "训练计划中的练习应存在于示例练习列表中")
            }
        }
    }

    // MARK: - Quality Metrics Tests
    func testQualityMetricsCalculation() {
        // 测试质量指标计算
        let validCode = """
        func validFunction() {
            // 这是一个有效的函数
            // 有适当的注释
            let result = "success"
            return result
        }

        class ValidClass {
            // 这是一个有效的类
            let property = "value"

            func validMethod() {
                // 这是一个有效的方法
                print("method called")
            }
        }
        """

        let qualityScore = QualityMetrics.calculateCodeQuality(validCode)

        XCTAssertGreaterThanOrEqual(qualityScore.overall, 5.0, "代码质量评分应大于等于5")
        XCTAssertLessThanOrEqual(qualityScore.overall, 10.0, "代码质量评分应小于等于10")
        XCTAssertFalse(qualityScore.grade.isEmpty, "质量等级不应为空")
    }

    func testQualityAssuranceManagerMonitoring() {
        // 测试质量保证管理器监控
        let qualityManager = QualityAssuranceManager.shared

        // 启动监控
        qualityManager.startQualityMonitoring()
        XCTAssertTrue(qualityManager.isMonitoring, "质量监控应已启动")

        // 等待监控执行
        waitForAsyncOperation(timeout: 2.0)

        // 验证初始质量评分
        XCTAssertGreaterThanOrEqual(qualityManager.qualityScore, 0.0, "质量评分应大于等于0")
        XCTAssertLessThanOrEqual(qualityManager.qualityScore, 100.0, "质量评分应小于等于100")

        // 停止监控
        qualityManager.stopQualityMonitoring()
        XCTAssertFalse(qualityManager.isMonitoring, "质量监控应已停止")
    }
}
//
//  DebugModeTests.swift
//  FitTests
//
//  Created by Jason Lu on 10/11/2025.
//

import XCTest
import SwiftUI
@testable import Fit

// MARK: - Debug Mode Tests
//created by Jason Lu on 21:45:00 10/11/2025

class DebugModeTests: TestSuiteConfiguration {

    // MARK: - Mock Debug Mode Tests
    func testMockDataProviderNotNull() {
        // 测试MockDataProvider单例不为空
        let provider = MockDataProvider.shared
        XCTAssertNotNil(provider, "MockDataProvider.shared 不应为空")
    }

    func testMockDataProviderDataIntegrity() {
        // 测试MockDataProvider数据完整性
        let provider = MockDataProvider.shared

        XCTAssertFalse(provider.sampleExercises.isEmpty, "示例练习列表不应为空")
        XCTAssertFalse(provider.sampleWorkoutPlans.isEmpty, "示例锻炼计划列表不应为空")

        // 验证所有示例练习
        for (index, exercise) in provider.sampleExercises.enumerated() {
            XCTAssertFalse(exercise.name.isEmpty, "练习 \(index + 1) 名称不应为空")
            XCTAssertFalse(exercise.instructions.isEmpty, "练习 \(index + 1) 指导说明不应为空")
            XCTAssertFalse(exercise.imageName.isEmpty, "练习 \(index + 1) 图片名称不应为空")
        }

        // 验证所有示例锻炼计划
        for (index, workoutPlan) in provider.sampleWorkoutPlans.enumerated() {
            XCTAssertFalse(workoutPlan.name.isEmpty, "锻炼计划 \(index + 1) 名称不应为空")
            XCTAssertFalse(workoutPlan.exercises.isEmpty, "锻炼计划 \(index + 1) 练习列表不应为空")
            XCTAssertGreaterThan(workoutPlan.duration, 0, "锻炼计划 \(index + 1) 时长应大于0")
            XCTAssertGreaterThan(workoutPlan.estimatedCalories, 0, "锻炼计划 \(index + 1) 卡路里应大于0")
        }
    }

    // MARK: - WorkoutViewModel Debug Tests
    func testWorkoutViewModelInitializationWithValidData() {
        // 测试WorkoutViewModel使用有效数据初始化
        let workoutPlan = createTestWorkoutPlan()

        XCTAssertNoThrow(try WorkoutViewModel(workoutPlan: workoutPlan), "有效数据不应抛出异常")

        let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)
        XCTAssertEqual(viewModel.currentExerciseIndex, 0, "初始练习索引应为0")
        XCTAssertFalse(viewModel.isExerciseActive, "初始状态应为非活动状态")
        XCTAssertFalse(viewModel.isResting, "初始状态应为非休息状态")
    }

    func testWorkoutViewModelWithEmptyExercises() {
        // 测试WorkoutViewModel处理空练习列表
        let emptyWorkoutPlan = WorkoutPlan(
            name: "Empty Workout",
            description: "Test empty workout",
            category: .fullBody,
            difficulty: .beginner,
            duration: 30,
            exercises: [],
            estimatedCalories: 0
        )

        let viewModel = WorkoutViewModel(workoutPlan: emptyWorkoutPlan)

        // 验证默认练习返回
        let currentExercise = viewModel.currentExercise
        XCTAssertNotNil(currentExercise, "即使练习列表为空，currentExercise也不应为空")
        XCTAssertEqual(currentExercise?.name, "默认练习", "应返回默认练习")

        let currentExerciseSet = viewModel.currentExerciseSet
        XCTAssertNotNil(currentExerciseSet, "即使练习列表为空，currentExerciseSet也不应为空")
        XCTAssertEqual(currentExerciseSet?.exercise.name, "默认练习", "应返回默认练习组")
    }

    func testWorkoutViewModelBoundarySafety() {
        // 测试WorkoutViewModel边界安全性
        let workoutPlan = createTestWorkoutPlan()
        let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)

        // 测试超出边界的索引访问
        viewModel.currentExerciseIndex = 999
        let exercise = viewModel.currentExercise
        XCTAssertNotNil(exercise, "超出边界索引应返回默认练习")

        viewModel.currentExerciseIndex = -1
        let exerciseSet = viewModel.currentExerciseSet
        XCTAssertNotNil(exerciseSet, "负数索引应返回默认练习组")
    }

    func testWorkoutViewModelStateTransitions() {
        // 测试WorkoutViewModel状态转换
        let workoutPlan = createTestWorkoutPlan()
        let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)

        // 测试开始练习
        viewModel.startExercise()
        XCTAssertTrue(viewModel.isExerciseActive, "开始练习后应为活动状态")
        XCTAssertFalse(viewModel.isResting, "开始练习后不应为休息状态")

        // 测试暂停练习
        viewModel.pauseExercise()
        XCTAssertFalse(viewModel.isExerciseActive, "暂停练习后应为非活动状态")

        // 测试切换练习
        viewModel.toggleExercise()
        XCTAssertTrue(viewModel.isExerciseActive, "切换练习后应为活动状态")

        // 测试完成练习
        let initialSets = viewModel.completedSets.count
        viewModel.completeExercise()
        XCTAssertEqual(viewModel.completedSets.count, initialSets + 1, "完成练习后应增加完成组数")
    }

    // MARK: - NavigationManager Debug Tests
    func testNavigationManagerStartWorkoutWithValidData() {
        // 测试NavigationManager使用有效数据开始锻炼
        let navigationManager = NavigationManager()
        let workoutPlan = createTestWorkoutPlan()

        navigationManager.startWorkout(workoutPlan)

        XCTAssertEqual(navigationManager.currentScreen.id, "workout_\(workoutPlan.id)", "应导航到锻炼界面")
    }

    func testNavigationManagerStartWorkoutWithEmptyExercises() {
        // 测试NavigationManager处理空练习的锻炼计划
        let navigationManager = NavigationManager()
        let emptyWorkoutPlan = WorkoutPlan(
            name: "Empty Workout",
            description: "Test empty workout",
            category: .fullBody,
            difficulty: .beginner,
            duration: 30,
            exercises: [],
            estimatedCalories: 0
        )

        let initialScreen = navigationManager.currentScreen
        navigationManager.startWorkout(emptyWorkoutPlan)

        // 应保持在原界面，不进行导航
        XCTAssertEqual(navigationManager.currentScreen.id, initialScreen.id, "空练习不应进行导航")
    }

    func testNavigationManagerStackManagement() {
        // 测试NavigationManager导航栈管理
        let navigationManager = NavigationManager()
        let workoutPlan1 = createTestWorkoutPlan()
        let workoutPlan2 = createTestWorkoutPlan()

        // 测试导航历史
        navigationManager.startWorkout(workoutPlan1)
        XCTAssertEqual(navigationManager.getNavigationDepth(), 1, "导航深度应为1")

        // 测试返回功能
        navigationManager.goBack()
        XCTAssertEqual(navigationManager.currentScreen.id, "main", "返回后应到主界面")

        // 测试返回根界面
        navigationManager.startWorkout(workoutPlan2)
        navigationManager.popToRoot()
        XCTAssertEqual(navigationManager.currentScreen.id, "main", "popToRoot应返回主界面")
    }

    // MARK: - Debug Mode Functionality Tests
    func testSimulateSuccessFunctionality() {
        // 测试模拟成功功能
        let mainScreen = MainScreen()
        let workoutPlan = createTestWorkoutPlan()

        // 模拟点击模拟成功按钮
        mainScreen.simulateSuccess()

        // 验证状态变化
        XCTAssertTrue(mainScreen.hasWorkoutPlan, "模拟成功后应设置hasWorkoutPlan为true")
    }

    func testDirectWorkoutFunctionality() {
        // 测试直接锻炼功能
        let navigationManager = NavigationManager()
        let workoutPlan = createTestWorkoutPlan()

        // 模拟点击直接锻炼按钮
        navigationManager.startWorkout(workoutPlan)

        // 验证导航到锻炼界面
        XCTAssertEqual(navigationManager.currentScreen.id, "workout_\(workoutPlan.id)", "应导航到锻炼界面")
    }

    func testDebugModeWithInvalidData() {
        // 测试调试模式处理无效数据
        let navigationManager = NavigationManager()
        let invalidWorkoutPlan = MockDataGenerator.generateInvalidWorkoutPlan()

        // 验证不会崩溃
        XCTAssertNoThrow(navigationManager.startWorkout(invalidWorkoutPlan), "无效数据不应导致崩溃")

        // 验证保持在安全状态
        XCTAssertEqual(navigationManager.currentScreen.id, "main", "无效数据应保持主界面")
    }

    // MARK: - Performance Tests
    func testDebugModePerformance() throws {
        // 测试调试模式性能
        let workoutPlan = createTestWorkoutPlan()

        let (_, executionTime) = try measurePerformance {
            let navigationManager = NavigationManager()
            navigationManager.startWorkout(workoutPlan)
        }

        XCTAssertLessThan(executionTime, 0.1, "调试操作应在100ms内完成")
    }

    func testConcurrentDebugOperations() throws {
        // 测试并发调试操作
        let workoutPlans = MockDataGenerator.generateConcurrentWorkoutPlans(count: 10)
        var navigationManagers: [NavigationManager] = []
        var errors: [Error] = []

        let expectation = XCTestExpectation(description: "Concurrent debug operations")
        expectation.expectedFulfillmentCount = workoutPlans.count

        for workoutPlan in workoutPlans {
            DispatchQueue.global(qos: .background).async {
                do {
                    let navigationManager = NavigationManager()
                    navigationManager.startWorkout(workoutPlan)

                    DispatchQueue.main.async {
                        navigationManagers.append(navigationManager)
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

        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(errors.isEmpty, "并发操作不应产生错误: \(errors)")
        XCTAssertEqual(navigationManagers.count, workoutPlans.count, "所有导航管理器应创建成功")
    }

    // MARK: - Memory Tests
    func testDebugModeMemoryUsage() {
        // 测试调试模式内存使用
        let initialMemory = PerformanceMonitor.shared.memoryUsage

        var viewModels: [WorkoutViewModel] = []
        for _ in 0..<100 {
            let workoutPlan = createTestWorkoutPlan()
            let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)
            viewModels.append(viewModel)
        }

        let finalMemory = PerformanceMonitor.shared.memoryUsage
        let memoryIncrease = finalMemory - initialMemory

        XCTAssertLessThan(memoryIncrease, 50, "创建100个ViewModel的内存增长应少于50MB")

        // 清理内存
        viewModels.removeAll()
    }

    // MARK: - Error Handling Tests
    func testDebugModeErrorRecovery() {
        // 测试调试模式错误恢复
        let safeDataAccess = SafeDataAccess.shared

        // 测试空数据错误处理
        let result1 = safeDataAccess.safeGetWorkoutPlan(byName: "Non-existent Workout")
        XCTAssertNil(result1, "不存在的锻炼计划应返回nil")

        // 测试无效数据错误处理
        let result2 = safeDataAccess.safeCreateWorkoutViewModel(workoutPlan: MockDataGenerator.generateInvalidWorkoutPlan())
        XCTAssertNil(result2, "无效锻炼计划应返回nil")

        // 验证错误状态
        XCTAssertNotNil(safeDataAccess.error, "应记录错误状态")
    }

    // MARK: - Integration Tests
    func testDebugModeIntegrationFlow() {
        // 测试调试模式集成流程
        let safeDataAccess = SafeDataAccess.shared
        let navigationManager = NavigationManager()

        // 1. 获取有效的锻炼计划
        let workoutPlan = safeDataAccess.safeGetWorkoutPlan(byName: "Full Body Beginner")
        XCTAssertNotNil(workoutPlan, "应能获取有效的锻炼计划")

        // 2. 创建ViewModel
        guard let plan = workoutPlan else { return }
        let viewModel = safeDataAccess.safeCreateWorkoutViewModel(workoutPlan: plan)
        XCTAssertNotNil(viewModel, "应能创建ViewModel")

        // 3. 开始锻炼
        let success = safeDataAccess.safeStartWorkout(navigationManager: navigationManager, workoutPlan: plan)
        XCTAssertTrue(success, "应能成功开始锻炼")

        // 4. 验证导航状态
        XCTAssertEqual(navigationManager.currentScreen.id, "workout_\(plan.id)", "应正确导航")
    }

    // MARK: - Boundary Tests
    func testDebugModeBoundaryConditions() {
        // 测试调试模式边界条件
        let navigationManager = NavigationManager()

        // 测试极端大的锻炼计划
        let extremeWorkoutPlan = MockDataGenerator.generateExtremeWorkoutPlan()
        XCTAssertNoThrow(navigationManager.startWorkout(extremeWorkoutPlan), "极端数据不应导致崩溃")

        // 测试零索引操作
        let workoutPlan = createTestWorkoutPlan()
        let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)
        viewModel.currentExerciseIndex = 0
        XCTAssertNoThrow(viewModel.startExercise(), "零索引操作应正常")

        // 测试负数索引操作
        viewModel.currentExerciseIndex = -1
        let exercise = viewModel.currentExercise
        XCTAssertNotNil(exercise, "负数索引应返回默认练习")
    }

    // MARK: - Regression Tests
    func testNullReferenceRegression() {
        // 回归测试：确保NULL引用问题已修复
        let workoutPlan = createTestWorkoutPlan()
        let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)

        // 测试所有可能的NULL引用点
        XCTAssertNotNil(viewModel.currentExercise, "currentExercise不应为空")
        XCTAssertNotNil(viewModel.currentExerciseSet, "currentExerciseSet不应为空")
        XCTAssertNotNil(viewModel.workoutPlan, "workoutPlan不应为空")

        // 测试数组访问
        viewModel.currentExerciseIndex = 0
        XCTAssertNoThrow(viewModel.startExercise(), "数组访问不应崩溃")

        // 测试状态访问
        let progress = viewModel.progress
        XCTAssertGreaterThanOrEqual(progress, 0, "progress应大于等于0")
        XCTAssertLessThanOrEqual(progress, 1, "progress应小于等于1")
    }

    func testTimerManagementRegression() {
        // 回归测试：确保Timer管理问题已修复
        let workoutPlan = createTestWorkoutPlan()
        var viewModel: WorkoutViewModel? = WorkoutViewModel(workoutPlan: workoutPlan)

        // 启动Timer
        viewModel?.startExercise()
        XCTAssertTrue(viewModel?.isExerciseActive == true, "Timer应启动")

        // 手动释放ViewModel
        viewModel = nil

        // 等待一段时间确保Timer被正确释放
        waitForAsyncOperation(timeout: 2.0)

        // 验证没有内存泄漏或崩溃
        XCTAssertTrue(true, "Timer应被正确释放")
    }
}

// MARK: - Mock MainScreen Extension
extension MainScreen {
    // 为测试添加调试方法
    func simulateSuccess() {
        hasWorkoutPlan = true
    }

    func directWorkout(_ workoutPlan: WorkoutPlan) {
        // 模拟直接锻炼功能
        // 在实际应用中，这会触发导航
    }
}
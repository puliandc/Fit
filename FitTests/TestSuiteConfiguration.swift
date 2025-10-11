//
//  TestSuiteConfiguration.swift
//  FitTests
//
//  Created by Jason Lu on 10/11/2025.
//

import XCTest
import Foundation
@testable import Fit

// MARK: - Test Suite Configuration
//created by Jason Lu on 21:30:00 10/11/2025

class TestSuiteConfiguration: XCTestCase {

    override func setUp() {
        super.setUp()
        // 在每个测试方法运行前调用
        print("🧪 开始测试: \(self.description)")

        // 重置测试环境
        resetTestEnvironment()

        // 开始性能监控（如果需要）
        if TestConfiguration.isPerformanceTestEnabled {
            PerformanceMonitor.shared.startMonitoring()
        }
    }

    override func tearDown() {
        // 在每个测试方法运行后调用
        print("✅ 测试完成: \(self.description)")

        // 停止性能监控
        PerformanceMonitor.shared.stopMonitoring()

        // 清理测试环境
        cleanupTestEnvironment()

        super.tearDown()
    }

    // MARK: - Test Environment Management
    private func resetTestEnvironment() {
        // 清理缓存
        SafeDataAccess.shared.clearCache()

        // 重置性能监控
        PerformanceMonitor.shared.alertCount = 0

        // 清理测试文件
        cleanupTestFiles()
    }

    private func cleanupTestEnvironment() {
        // 确保所有异步操作完成
        let expectation = XCTestExpectation(description: "Cleanup")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    private func cleanupTestFiles() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testFiles = [
            "test_data.dat",
            "performance_alerts.json",
            "test_workout.json",
            "test_exercise.json"
        ]

        for fileName in testFiles {
            let filePath = documentsPath.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: filePath)
        }
    }

    // MARK: - Test Helper Methods
    func createTestWorkoutPlan() -> WorkoutPlan {
        return WorkoutPlan(
            name: "Test Workout",
            description: "Test Description",
            category: .fullBody,
            difficulty: .beginner,
            duration: 30,
            exercises: [
                ExerciseSet(
                    exercise: Exercise(
                        name: "Test Exercise",
                        category: .strength,
                        muscleGroups: [.chest],
                        equipment: .none,
                        difficulty: .beginner,
                        instructions: ["Test instruction"],
                        imageName: "test"
                    ),
                    targetReps: 10,
                    targetWeight: 0,
                    restTime: 60
                )
            ],
            estimatedCalories: 200
        )
    }

    func createTestExercise() -> Exercise {
        return Exercise(
            name: "Test Exercise",
            category: .strength,
            muscleGroups: [.chest],
            equipment: .none,
            difficulty: .beginner,
            instructions: ["Test instruction 1", "Test instruction 2"],
            tips: ["Test tip 1"],
            imageName: "test"
        )
    }

    func createTestExerciseSet() -> ExerciseSet {
        return ExerciseSet(
            exercise: createTestExercise(),
            targetReps: 12,
            targetWeight: 50,
            restTime: 90
        )
    }

    func waitForAsyncOperation(timeout: TimeInterval = 5.0) {
        let expectation = XCTestExpectation(description: "Async operation")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func measurePerformance<T>(operation: () throws -> T, file: StaticString = #file, line: UInt = #line) throws -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime

        // 记录性能指标
        print("📊 性能测试 - 耗时: \(String(format: "%.4f", executionTime * 1000))ms")

        // 性能断言
        XCTAssertLessThan(executionTime, 0.1, "操作耗时超过100ms", file: file, line: line)

        return (result, executionTime)
    }

    func assertNoError<T>(_ result: Result<T, ValidationError>, file: StaticString = #file, line: UInt = #line) {
        switch result {
        case .success:
            break
        case .failure(let error):
            XCTFail("期望成功但收到错误: \(error.localizedDescription)", file: file, line: line)
        }
    }

    func assertValidationError<T>(_ result: Result<T, ValidationError>, expectedError: ValidationError, file: StaticString = #file, line: UInt = #line) {
        switch result {
        case .success:
            XCTFail("期望错误但收到成功", file: file, line: line)
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, file: file, line: line)
        }
    }
}

// MARK: - Test Configuration
struct TestConfiguration {
    static var isRunningTests: Bool {
        return NSClassFromString("XCTest") != nil
    }

    static var isPerformanceTestEnabled: Bool {
        return ProcessInfo.processInfo.environment["PERFORMANCE_TESTS"] == "1"
    }

    static var isIntegrationTestEnabled: Bool {
        return ProcessInfo.processInfo.environment["INTEGRATION_TESTS"] == "1"
    }

    static var isUITestEnabled: Bool {
        return ProcessInfo.processInfo.environment["UI_TESTS"] == "1"
    }

    static var mockDataPath: String {
        return Bundle(for: TestSuiteConfiguration.self).path(forResource: "MockData", ofType: "json") ?? ""
    }

    static var testTimeout: TimeInterval {
        return 10.0
    }

    static var performanceThreshold: TimeInterval {
        return 0.1 // 100ms
    }

    static var memoryThreshold: Double {
        return 100.0 // 100MB
    }

    static var frameRateThreshold: Double {
        return 55.0 // 55fps
    }
}

// MARK: - Mock Data Generator
class MockDataGenerator {
    static func generateValidWorkoutPlan() -> WorkoutPlan {
        return WorkoutPlan(
            name: "Valid Test Workout",
            description: "A valid workout plan for testing",
            category: .fullBody,
            difficulty: .beginner,
            duration: 30,
            exercises: [
                ExerciseSet(
                    exercise: Exercise(
                        name: "Valid Exercise",
                        category: .strength,
                        muscleGroups: [.chest],
                        equipment: .none,
                        difficulty: .beginner,
                        instructions: ["Valid instruction"],
                        imageName: "valid"
                    ),
                    targetReps: 10,
                    targetWeight: 0,
                    restTime: 60
                )
            ],
            estimatedCalories: 200
        )
    }

    static func generateInvalidWorkoutPlan() -> WorkoutPlan {
        return WorkoutPlan(
            name: "", // 无效名称
            description: "",
            category: .fullBody,
            difficulty: .beginner,
            duration: 0, // 无效时长
            exercises: [], // 无效练习列表
            estimatedCalories: 0
        )
    }

    static func generateExtremeWorkoutPlan() -> WorkoutPlan {
        return WorkoutPlan(
            name: String(repeating: "Very Long Name ", count: 20),
            description: String(repeating: "Description ", count: 100),
            category: .fullBody,
            difficulty: .beginner,
            duration: 1000,
            exercises: Array(repeating: ExerciseSet(
                exercise: Exercise(
                    name: "Extreme Exercise",
                    category: .strength,
                    muscleGroups: [.chest],
                    equipment: .none,
                    difficulty: .beginner,
                    instructions: ["Extreme instruction"],
                    imageName: "extreme"
                ),
                targetReps: 1000,
                targetWeight: 1000,
                restTime: 3600
            ), count: 100),
            estimatedCalories: 100000
        )
    }

    static func generateConcurrentWorkoutPlans(count: Int) -> [WorkoutPlan] {
        return (0..<count).map { index in
            WorkoutPlan(
                name: "Concurrent Workout \(index)",
                description: "Concurrent test workout \(index)",
                category: .fullBody,
                difficulty: .beginner,
                duration: 30,
                exercises: [
                    ExerciseSet(
                        exercise: Exercise(
                            name: "Concurrent Exercise \(index)",
                            category: .strength,
                            muscleGroups: [.chest],
                            equipment: .none,
                            difficulty: .beginner,
                            instructions: ["Concurrent instruction \(index)"],
                            imageName: "concurrent_\(index)"
                        ),
                        targetReps: 10,
                        targetWeight: 0,
                        restTime: 60
                    )
                ],
                estimatedCalories: 200
            )
        }
    }
}

// MARK: - Test Utilities
extension XCTestCase {
    func XCTAssertThrows<T>(_ expression: @autoclosure () throws -> T, errorType: T.Type, file: StaticString = #file, line: UInt = #line) {
        do {
            _ = try expression()
            XCTFail("期望抛出异常但没有抛出", file: file, line: line)
        } catch {
            XCTAssertTrue(error is T, "期望的异常类型不匹配", file: file, line: line)
        }
    }

    func XCTAssertPerformance<T>(_ operation: () throws -> T, within threshold: TimeInterval = TestConfiguration.performanceThreshold, file: StaticString = #file, line: UInt = #line) throws -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime

        XCTAssertLessThanOrEqual(executionTime, threshold, "操作耗时 \(String(format: "%.4f", executionTime * 1000))ms 超过阈值 \(String(format: "%.4f", threshold * 1000))ms", file: file, line: line)

        return result
    }

    func XCTAssertMainThread(_ operation: @escaping () -> Void, timeout: TimeInterval = 1.0, file: StaticString = #file, line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Main thread operation")

        DispatchQueue.main.async {
            operation()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }
}

// MARK: - Test Categories
enum TestCategory {
    case unit
    case integration
    case performance
    case ui
    case accessibility

    var description: String {
        switch self {
        case .unit:
            return "单元测试"
        case .integration:
            return "集成测试"
        case .performance:
            return "性能测试"
        case .ui:
            return "UI测试"
        case .accessibility:
            return "可访问性测试"
        }
    }
}

// MARK: - Test Report Generator
class TestReportGenerator {
    static func generateTestReport(results: [TestResult]) -> String {
        let totalTests = results.count
        let passedTests = results.filter { $0.passed }.count
        let failedTests = totalTests - passedTests

        var report = """

        # Fit应用测试报告
        生成时间: \(Date())

        ## 测试概览
        - 总测试数: \(totalTests)
        - 通过: \(passedTests)
        - 失败: \(failedTests)
        - 成功率: \(String(format: "%.1f", Double(passedTests) / Double(totalTests) * 100))%

        ## 分类测试结果
        """

        let categories = TestCategory.allCases
        for category in categories {
            let categoryResults = results.filter { $0.category == category }
            let categoryPassed = categoryResults.filter { $0.passed }.count
            let categoryTotal = categoryResults.count

            report += """

            ### \(category.description)
            - 总数: \(categoryTotal)
            - 通过: \(categoryPassed)
            - 失败: \(categoryTotal - categoryPassed)
            - 成功率: \(categoryTotal > 0 ? String(format: "%.1f", Double(categoryPassed) / Double(categoryTotal) * 100) : "0")%
            """
        }

        // 添加失败测试详情
        let failedResults = results.filter { !$0.passed }
        if !failedResults.isEmpty {
            report += "\n\n## 失败测试详情\n"
            for result in failedResults {
                report += """

                ### \(result.testName)
                - 类别: \(result.category.description)
                - 失败原因: \(result.errorMessage ?? "未知错误")
                - 耗时: \(String(format: "%.4f", result.executionTime * 1000))ms
                """
            }
        }

        return report
    }
}

// MARK: - Test Result Model
struct TestResult {
    let testName: String
    let category: TestCategory
    let passed: Bool
    let executionTime: TimeInterval
    let errorMessage: String?
    let timestamp: Date

    init(testName: String, category: TestCategory, passed: Bool, executionTime: TimeInterval, errorMessage: String? = nil) {
        self.testName = testName
        self.category = category
        self.passed = passed
        self.executionTime = executionTime
        self.errorMessage = errorMessage
        self.timestamp = Date()
    }
}

// MARK: - TestCategory Extension
extension TestCategory: CaseIterable {
    static var allCases: [TestCategory] {
        return [.unit, .integration, .performance, .ui, .accessibility]
    }
}
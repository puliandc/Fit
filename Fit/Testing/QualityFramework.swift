//
//  QualityFramework.swift
//  Fit
//
//  Created by Quality Engineer on 10/11/2025.
//  Quality assurance and data validation framework
//

import Foundation
import SwiftUI
import Combine

// MARK: - Performance Monitor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    @Published var alertCount: Int = 0
    @Published var memoryUsage: Double = 0
    @Published var cpuUsage: Double = 0
    @Published var frameRate: Double = 60.0

    private var monitoringTimer: Timer?
    private var startTime: CFAbsoluteTime?

    private init() {}

    func startMonitoring() {
        startTime = CFAbsoluteTimeGetCurrent()
        alertCount = 0

        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateMetrics()
        }
    }

    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        startTime = nil
    }

    private func updateMetrics() {
        // 简化的性能监控
        memoryUsage = getCurrentMemoryUsage()
        cpuUsage = getCurrentCPUUsage()
        frameRate = max(30.0, 60.0 - Double.random(in: 0...1) * 10) // 模拟帧率
    }

    private func getCurrentMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0 // Convert to MB
        }
        return 0.0
    }

    private func getCurrentCPUUsage() -> Double {
        // 简化的CPU使用率计算
        return Double.random(in: 0...1) * 80.0 // 模拟0-80%的CPU使用率
    }

    func recordAlert() {
        alertCount += 1
    }

    func getExecutionTime() -> TimeInterval? {
        guard let startTime = startTime else { return nil }
        return CFAbsoluteTimeGetCurrent() - startTime
    }
}

// MARK: - Safe Data Access
class SafeDataAccess: ObservableObject {
    static let shared = SafeDataAccess()

    @Published var error: ValidationError?
    @Published var isLoading: Bool = false
    private var cache: [String: Any] = [:]

    private init() {}

    func clearCache() {
        cache.removeAll()
        error = nil
    }

    func safeGetWorkoutPlan(byName name: String) -> WorkoutPlan? {
        do {
            return try safeExecute {
                let provider = MockDataProvider.shared
                return provider.getWorkoutPlan(byName: name)
            }
        } catch {
            return nil
        }
    }

    func safeCreateWorkoutViewModel(workoutPlan: WorkoutPlan) -> WorkoutViewModel? {
        do {
            return try safeExecute {
                return WorkoutViewModel(workoutPlan: workoutPlan)
            }
        } catch {
            return nil
        }
    }

    func safeStartWorkout(navigationManager: NavigationManager, workoutPlan: WorkoutPlan) -> Bool {
        do {
            try safeExecute {
                navigationManager.startWorkout(workoutPlan)
            }
            return true
        } catch {
            return false
        }
    }

    private func safeExecute<T>(_ operation: () throws -> T) throws -> T {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try operation()
            error = nil
            return result
        } catch let error as ValidationError {
            self.error = error
            throw error
        } catch {
            let validationError = ValidationError.unknown(error.localizedDescription)
            self.error = validationError
            throw validationError
        }
    }
}

// MARK: - Validation Error
enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case invalidRange(String, min: Double, max: Double, actual: Double)
    case nullReference(String)
    case invalidData(String)
    case timeout(String)
    case networkError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "字段不能为空: \(field)"
        case .invalidRange(let field, let min, let max, let actual):
            return "字段 \(field) 超出有效范围 \(min)-\(max)，当前值: \(actual)"
        case .nullReference(let object):
            return "对象引用为空: \(object)"
        case .invalidData(let data):
            return "数据无效: \(data)"
        case .timeout(let operation):
            return "操作超时: \(operation)"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .unknown(let message):
            return "未知错误: \(message)"
        }
    }
}

// MARK: - Data Validator
class DataValidator {
    static func validateWorkoutPlan(_ workoutPlan: WorkoutPlan) -> ValidationResult {
        var errors: [ValidationError] = []

        // 验证名称
        if workoutPlan.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyField("锻炼计划名称"))
        }

        // 验证时长
        if workoutPlan.duration <= 0 {
            errors.append(.invalidRange("锻炼时长", min: 1, max: 300, actual: Double(workoutPlan.duration)))
        } else if workoutPlan.duration > 300 {
            errors.append(.invalidRange("锻炼时长", min: 1, max: 300, actual: Double(workoutPlan.duration)))
        }

        // 验证练习列表
        if workoutPlan.exercises.isEmpty {
            errors.append(.emptyField("练习列表"))
        }

        // 验证卡路里
        if workoutPlan.estimatedCalories < 0 {
            errors.append(.invalidRange("卡路里", min: 0, max: 5000, actual: Double(workoutPlan.estimatedCalories)))
        } else if workoutPlan.estimatedCalories > 5000 {
            errors.append(.invalidRange("卡路里", min: 0, max: 5000, actual: Double(workoutPlan.estimatedCalories)))
        }

        return ValidationResult(errors: errors, isValid: errors.isEmpty)
    }

    static func validateExercise(_ exercise: Exercise) -> ValidationResult {
        var errors: [ValidationError] = []

        // 验证名称
        if exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyField("练习名称"))
        }

        // 验证指导说明
        if exercise.instructions.isEmpty {
            errors.append(.emptyField("指导说明"))
        }

        // 验证图片名称
        if exercise.imageName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyField("图片名称"))
        }

        return ValidationResult(errors: errors, isValid: errors.isEmpty)
    }

    static func validateExerciseSet(_ exerciseSet: ExerciseSet) -> ValidationResult {
        var errors: [ValidationError] = []

        // 验证重复次数
        if exerciseSet.targetReps <= 0 {
            errors.append(.invalidRange("重复次数", min: 1, max: 100, actual: Double(exerciseSet.targetReps)))
        } else if exerciseSet.targetReps > 100 {
            errors.append(.invalidRange("重复次数", min: 1, max: 100, actual: Double(exerciseSet.targetReps)))
        }

        // 验证重量
        if exerciseSet.targetWeight < 0 {
            errors.append(.invalidRange("重量", min: 0, max: 1000, actual: exerciseSet.targetWeight))
        } else if exerciseSet.targetWeight > 1000 {
            errors.append(.invalidRange("重量", min: 0, max: 1000, actual: exerciseSet.targetWeight))
        }

        // 验证休息时间
        if exerciseSet.restTime < 0 {
            errors.append(.invalidRange("休息时间", min: 0, max: 600, actual: Double(exerciseSet.restTime)))
        } else if exerciseSet.restTime > 600 {
            errors.append(.invalidRange("休息时间", min: 0, max: 600, actual: Double(exerciseSet.restTime)))
        }

        return ValidationResult(errors: errors, isValid: errors.isEmpty)
    }
}

// MARK: - Validation Result
struct ValidationResult {
    let errors: [ValidationError]
    let isValid: Bool

    init(errors: [ValidationError], isValid: Bool) {
        self.errors = errors
        self.isValid = isValid
    }
}

// MARK: - Quality Metrics
class QualityMetrics {
    static func calculateCodeQuality(_ code: String) -> CodeQualityScore {
        // 简化的代码质量计算
        let lineCount = code.components(separatedBy: .newlines).count
        let functionCount = code.components(separatedBy: "func ").count - 1
        let classCount = code.components(separatedBy: "class ").count - 1

        let complexityScore = calculateComplexity(code)
        let maintainabilityScore = calculateMaintainability(lineCount: lineCount, functionCount: functionCount, classCount: classCount)
        let readabilityScore = calculateReadability(code)

        let overallScore = (complexityScore + maintainabilityScore + readabilityScore) / 3.0

        return CodeQualityScore(
            overall: overallScore,
            complexity: complexityScore,
            maintainability: maintainabilityScore,
            readability: readabilityScore
        )
    }

    private static func calculateComplexity(_ code: String) -> Double {
        // 简化的复杂度计算
        let keywords = ["if", "else", "for", "while", "switch", "case", "guard", "try", "catch"]
        var complexity = 1.0

        for keyword in keywords {
            complexity += Double(code.components(separatedBy: keyword).count - 1) * 0.1
        }

        return min(10.0, max(1.0, 10.0 - complexity))
    }

    private static func calculateMaintainability(lineCount: Int, functionCount: Int, classCount: Int) -> Double {
        // 基于行数、函数数和类数的可维护性评分
        let avgLinesPerFunction = functionCount > 0 ? Double(lineCount) / Double(functionCount) : Double(lineCount)
        let avgLinesPerClass = classCount > 0 ? Double(lineCount) / Double(classCount) : Double(lineCount)

        let functionScore = avgLinesPerFunction <= 50 ? 10.0 : max(1.0, 10.0 - (avgLinesPerFunction - 50) / 10.0)
        let classScore = avgLinesPerClass <= 200 ? 10.0 : max(1.0, 10.0 - (avgLinesPerClass - 200) / 20.0)

        return (functionScore + classScore) / 2.0
    }

    private static func calculateReadability(_ code: String) -> Double {
        // 简化的可读性计算
        let commentLines = code.components(separatedBy: .newlines).filter { $0.hasPrefix("//") || $0.hasPrefix("/*") }.count
        let totalLines = code.components(separatedBy: .newlines).count

        let commentRatio = totalLines > 0 ? Double(commentLines) / Double(totalLines) : 0.0
        let commentScore = min(10.0, commentRatio * 50.0) // 20%的注释率给满分

        return commentScore
    }
}

// MARK: - Code Quality Score
struct CodeQualityScore {
    let overall: Double
    let complexity: Double
    let maintainability: Double
    let readability: Double

    var grade: String {
        switch overall {
        case 9.0...10.0:
            return "优秀"
        case 7.0..<9.0:
            return "良好"
        case 5.0..<7.0:
            return "一般"
        case 3.0..<5.0:
            return "较差"
        default:
            return "很差"
        }
    }
}

// MARK: - Quality Assurance Manager
class QualityAssuranceManager: ObservableObject {
    static let shared = QualityAssuranceManager()

    @Published var isMonitoring = false
    @Published var qualityScore: Double = 0.0
    @Published var violations: [QualityViolation] = []

    private var qualityTimer: Timer?

    private init() {}

    func startQualityMonitoring() {
        isMonitoring = true
        qualityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.performQualityCheck()
        }
    }

    func stopQualityMonitoring() {
        isMonitoring = false
        qualityTimer?.invalidate()
        qualityTimer = nil
    }

    private func performQualityCheck() {
        // 执行质量检查
        violations.removeAll()

        // 检查数据完整性
        checkDataIntegrity()

        // 检查性能指标
        checkPerformanceMetrics()

        // 计算质量评分
        calculateQualityScore()
    }

    private func checkDataIntegrity() {
        let provider = MockDataProvider.shared

        // 检查练习数据完整性
        for (index, exercise) in provider.sampleExercises.enumerated() {
            let validation = DataValidator.validateExercise(exercise)
            if !validation.isValid {
                violations.append(QualityViolation(
                    type: .dataIntegrity,
                    description: "练习 \(index + 1) 数据验证失败: \(validation.errors.first?.errorDescription ?? "未知错误")",
                    severity: .high
                ))
            }
        }

        // 检查训练计划数据完整性
        for (index, workoutPlan) in provider.sampleWorkoutPlans.enumerated() {
            let validation = DataValidator.validateWorkoutPlan(workoutPlan)
            if !validation.isValid {
                violations.append(QualityViolation(
                    type: .dataIntegrity,
                    description: "训练计划 \(index + 1) 数据验证失败: \(validation.errors.first?.errorDescription ?? "未知错误")",
                    severity: .high
                ))
            }
        }
    }

    private func checkPerformanceMetrics() {
        let monitor = PerformanceMonitor.shared

        if monitor.memoryUsage > 100 {
            violations.append(QualityViolation(
                type: .performance,
                description: "内存使用过高: \(String(format: "%.1f", monitor.memoryUsage))MB",
                severity: .medium
            ))
        }

        if monitor.cpuUsage > 80 {
            violations.append(QualityViolation(
                type: .performance,
                description: "CPU使用过高: \(String(format: "%.1f", monitor.cpuUsage))%",
                severity: .medium
            ))
        }

        if monitor.frameRate < 55 {
            violations.append(QualityViolation(
                type: .performance,
                description: "帧率过低: \(String(format: "%.1f", monitor.frameRate))fps",
                severity: .low
            ))
        }
    }

    private func calculateQualityScore() {
        // 基于违规数量计算质量评分
        let highSeverityCount = violations.filter { $0.severity == .high }.count
        let mediumSeverityCount = violations.filter { $0.severity == .medium }.count
        let lowSeverityCount = violations.filter { $0.severity == .low }.count

        let penaltyScore = highSeverityCount * 10 + mediumSeverityCount * 5 + lowSeverityCount * 1
        qualityScore = Double(max(0, 100 - penaltyScore))
    }
}

// MARK: - Quality Violation
struct QualityViolation {
    let type: ViolationType
    let description: String
    let severity: ViolationSeverity
    let timestamp: Date

    init(type: ViolationType, description: String, severity: ViolationSeverity) {
        self.type = type
        self.description = description
        self.severity = severity
        self.timestamp = Date()
    }
}

// MARK: - Violation Types
enum ViolationType {
    case dataIntegrity
    case performance
    case security
    case usability
    case accessibility
}

// MARK: - Violation Severity
enum ViolationSeverity {
    case low
    case medium
    case high
    case critical
}
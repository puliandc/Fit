# Fit 应用 API 契约定义

//created by Jason Lu on 14:40:00 10/12/2025

## 📋 概述

本文档定义了Fit应用内部的API契约，包括数据模型、服务接口和业务逻辑规范。这些契约确保组件间的一致性和可预测性。

## 🏗️ 数据模型契约

### 1. 核心实体定义

#### Workout（训练记录）
```swift
struct Workout: Identifiable, Codable {
    // 基础属性
    let id: UUID                    // 唯一标识符
    let date: Date                  // 训练日期
    let createdAt: Date            // 创建时间
    let updatedAt: Date            // 更新时间

    // 训练数据
    let sets: [WorkoutSet]         // 训练组数列表
    let duration: TimeInterval     // 训练时长（秒）
    let notes: String?             // 训练备注

    // 元数据
    let tags: [String]             // 标签列表
    let isCompleted: Bool          // 是否已完成

    // 验证规则
    // - date不能是未来时间
    // - sets不能为空
    // - duration必须 >= 60秒
    // - notes长度 <= 200字符
}
```

#### WorkoutSet（训练组数）
```swift
struct WorkoutSet: Identifiable, Codable {
    // 基础属性
    let id: UUID                   // 唯一标识符
    let workoutId: UUID           // 所属训练ID
    let timestamp: Date           // 完成时间

    // 训练数据
    let weight: Double            // 重量（公斤）
    let reps: Int                 // 次数
    let restTime: TimeInterval?   // 休息时间（秒）
    let rpe: Int?                 // 主观疲劳度（1-10）

    // 元数据
    let notes: String?            // 备注
    let isWarmup: Bool            // 是否为热身组

    // 验证规则
    // - weight >= 0 且 <= 1000，精度0.1
    // - reps >= 1 且 <= 1000
    // - rpe >= 1 且 <= 10
    // - notes长度 <= 100字符
}
```

#### Exercise（训练动作）
```swift
struct Exercise: Identifiable, Codable {
    // 基础属性
    let id: UUID                   // 唯一标识符
    let name: String              // 动作名称
    let category: ExerciseCategory // 动作类别
    let description: String?      // 动作描述
    let instructions: [String]?   // 执行说明

    // 难度和等级
    let difficulty: Int           // 难度等级（1-5）
    let muscleGroups: [String]    // 目标肌群

    // 元数据
    let equipment: [String]?      // 所需设备
    let imageURL: URL?            // 示例图片URL
    let videoURL: URL?            // 示例视频URL

    // 验证规则
    // - name长度 2-50字符
    // - difficulty 1-5
    // - description长度 <= 500字符
}
```

### 2. 枚举类型定义

#### ExerciseCategory（动作类别）
```swift
enum ExerciseCategory: String, CaseIterable, Codable {
    case strength = "strength"           // 力量训练
    case cardio = "cardio"               // 有氧运动
    case flexibility = "flexibility"     // 柔韧性
    case balance = "balance"             // 平衡训练
    case functional = "functional"       // 功能性训练
    case sports = "sports"               // 运动专项
    case rehabilitation = "rehabilitation" // 康复训练

    var displayName: String {
        switch self {
        case .strength: return "力量训练"
        case .cardio: return "有氧运动"
        case .flexibility: return "柔韧性"
        case .balance: return "平衡训练"
        case .functional: return "功能性训练"
        case .sports: return "运动专项"
        case .rehabilitation: return "康复训练"
        }
    }
}
```

#### WorkoutStatus（训练状态）
```swift
enum WorkoutStatus: String, Codable {
    case notStarted = "not_started"     // 未开始
    case inProgress = "in_progress"     // 进行中
    case paused = "paused"              // 暂停
    case completed = "completed"        // 已完成
    case abandoned = "abandoned"        // 已放弃

    var displayName: String {
        switch self {
        case .notStarted: return "未开始"
        case .inProgress: return "进行中"
        case .paused: return "暂停"
        case .completed: return "已完成"
        case .abandoned: return "已放弃"
        }
    }
}
```

### 3. 响应模型定义

#### APIResponse（通用响应）
```swift
struct APIResponse<T: Codable>: Codable {
    let success: Bool              // 请求是否成功
    let data: T?                  // 响应数据
    let message: String            // 响应消息
    let errors: [APIError]?        // 错误列表
    let timestamp: Date           // 响应时间

    // 验证规则
    // - message不能为空
    // - timestamp必须是当前时间
}
```

#### APIError（错误信息）
```swift
struct APIError: Codable, LocalizedError {
    let code: String              // 错误代码
    let message: String           // 错误消息
    let details: [String]?        // 错误详情
    let field: String?            // 相关字段

    var errorDescription: String? {
        return message
    }

    // 预定义错误代码
    static let invalidInput = APIError(code: "INVALID_INPUT", message: "输入数据无效")
    static let validationFailed = APIError(code: "VALIDATION_FAILED", message: "数据验证失败")
    static let notFound = APIError(code: "NOT_FOUND", message: "资源未找到")
    static let serverError = APIError(code: "SERVER_ERROR", message: "服务器错误")
}
```

## 🔧 服务接口契约

### 1. WorkoutService（训练服务）

#### 开始训练
```swift
/// 开始新的训练
/// - Parameters:
///   - exercises: 训练动作列表
///   - scheduledDuration: 预期训练时长
/// - Returns: 创建的训练记录
func startWorkout(
    exercises: [Exercise],
    scheduledDuration: TimeInterval?
) async throws -> Workout

// 契约要求：
// - exercises不能为空
// - scheduledDuration >= 600秒（10分钟）
// - 返回的Workout状态为.inProgress
// - 自动设置createdAt和updatedAt
```

#### 添加训练组数
```swift
/// 添加训练组数
/// - Parameters:
///   - workoutId: 训练ID
///   - weight: 重量
///   - reps: 次数
///   - restTime: 休息时间（可选）
///   - rpe: 主观疲劳度（可选）
/// - Returns: 创建的训练组数
func addWorkoutSet(
    workoutId: UUID,
    weight: Double,
    reps: Int,
    restTime: TimeInterval?,
    rpe: Int?
) async throws -> WorkoutSet

// 契约要求：
// - workoutId必须对应存在的训练
// - weight和reps必须通过验证
// - 自动设置timestamp
// - 更新Workout的updatedAt
```

#### 完成训练
```swift
/// 完成训练
/// - Parameter workoutId: 训练ID
/// - Returns: 更新后的训练记录
func completeWorkout(workoutId: UUID) async throws -> Workout

// 契约要求：
// - 计算实际训练时长
// - 设置状态为.completed
// - 更新updatedAt
// - 验证至少有一个训练组数
```

#### 获取训练历史
```swift
/// 获取训练历史
/// - Parameters:
///   - limit: 返回数量限制
///   - offset: 偏移量
///   - startDate: 开始日期（可选）
///   - endDate: 结束日期（可选）
/// - Returns: 训练记录列表
func getWorkoutHistory(
    limit: Int?,
    offset: Int?,
    startDate: Date?,
    endDate: Date?
) async throws -> [Workout]

// 契约要求：
// - 按date降序排列
// - limit <= 100，默认20
// - offset >= 0，默认0
// - 默认返回最近30天的记录
```

### 2. ExerciseService（动作服务）

#### 获取动作列表
```swift
/// 获取动作列表
/// - Parameters:
///   - category: 动作类别（可选）
///   - muscleGroups: 目标肌群（可选）
///   - difficulty: 难度等级（可选）
/// - Returns: 动作列表
func getExercises(
    category: ExerciseCategory?,
    muscleGroups: [String]?,
    difficulty: Int?
) async throws -> [Exercise]

// 契约要求：
// - 支持多条件筛选
// - 按name升序排列
// - 返回完整的动作信息
```

#### 搜索动作
```swift
/// 搜索动作
/// - Parameters:
///   - query: 搜索关键词
///   - limit: 返回数量限制
/// - Returns: 匹配的动作列表
func searchExercises(
    query: String,
    limit: Int?
) async throws -> [Exercise]

// 契约要求：
// - query长度 >= 2字符
// - 支持name和description模糊搜索
// - 按相关度排序
// - limit <= 50，默认20
```

### 3. ValidationService（验证服务）

#### 验证训练数据
```swift
/// 验证训练数据
/// - Parameter workout: 训练记录
/// - Returns: 验证结果
func validateWorkout(_ workout: Workout) -> ValidationResult

// 契约要求：
// - 验证所有必需字段
// - 检查数据类型和范围
// - 返回详细的验证错误
```

#### ValidationResult（验证结果）
```swift
struct ValidationResult: Codable {
    let isValid: Bool              // 是否有效
    let errors: [ValidationError]  // 错误列表
    let warnings: [ValidationWarning] // 警告列表

    struct ValidationError: Codable {
        let field: String          // 字段名
        let code: String           // 错误代码
        let message: String        // 错误消息
    }

    struct ValidationWarning: Codable {
        let field: String          // 字段名
        let code: String           // 警告代码
        let message: String        // 警告消息
    }
}
```

## 📊 事件契约

### 1. 业务事件定义

#### WorkoutStarted（训练开始）
```swift
struct WorkoutStartedEvent: Codable {
    let workoutId: UUID
    let startTime: Date
    let exercises: [Exercise]
}
```

#### WorkoutSetAdded（组数添加）
```swift
struct WorkoutSetAddedEvent: Codable {
    let workoutId: UUID
    let setId: UUID
    let weight: Double
    let reps: Int
    let timestamp: Date
}
```

#### WorkoutCompleted（训练完成）
```swift
struct WorkoutCompletedEvent: Codable {
    let workoutId: UUID
    let endTime: Date
    let totalSets: Int
    let duration: TimeInterval
}
```

### 2. 事件发布契约

#### EventPublisher（事件发布器）
```swift
protocol EventPublisher {
    /// 发布事件
    /// - Parameter event: 要发布的事件
    func publish<T: Codable>(_ event: T) async

    /// 订阅事件
    /// - Parameters:
    ///   - eventType: 事件类型
    ///   - handler: 事件处理器
    func subscribe<T: Codable>(
        to eventType: T.Type,
        handler: @escaping (T) async -> Void
    )
}
```

## 🔄 数据流契约

### 1. ViewModel数据流

#### WorkoutViewModel数据流契约
```swift
class WorkoutViewModel: ObservableObject {
    // 输入属性（外部设置）
    let exercises: [Exercise]

    // 状态属性（内部管理）
    @Published var currentWorkout: Workout?
    @Published var sets: [WorkoutSet] = []
    @Published var isLoading: Bool = false
    @Published var errors: [APIError] = []

    // 计算属性（派生数据）
    var totalSets: Int { sets.count }
    var totalVolume: Double { /* 计算总容量 */ }
    var canCompleteWorkout: Bool { /* 验证完成条件 */ }

    // 业务方法
    func startWorkout() async
    func addSet(weight: Double, reps: Int) async
    func removeSet(_ set: WorkoutSet) async
    func completeWorkout() async
}
```

### 2. 状态变更契约

#### 状态变更规则
```
1. 开始训练：
   - 设置isLoading = true
   - 创建Workout实例
   - 更新currentWorkout
   - 设置isLoading = false

2. 添加组数：
   - 验证输入数据
   - 创建WorkoutSet实例
   - 更新sets数组
   - 清空errors

3. 完成训练：
   - 验证完成条件
   - 更新Workout状态
   - 发布完成事件
   - 清理状态
```

## 📋 性能契约

### 1. 响应时间要求

| 操作类型 | 最大响应时间 | 平均响应时间 |
|---------|-------------|-------------|
| 开始训练 | 1秒 | 500ms |
| 添加组数 | 500ms | 200ms |
| 完成训练 | 2秒 | 1秒 |
| 获取历史 | 3秒 | 1.5秒 |
| 搜索动作 | 1秒 | 500ms |

### 2. 数据量限制

| 数据类型 | 最大数量 | 分页大小 |
|---------|---------|---------|
| 训练历史 | 1000条 | 20条 |
| 训练组数 | 100组/训练 | 不分页 |
| 动作列表 | 500个 | 50个 |
| 搜索结果 | 100个 | 20个 |

### 3. 内存使用限制

- ViewModel内存占用 < 10MB
- 缓存数据大小 < 50MB
- 单次操作内存增长 < 5MB

## 🧪 测试契约

### 1. 单元测试覆盖要求

| 组件类型 | 最低覆盖率 | 目标覆盖率 |
|---------|-----------|-----------|
| ViewModel | 90% | 95% |
| Model | 95% | 98% |
| Service | 85% | 90% |
| Utility | 80% | 85% |

### 2. 集成测试场景

- 完整训练流程测试
- 数据验证集成测试
- 错误处理集成测试
- 性能基准测试

### 3. 测试数据契约

#### MockData（模拟数据）
```swift
struct MockData {
    static let sampleExercises: [Exercise] = [
        // 预定义的示例动作
    ]

    static let sampleWorkout: Workout = {
        // 预定义的示例训练
    }()

    static var randomWorkoutSet: WorkoutSet {
        // 随机生成训练组数
    }
}
```

## 🚫 约束和限制

### 1. 数据约束

- 训练日期不能是未来时间
- 重量必须为非负数
- 次数必须为正整数
- 训练时长不能为负数

### 2. 业务约束

- 一次只能有一个进行中的训练
- 已完成的训练不能修改
- 删除操作需要确认
- 批量操作有限制

### 3. 技术约束

- 支持iOS 15.0+
- 使用Swift 5.7+
- 遵循SwiftUI最佳实践
- 内存使用限制100MB

---

这份API契约定义确保了Fit应用内部组件间的一致性和可预测性，为开发和维护提供了明确的规范指导。
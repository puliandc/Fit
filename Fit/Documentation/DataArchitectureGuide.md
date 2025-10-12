# FitApp 数据架构设计指南

## 概述

FitApp 采用简化的数据架构，基于用户反馈，将训练计划(TrainingPlan)和训练日志(TrainingSession)设计为完全独立的两个文件系统。本文档详细说明了数据模型、存储策略和操作规范。

## 核心设计原则

### 数据分离原则

- **训练计划(TrainingPlan)**：训练前和训练中读取的默认设置，不参与业务逻辑的增删改查
- **训练日志(TrainingSession)**：实际完成的训练记录，由应用生成
- **完全独立**：两个文件系统无直接关联，计划文件仅作为配置参考

### 简化设计理念

- 移除复杂的超级组设计
- 去除主观疲劳度记录(RPE)
- 简化状态管理
- 专注核心训练功能

## 数据模型

### 1. 训练计划 (TrainingPlan)

训练计划是训练的基础配置文件，包含固定的动作序列和参数设置。

```swift
// 训练计划模型
struct TrainingPlan: Codable {
    let planName: String
    let exercises: [Exercise]

// 动作模型
struct Exercise: Codable {
    let name: String
    let sets: [ExerciseSet]
}

// 组配置模型
struct ExerciseSet: Codable {
    let setType: SetType
    let targetReps: Int
    let targetWeight: Double
    let restTime: Int
}

// 组类型枚举
enum SetType: String, Codable, CaseIterable {
    case warmup = "热身组"
    case formal = "正式组"
}
```

#### 示例训练计划

```json
{
  "planName": "胸肌基础训练",
  "createdDate": "2025-10-01T00:00:00Z",
  "lastModified": "2025-10-01T00:00:00Z",
  "description": "初学者胸肌训练计划",
  "exercises": [
    {
      "name": "卧推",
      "sets": [
        {
          "setType": "热身组",
          "targetReps": 15,
          "targetWeight": 20.0,
          "restTime": 90
        },
        {
          "setType": "正式组",
          "targetReps": 12,
          "targetWeight": 40.0,
          "restTime": 120
        },
        {
          "setType": "正式组",
          "targetReps": 10,
          "targetWeight": 45.0,
          "restTime": 120
        }
      ]
    },
    {
      "name": "哑铃飞鸟",
      "sets": [
        {
          "setType": "正式组",
          "targetReps": 12,
          "targetWeight": 8.0,
          "restTime": 90
        },
        {
          "setType": "正式组",
          "targetReps": 10,
          "targetWeight": 10.0,
          "restTime": 90
        }
      ]
    }
  ]
}
```

### 2. 训练日志 (TrainingSession)

训练日志记录实际完成的训练内容，由应用在训练过程中动态生成。

```swift
// 训练会话模型
struct TrainingSession: Codable {
    let id: UUID
    let date: String           // 格式: "2025年10月2日"
    let planName: String       // 关联的训练计划名称
    let startTime: Date
    let endTime: Date
    let setRecords: [SetRecord]

    // 计算属性
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var totalSets: Int {
        setRecords.count
    }

    var completedSets: Int {
        setRecords.filter { !$0.notes.contains("放弃") }.count
    }
}

// 组记录模型
struct SetRecord: Codable {
    let id: UUID
    let exerciseName: String
    let targetWeight: Double
    let targetReps: Int
    let setOrder: Int
    let actualWeight: Double
    let actualReps: Int
    let notes: String          // 放弃时填写"放弃"，其他情况可为空
    let completedAt: Date
}
```

#### 示例训练日志

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "date": "2025年10月2日",
  "planName": "胸肌基础训练",
  "startTime": "2025-10-02T09:00:00Z",
  "endTime": "2025-10-02T10:15:00Z",
  "setRecords": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174001",
      "exerciseName": "卧推",
      "targetWeight": 20.0,
      "targetReps": 15,
      "setOrder": 1,
      "actualWeight": 20.0,
      "actualReps": 15,
      "notes": "",
      "completedAt": "2025-10-02T09:05:00Z"
    },
    {
      "id": "123e4567-e89b-12d3-a456-426614174002",
      "exerciseName": "卧推",
      "targetWeight": 40.0,
      "targetReps": 12,
      "setOrder": 2,
      "actualWeight": 40.0,
      "actualReps": 12,
      "notes": "",
      "completedAt": "2025-10-02T09:10:00Z"
    },
    {
      "id": "123e4567-e89b-12d3-a456-426614174003",
      "exerciseName": "卧推",
      "targetWeight": 45.0,
      "targetReps": 10,
      "setOrder": 3,
      "actualWeight": 45.0,
      "actualReps": 8,
      "notes": "放弃",
      "completedAt": "2025-10-02T09:15:00Z"
    }
  ]
}
```

## 文件存储架构

### 目录结构

```
Documents/
├── TrainingPlans/
│   ├── plan_chest_basics.json
│   ├── plan_legs_strength.json
│   └── plan_back_volume.json
└── TrainingLogs/
    ├── 2025-10-02_sessions.json
    ├── 2025-10-01_sessions.json
    └── 2025-09-30_sessions.json
```

### 文件命名规范

#### 训练计划文件

- **格式**: `plan_{sanitized_name}.json`
- **示例**: `plan_chest_basics.json`
- **规则**: 使用小写字母和下划线，移除特殊字符

#### 训练日志文件

- **格式**: `{YYYY-MM-DD}_sessions.json`
- **示例**: `2025-10-02_sessions.json`
- **内容**: 包含当天所有训练会话的数组

### 访问权限

- **训练计划**: 只读权限，应用不提供编辑功能
- **训练日志**: 完整读写权限，应用动态创建和管理

## 业务逻辑

### 训练流程

#### 1. 开始训练

```swift
// 1. 选择训练计划
let selectedPlan = TrainingPlanManager.loadPlan(name: "胸肌基础训练")

// 2. 创建训练会话
let session = TrainingSession(
    id: UUID(),
    date: currentDateFormatter.string(from: Date()),
    planName: selectedPlan.planName,
    startTime: Date(),
    endTime: Date(), // 将在训练结束时更新
    setRecords: []
)

// 3. 开始训练流程
TrainingSessionManager.startSession(session)
```

#### 2. 完成组

```swift
// 用户完成一组时的记录
func completeSet(target: ExerciseSet, exerciseName: String, actualWeight: Double, actualReps: Int) {
    let record = SetRecord(
        id: UUID(),
        exerciseName: exerciseName,
        targetWeight: target.targetWeight,
        targetReps: target.targetReps,
        setOrder: currentSetOrder,
        actualWeight: actualWeight,
        actualReps: actualReps,
        notes: actualReps >= target.targetReps ? "" : "未完成目标次数",
        completedAt: Date()
    )

    currentSession.setRecords.append(record)
    TrainingSessionManager.saveSession(currentSession)
}
```

#### 3. 放弃训练

```swift
// 用户放弃整个训练时的处理
func abandonTraining(reason: String) {
    currentSession.endTime = Date()

    // 标记剩余未完成的组为放弃
    let remainingSets = calculateRemainingSets()
    for set in remainingSets {
        let abandonRecord = SetRecord(
            id: UUID(),
            exerciseName: set.exerciseName,
            targetWeight: set.targetWeight,
            targetReps: set.targetReps,
            setOrder: set.setOrder,
            actualWeight: 0.0,
            actualReps: 0,
            notes: "放弃",
            completedAt: Date()
        )
        currentSession.setRecords.append(abandonRecord)
    }

    TrainingSessionManager.saveSession(currentSession)
}
```

### 训练计划管理

#### 只读访问

```swift
class TrainingPlanManager {
    static func loadPlan(name: String) -> TrainingPlan? {
        guard let url = planURL(for: name),
              let data = try? Data(contentsOf: url),
              let plan = try? JSONDecoder().decode(TrainingPlan.self, from: data) else {
            return nil
        }
        return plan
    }

    static func loadAllPlans() -> [TrainingPlan] {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                         in: .userDomainMask).first else {
            return []
        }

        let plansURL = documentsURL.appendingPathComponent("TrainingPlans")
        guard let enumerator = FileManager.default.enumerator(at: plansURL,
                                                              includingPropertiesForKeys: nil) else {
            return []
        }

        var plans: [TrainingPlan] = []
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "json",
               let data = try? Data(contentsOf: fileURL),
               let plan = try? JSONDecoder().decode(TrainingPlan.self, from: data) {
                plans.append(plan)
            }
        }
        return plans
    }
}
```

### 训练日志管理

#### 完整读写操作

```swift
class TrainingSessionManager {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func saveSession(_ session: TrainingSession) {
        let fileName = "\(dateFormatter.string(from: session.startTime))_sessions.json"
        guard let url = sessionsURL.appendingPathComponent(fileName) else { return }

        var sessions: [TrainingSession] = []

        // 读取现有会话
        if let existingData = try? Data(contentsOf: url),
           let existingSessions = try? JSONDecoder().decode([TrainingSession].self, from: existingData) {
            sessions = existingSessions
        }

        // 添加或更新会话
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }

        // 保存到文件
        if let data = try? JSONEncoder().encode(sessions) {
            try? data.write(to: url)
        }
    }

    static func loadSessions(for date: Date) -> [TrainingSession] {
        let fileName = "\(dateFormatter.string(from: date))_sessions.json"
        guard let url = sessionsURL.appendingPathComponent(fileName),
              let data = try? Data(contentsOf: url),
              let sessions = try? JSONDecoder().decode([TrainingSession].self, from: data) else {
            return []
        }
        return sessions
    }
}
```

## 状态管理

### 简化的状态模型

```swift
enum TrainingState {
    case notStarted          // 未开始
    case inProgress          // 训练中
    case completed           // 已完成
    case abandoned           // 已放弃
}

class TrainingViewModel: ObservableObject {
    @Published var currentState: TrainingState = .notStarted
    @Published var currentSession: TrainingSession?
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0

    private var trainingPlan: TrainingPlan?

    func startTraining(with plan: TrainingPlan) {
        trainingPlan = plan
        currentSession = TrainingSession(
            id: UUID(),
            date: currentDateFormatter.string(from: Date()),
            planName: plan.planName,
            startTime: Date(),
            endTime: Date(),
            setRecords: []
        )
        currentState = .inProgress
    }

    func completeSet(actualWeight: Double, actualReps: Int) {
        guard let session = currentSession,
              let plan = trainingPlan,
              currentExerciseIndex < plan.exercises.count else { return }

        let currentExercise = plan.exercises[currentExerciseIndex]
        let targetSet = currentExercise.sets[currentSetIndex]

        let record = SetRecord(
            id: UUID(),
            exerciseName: currentExercise.name,
            targetWeight: targetSet.targetWeight,
            targetReps: targetSet.targetReps,
            setOrder: currentSetIndex + 1,
            actualWeight: actualWeight,
            actualReps: actualReps,
            notes: actualReps >= targetSet.targetReps ? "" : "未完成目标",
            completedAt: Date()
        )

        session.setRecords.append(record)
        TrainingSessionManager.saveSession(session)

        // 移动到下一组
        moveToNextSet()
    }

    func abandonTraining() {
        guard var session = currentSession else { return }

        session.endTime = Date()
        currentState = .abandoned

        TrainingSessionManager.saveSession(session)
        currentSession = nil
    }

    private func moveToNextSet() {
        guard let plan = trainingPlan else { return }

        currentSetIndex += 1

        // 检查是否需要移动到下一个动作
        if currentSetIndex >= plan.exercises[currentExerciseIndex].sets.count {
            currentExerciseIndex += 1
            currentSetIndex = 0

            // 检查是否完成所有动作
            if currentExerciseIndex >= plan.exercises.count {
                completeTraining()
            }
        }
    }

    private func completeTraining() {
        guard var session = currentSession else { return }

        session.endTime = Date()
        currentState = .completed

        TrainingSessionManager.saveSession(session)
        currentSession = nil
    }
}
```

## 数据验证规则

### 训练计划验证

```swift
extension TrainingPlan {
    func validate() -> [ValidationError] {
        var errors: [ValidationError] = []

        // 计划名称验证
        if planName.isEmpty {
            errors.append(.emptyPlanName)
        }

        // 动作验证
        if exercises.isEmpty {
            errors.append(.noExercises)
        }

        for exercise in exercises {
            if exercise.name.isEmpty {
                errors.append(.emptyExerciseName)
            }

            if exercise.sets.isEmpty {
                errors.append(.noSetsInExercise(exercise.name))
            }

            for set in exercise.sets {
                if set.targetReps <= 0 {
                    errors.append(.invalidTargetReps(exercise.name))
                }
                if set.targetWeight < 0 {
                    errors.append(.invalidTargetWeight(exercise.name))
                }
                if set.restTime < 0 {
                    errors.append(.invalidRestTime(exercise.name))
                }
            }
        }

        return errors
    }
}

enum ValidationError: LocalizedError {
    case emptyPlanName
    case noExercises
    case emptyExerciseName
    case noSetsInExercise(String)
    case invalidTargetReps(String)
    case invalidTargetWeight(String)
    case invalidRestTime(String)

    var errorDescription: String? {
        switch self {
        case .emptyPlanName:
            return "训练计划名称不能为空"
        case .noExercises:
            return "训练计划必须包含至少一个动作"
        case .emptyExerciseName:
            return "动作名称不能为空"
        case .noSetsInExercise(let exerciseName):
            return "动作 '\(exerciseName)' 必须包含至少一组训练"
        case .invalidTargetReps(let exerciseName):
            return "动作 '\(exerciseName)' 的目标次数必须大于0"
        case .invalidTargetWeight(let exerciseName):
            return "动作 '\(exerciseName)' 的目标重量不能为负数"
        case .invalidRestTime(let exerciseName):
            return "动作 '\(exerciseName)' 的休息时间不能为负数"
        }
    }
}
```

### 训练日志验证

```swift
extension TrainingSession {
    func validate() -> [ValidationError] {
        var errors: [ValidationError] = []

        // 基础验证
        if planName.isEmpty {
            errors.append(.emptyPlanName)
        }

        if startTime > endTime {
            errors.append(.invalidTimeRange)
        }

        // 组记录验证
        for record in setRecords {
            if record.exerciseName.isEmpty {
                errors.append(.emptyExerciseName)
            }
            if record.actualWeight < 0 {
                errors.append(.invalidActualWeight)
            }
            if record.actualReps < 0 {
                errors.append(.invalidActualReps)
            }
            if record.setOrder <= 0 {
                errors.append(.invalidSetOrder)
            }
        }

        return errors
    }
}
```

## 性能优化

### 延迟加载策略

- **训练计划**: 按需加载，仅在用户选择时读取
- **训练日志**: 按日期加载，减少内存占用
- **历史数据**: 分页加载，支持渐进式检索

### 缓存机制

```swift
class DataCacheManager {
    private var planCache: [String: TrainingPlan] = [:]
    private var sessionCache: [String: [TrainingSession]] = [:]

    func getCachedPlan(name: String) -> TrainingPlan? {
        return planCache[name]
    }

    func cachePlan(_ plan: TrainingPlan) {
        planCache[plan.planName] = plan
    }

    func getCachedSessions(for date: String) -> [TrainingSession]? {
        return sessionCache[date]
    }

    func cacheSessions(_ sessions: [TrainingSession], for date: String) {
        sessionCache[date] = sessions
    }
}
```

### 文件大小管理

- **日志轮转**: 自动归档超过 30 天的日志文件
- **压缩存储**: 对历史日志进行 JSON 压缩
- **清理策略**: 定期清理重复或异常的训练记录

## 错误处理

### 文件操作错误

```swift
enum DataError: LocalizedError {
    case fileNotFound(String)
    case invalidFormat(String)
    case permissionDenied(String)
    case diskSpaceInsufficient
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "找不到文件: \(fileName)"
        case .invalidFormat(let fileName):
            return "文件格式错误: \(fileName)"
        case .permissionDenied(let fileName):
            return "文件访问权限不足: \(fileName)"
        case .diskSpaceInsufficient:
            return "磁盘空间不足"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
}
```

### 数据一致性保证

- **事务性操作**: 训练日志更新使用原子操作
- **备份机制**: 重要数据变更前自动备份
- **恢复策略**: 数据损坏时的自动恢复流程

## 安全性

### 数据保护

- **本地存储**: 所有数据存储在设备本地，不上传云端
- **访问控制**: 应用沙盒限制文件访问权限
- **数据加密**: 敏感数据使用设备级加密保护

### 隐私保护

- **无追踪**: 不收集用户个人训练数据
- **离线使用**: 完全支持离线训练功能
- **数据导出**: 支持用户导出个人训练数据

## 测试策略

### 单元测试

```swift
class TrainingPlanTests: XCTestCase {
    func testPlanValidation() {
        let validPlan = TrainingPlan(
            planName: "测试计划",
            exercises: [
                Exercise(name: "卧推", sets: [
                    ExerciseSet(setType: .formal, targetReps: 12, targetWeight: 40.0, restTime: 120)
                ])
            ]
        )

        XCTAssertTrue(validPlan.validate().isEmpty)
    }

    func testInvalidPlanValidation() {
        let invalidPlan = TrainingPlan(planName: "", exercises: [])
        let errors = invalidPlan.validate()
        XCTAssertTrue(errors.contains(.emptyPlanName))
        XCTAssertTrue(errors.contains(.noExercises))
    }
}
```

### 集成测试

- **文件操作测试**: 验证数据读写正确性
- **并发测试**: 确保多线程操作的数据一致性
- **性能测试**: 验证大数据量下的操作性能

## 版本迁移

### 数据版本控制

```swift
struct DataVersion {
    let major: Int
    let minor: Int
    let patch: Int

    static let current = DataVersion(major: 1, minor: 0, patch: 0)
}

protocol DataMigrator {
    func canMigrate(from version: DataVersion) -> Bool
    func migrate(data: Data, from version: DataVersion) throws -> Data
}

class TrainingPlanMigrator: DataMigrator {
    func canMigrate(from version: DataVersion) -> Bool {
        return version.major <= 1
    }

    func migrate(data: Data, from version: DataVersion) throws -> Data {
        // 迁移逻辑实现
        return data
    }
}
```

## 总结

本数据架构设计遵循用户反馈的简化原则，实现了：

1. **完全独立的训练计划和训练日志系统**
2. **简化的数据模型，专注于核心功能**
3. **清晰的业务逻辑和状态管理**
4. **健壮的错误处理和数据验证**
5. **良好的性能和安全性保障**

该架构为 FitApp 提供了稳定可靠的数据基础，支持核心训练功能的实现，同时保持了足够的扩展性以应对未来的功能需求。

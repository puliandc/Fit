# 训练日志后台记录系统技术设计文档

**创建时间**: 2025-10-14
**文档版本**: 2.0
**作者**: 系统架构师 & 后端架构师

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心需求分析](#2-核心需求分析)
3. [数据模型设计](#3-数据模型设计)
4. [后台记录系统设计](#4-后台记录系统设计)
5. [实施计划](#5-实施计划)
6. [技术考虑](#6-技术考虑)

---

## 1. 项目概述

### 1.1 功能目标

训练日志后台记录系统为用户提供完全透明的训练数据记录功能：

- 📝 **后台自动记录**：训练过程中完全感知不到日志系统的存在
- 💾 **JSON 文件导出**：训练完成后自动生成 JSON 格式日志文件到下载文件夹 ##训练开始后就在下载文件夹中直接建立日志文件，每完成/跳过一组动作就生成对应的记录，这样可以确保应用中断等意外发生时，已经发生的记录不会丢失。
- ⏱️ **时间精确记录**：准确记录每组动作的训练时长和组间休息时间
- 🔄 **数据完整性**：确保训练数据的准确记录，包括跳过动作的特殊处理

### 1.2 设计原则

- **完全透明**：用户在训练过程中完全感知不到日志记录的存在
- **自动化处理**：训练完成后自动生成并保存日志文件 ##训练开始后就在下载文件夹中直接建立日志文件，每完成/跳过一组动作就生成对应的记录，这样可以确保应用中断等意外发生时，已经发生的记录不会丢失。
- **数据准确**：精确记录训练过程中的所有关键数据
- **简洁高效**：最小化对现有训练流程的影响

---

## 2. 核心需求分析

### 2.1 核心功能需求

**完全透明的后台日志记录系统**：

1. **存储位置**：iPhone 下载文件夹
2. **文件命名**：`fit_YYYYMMDDHHMMSS.json` 格式（例：`fit_20251014092822.json`）
3. **用户感知**：训练过程中完全感知不到日志记录的存在
4. **数据字段**：
   - 动作（来自训练计划）
   - 组序（自动递增）
   - 目标重量（来自训练计划）
   - 实际重量（来自用户输入）
   - 目标次数（来自训练计划）
   - 实际次数（来自用户输入）
   - 训练时长（从动作开始到点击完成的时间）
   - 组间休息（来自训练计划）
   - 备注（来自用户输入）

### 2.2 特殊情况处理

**跳过动作的处理规则**：

- 实际重量：`"N/A"`
- 实际次数：`"N/A"`
- 训练时长：`"N/A"`
- 备注：`"放弃"`

### 2.3 数据来源映射

| 字段     | 数据来源                 | 获取时机   |
| -------- | ------------------------ | ---------- |
| 动作     | 训练计划(WorkoutPlan)    | 训练开始时 |
| 组序     | 自动计算                 | 每组完成时 |
| 目标重量 | 训练计划(ExerciseSet)    | 训练开始时 |
| 实际重量 | 用户输入(完成弹窗)       | 每组完成时 |
| 目标次数 | 训练计划(ExerciseSet)    | 训练开始时 |
| 实际次数 | 用户输入(完成弹窗)       | 每组完成时 |
| 训练时长 | 计时器(WorkoutViewModel) | 每组完成时 |
| 组间休息 | 训练计划(ExerciseSet)    | 训练开始时 |
| 备注     | 用户输入(完成弹窗)       | 每组完成时 |

---

## 3. 数据模型设计

### 3.1 简化的日志记录模型

#### 3.1.1 训练日志条目模型

```swift
// MARK: - WorkoutLogEntry
struct WorkoutLogEntry: Codable {
    let exercise: String          // 动作名称
    let setOrder: Int             // 组序
    let targetWeight: Double      // 目标重量
    let actualWeight: WorkoutValue  // 实际重量
    let targetReps: Int           // 目标次数
    let actualReps: WorkoutValue   // 实际次数
    let trainingDuration: WorkoutValue // 训练时长
    let restTime: Double          // 组间休息
    let notes: String             // 备注
}

// MARK: - WorkoutValue (处理实际值或N/A)
enum WorkoutValue: Codable {
    case value(Double)
    case na(String)

    var stringValue: String {
        switch self {
        case .value(let double):
            return String(format: "%.1f", double)
        case .na(let string):
            return string
        }
    }

    var doubleValue: Double? {
        switch self {
        case .value(let double):
            return double
        case .na:
            return nil
        }
    }
}
```

#### 3.1.2 完整训练日志模型

```swift
// MARK: - WorkoutLog
struct WorkoutLog: Codable {
    let workoutName: String         // 训练名称
    let workoutDate: String         // 训练日期
    let startTime: String           // 开始时间
    let endTime: String             // 结束时间
    let totalDuration: String       // 总训练时长
    let entries: [WorkoutLogEntry]   // 训练条目列表

    // JSON导出方法
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to encode workout log: \(error)")
            return nil
        }
    }
}
```

### 3.2 JSON 文件格式示例

```json
{
  "workoutName": "A组卧推深蹲",
  "workoutDate": "2025年9月30日",
  "startTime": "10:31",
  "endTime": "11:20",
  "totalDuration": "00:49:30",
  "entries": [
    {
      "exercise": "杠铃卧推",
      "setOrder": 1,
      "targetWeight": 45,
      "actualWeight": {
        "value": 45.0
      },
      "targetReps": 5,
      "actualReps": {
        "value": 5.0
      },
      "trainingDuration": {
        "value": 35.5
      },
      "restTime": 90,
      "notes": ""
    },
    {
      "exercise": "杠铃卧推",
      "setOrder": 2,
      "targetWeight": 45,
      "actualWeight": {
        "value": 45.0
      },
      "targetReps": 5,
      "actualReps": {
        "value": 5.0
      },
      "trainingDuration": {
        "value": 42.3
      },
      "restTime": 90,
      "notes": ""
    },
    {
      "exercise": "杠铃深蹲",
      "setOrder": 1,
      "targetWeight": 62.5,
      "actualWeight": {
        "na": "N/A"
      },
      "targetReps": 5,
      "actualReps": {
        "na": "N/A"
      },
      "trainingDuration": {
        "na": "N/A"
      },
      "restTime": 120,
      "notes": "放弃"
    }
  ]
}
```

### 3.3 文件存储路径设计

```swift
// MARK: - 文件存储管理
class WorkoutLogFileManager {
    private let fileManager = FileManager.default

    // 获取下载文件夹路径
    private var downloadsDirectoryURL: URL {
        let paths = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask)
        return paths.first!
    }

    // 生成文件名
    func generateLogFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let timestamp = formatter.string(from: Date())
        return "fit_\(timestamp).json"
    }

    // 获取完整的文件路径
    func getLogFileURL() -> URL {
        let fileName = generateLogFileName()
        return downloadsDirectoryURL.appendingPathComponent(fileName)
    }

    // 保存日志文件
    func saveWorkoutLog(_ workoutLog: WorkoutLog) -> Bool {
        let fileURL = getLogFileURL()

        guard let jsonString = workoutLog.toJSON() else {
            print("Failed to convert workout log to JSON")
            return false
        }

        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Workout log saved to: \(fileURL.path)")
            return true
        } catch {
            print("Failed to save workout log: \(error)")
            return false
        }
    }
}
```

---

## 4. 后台记录系统设计

### 4.1 训练日志记录器

```swift
// MARK: - WorkoutLogRecorder
class WorkoutLogRecorder {
    private let fileManager = WorkoutLogFileManager()
    private var workoutStartTime: Date?
    private var currentExerciseStartTime: Date?
    private var logEntries: [WorkoutLogEntry] = []
    private var currentExerciseSetOrder = 1
    private var currentExerciseName: String = ""

    // 开始训练记录
    func startWorkout(workoutPlan: WorkoutPlan) {
        workoutStartTime = Date()
        currentExerciseSetOrder = 1

        print("📝 Workout logging started for: \(workoutPlan.name)")
    }

    // 开始新动作
    func startExercise(exercise: Exercise) {
        currentExerciseName = exercise.name
        currentExerciseStartTime = Date()
        currentExerciseSetOrder = 1

        print("📝 Started logging exercise: \(exercise.name)")
    }

    // 记录完成的训练组
    func recordCompletedSet(
        exerciseSet: ExerciseSet,
        actualReps: Int,
        actualWeight: Double,
        notes: String = ""
    ) {
        guard let startTime = currentExerciseStartTime else {
            print("⚠️ Warning: Exercise start time not recorded")
            return
        }

        let trainingDuration = Date().timeIntervalSince(startTime)

        let entry = WorkoutLogEntry(
            exercise: currentExerciseName,
            setOrder: currentExerciseSetOrder,
            targetWeight: exerciseSet.targetWeight,
            actualWeight: .value(actualWeight),
            targetReps: exerciseSet.targetReps,
            actualReps: .value(Double(actualReps)),
            trainingDuration: .value(trainingDuration),
            restTime: exerciseSet.restTime,
            notes: notes
        )

        logEntries.append(entry)
        currentExerciseSetOrder += 1

        print("📝 Recorded set: \(currentExerciseName) Set \(currentExerciseSetOrder - 1)")
    }

    // 记录跳过的训练组
    func recordSkippedSet(exerciseSet: ExerciseSet) {
        let entry = WorkoutLogEntry(
            exercise: currentExerciseName,
            setOrder: currentExerciseSetOrder,
            targetWeight: exerciseSet.targetWeight,
            actualWeight: .na("N/A"),
            targetReps: exerciseSet.targetReps,
            actualReps: .na("N/A"),
            trainingDuration: .na("N/A"),
            restTime: exerciseSet.restTime,
            notes: "放弃"
        )

        logEntries.append(entry)
        currentExerciseSetOrder += 1

        print("📝 Recorded skipped set: \(currentExerciseName) Set \(currentExerciseSetOrder - 1)")
    }

    // 完成训练并保存日志
    func finishWorkout(workoutPlan: WorkoutPlan) -> Bool {
        guard let startTime = workoutStartTime else {
            print("⚠️ Warning: Workout start time not recorded")
            return false
        }

        let endTime = Date()
        let totalDuration = endTime.timeIntervalSince(startTime)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"
        let workoutDate = dateFormatter.string(from: startTime)

        dateFormatter.dateFormat = "HH:mm"
        let startTimeString = dateFormatter.string(from: startTime)
        let endTimeString = dateFormatter.string(from: endTime)

        let workoutLog = WorkoutLog(
            workoutName: workoutPlan.name,
            workoutDate: workoutDate,
            startTime: startTimeString,
            endTime: endTimeString,
            totalDuration: formatDuration(totalDuration),
            entries: logEntries
        )

        let success = fileManager.saveWorkoutLog(workoutLog)

        if success {
            print("✅ Workout log saved successfully")
        } else {
            print("❌ Failed to save workout log")
        }

        // 重置状态
        reset()

        return success
    }

    // 重置记录器状态
    private func reset() {
        workoutStartTime = nil
        currentExerciseStartTime = nil
        logEntries.removeAll()
        currentExerciseSetOrder = 1
        currentExerciseName = ""
    }

    // 格式化时长显示
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
```

### 4.2 与现有系统集成

#### 4.2.1 扩展 WorkoutViewModel

```swift
// MARK: - WorkoutViewModel Extension
extension WorkoutViewModel {
    // 添加日志记录器
    private var workoutLogRecorder = WorkoutLogRecorder()

    // 重写init方法
    convenience init(workoutPlan: WorkoutPlan) {
        self.init(workoutPlan: workoutPlan)
        workoutLogRecorder = WorkoutLogRecorder()
        workoutLogRecorder.startWorkout(workoutPlan: workoutPlan)
    }

    // 重写startExercise方法
    override func startExercise() {
        super.startExercise()
        workoutLogRecorder.startExercise(exercise: currentExercise)
    }

    // 重写completeExerciseWith方法
    override func completeExerciseWith(actualReps: Int, actualWeight: Double) {
        // 执行原有的完成逻辑
        super.completeExerciseWith(actualReps: actualReps, actualWeight: actualWeight)

        // 记录日志
        workoutLogRecorder.recordCompletedSet(
            exerciseSet: currentExerciseSet,
            actualReps: actualReps,
            actualWeight: actualWeight,
            notes: ""
        )
    }

    // 添加带备注的完成方法
    func completeExerciseWith(actualReps: Int, actualWeight: Double, notes: String) {
        // 执行原有的完成逻辑
        super.completeExerciseWith(actualReps: actualReps, actualWeight: actualWeight)

        // 记录日志
        workoutLogRecorder.recordCompletedSet(
            exerciseSet: currentExerciseSet,
            actualReps: actualReps,
            actualWeight: actualWeight,
            notes: notes
        )
    }

    // 重写跳过方法
    override func skipCurrentExerciseCompletely() {
        super.skipCurrentExerciseCompletely()

        // 记录跳过的所有组
        let currentExerciseSets = workoutPlan.exercises.filter { $0.exercise.id == currentExercise.id }
        let currentSetPosition = currentExerciseSets.firstIndex(where: { $0.id == currentExerciseSet.id }) ?? 0

        for i in currentSetPosition..<currentExerciseSets.count {
            workoutLogRecorder.recordSkippedSet(exerciseSet: currentExerciseSets[i])
        }
    }

    // 添加训练完成方法
    func finishWorkoutAndSaveLog() -> Bool {
        pauseExercise()
        return workoutLogRecorder.finishWorkout(workoutPlan: workoutPlan)
    }
}
```

#### 4.2.2 扩展 NavigationManager

```swift
// MARK: - NavigationManager Extension
extension NavigationManager {
    // 修改训练完成对话框逻辑
    func completeWorkout() {
        if let viewModel = currentWorkoutViewModel {
            // 保存训练日志
            let logSaved = viewModel.finishWorkoutAndSaveLog()

            if logSaved {
                print("✅ Workout completed and log saved successfully")
            } else {
                print("❌ Workout completed but log saving failed")
            }
        }

        presentDialog(.workoutComplete)
    }
}
```

---

## 5. 实施计划

### 5.1 简化实施策略（2 个阶段）

#### 阶段 1：后台日志记录系统（预计 2-3 天）

**目标**：建立完全透明的后台日志记录功能

**任务清单**：

- [ ] 创建 WorkoutLogRecorder 类
- [ ] 创建 WorkoutLogFileManager 类
- [ ] 定义 WorkoutLogEntry 和 WorkoutValue 数据模型
- [ ] 扩展 WorkoutViewModel 集成日志记录
- [ ] 扩展 NavigationManager 在训练完成时保存日志

**验收标准**：

- 训练过程中用户完全感知不到日志记录的存在
- 训练完成后自动在下载文件夹生成 JSON 文件
- 文件命名格式正确：`fit_YYYYMMDDHHMMSS.json`
- 数据字段完整且格式正确

#### 阶段 2：集成测试和优化（预计 1 天）

**目标**：系统集成和边界情况处理

**任务清单**：

- [ ] 测试正常训练流程的日志记录
- [ ] 测试跳过动作的日志记录
- [ ] 测试训练中断的日志记录
- [ ] 验证 JSON 文件格式的正确性
- [ ] 优化性能和错误处理

**验收标准**：

- 所有训练场景都能正确记录日志
- JSON 文件格式符合要求
- 系统性能良好，无卡顿现象
- 错误处理机制完善

### 5.2 关键里程碑

| 里程碑               | 完成时间 | 主要交付物                       |
| -------------------- | -------- | -------------------------------- |
| M1: 后台记录系统完成 | Day 3    | 日志记录器、文件管理器、数据模型 |
| M2: 系统集成完成     | Day 4    | 完整的透明日志记录系统           |

---

## 6. 技术考虑

### 6.1 系统集成考虑

#### 6.1.1 最小化现有代码影响

- 通过扩展而非修改现有类来集成日志功能
- 保持现有训练流程完全不变
- 日志记录失败不影响正常训练功能

#### 6.1.2 错误处理策略

```swift
// 优雅的错误处理
extension WorkoutLogRecorder {
    private func handleFileSaveError(_ error: Error) {
        // 静默处理文件保存错误，不影响训练流程
        print("⚠️ Warning: Failed to save workout log: \(error.localizedDescription)")

        // 可选：尝试保存到备用位置
        // saveToBackupLocation()
    }
}
```

### 6.2 性能考虑

#### 6.2.1 内存优化

- 使用轻量级数据结构
- 及时释放不需要的临时数据
- 避免在训练过程中创建大量临时对象

#### 6.2.2 文件操作优化

- 异步文件写入避免阻塞 UI 线程
- 使用最小化的 JSON 格式
- 在训练完成时一次性写入，而非频繁写入

### 6.3 数据准确性保证

#### 6.3.1 时间记录精度

```swift
// 确保时间记录的准确性
extension WorkoutLogRecorder {
    private func recordTrainingDuration() -> TimeInterval {
        guard let startTime = currentExerciseStartTime else {
            return 0
        }

        let duration = Date().timeIntervalSince(startTime)

        // 验证时间合理性（避免异常值）
        if duration < 0 || duration > 3600 { // 最大1小时
            print("⚠️ Warning: Unusual training duration detected: \(duration) seconds")
            return 0
        }

        return duration
    }
}
```

#### 6.3.2 数据一致性

- 确保组序的连续性和正确性
- 验证跳过动作时数据标记的一致性
- 保持 JSON 文件格式的一致性

---

## 8. 附录

### 8.1 代码示例

完整的代码实现示例已在各章节中提供，包括：

- 数据模型定义
- 服务层实现
- 界面组件代码
- 数据管理逻辑

### 8.2 测试策略

建议采用以下测试策略：

- **单元测试**：测试数据模型和服务层逻辑
- **集成测试**：测试组件间的协作
- **UI 测试**：测试用户界面交互
- **性能测试**：测试大数据量下的性能表现

### 8.3 部署注意事项

1. **数据迁移**：确保现有数据能够正确迁移到新格式
2. **向后兼容**：保持与现有功能的兼容性
3. **性能监控**：监控应用性能，及时优化
4. **用户反馈**：收集用户反馈，持续改进

---

**文档结束**

_本文档将根据实施进展和用户反馈持续更新和完善。_

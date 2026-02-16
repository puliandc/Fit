# Fit 健身训练记录应用 - 功能规格说明书

// updated: 2025-10-30

本说明书与当前 SwiftUI 代码保持一致，聚焦已有功能（训练计划导入、训练执行、语音提示与日志记录）。

## 产品概述
- **定位**：面向单一用户的离线训练记录工具，强调 30 秒内开始训练、语音提示与最少屏幕交互。
- **平台**：iOS 15+，Swift 5.8+，SwiftUI。
- **架构**：MVVM + EnvironmentObject，主要管理器和服务均在 `Fit/` 目录内实现。

## 系统架构与模块

### 视图层
- **MainScreen**：主入口，包含训练计划导入（FilePickerView）、训练计划摘要卡片、开始训练按钮。
- **WorkoutScreen**：训练执行界面，显示当前动作/组信息、计时器、完成/放弃操作，承载对话框蒙层。
- **FilePickerView**：文件选择 Sheet，用于导入 JSON 训练计划。
- **通用组件**：`AnimatedBackground`、`SafeAreaBackground`、`LogoHeader`、`ModernButton` 等在 `Components/` 与 `Views/MainScreen.swift` 内定义。

### 状态管理
- **NavigationManager**：全局导航状态（主界面 / 训练界面）。
- **DialogManager**：统一管理当前弹窗状态。
- **WorkoutSessionManager**：创建与持有 `WorkoutViewModel`，封装训练开始/完成/退出。
- **WorkoutViewModel**：训练流程核心状态（当前动作、组序、休息状态、计时、完成记录）。

### 服务与业务逻辑
- **ExternalTrainingPlanService**：调用 `FileSecurityValidator` 校验文件，使用 `JSONWorkoutParser` 解析 JSON，产出 `WorkoutPlan`。
- **JSONWorkoutParser**：基于中文字段的解析器；支持 `目标重量` 整数/小数、组级 `备注` 入模，并对任一组配置异常执行整份导入失败。
- **VoiceManager**：集中播放语音提示（应用启动、训练播报等）。
- **WorkoutLogRecorder**：负责开始/记录/结束训练日志，生成 JSON（`WorkoutLog`）。
- **FileSecurityValidator**：检查扩展名、大小、基本结构安全。

## 核心功能规格

### 1. 训练计划导入（MainScreen + FilePickerView）
- 触发：点击“读取健身计划”按钮，弹出文件选择器。
- 文件校验：`FileSecurityValidator.validateFile(url)`，限制扩展名 json，大小 ≤10MB，非空。
- 解析：`JSONWorkoutParser.parseWorkoutPlan(from:)`，失败时弹出“JSON解析错误”警告。
- 组配置规则：
  - `目标重量` 支持整数与小数（如 `40`、`17.5`）。
  - 每组 `备注` 可选，解析后写入 `ExerciseSet.notes`。
  - 任一组字段类型或结构异常（如重量非数字）会导致整份计划导入失败，不做静默跳过。
- 成功结果：`ExternalTrainingPlanService.currentWorkoutPlan` 持有解析出的 `WorkoutPlan`，主界面显示摘要卡片与“开始训练”按钮。

### 2. 训练执行（WorkoutScreen + WorkoutViewModel）
- 导航：MainScreen 成功导入后，点击“开始训练”调用 `WorkoutSessionManager.startWorkout(plan)`，进入 WorkoutScreen。
- 核心模块：
  - **CompactWorkoutHeader**：显示计划名称与进度。
  - **CompactExerciseInfoCard**：展示当前动作、组序、目标重量/次数，并显示当前组的计划备注（若存在）。
  - **CompactTimerView**：休息阶段显示倒计时，支持跳过休息（当组间休息时间为 0 时可无缝衔接下一组）。
  - **ActionTimerView**（仅在需要时）：显示动作计时。
  - **EditSetDialog**：录入实际次数/重量/备注；默认备注来自计划组备注，用户可编辑；空或“自重”重量视为 0。
  - **EnhancedQuitDialog**：放弃当前动作/全部动作；确认后调用 ViewModel 的跳过逻辑，并触发完成弹窗。
- 完成流程：`WorkoutSessionManager.completeWorkout()` 仅在 ViewModel 标记完成后保存日志并展示完成对话框，再由 `cleanupAfterWorkoutComplete()` 清理会话。

### 3. 语音提示（VoiceManager）
- 应用启动：`FitApp` 调用 `voiceManager.speak("今天的燃动开始了")`。
- 其他提示：由业务视需求触发（休息结束、完成等），保持简短明确。

### 4. 日志记录（WorkoutLogRecorder）
- `startWorkout(workoutPlan:)` 在训练开始时记录基准时间。
- `startExercise(exercise:)` 重置组序并记录开始时间。
- `recordCompletedSet` / `recordSkippedSet` 生成 `WorkoutLogEntry`，保存目标/实际数据与休息时间。
- 备注策略：日志条目 `notes` 合并“计划组备注 + 用户输入备注”；若任一侧为空，仅保留非空侧。
- `finishWorkout` 生成 `WorkoutLog`，文件名 `训练日志_yyyy-MM-dd_HH-mm.json`，存储于用户文档目录。

## 数据模型（实际代码）
- **Exercise**：`id: UUID`，`name: String`
- **ExerciseSet**：`id: UUID`，`exercise: Exercise`，`targetReps: Int`，`targetWeight: Double`，`restTime: Int`，`notes: String?`
- **WorkoutPlan**：`id: UUID`，`name: String`，`duration: Int`（估算分钟） ，`exercises: [ExerciseSet]`
- **CompletedSet**：`id: UUID`，`exerciseSetId: UUID`，`actualReps: Int`，`actualWeight: Double`，`completedAt: Date`，`notes: String?`
- **WorkoutLogEntry / WorkoutLog**：见 `Fit/Models/WorkoutLogModels.swift`，含 `WorkoutValue` 枚举以支持 `value` / `na`。
- **JSONParseError**：`invalidFormat`、`invalidStructure`、`missingPlanName`、`missingExercises`、`missingExerciseName(Int)`、`missingSetConfig(String)`、`invalidSetConfig(exerciseName:setIndex:reason:)`。

## 业务流程
### 训练计划导入流程
1) 用户在 MainScreen 点击“读取健身计划”  
2) FilePickerView 返回文件 URL → ExternalTrainingPlanService  
3) 验证文件 → 读取 Data → JSONWorkoutParser 解析 → 生成 WorkoutPlan  
4) MainScreen 显示计划摘要卡片与“开始训练”按钮

### 训练执行流程
1) 点击“开始训练” → WorkoutSessionManager 创建 WorkoutViewModel  
2) WorkoutScreen 展示当前动作/组、计时/休息状态  
3) 用户点击“动作完成” → EditSetDialog 输入实际数据 → 记录到 ViewModel & WorkoutLogRecorder  
4) 休息阶段使用 CompactTimerView；可跳过休息  
5) 所有组完成 → 弹出完成对话框 → `completeWorkout` 保存日志  
6) 关闭完成弹窗后清理会话并返回主界面

## 非功能性要求
- **离线优先**：核心功能不依赖网络。
- **性能**：主界面/训练界面加载即时；动画可在低电量/减少动画时禁用。
- **兼容性**：iOS 15+；深浅模式以浅色渐变为主，深色仅在局部背景需要时使用。

## 测试与验证
- 单元测试：`FitTests/DataValidationTests.swift`、`FitTests/DebugModeTests.swift`。
- 建议命令：`fit-test`（或 `xcodebuild test -project Fit.xcodeproj -scheme Fit -destination 'platform=iOS Simulator,name=iPhone 17'`）。
- 手动验证：导入示例 `11282025.json`，完成至少一组训练，确认日志文件生成且 JSON 结构与 `WorkoutLogModels` 定义一致。

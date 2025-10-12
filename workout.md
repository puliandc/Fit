# Workout 界面 UI 元素和交互逻辑文档

**文档创建时间**: 2025 年 1 月 12 日
**版本**: 1.0
**基于代码**: WorkoutScreen.swift, WorkoutViewModel.swift, MockData.swift, NavigationManager.swift

---

## 目录

1. [界面概述](#界面概述)
2. [UI 元素详细分析](#ui元素详细分析)
3. [交互逻辑详解](#交互逻辑详解)
4. [功能实现说明](#功能实现说明)
5. [用户操作流程](#用户操作流程)
6. [技术实现要点](#技术实现要点)
7. [状态管理](#状态管理)
8. [数据流分析](#数据流分析)

---

## 界面概述

Workout 界面是一个紧凑设计的训练执行界面，基于 Figma 设计规范，采用垂直布局和模块化组件架构。界面主要功能是引导用户完成训练计划中的各个动作，提供实时计时、进度跟踪和参数记录功能。

**设计特点**：

- 简洁的单卡片信息展示
- 渐变背景和模糊光斑效果
- 响应式动画和过渡效果
- 模块化组件设计
- 中文界面，符合中国用户使用习惯

---

## UI 元素详细分析

### 1. 背景层 (CompactWorkoutBackground)

**位置**: 最底层，覆盖整个屏幕
**视觉特征**:

- 三色渐变背景：橙色(255,247,237) → 粉色(253,242,248) → 紫色(243,232,255)
- 两个模糊光斑效果：橙色光斑(384x384)和粉色光斑(320x320)
- 光斑偏移位置：橙色光斑(x:180, y:132)，粉色光斑(x:-74, y:407)

**用途**: 提供美观的视觉背景，营造舒适的训练氛围

### 2. 顶部标题栏 (CompactWorkoutHeader)

**位置**: 界面顶部
**视觉特征**:

- 半透明白色背景(透明度 70%)
- 圆角设计(24px)
- 阴影效果(黑色 8%透明度，半径 32px)
- 高度自适应内容

**子元素**:

- **返回按钮**: 36x32px 白色圆角矩形，包含橙色返回图标 ## 橙色返回图标在现版本上看不到，请换其他颜色的返回图标
- **标题文字**: "快速训练计划"，橙色到粉色渐变字体，16px 中等字重
- **进度信息**:
  - "训练进度"文字：灰色，12px 中等字重 ## 取消训练进度字样
  - 百分比显示：橙色，12px 中等字重 ## 百分比显示提到标题文字同样的高度，显示在标题文字后面，字重保持不变
- **进度条**:
  - 背景轨道：灰色 30%透明度，8px 高度，4px 圆角
  - 进度填充：橙色到粉色渐变，8px 高度，动画过渡

**交互行为**:

- 返回按钮点击：调用 navigationManager.quitWorkout()
- 进度条自动更新：基于 WorkoutViewModel 的 progress 属性 ## 目前进度条不会更新，请修复。进度条比例 = 整个计划已完成组数/整个计划总组数 \* 100% 取整。

### 3. 休息时间覆盖层 (CompactRestTimerView)

**位置**: 主内容区域上方，条件显示
**显示条件**: workoutViewModel.isResting 为 true 时
**视觉特征**:

- 白色半透明背景(70%透明度)
- 圆角 16px
- 阴影效果
- 弹性进入动画

**子元素**:

- **休息图标**: 床图标，蓝色，18px
- **休息标题**: "休息时间"，蓝色，14px 半粗体
- **倒计时显示**: 格式化时间(MM:SS)，蓝色，24px 粗体
- **跳过提示**: "点击跳过休息"，灰色，12px，44px 最小点击区域

**交互行为**:

- 点击任意位置：调用 workoutViewModel.skipRest()
- 自动倒计时：每秒减少 timeLeft，归零时自动开始下一个动作

### 4. 运动信息卡片 (CompactExerciseInfoCard)

**位置**: 主内容区域中央
**视觉特征**:

- 白色半透明背景(70%透明度)
- 14px 圆角
- 阴影效果
- 16px 内边距
- 垂直布局，16px 间距

**子元素**:

- **运动名称**: 橙粉渐变，16px 中等字重，居左显示
- **运动时间模块**:
  - 橙色背景渐变
  - 时间图标 + "动作时间：" + 格式化时间
  - 橙色主题，14px 标签文字，16px 数值文字
- **当前组数模块**:
  - 蓝色背景渐变
  - 组数图标 + "当前组数：" + "当前/总数"
  - 蓝色主题
- **次数和重量模块**: 水平排列，12px 间距
  - **次数模块**: 绿色主题，包含图标、标签、大号数值
  - **重量模块**: 紫色主题，包含图标、标签、大号数值(0 显示为半透明)

**数据绑定**:

- 运动名称：workoutViewModel.currentExercise.name
- 时间：workoutViewModel.exerciseElapsedTime
- 组数：workoutViewModel.currentSet / 总组数计算
- 次数：workoutViewModel.currentExerciseSet.targetReps
- 重量：workoutViewModel.currentExerciseSet.targetWeight

### 5. 底部按钮区域

**位置**: 界面底部，固定位置
**布局**: 水平排列，12px 间距
**包含元素**:

#### 5.1 动作完成按钮 (CompactCompleteButton) ## 切换下动作完成按钮和放弃动作按钮的位置。我是右撇子，习惯动作完成在右侧。

- **尺寸**: 全宽度，48px 高度
- **样式**: 绿色渐变背景，14px 半粗体白色文字
- **圆角**: 14px
- **阴影**: 绿色 30%透明度，半径 15px
- **状态**:
  - 正常：完全可见
  - 禁用：50%透明度(休息时禁用)
- **交互**: 点击时弹出参数编辑对话框

#### 5.2 放弃动作按钮 (CompactQuitButton)

- **尺寸**: 全宽度，48px 高度
- **样式**: 白色 60%透明度背景，红色文字
- **边框**: 白色 60%透明度，1px 线宽
- **圆角**: 14px
- **阴影**: 黑色 10%透明度，半径 10px
- **交互**: 点击时触发放弃确认对话框

### 6. 对话框覆盖层 (CompactDialogOverlay)

**位置**: 全屏覆盖
**背景**: 黑色 40%透明度遮罩
**z-index**: 1000

**对话框类型**:

- **参数编辑对话框** (CompactEditSetDialog)
- **训练完成对话框** (CompactWorkoutCompleteDialog)
- **放弃训练对话框** (CompactQuitDialog)
- **完成确认对话框** (CompactCompletionDialog)

---

## 交互逻辑详解

### 1. 界面启动流程

```swift
onAppear {
    // 1. 安全检查：确保有训练动作
    guard !workoutViewModel.workoutPlan.exercises.isEmpty else { return }

    // 2. 开始第一个动作
    workoutViewModel.startExercise()

    // 3. 触发内容显示动画
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
        showContent = true
    }
}
```

### 2. 动作完成交互流程

1. **用户点击"动作完成"按钮**

   - 检查是否在休息状态(禁用逻辑)
   - 触发参数编辑对话框 ## 参数编辑对话框改名为“动作完成”对话框

2. **参数编辑对话框显示**

   - 预填充默认参数：次数和重量
   - 用户输入实际完成的次数和重量
   - 数据验证：确保输入有效

3. **保存参数**
   - 调用 workoutViewModel.completeExerciseWith(actualReps, actualWeight)
   - 记录完成的组数据 ## 记录完成的组数据调用的是哪个函数或者 API？ 这里留个 Todo
   - 判断是否进入休息或下一个动作 ## 目前点击保存之后并不会进入下一个动作。另外这个时候需要刷新训练进度。

### 3. 休息时间交互

1. **自动进入休息状态**

   - 完成动作后自动触发
   - 显示休息倒计时界面
   - 开始倒计时计时器

2. **跳过休息功能**

   - 点击休息界面任意位置
   - 停止休息计时器
   - 立即开始下一个动作

3. **自动结束休息**
   - 倒计时归零时自动触发
   - 隐藏休息界面
   - 开始下一个动作计时

### 4. 放弃训练交互

1. **点击"放弃动作"按钮** ## 点击放弃训练后应该提供三个选项 “放弃该动作”， “放弃后续全部” 和 “取消”，具体设计可以参考 https://www.figma.com/design/V65DyYQuROJ9GytNIAT5Ih/Figma-Design?node-id=6-3&t=hPU1egHwyNvIQrhi-1

   - 显示确认对话框
   - 提供确认和取消选项

2. **确认放弃** ## 如果选择放弃后续全部则返回主界面，但也要记得保存已经完成的所有训练日志，以及现在回到主界面这个放弃训练交互框并没有被正确关闭。
   - 调用 navigationManager.popToRoot()
   - 清理计时器资源
   - 返回主界面

---

## 功能实现说明

### 1. 计时器管理

**运动计时器**:

- 每秒递增 exerciseElapsedTime
- 只在 isExerciseActive 为 true 时运行
- 使用 Timer.scheduledTimer 实现

**休息计时器**:

- 每秒递减 timeLeft
- 倒计时结束自动开始下一个动作
- 可通过点击手动跳过

### 2. 进度计算

```swift
var progress: Double {
    let totalExercises = workoutPlan.exercises.count
    let completedExercises = currentExerciseIndex
    return totalExercises > 0 ? Double(completedExercises) / Double(totalExercises) : 0.0
}
```

### 3. 数据记录

**完成的组数据**:

```swift
struct CompletedSet {
    let exerciseSetId: UUID
    let actualReps: Int
    let actualWeight: Double
    let completedAt: Date
}
```

**组数管理**:

- 跟踪每个练习的已完成组数
- 计算剩余组数
- 支持同一练习的多组训练

### 4. 安全机制

1. **空数据保护**: 初始化时检查训练计划是否为空
2. **索引越界保护**: 访问练习数组时进行边界检查
3. **默认值提供**: 异常情况下提供安全的默认练习

---

## 用户操作流程

### 完整训练流程

```
开始训练
    ↓
显示第一个动作信息
    ↓
开始运动计时
    ↓
[用户完成动作] → 点击"动作完成"
    ↓
弹出参数编辑对话框  ## "参数编辑"对话框 应该为 "动作完成"对话框，请修改对话框标题
    ↓
输入实际次数和重量 → 点击"保存"
    ↓
记录完成数据 → 进入休息状态  ## 目前不会进入休息状态，请解决这个Bug。同时这个时候需要刷新“训练进度”
    ↓
显示休息倒计时
    ↓
[倒计时结束 或 点击跳过]
    ↓
开始下一个动作
    ↓
[重复直到所有动作完成]
    ↓
显示训练完成对话框
    ↓
点击"完成" → 返回主界面
```

### 关键决策点

1. **动作完成时**: 用户输入实际参数 vs 使用默认参数
2. **休息时间时**: 等待倒计时结束 vs 手动跳过
3. **训练过程中**: 继续训练 vs 放弃训练 ## 训练过程中的关键决策是 “完成训练” 和 “放弃训练”

### 异常处理流程

1. **无训练数据**: 显示默认练习，记录错误日志
2. **索引越界**: 回退到第一个练习，记录警告
3. **计时器异常**: 清理资源，重新初始化

---

## 技术实现要点

### 1. SwiftUI 组件使用

**主要视图组件**:

- `ZStack`: 层次布局(背景 → 内容 → 对话框)
- `VStack`: 垂直布局(顶部栏 → 主内容 → 底部按钮)
- `HStack`: 水平布局(按钮排列、信息模块)
- `GeometryReader`: 进度条宽度计算

**动画效果**:

- `.spring()`: 弹性动画(内容显示、对话框)
- `.easeInOut()`: 平滑过渡(进度条)
- `.asymmetric()`: 不对称过渡(休息界面)

### 2. 数据绑定机制

**@Published 属性**:

```swift
@Published var currentExerciseIndex: Int = 0
@Published var currentSet: Int = 1
@Published var exerciseElapsedTime: Int = 0
@Published var isExerciseActive: Bool = false
@Published var isResting: Bool = false
@Published var timeLeft: Int = 0
@Published var completedSets: [CompletedSet] = []
```

**@StateObject 和@EnvironmentObject**:

- `@StateObject private var workoutViewModel`: 视图模型管理
- `@EnvironmentObject var navigationManager`: 导航管理

### 3. 状态管理

**状态模式**:

```swift
enum WorkoutState {
    case notStarted    // 未开始
    case inProgress    // 进行中
    case paused        // 暂停
    case completed     // 已完成
    case quit          // 放弃
}
```

**状态转换**:

- 开始训练 → 进行中
- 进行中 → 暂停/休息
- 休息 → 进行中
- 进行中 → 完成/放弃

### 4. 业务逻辑实现

**练习管理**:

```swift
func completeExerciseWith(actualReps: Int, actualWeight: Double) {
    // 1. 暂停当前计时
    pauseExercise()

    // 2. 记录完成数据
    let completedSet = CompletedSet(...)
    completedSets.append(completedSet)

    // 3. 判断下一个动作
    if currentSet >= getTargetSetsForCurrentExercise() {
        // 当前练习完成，进入下一个练习
        moveToNextExercise()
    } else {
        // 进入下一组
        currentSet += 1
        startRest()
    }
}
```

**组数计算**:

```swift
private func getTargetSetsForCurrentExercise() -> Int {
    let currentExerciseId = currentExercise.id
    return workoutPlan.exercises.filter {
        $0.exercise.id == currentExerciseId
    }.count
}
```

---

## 状态管理

### ViewModel 状态属性

| 属性名               | 类型           | 用途         | 更新触发      |
| -------------------- | -------------- | ------------ | ------------- |
| currentExerciseIndex | Int            | 当前练习索引 | 完成练习后    |
| currentSet           | Int            | 当前组数     | 完成组后      |
| exerciseElapsedTime  | Int            | 动作执行时间 | 计时器每秒    |
| isExerciseActive     | Bool           | 动作是否激活 | 开始/暂停动作 |
| isResting            | Bool           | 是否在休息   | 进入/结束休息 |
| timeLeft             | Int            | 休息剩余时间 | 休息计时器    |
| completedSets        | [CompletedSet] | 完成的组数据 | 完成动作时    |

### 导航状态管理

```swift
class NavigationManager: ObservableObject {
    @Published var currentScreen: AppScreen = .main
    @Published var presentedDialog: DialogType?

    func presentDialog(_ dialog: DialogType) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            presentedDialog = dialog
        }
    }
}
```

### 对话框状态

```swift
enum DialogType {
    case editSet(Exercise, Int)    // 编辑参数
    case completion                // 完成确认
    case quitWorkout              // 放弃训练
    case workoutComplete          // 训练完成
}
```

---

## 数据流分析

### 数据流向图

```
MockData (训练计划)
    ↓
WorkoutViewModel (状态管理)
    ↓
WorkoutScreen (UI展示)
    ↓
用户交互
    ↓
NavigationManager (导航控制)
    ↓
状态更新 → UI刷新
```

### 关键数据传递

1. **训练数据传递**:

   ```
   MockDataProvider → WorkoutPlan → WorkoutViewModel → UI组件
   ```

2. **用户输入传递**:

   ```
   用户输入 → 对话框 → ViewModel → 数据模型 → 状态更新
   ```

3. **进度计算传递**:
   ```
   已完成练习数 / 总练习数 → progress属性 → 进度条显示
   ```

### 响应式更新机制

**SwiftUI 响应式流程**:

1. ViewModel 的@Published 属性发生变化
2. 自动触发 UI 重新渲染
3. 相关视图组件更新显示
4. 动画效果平滑过渡

**示例**:

```swift
// 休息时间变化时
@Published var timeLeft: Int = 0
// 自动触发
CompactRestTimerView重新渲染
// 显示新的倒计时
```

---

## 总结

Workout 界面采用了现代 SwiftUI 开发模式，具有以下特点：

**设计优势**:

- 简洁直观的用户界面
- 流畅的动画过渡效果
- 模块化的组件架构
- 完善的状态管理

**技术特色**:

- 响应式数据绑定
- 类型安全的状态管理
- 完善的错误处理机制
- 优雅的资源管理

**用户体验**:

- 清晰的训练引导
- 实时的进度反馈
- 便捷的参数记录
- 灵活的训练控制

该界面为用户提供了完整的训练执行体验，从开始训练到完成记录的整个流程都经过精心设计，确保用户能够专注于训练本身而不被复杂的操作分散注意力。

---

**文档维护**: 随代码更新同步维护
**联系方式**: 如有疑问请联系开发团队

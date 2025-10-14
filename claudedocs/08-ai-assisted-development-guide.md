# AI辅助开发指南
//created by Jason Lu on 14:30:00 10/14/2025

## 🤖 AI助手项目协作指南

本指南为AI助手提供Fit项目的开发协作规范，确保AI能够高效、安全地协助项目开发和维护。

---

## 🎯 项目理解核心

### 项目定位
- **iOS SwiftUI健身训练应用**
- **MVVM架构 + 响应式状态管理**
- **数据持久化 + 训练日志记录**
- **开发阶段**: 基础功能已完成，进入优化和维护阶段

### 核心设计哲学
1. **简单优先**: 避免过度工程化，保持代码简洁
2. **快速迭代**: 小步快跑，快速测试，快速修复
3. **状态驱动**: 所有UI变化通过状态管理驱动
4. **数据一致性**: 确保训练数据的完整性和准确性

---

## 🏗️ 架构理解指南

### 系统架构层次
```
Views (UI层)
    ↓ @Published bindings
ViewModels (业务逻辑层)
    ↓ Direct method calls
Models (数据层)
    ↓ Service calls
Services (文件系统层)
```

### 关键组件职责

#### NavigationManager (待重构)
```swift
// 当前状态: 职责过载，需要拆分
// AI注意: 新功能开发应避免在此添加更多职责
// 未来计划: 拆分为NavigationManager + DialogManager + WorkoutSessionManager

class NavigationManager: ObservableObject {
    // 导航职责 (保留)
    @Published var currentScreen: AppScreen = .main
    @Published var navigationStack: [AppScreen] = []

    // 对话框职责 (即将移出)
    @Published var presentedDialog: DialogType?

    // 训练职责 (即将移出)
    @Published var currentWorkoutViewModel: WorkoutViewModel?
}
```

#### WorkoutViewModel (核心业务逻辑)
```swift
// AI注意: 这是训练流程的核心控制器
// 重要: 状态变更必须通过@Published触发UI更新
// 注意: 避免直接修改内部状态，使用提供的方法

class WorkoutViewModel: ObservableObject {
    // 训练状态 - AI操作时注意状态一致性
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var isExerciseActive: Bool = false
    @Published var isResting: Bool = false

    // 关键方法 - AI应使用这些方法而不是直接操作状态
    func startExercise()
    func completeExerciseWith(actualReps: Int, actualWeight: Double, notes: String)
    func skipCurrentExercise()
    func startRestTimer()
}
```

#### WorkoutLogRecorder (数据持久化)
```swift
// AI注意: 最近修复了exercise name override和set ordering问题
// 重要: 训练数据的准确性依赖此组件
// 警告: 修改此代码前必须充分测试数据一致性

class WorkoutLogRecorder {
    // 关键方法 - AI调用时注意参数正确性
    func startWorkout(workoutPlan: WorkoutPlan)
    func startExercise(exercise: Exercise)  // 注意: 会重置set order
    func recordCompletedSet(exerciseSet: ExerciseSet, actualReps: Int, actualWeight: Double, notes: String)
    func recordSkippedSet(exerciseSet: ExerciseSet)
}
```

---

## 🔧 AI开发协作规范

### 代码修改原则

#### ✅ 推荐做法
```swift
// 1. 使用现有模式和方法
workoutViewModel.completeExerciseWith(actualReps: 12, actualWeight: 20.0, notes: "感觉轻松")

// 2. 遵循MVVM数据流
// View → ViewModel → Model → Service

// 3. 使用响应式状态管理
@Published var someState: Bool = false
// UI自动响应状态变化

// 4. 利用现有的工具类和扩展
String(format: "%.1f", weight)  // 使用现有格式化方法
```

#### ❌ 避免做法
```swift
// 1. 避免直接操作ViewModel内部状态
workoutViewModel.currentExerciseIndex = 5  // 错误
workoutViewModel.goToExercise(index: 5)    // 正确

// 2. 避免绕过现有的验证逻辑
// 不要直接修改WorkoutLogRecorder的内部状态

// 3. 避免创建重复的UI组件
// 使用现有的对话框系统，不要创建新的Dialog

// 4. 避免添加新的全局状态
// 尽量使用现有的状态管理系统
```

### 新功能开发指南

#### 功能开发前检查清单
- [ ] 是否真的需要这个功能？
- [ ] 能否复用现有组件？
- [ ] 是否遵循MVVM架构？
- [ ] 是否影响现有数据一致性？

#### 开发步骤规范
1. **理解需求**: 明确功能边界和用户价值
2. **架构设计**: 确定在哪个层级添加逻辑
3. **状态管理**: 设计状态变化和UI响应
4. **数据流**: 确保数据在正确层次流动
5. **测试验证**: 功能测试 + 数据一致性验证

#### 示例: 添加新的训练统计功能
```swift
// Step 1: 在ViewModel中添加状态
@Published var workoutStats: WorkoutStats = WorkoutStats()

// Step 2: 在适当的方法中更新状态
func completeExerciseWith(actualReps: Int, actualWeight: Double, notes: String) {
    // 现有逻辑...

    // 更新统计信息
    workoutStats.addCompletedSet(reps: actualReps, weight: actualWeight)
}

// Step 3: 在View中展示统计信息
VStack {
    Text("已完成组数: \(workoutViewModel.workoutStats.completedSets)")
    Text("总重量: \(workoutViewModel.workoutStats.totalWeight, specifier: "%.1f") kg")
}
```

---

## 🚨 常见陷阱和规避策略

### 数据一致性陷阱
```swift
// ❌ 错误: 可能导致数据不一致
func skipExercise() {
    currentExerciseIndex += 1  // 直接操作状态
    // 忘记同步其他相关状态
}

// ✅ 正确: 使用现有方法确保一致性
func skipCurrentExercise() {
    // 使用ViewModel提供的方法
    // 会自动处理所有相关状态更新
    workoutViewModel.skipCurrentExercise()
}
```

### UI状态同步陷阱
```swift
// ❌ 错误: 状态更新后UI不同步
@Published var isResting: Bool = false

func startRest() {
    timeLeft = restTime  // @Published但UI可能不更新
    isResting = true    // @Published但顺序可能有问题
}

// ✅ 正确: 确保状态更新的原子性
func startRestTimer() {
    isResting = true
    timeLeft = currentExerciseSet.restTime
    startTimer()  // 确保所有状态一起更新
}
```

### 内存管理陷阱
```swift
// ❌ 错误: 可能导致循环引用
class SomeClass {
    var navigationManager: NavigationManager?
    var workoutViewModel: WorkoutViewModel?

    init() {
        // 可能的循环引用
        navigationManager?.currentWorkoutViewModel = workoutViewModel
    }
}

// ✅ 正确: 使用weak引用避免循环引用
class SomeClass {
    weak var navigationManager: NavigationManager?
    weak var workoutViewModel: WorkoutViewModel?
}
```

---

## 🔍 代码审查检查点

### AI代码提交前检查清单

#### 架构一致性
- [ ] 是否遵循MVVM架构？
- [ ] 状态是否通过@Published正确发布？
- [ ] 数据流是否单向且可预测？

#### 代码质量
- [ ] 是否复用现有组件而非重复开发？
- [ ] 方法命名是否清晰且一致？
- [ ] 是否有硬编码的魔法数字或字符串？

#### 功能完整性
- [ ] 新功能是否与现有功能协调？
- [ ] 是否处理了边界情况和错误状态？
- [ ] 数据持久化是否正确？

#### 性能影响
- [ ] 是否引入不必要的计算？
- [ ] UI响应是否保持流畅？
- [ ] 内存使用是否合理？

### 常见问题识别

#### 过度设计识别
```swift
// ❌ 警示信号: 过度抽象
protocol ExercisePerformer {
    func perform(exercise: Exercise)
}

class AdvancedExercisePerformer: ExercisePerformer {
    // 复杂实现但实际不需要
}

// ✅ 更简单: 直接使用现有方法
workoutViewModel.completeExerciseWith(actualReps: reps, actualWeight: weight)
```

#### 重复代码识别
```swift
// ❌ 警示信号: 相似的UI结构
struct DialogA {
    var body: some View {
        VStack {
            // 50行相似的布局代码
        }
        .background(RoundedRectangle(cornerRadius: 20))
        .shadow(...)
    }
}

struct DialogB {
    var body: some View {
        VStack {
            // 50行相似的布局代码
        }
        .background(RoundedRectangle(cornerRadius: 20))
        .shadow(...)
    }
}

// ✅ 更好: 使用通用组件
struct BaseDialog<Content: View>: View {
    // 统一的对话框实现
}
```

---

## 📚 项目特定知识

### 训练流程核心逻辑
```swift
// AI必须理解的核心训练流程
1. startWorkout(plan) → 创建PrebuiltWorkoutSession
2. startExercise(exercise) → 开始计时，记录开始时间
3. completeExerciseWith() → 记录完成数据，更新进度
4. startRestTimer() → 开始组间休息计时
5. finishWorkoutAndSaveLog() → 保存完整训练日志
```

### 数据持久化机制
```swift
// 关键文件和格式
1. WorkoutLogRecorder → JSON格式训练日志
2. 文件位置: Documents/训练日志_YYYY-MM-dd_HH-mm.json
3. 数据结构: WorkoutLog → WorkoutLogEntry[]
4. 文件管理: EnhancedWorkoutLogFileManager
```

### 已知问题和解决方案
```swift
// 1. Exercise name override bug (已修复)
// 问题: 跳过的练习被记录为当前练习名称
// 解决: 在recordSkippedSet中使用正确的exercise名称

// 2. Set ordering chaos (已修复)
// 问题: set order在练习间不正确递增
// 解决: 在startExercise中重置currentExerciseSetOrder

// 3. NavigationManager职责过载 (标记待修复)
// 问题: 单个类承担过多职责
// 解决: 计划拆分为多个专门的管理器
```

---

## 🛠️ AI工具使用指南

### 推荐的AI操作模式

#### 代码分析模式
```bash
# AI应该使用这些工具进行代码分析
/sc:analyze --focus architecture  # 架构分析
/sc:analyze --focus quality       # 代码质量分析
/sc:index                         # 生成项目知识库
```

#### 开发协助模式
```bash
# 功能开发时的推荐命令
/sc:implement --with-tests        # 带测试的实现
/sc:improve --safe                # 安全的代码改进
/sc:cleanup --interactive         # 交互式代码清理
```

#### 问题诊断模式
```bash
# 出现问题时的诊断流程
/sc:troubleshoot --type bug       # Bug诊断
/sc:analyze --focus performance   # 性能问题分析
/sc:research                      # 查找最佳实践
```

### AI响应格式规范

#### 代码建议格式
```swift
// 🎯 建议: [简短描述]
// 原因: [为什么这样更好]
// 影响: [对现有代码的影响]

// 示例代码
func improvedMethod() {
    // 具体实现
}
```

#### 问题分析格式
```swift
// 🔍 问题: [问题描述]
// 根本原因: [问题根源]
// 解决方案: [具体解决步骤]
// 预防措施: [如何避免再次发生]
```

#### 架构建议格式
```swift
// 🏗️ 架构建议: [建议内容]
// 现状: [当前架构状况]
// 改进: [具体改进方案]
// 权衡: [利弊分析]
```

---

## 📞 协作沟通指南

### AI主动沟通场景

#### 需要人工确认的场景
1. **架构重大变更**: 可能影响现有功能
2. **数据格式修改**: 可能破坏向后兼容性
3. **性能权衡**: 需要在速度和内存间选择
4. **用户体验变更**: 可能改变用户习惯

#### 提供选项的场景
```swift
// AI应该这样提供选择
"我发现有两种实现方式：
1. 方案A: 更简单但扩展性较差 (推荐)
2. 方案B: 更复杂但更灵活

您希望我实现哪种方案？"
```

#### 风险提示的场景
```swift
// AI应该这样提示风险
"⚠️ 注意: 这个修改可能影响以下功能：
- 训练数据导出
- 历史记录查看
- 建议先备份现有数据

是否继续？"
```

### 学习和改进机制

#### AI自我评估清单
- [ ] 我是否理解了项目的核心架构？
- [ ] 我的建议是否符合项目的设计哲学？
- [ ] 我是否避免了过度设计的陷阱？
- [ ] 我是否考虑了数据一致性问题？

#### 持续改进要点
1. **从错误中学习**: 记录常见的错误模式
2. **项目理解深化**: 随着项目演进更新理解
3. **最佳实践积累**: 总结有效的开发模式
4. **沟通效率提升**: 改进与人类的协作方式

---

## 🎯 成功协作指标

### 代码质量指标
- **零编译错误**: AI生成的代码必须编译通过
- **功能正确性**: 新功能必须按预期工作
- **数据一致性**: 不能破坏训练数据的完整性
- **性能保持**: 不能降低现有功能的性能

### 开发效率指标
- **理解准确度**: AI正确理解项目需求的程度
- **建议质量**: AI提供的代码建议的质量
- **问题解决速度**: AI识别和解决问题的速度
- **学习能力**: AI从反馈中学习和改进的能力

### 协作满意度指标
- **沟通清晰度**: AI表达是否清晰易懂
- **风险意识**: AI是否能识别和提示风险
- **主动性**: AI是否能主动发现改进机会
- **可靠性**: AI的工作成果是否可信赖

---

**指南制定时间**: 2025-10-14 14:30:00
**适用版本**: Fit v1.3+
**更新频率**: 随项目演进定期更新
**维护责任**: 项目维护者 + AI助手共同维护
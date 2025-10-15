# Bug修复实施计划

//created by Jason Lu on 10:45:00 10/15/2025

## 问题描述
在动作的最后一组时，"下一组"显示错误信息（显示当前动作的数据而不是下一个动作）。

## 根本原因
1. `nextSetInfo`计算逻辑中使用了不一致的数据源
2. 状态更新时序问题导致数据不同步
3. 计算属性依赖的状态在UI刷新时已过期

## 修复方案

### 方案1：改进nextSetInfo计算逻辑（推荐）

#### 当前问题代码
```swift
private var nextSetInfo: String? {
    let allExercises = workoutViewModel.workoutPlan.exercises
    let currentExerciseIndex = allExercises.firstIndex(where: { $0.exercise.name == exercise.name }) ?? 0

    // 问题：使用exercise.name匹配，可能在状态更新后得到错误的索引
    if currentSet < totalSets {
        if currentSet < allExerciseSets.count {
            let nextSet = allExerciseSets[currentSet] // 可能使用过时的索引
        }
    }
}
```

#### 修复后代码
```swift
private var nextSetInfo: String? {
    // 使用ViewModel的当前状态，确保数据一致性
    let currentExerciseIndex = workoutViewModel.currentExerciseIndex
    let currentSet = workoutViewModel.currentSet
    let allExercises = workoutViewModel.workoutPlan.exercises

    // 确保索引有效
    guard currentExerciseIndex < allExercises.count else {
        return nil
    }

    let currentExercise = allExercises[currentExerciseIndex].exercise
    let exerciseSets = allExercises.filter { $0.exercise.id == currentExercise.id }

    // 检查是否还有下一组
    if currentSet < exerciseSets.count {
        let nextSetIndexInExerciseSets = currentSet // currentSet已经是1-based
        guard nextSetIndexInExerciseSets < exerciseSets.count else {
            return nil
        }

        let nextSet = exerciseSets[nextSetIndexInExerciseSets]
        let weightText = formatWeight(nextSet.targetWeight)
        return "下一组: \(currentExercise.name) \(nextSet.targetReps)次 * \(weightText)公斤"
    }

    // 检查是否还有下一个练习
    if currentExerciseIndex < allExercises.count - 1 {
        let nextExerciseSet = allExercises[currentExerciseIndex + 1]
        let nextExercise = nextExerciseSet.exercise
        let weightText = formatWeight(nextExerciseSet.targetWeight)
        return "下一组: \(nextExercise.name) \(nextExerciseSet.targetReps)次 * \(weightText)公斤"
    }

    return nil
}
```

### 方案2：修复状态更新时序

#### 问题代码位置
```swift
// WorkoutViewModel.startRest()
func startRest() {
    DispatchQueue.main.async {
        self.isResting = true
        self.isExerciseActive = false
        self.timeLeft = self.currentExerciseSet.restTime

        // 问题：状态更新不原子，可能导致UI显示不一致
        self.moveToNextExerciseOrSet()
        self.startRestTimer()
    }
}
```

#### 修复方案
```swift
func startRest() {
    // 确保在主线程上进行原子性状态更新
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        // 保存当前状态用于计算
        let shouldMoveToNext = self.currentExerciseIndex < self.workoutPlan.exercises.count - 1

        // 原子性更新所有相关状态
        self.isResting = true
        self.isExerciseActive = false
        self.timeLeft = self.currentExerciseSet.restTime

        // 只有在需要时才移动到下一个练习
        if shouldMoveToNext {
            self.moveToNextExerciseOrSet()
        }

        // 启动休息计时器
        self.startRestTimer()
    }
}

// 改进moveToNextExerciseOrSet方法
private func moveToNextExerciseOrSet() {
    // 确保在主线程上执行
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        if self.currentExerciseIndex < self.workoutPlan.exercises.count - 1 {
            // 更新索引
            self.currentExerciseIndex += 1

            // 立即更新组数显示
            self.updateCurrentSetDisplay()

            // 强制触发UI更新
            self.objectWillChange.send()
        }
    }
}
```

### 方案3：添加状态同步机制

#### 新增状态同步方法
```swift
// 在WorkoutViewModel中添加
private func syncStateAndNotifyUI() {
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        // 确保所有状态都是最新的
        self.updateCurrentSetDisplay()

        // 强制触发UI更新
        self.objectWillChange.send()
    }
}
```

#### 在关键状态更新点调用
```swift
func completeExerciseWith(actualReps: Int, actualWeight: Double, notes: String = "") {
    // ... 现有逻辑 ...

    // 确保状态同步
    syncStateAndNotifyUI()
}
```

## 实施步骤

### 第一步：修复nextSetInfo计算逻辑
1. 修改`CompactExerciseInfoCard.swift`中的`nextSetInfo`计算属性
2. 使用ViewModel的当前状态而不是基于exercise.name的查找
3. 添加边界检查确保数组访问安全

### 第二步：修复状态更新时序
1. 修改`WorkoutViewModel.swift`中的`startRest()`方法
2. 确保状态更新的原子性
3. 在`moveToNextExerciseOrSet()`中添加UI更新通知

### 第三步：测试验证
1. 创建测试用例验证修复效果
2. 测试各种场景：最后一组、中间组、单个练习等
3. 验证状态转换的正确性

## 测试用例

### 测试场景1：最后一组
```swift
func testLastSetNextSetInfo() {
    let workoutPlan = createWorkoutPlanWithExercises([
        ("Push-ups", 3),
        ("Squats", 2)
    ])

    let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)
    viewModel.currentExerciseIndex = 0  // Push-ups
    viewModel.currentSet = 3            // 最后一组

    let infoCard = CompactExerciseInfoCard(
        exercise: viewModel.currentExercise,
        currentSet: viewModel.currentSet,
        totalSets: viewModel.getCurrentExerciseTotalSets(),
        targetReps: viewModel.currentExerciseSet.targetReps,
        targetWeight: viewModel.currentExerciseSet.targetWeight,
        elapsedTime: viewModel.exerciseElapsedTime
    )

    let nextSetInfo = infoCard.nextSetInfo
    XCTAssertEqual(nextSetInfo, "下一组: Squats 15次 * 0公斤")
}
```

### 测试场景2：中间组
```swift
func testMiddleSetNextSetInfo() {
    let workoutPlan = createWorkoutPlanWithExercises([
        ("Push-ups", 3)
    ])

    let viewModel = WorkoutViewModel(workoutPlan: workoutPlan)
    viewModel.currentExerciseIndex = 0
    viewModel.currentSet = 2

    let infoCard = CompactExerciseInfoCard(
        exercise: viewModel.currentExercise,
        currentSet: viewModel.currentSet,
        totalSets: viewModel.getCurrentExerciseTotalSets(),
        targetReps: viewModel.currentExerciseSet.targetReps,
        targetWeight: viewModel.currentExerciseSet.targetWeight,
        elapsedTime: viewModel.exerciseElapsedTime
    )

    let nextSetInfo = infoCard.nextSetInfo
    XCTAssertEqual(nextSetInfo, "下一组: Push-ups 8次 * 0公斤")
}
```

## 预期结果

修复后，"下一组"显示应该：
1. 在非最后一组时，显示同一练习的下一组信息
2. 在最后一组时，显示下一个练习的第一组信息
3. 在整个训练的最后一组时，不显示"下一组"信息
4. 状态转换过程中不出现闪烁或错误信息

## 风险评估

### 低风险
- 修改计算逻辑不会影响现有功能
- 添加边界检查提高代码健壮性
- 保持向后兼容性

### 中等风险
- 状态更新时序修改可能影响其他功能
- 需要全面测试各种场景

### 缓解措施
- 分阶段实施，先修复计算逻辑
- 充分测试后再修改状态更新时序
- 保留原有代码作为回退方案

## 长期改进建议

1. **引入状态机模式**：解决复杂状态管理问题
2. **单元测试覆盖**：确保状态转换的正确性
3. **性能优化**：减少不必要的UI更新
4. **错误处理**：添加异常情况的处理逻辑
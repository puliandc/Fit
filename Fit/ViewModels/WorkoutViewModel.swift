//
//  WorkoutViewModel.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated by Jason Lu on 10/14/2025 - 清理调试代码和过度设计的复杂逻辑
//  Updated by Jason Lu on 10/28/2025 - 状态管理优化：引入防抖机制减少UI重渲染，解决频繁状态更新导致的性能问题
//

import SwiftUI
import Combine
import QuartzCore

// MARK: - Workout Completion Notification
extension Notification.Name {
    static let workoutCompleted = Notification.Name("workoutCompleted")
}

class WorkoutViewModel: ObservableObject {
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var exerciseElapsedTime: Int = 0
    @Published var isExerciseActive: Bool = false
    @Published var isResting: Bool = false
    @Published var timeLeft: Int = 0
    @Published var completedSets: [CompletedSet] = []

    let workoutPlan: WorkoutPlan
    private var unifiedDisplayLink: CADisplayLink?
    private var lastUpdateTime: CFTimeInterval = 0

    // 简化计时方案：只记录开始时间
    private var workoutStartTime: Date?

    // TTS相关状态
    private var hasAnnounced15Seconds = false
    private var hasAnnounced3Seconds = false

    // 状态管理优化：防抖机制
    private var uiUpdateWorkItem: DispatchWorkItem?
    private var lastUIUpdateTime: CFTimeInterval = 0
    private let uiUpdateDebounceInterval: CFTimeInterval = 0.1 // 100ms防抖

    // 计算优化：缓存常用计算结果
    private var _totalExerciseSets: Int = 0
    private var _completedSetsCount: Int = 0
    private var _exerciseGroupsCache: [UUID: [ExerciseSet]] = [:]
    private var _lastExerciseId: UUID = UUID()
    private var _needsRecalculation: Bool = true

    // DEPRECATED: 简化数据结构，不再使用复杂的预建立系统
    // 直接使用workoutPlan和completedSets来跟踪进度

    // MARK: - Training Log Integration
    private let workoutLogRecorder = WorkoutLogRecorder()

    init(workoutPlan: WorkoutPlan) {
        self.workoutPlan = workoutPlan

        // 初始化计算缓存
        initializeCaches()

        // 初始化当前组数显示
        updateCurrentSetDisplay()

        // 初始化训练日志记录器
        workoutLogRecorder.startWorkout(workoutPlan: workoutPlan)
    }

    // MARK: - Computed Properties
    var currentExercise: Exercise {
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            if let firstExercise = workoutPlan.exercises.first {
                return firstExercise.exercise
            } else {
                // 创建一个安全的默认练习
                return Exercise(name: "默认练习")
            }
        }
        return workoutPlan.exercises[currentExerciseIndex].exercise
    }

    var currentExerciseSet: ExerciseSet {
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            if let firstExercise = workoutPlan.exercises.first {
                return firstExercise
            } else {
                // 创建一个安全的默认练习组
                let defaultExercise = Exercise(name: "默认练习")
                return ExerciseSet(
                    exercise: defaultExercise,
                    targetReps: 1,
                    targetWeight: 0,
                    restTime: 60
                )
            }
        }
        return workoutPlan.exercises[currentExerciseIndex]
    }

    var progress: Double {
        // 使用缓存的计算结果：已完成组数/总组数
        if _needsRecalculation {
            updateCachesIfNeeded()
        }

        let progressValue = _totalExerciseSets > 0 ? Double(_completedSetsCount) / Double(_totalExerciseSets) : 0.0

        // 防止进度超过100%
        let clampedProgress = min(progressValue, 1.0)
        return clampedProgress
    }

    
    var isWorkoutComplete: Bool {
        return currentExerciseIndex >= workoutPlan.exercises.count
    }

    // 简化计时方案：实时计算训练总时长
    var totalWorkoutTime: Int {
        guard let startTime = workoutStartTime else { return 0 }
        return Int(Date().timeIntervalSince(startTime))
    }

    // MARK: - Exercise Management
    func startExercise() {
        // 安全检查
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            return
        }

        // 简化计时方案：记录训练开始时间（仅在第一次开始时）
        if workoutStartTime == nil {
            workoutStartTime = Date()
        }

        exerciseElapsedTime = 0
        isExerciseActive = true
        isResting = false

        // 开始记录当前动作
        workoutLogRecorder.startExercise(exercise: currentExercise)

        // 启动统一计时器
        startUnifiedTimer()
    }

    func pauseExercise() {
        isExerciseActive = false
        stopUnifiedTimer()
    }

    func toggleExercise() {
        if isExerciseActive {
            pauseExercise()
        } else {
            startExercise()
        }
    }

    func completeExercise() {
        pauseExercise()

        // 触发参数编辑对话框，而不是直接完成
        // 这将通过WorkoutScreen中的NavigationManager来处理
    }

    // 新增：完成指定参数的练习
    func completeExerciseWith(actualReps: Int, actualWeight: Double, notes: String = "") {
        pauseExercise()

        // 记录训练日志
        workoutLogRecorder.recordCompletedSet(
            exerciseSet: currentExerciseSet,
            actualReps: actualReps,
            actualWeight: actualWeight,
            notes: notes
        )

        // Record completed set with user-specified parameters (保持向后兼容)
        let completedSet = CompletedSet(
            exerciseSetId: currentExerciseSet.id,
            actualReps: actualReps,
            actualWeight: actualWeight,
            completedAt: Date()
        )
        completedSets.append(completedSet)

        // 更新当前组数显示
        updateCurrentSetDisplay()

        // 更新进度 - 使用防抖机制触发UI刷新
        debouncedUIUpdate()

        // 检查是否还有更多的组需要完成 - 使用缓存值
        if _needsRecalculation {
            updateCachesIfNeeded()
        }
        let remainingSetsInWorkout = _totalExerciseSets - _completedSetsCount

        if remainingSetsInWorkout > 0 {
            // 进入休息状态，然后继续下一组/下一个动作
            startRest()
        } else {
            // 训练完成
            pauseExercise()

            // 确保进度更新能触发UI刷新 - 使用立即更新机制处理关键状态变化
            DispatchQueue.main.async {
                self.immediateUIUpdate()
                // 发送训练完成通知
                NotificationCenter.default.post(name: .workoutCompleted, object: self)
            }
        }
    }

  
    // 获取当前练习的默认次数和重量
    func getDefaultParametersForCurrentExercise() -> (reps: Int, weight: Double) {
        let targetReps = currentExerciseSet.targetReps
        let targetWeight = currentExerciseSet.targetWeight
        return (targetReps, targetWeight)
    }

    // 获取当前练习的总组数 - 使用缓存
    func getCurrentExerciseTotalSets() -> Int {
        let currentExerciseId = currentExercise.id

        // 如果缓存需要更新或者练习ID改变，重新计算
        if _needsRecalculation || _lastExerciseId != currentExerciseId {
            updateCachesIfNeeded()
        }

        return _exerciseGroupsCache[currentExerciseId]?.count ?? 0
    }

    
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

            // 启动统一计时器
            self.startUnifiedTimer()
        }
    }

    // 新增：移动到下一个练习或组
    private func moveToNextExerciseOrSet() {
        // 确保在主线程上执行
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.currentExerciseIndex < self.workoutPlan.exercises.count - 1 {
                // 更新索引
                self.currentExerciseIndex += 1

                // 立即更新组数显示
                self.updateCurrentSetDisplay()

                // 使用防抖机制触发UI更新
                self.debouncedUIUpdate()
            }
        }
    }

    // 新增：更新当前组数显示 - 使用缓存优化
    private func updateCurrentSetDisplay() {
        // 安全检查：确保索引有效
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            return
        }

        let currentExerciseId = currentExercise.id

        // 如果缓存需要更新，重新计算分组
        if _needsRecalculation || _lastExerciseId != currentExerciseId {
            updateCachesIfNeeded()
        }

        // 从缓存中获取当前练习的所有组
        guard let exerciseSetsForThisExercise = _exerciseGroupsCache[currentExerciseId] else {
            currentSet = 1
            return
        }

        // 计算当前是第几组（基于当前ExerciseSet在所有相同练习中的位置）
        let currentExerciseSet = currentExerciseSet
        let currentSetNumber = exerciseSetsForThisExercise.firstIndex(where: { $0.id == currentExerciseSet.id }) ?? 0

        // 更新当前组数（从1开始计数）
        currentSet = currentSetNumber + 1
    }

    // 新增：跳过当前动作的所有组，移动到下一个不同的动作
    func skipCurrentExerciseCompletely() {
        // 暂停当前练习
        pauseExercise()

        // 获取当前练习的ID
        let currentExerciseId = currentExercise.id

        // 获取当前组在相同练习中的位置，只跳过当前组及之后的组 - 使用缓存
        if _needsRecalculation || _lastExerciseId != currentExerciseId {
            updateCachesIfNeeded()
        }
        let currentExerciseSets = _exerciseGroupsCache[currentExerciseId] ?? []
        let currentSetPosition = currentExerciseSets.firstIndex(where: { $0.id == currentExerciseSet.id }) ?? 0

        // 记录跳过的动作到日志（只记录当前组及之后的组）
        for i in currentSetPosition..<currentExerciseSets.count {
            let exerciseSetToSkip = currentExerciseSets[i]
            workoutLogRecorder.recordSkippedSet(exerciseSet: exerciseSetToSkip)

            let skippedSet = CompletedSet(
                exerciseSetId: exerciseSetToSkip.id,
                actualReps: 0,  // 跳过的组记为0次
                actualWeight: 0,  // 跳过的组记为0重量
                completedAt: Date()
            )
            completedSets.append(skippedSet)
        }

        // 更新当前组数显示
        updateCurrentSetDisplay()

        // 更新进度 - 使用防抖机制触发UI刷新
        debouncedUIUpdate()

        // 找到下一个不同练习的索引
        var nextExerciseIndex = currentExerciseIndex + 1
        while nextExerciseIndex < workoutPlan.exercises.count {
            let nextExercise = workoutPlan.exercises[nextExerciseIndex].exercise
            if nextExercise.id != currentExerciseId {
                break
            }
            nextExerciseIndex += 1
        }

        if nextExerciseIndex < workoutPlan.exercises.count {
            // 移动到下一个不同的练习
            currentExerciseIndex = nextExerciseIndex
            exerciseElapsedTime = 0

            // 确保在主线程上更新UI状态
            DispatchQueue.main.async {
                // 使用防抖机制发送UI更新通知
                self.debouncedUIUpdate()

                // 立即更新组数显示，确保数据正确
                self.updateCurrentSetDisplay()

                // 修复：延迟自动开始新练习，确保UI完全更新
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.startExercise()
                }
            }
        } else {
            // 没有更多不同练习，完成训练
            DispatchQueue.main.async {
                self.pauseExercise()
            }
        }
    }

    // 新增：公共方法用于跳过当前练习（保持向后兼容）
    func moveToNextExercise() {
        // 暂停当前练习
        pauseExercise()

        // 移动到下一个练习
        if currentExerciseIndex < workoutPlan.exercises.count - 1 {
            currentExerciseIndex += 1
            exerciseElapsedTime = 0 // 重置时间

            // 更新组数显示（这会重置为新练习的组数）
            updateCurrentSetDisplay()

            // 自动开始新练习
            startExercise()
        } else {
            // 如果没有更多练习，完成训练
            DispatchQueue.main.async {
                self.pauseExercise()
            }
        }
    }

    func skipRest() {
        stopUnifiedTimer()
        isResting = false
        startExercise()
    }

    // 新增：跳过所有剩余练习，完成训练
    func skipAllRemainingExercises() {
        // 暂停当前练习
        pauseExercise()

        // 为当前及所有剩余的练习组添加跳过记录 - 使用缓存值
        if _needsRecalculation {
            updateCachesIfNeeded()
        }
        let currentExerciseSet = currentExerciseSet

        // 找到当前ExerciseSet在计划中的位置
        if let currentPosition = workoutPlan.exercises.firstIndex(where: { $0.id == currentExerciseSet.id }) {
            var lastExerciseName: String = ""

            // 从当前位置开始，为所有剩余的练习组添加跳过记录
            for i in currentPosition..<_totalExerciseSets {
                let exerciseSetToSkip = workoutPlan.exercises[i]
                let exerciseName = exerciseSetToSkip.exercise.name

                // 修复：检查是否是新的动作，如果是则通知WorkoutLogRecorder更新动作名称
                if exerciseName != lastExerciseName {
                    // 创建一个临时的Exercise对象来传递给startExercise
                    let tempExercise = exerciseSetToSkip.exercise
                    workoutLogRecorder.startExercise(exercise: tempExercise)
                    lastExerciseName = exerciseName
                }

                // 记录跳过的练习到训练日志
                workoutLogRecorder.recordSkippedSet(exerciseSet: exerciseSetToSkip)

                let skippedSet = CompletedSet(
                    exerciseSetId: exerciseSetToSkip.id,
                    actualReps: 0,  // 跳过的组记为0次
                    actualWeight: 0,  // 跳过的组记为0重量
                    completedAt: Date()
                )
                completedSets.append(skippedSet)
            }
        }

        // 更新进度 - 使用防抖机制触发UI刷新
        debouncedUIUpdate()

        // 检查是否所有练习都已跳过（训练完成） - 使用缓存值
        if _needsRecalculation {
            updateCachesIfNeeded()
        }
        if _completedSetsCount == _totalExerciseSets {
            DispatchQueue.main.async {
                // 发送训练完成通知
                NotificationCenter.default.post(name: .workoutCompleted, object: self)
            }
        }
    }

    // 简化计时方案：处理应用恢复时的计时同步
    func resetTimerIfNeeded() {
        guard let startTime = workoutStartTime else { return }

        // 计算应该经过的时间
        let elapsedTime = Int(Date().timeIntervalSince(startTime))

        // 更新动作计时器显示
        if isExerciseActive {
            exerciseElapsedTime = elapsedTime
        }
    }

    // MARK: - Timer Management
    private func startUnifiedTimer() {
        // 停止之前的计时器
        stopUnifiedTimer()

        // 初始化时间戳
        lastUpdateTime = CACurrentMediaTime()

        // 创建CADisplayLink，设置为每秒更新1次
        unifiedDisplayLink = CADisplayLink(target: self, selector: #selector(updateAllTimers))
        unifiedDisplayLink?.preferredFramesPerSecond = 1

        // 添加到RunLoop
        unifiedDisplayLink?.add(to: .main, forMode: .common)
    }

    private func stopUnifiedTimer() {
        unifiedDisplayLink?.invalidate()
        unifiedDisplayLink = nil
    }

    @objc private func updateAllTimers() {
        let currentTime = CACurrentMediaTime()

        // 防抖机制：确保真正间隔1秒才更新
        guard currentTime - lastUpdateTime >= 1.0 else { return }

        lastUpdateTime = currentTime

        // 批量更新所有时间相关状态，减少UI刷新次数
        var needsUIUpdate = false

        // 更新动作计时
        if isExerciseActive {
            exerciseElapsedTime += 1
            needsUIUpdate = true
        }

        // 更新休息倒计时
        if isResting && timeLeft > 0 {
            timeLeft -= 1

            // 语音播报逻辑
            if timeLeft == 15 && !hasAnnounced15Seconds {
                hasAnnounced15Seconds = true
                VoiceManager.shared.announceRestCountdown(seconds: 15)
            }

            if timeLeft == 3 && !hasAnnounced3Seconds {
                hasAnnounced3Seconds = true
                VoiceManager.shared.announceRestComplete()
            }

            // 休息结束，自动开始下一个动作
            if timeLeft == 0 {
                isResting = false
                // 延迟一帧开始下一个动作，确保状态更新完成
                DispatchQueue.main.async {
                    self.startExercise()
                }
            }

            needsUIUpdate = true
        }

        // 只在需要时触发UI更新 - 使用防抖机制减少重渲染
        if needsUIUpdate {
            debouncedUIUpdate()
        }
    }

    
    // MARK: - TTS Integration

    /// 获取下一组动作信息用于TTS播报
    /// - Returns: 下一组的动作信息，如果没有下一组则返回nil
    func getNextExerciseInfo() -> (exerciseName: String, weight: Double, reps: Int)? {
        let currentExerciseIndex = self.currentExerciseIndex
        let allExercises = workoutPlan.exercises

        // 确保索引有效
        guard currentExerciseIndex < allExercises.count else {
            return nil
        }

        let currentExercise = allExercises[currentExerciseIndex].exercise
        let exerciseSets = allExercises.filter { $0.exercise.id == currentExercise.id }

        // 找到当前ExerciseSet在相同练习中的位置
        guard let currentPositionInExercise = exerciseSets.firstIndex(where: { $0.id == allExercises[currentExerciseIndex].id }) else {
            return nil
        }

        // 检查是否还有下一组（相同练习）
        if currentPositionInExercise < exerciseSets.count - 1 {
            let nextSet = exerciseSets[currentPositionInExercise + 1]
            return (nextSet.exercise.name, nextSet.targetWeight, nextSet.targetReps)
        }

        // 检查是否还有下一个练习
        var nextIndex = currentExerciseIndex + 1
        while nextIndex < allExercises.count {
            let nextExerciseSet = allExercises[nextIndex]
            if nextExerciseSet.exercise.id != currentExercise.id {
                return (nextExerciseSet.exercise.name, nextExerciseSet.targetWeight, nextExerciseSet.targetReps)
            }
            nextIndex += 1
        }

        return nil
    }

    /// 播报下一组动作信息
    private func announceNextSetIfNeeded() {
        guard let nextExerciseInfo = getNextExerciseInfo() else {
            return
        }

        // 使用VoiceManager播报下一组信息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            VoiceManager.shared.announceNextSet(
                exerciseName: nextExerciseInfo.exerciseName,
                weight: nextExerciseInfo.weight,
                reps: nextExerciseInfo.reps
            )
        }
    }

  
    // MARK: - Training Log Integration
    // 添加训练完成方法
    func finishWorkoutAndSaveLog() -> Bool {
        pauseExercise()
        return workoutLogRecorder.finishWorkout(workoutPlan: workoutPlan)
    }

    // MARK: - State Management Optimization

    /// 防抖UI更新机制 - 减少不必要的重渲染
    private func debouncedUIUpdate() {
        // 取消之前的更新任务
        uiUpdateWorkItem?.cancel()

        // 创建新的更新任务
        uiUpdateWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            let currentTime = CACurrentMediaTime()
            // 确保距离上次更新已超过防抖间隔
            if currentTime - self.lastUIUpdateTime >= self.uiUpdateDebounceInterval {
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                self.lastUIUpdateTime = currentTime
            }
        }

        // 延迟执行防抖更新
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + uiUpdateDebounceInterval, execute: uiUpdateWorkItem!)
    }

    /// 立即UI更新机制 - 用于关键状态变化
    private func immediateUIUpdate() {
        // 取消任何待处理的防抖更新
        uiUpdateWorkItem?.cancel()

        let currentTime = CACurrentMediaTime()
        lastUIUpdateTime = currentTime

        // 立即触发UI更新
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.objectWillChange.send()
        }
    }

    /// 智能UI更新机制 - 根据状态变化频率自动选择更新策略
    private func smartUIUpdate(isCriticalStateChange: Bool = false) {
        if isCriticalStateChange {
            immediateUIUpdate()
        } else {
            debouncedUIUpdate()
        }
    }

    /// 初始化计算缓存
    private func initializeCaches() {
        _totalExerciseSets = workoutPlan.exercises.count
        _completedSetsCount = completedSets.count
        _needsRecalculation = true
        _exerciseGroupsCache.removeAll()
        updateCachesIfNeeded()
    }

    /// 更新缓存（仅在需要时）
    private func updateCachesIfNeeded() {
        guard _needsRecalculation else { return }

        // 更新基础计数缓存
        _totalExerciseSets = workoutPlan.exercises.count
        _completedSetsCount = completedSets.count

        // 更新练习分组缓存
        updateExerciseGroupsCache()

        // 标记缓存已更新
        _needsRecalculation = false
        _lastExerciseId = currentExercise.id
    }

    /// 更新练习分组缓存 - 按练习ID分组所有ExerciseSet
    private func updateExerciseGroupsCache() {
        _exerciseGroupsCache.removeAll()

        for exerciseSet in workoutPlan.exercises {
            let exerciseId = exerciseSet.exercise.id

            if _exerciseGroupsCache[exerciseId] == nil {
                _exerciseGroupsCache[exerciseId] = []
            }
            _exerciseGroupsCache[exerciseId]?.append(exerciseSet)
        }
    }

    /// 手动触发缓存失效
    private func invalidateCaches() {
        _needsRecalculation = true
    }

    // MARK: - Cleanup
    deinit {
        stopUnifiedTimer()
        uiUpdateWorkItem?.cancel()
    }
}

// MARK: - Preview Helper
extension WorkoutViewModel {
    static var preview: WorkoutViewModel {
        return WorkoutViewModel(workoutPlan: MockDataProvider.previewWorkout)
    }
}
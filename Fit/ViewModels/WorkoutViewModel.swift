//
//  WorkoutViewModel.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated by Jason Lu on 10/14/2025 - 清理调试代码和过度设计的复杂逻辑
//

import SwiftUI
import Combine

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
    private var exerciseTimer: Timer?
    private var restTimer: Timer?

    // 简化计时方案：只记录开始时间
    private var workoutStartTime: Date?

    // TTS相关状态
    private var hasAnnounced15Seconds = false
    private var hasAnnounced3Seconds = false

    // DEPRECATED: 简化数据结构，不再使用复杂的预建立系统
    // 直接使用workoutPlan和completedSets来跟踪进度

    // MARK: - Training Log Integration
    private let workoutLogRecorder = WorkoutLogRecorder()

    init(workoutPlan: WorkoutPlan) {
        self.workoutPlan = workoutPlan

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
        // 简化进度计算：已完成组数/总组数
        let totalSets = workoutPlan.exercises.count
        let completedSetsCount = completedSets.count
        let progressValue = totalSets > 0 ? Double(completedSetsCount) / Double(totalSets) : 0.0

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

        startExerciseTimer()
    }

    func pauseExercise() {
        isExerciseActive = false
        exerciseTimer?.invalidate()
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

        // 更新进度 - 触发UI刷新
        objectWillChange.send()

        // 检查是否还有更多的组需要完成
        let totalSets = workoutPlan.exercises.count
        let remainingSetsInWorkout = totalSets - completedSets.count

        if remainingSetsInWorkout > 0 {
            // 进入休息状态，然后继续下一组/下一个动作
            startRest()
        } else {
            // 训练完成
            pauseExercise()

            // 确保进度更新能触发UI刷新 - 主动发送对象变化通知
            DispatchQueue.main.async {
                self.objectWillChange.send()
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

    // 获取当前练习的总组数
    func getCurrentExerciseTotalSets() -> Int {
        let currentExerciseId = currentExercise.id
        return workoutPlan.exercises.filter { $0.exercise.id == currentExerciseId }.count
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

            // 启动休息计时器
            self.startRestTimer()
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

                // 强制触发UI更新
                self.objectWillChange.send()
            }
        }
    }

    // 新增：更新当前组数显示
    private func updateCurrentSetDisplay() {
        // 安全检查：确保索引有效
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            return
        }

        let currentExerciseId = currentExercise.id
        let exerciseSetsForThisExercise = workoutPlan.exercises.filter { $0.exercise.id == currentExerciseId }

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

        // 获取当前组在相同练习中的位置，只跳过当前组及之后的组
        let currentExerciseSets = workoutPlan.exercises.filter { $0.exercise.id == currentExerciseId }
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

        // 更新进度 - 触发UI刷新
        objectWillChange.send()

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
                // 发送UI更新通知
                self.objectWillChange.send()

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
        restTimer?.invalidate()
        isResting = false
        startExercise()
    }

    // 新增：跳过所有剩余练习，完成训练
    func skipAllRemainingExercises() {
        // 暂停当前练习
        pauseExercise()

        // 为当前及所有剩余的练习组添加跳过记录
        let totalSets = workoutPlan.exercises.count
        let currentExerciseSet = currentExerciseSet

        // 找到当前ExerciseSet在计划中的位置
        if let currentPosition = workoutPlan.exercises.firstIndex(where: { $0.id == currentExerciseSet.id }) {
            var lastExerciseName: String = ""

            // 从当前位置开始，为所有剩余的练习组添加跳过记录
            for i in currentPosition..<totalSets {
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

        // 更新进度 - 触发UI刷新
        objectWillChange.send()

        // 检查是否所有练习都已跳过（训练完成）
        if completedSets.count == workoutPlan.exercises.count {
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
    private func startExerciseTimer() {
        exerciseTimer?.invalidate()

        exerciseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.exerciseElapsedTime += 1
        }
    }

    private func startRestTimer() {
        // 清理之前的计时器
        restTimer?.invalidate()
        restTimer = nil

        // 重置播报标志
        hasAnnounced15Seconds = false
        hasAnnounced3Seconds = false

        // 播报下一组动作信息
        announceNextSetIfNeeded()

        // 确保在主线程上创建和启动计时器
        DispatchQueue.main.async {
            self.restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }

                // 确保UI更新在主线程上
                DispatchQueue.main.async {
                    if self.timeLeft > 0 {
                        self.timeLeft -= 1

                        // 当倒计时到15秒时播报
                        if self.timeLeft == 15 && !self.hasAnnounced15Seconds {
                            self.hasAnnounced15Seconds = true
                            VoiceManager.shared.announceRestCountdown(seconds: 15)
                        }

                        // 当倒计时到3秒时播报休息完成
                        if self.timeLeft == 3 && !self.hasAnnounced3Seconds {
                            self.hasAnnounced3Seconds = true
                            VoiceManager.shared.announceRestComplete()
                        }
                    } else {
                        timer.invalidate()
                        self.restTimer = nil
                        self.isResting = false

                        // 确保下一个动作也在主线程上开始
                        self.startExercise()
                    }
                }
            }

            // 将计时器添加到RunLoop中，确保在真机上正常工作
            let runLoop = RunLoop.current
            self.restTimer?.fireDate = Date().addingTimeInterval(1.0)
            runLoop.add(self.restTimer!, forMode: .common)
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

    // MARK: - Cleanup
    deinit {
        exerciseTimer?.invalidate()
        restTimer?.invalidate()
    }
}

// MARK: - Preview Helper
extension WorkoutViewModel {
    static var preview: WorkoutViewModel {
        return WorkoutViewModel(workoutPlan: MockDataProvider.previewWorkout)
    }
}
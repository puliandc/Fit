//
//  WorkoutViewModel.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI
import Combine

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

    init(workoutPlan: WorkoutPlan) {
        print("🐛 DEBUG: WorkoutViewModel initializing...")
        print("🐛 DEBUG: Workout plan: \(workoutPlan.name)")
        print("🐛 DEBUG: Exercise count: \(workoutPlan.exercises.count)")
        print("🐛 DEBUG: Exercise details: \(workoutPlan.exercises.map { $0.exercise.name })")

        self.workoutPlan = workoutPlan

        print("🐛 DEBUG: WorkoutViewModel initialization complete")

        // 初始化当前组数显示
        updateCurrentSetDisplay()
    }

    // MARK: - Computed Properties
    var currentExercise: Exercise {
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: currentExerciseIndex (\(currentExerciseIndex)) >= exercises.count (\(workoutPlan.exercises.count))")
            if let firstExercise = workoutPlan.exercises.first {
                return firstExercise.exercise
            } else {
                // 创建一个安全的默认练习
                return Exercise(
                    name: "默认练习",
                    category: .strength,
                    muscleGroups: [.chest],
                    equipment: .none,
                    difficulty: .beginner,
                    instructions: ["请联系开发者"],
                    imageName: "default"
                )
            }
        }
        return workoutPlan.exercises[currentExerciseIndex].exercise
    }

    var currentExerciseSet: ExerciseSet {
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: currentExerciseIndex (\(currentExerciseIndex)) >= exercises.count (\(workoutPlan.exercises.count))")
            if let firstExercise = workoutPlan.exercises.first {
                return firstExercise
            } else {
                // 创建一个安全的默认练习组
                let defaultExercise = Exercise(
                    name: "默认练习",
                    category: .strength,
                    muscleGroups: [.chest],
                    equipment: .none,
                    difficulty: .beginner,
                    instructions: ["请联系开发者"],
                    imageName: "default"
                )
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
        // 根据workout.md要求：进度条比例 = 整个计划已完成组数/整个计划总组数 * 100% 取整
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
            print("🚨 ERROR: Cannot start exercise - invalid exercise index")
            return
        }

        // 简化计时方案：记录训练开始时间（仅在第一次开始时）
        if workoutStartTime == nil {
            workoutStartTime = Date()
            print("🐛 DEBUG: 训练开始时间已记录: \(workoutStartTime!)")
        }

        print("🐛 DEBUG: Starting exercise: \(currentExercise.name)")
        exerciseElapsedTime = 0
        isExerciseActive = true
        isResting = false

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
    func completeExerciseWith(actualReps: Int, actualWeight: Double) {
        print("🐛 DEBUG: 完成练习 - 次数: \(actualReps), 重量: \(actualWeight)kg")

        // 防护：检查训练是否已经完成
        let completedSetsCount = completedSets.count
        let totalSets = workoutPlan.exercises.count
        if completedSetsCount >= totalSets {
            print("⚠️ WARNING: 训练已完成！忽略额外的完成操作。")
            return
        }

        pauseExercise()

        // Record completed set with user-specified parameters
        let completedSet = CompletedSet(
            exerciseSetId: currentExerciseSet.id,
            actualReps: actualReps,
            actualWeight: actualWeight,
            completedAt: Date()
        )
        completedSets.append(completedSet)

        // 打印进度更新
        let newProgress = completedSets.count > 0 ? (Double(completedSets.count) / Double(totalSets) * 100) : 0
        print("🐛 DEBUG: 进度更新 - 已完成组数: \(completedSets.count)/\(totalSets) = \(Int(newProgress))%")

        // 更新当前组数显示
        updateCurrentSetDisplay()

        // 更新进度 - 触发UI刷新
        objectWillChange.send()

        // 检查是否还有更多的组需要完成
        let remainingSetsInWorkout = totalSets - completedSets.count
        print("🐛 DEBUG: 剩余组数: \(remainingSetsInWorkout), 总组数: \(totalSets), 已完成: \(completedSets.count)")

        if remainingSetsInWorkout > 0 {
            // 进入休息状态，然后继续下一组/下一个动作
            print("🐛 DEBUG: 开始休息时间...")
            startRest()
        } else {
            // 训练完成
            print("🐛 DEBUG: 训练完成！触发进度更新")
            pauseExercise()

            // 确保进度更新能触发UI刷新 - 主动发送对象变化通知
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            // 训练完成对话框将由WorkoutScreen中的进度监听器处理
        }
    }

    // 新增：获取当前练习的目标组数（基于实际的训练计划逻辑）
    private func getTargetSetsForCurrentExercise() -> Int {
        // 这里根据实际的训练计划逻辑来确定组数
        // 从MockData看，每个ExerciseSet代表一组，所以需要统计同一个练习的组数
        let currentExerciseId = currentExercise.id
        return workoutPlan.exercises.filter { $0.exercise.id == currentExerciseId }.count
    }

    // 获取当前练习的默认次数和重量
    func getDefaultParametersForCurrentExercise() -> (reps: Int, weight: Double) {
        let targetReps = currentExerciseSet.targetReps
        let targetWeight = currentExerciseSet.targetWeight

        return (targetReps, targetWeight)
    }

    
    // 新增：获取指定练习的已完成组数
    func getCompletedSetsCount(for exercise: Exercise) -> Int {
        let exerciseSetIds = workoutPlan.exercises.filter { $0.exercise.id == exercise.id }.map { $0.id }
        return completedSets.filter { exerciseSetIds.contains($0.exerciseSetId) }.count
    }

    // 新增：获取指定练习的剩余组数
    func getRemainingSetsCount(for exercise: Exercise) -> Int {
        let totalSets = workoutPlan.exercises.filter { $0.exercise.id == exercise.id }.count
        let completedSets = getCompletedSetsCount(for: exercise)
        return max(0, totalSets - completedSets)
    }

    func startRest() {
        // 确保在主线程上更新UI状态
        DispatchQueue.main.async {
            self.isResting = true
            self.isExerciseActive = false
            self.timeLeft = self.currentExerciseSet.restTime

            // 更新当前练习索引到下一个动作
            self.moveToNextExerciseOrSet()

            print("🐛 DEBUG: 休息开始，时间: \(self.timeLeft)秒")

            // 在主线程上启动休息计时器
            self.startRestTimer()
        }
    }

    // 新增：移动到下一个练习或组
    private func moveToNextExerciseOrSet() {
        // 简化逻辑：每次完成一组后移动到下一个ExerciseSet
        if currentExerciseIndex < workoutPlan.exercises.count - 1 {
            currentExerciseIndex += 1
            // 更新组数显示
            updateCurrentSetDisplay()
        }
    }

    // 新增：更新当前组数显示
    private func updateCurrentSetDisplay() {
        let currentExerciseId = currentExercise.id
        let exerciseSetsForThisExercise = workoutPlan.exercises.filter { $0.exercise.id == currentExerciseId }
        let totalSetsForThisExercise = exerciseSetsForThisExercise.count

        // 计算当前是第几组（基于当前ExerciseSet在所有相同练习中的位置）
        let currentExerciseSet = currentExerciseSet
        let currentSetNumber = exerciseSetsForThisExercise.firstIndex(where: { $0.id == currentExerciseSet.id }) ?? 0

        // 更新当前组数（从1开始计数）
        currentSet = currentSetNumber + 1

        print("🐛 DEBUG: 更新组数显示 - 练习: \(currentExercise.name), 当前组: \(currentSet)/\(totalSetsForThisExercise), ExerciseSet位置: \(currentSetNumber)")
    }

    // 新增：跳过当前动作的所有组，移动到下一个不同的动作
    func skipCurrentExerciseCompletely() {
        print("🐛 DEBUG: skipCurrentExerciseCompletely called - current exercise: \(currentExercise.name)")

        // 暂停当前练习
        pauseExercise()

        // 获取当前练习的ID
        let currentExerciseId = currentExercise.id
        print("🐛 DEBUG: Current exercise ID: \(currentExerciseId)")

        // 为当前练习的所有组添加跳过记录，以更新完成度
        let currentExerciseSets = workoutPlan.exercises.filter { $0.exercise.id == currentExerciseId }
        let currentSetPosition = currentExerciseSets.firstIndex(where: { $0.id == currentExerciseSet.id }) ?? 0

        // 为当前组及后续所有相同练习的组添加跳过记录
        for i in currentSetPosition..<currentExerciseSets.count {
            let exerciseSetToSkip = currentExerciseSets[i]
            let skippedSet = CompletedSet(
                exerciseSetId: exerciseSetToSkip.id,
                actualReps: 0,  // 跳过的组记为0次
                actualWeight: 0,  // 跳过的组记为0重量
                completedAt: Date()
            )
            completedSets.append(skippedSet)
            print("🐛 DEBUG: 添加跳过记录 - 练习: \(exerciseSetToSkip.exercise.name), 组ID: \(exerciseSetToSkip.id)")
        }

        // 打印进度更新
        let totalSets = workoutPlan.exercises.count
        let newProgress = completedSets.count > 0 ? (Double(completedSets.count) / Double(totalSets) * 100) : 0
        print("🐛 DEBUG: 跳过动作后进度更新 - 已完成组数: \(completedSets.count)/\(totalSets) = \(Int(newProgress))%")

        // 更新当前组数显示
        updateCurrentSetDisplay()

        // 更新进度 - 触发UI刷新
        objectWillChange.send()

        // 找到下一个不同练习的索引
        var nextExerciseIndex = currentExerciseIndex + 1
        while nextExerciseIndex < workoutPlan.exercises.count {
            let nextExercise = workoutPlan.exercises[nextExerciseIndex].exercise
            if nextExercise.id != currentExerciseId {
                // 找到了不同的练习
                print("🐛 DEBUG: Found next different exercise: \(nextExercise.name) at index \(nextExerciseIndex)")
                break
            }
            nextExerciseIndex += 1
        }

        if nextExerciseIndex < workoutPlan.exercises.count {
            // 移动到下一个不同的练习
            currentExerciseIndex = nextExerciseIndex
            exerciseElapsedTime = 0
            print("🐛 DEBUG: Skipped entire exercise \(currentExercise.name). New index: \(currentExerciseIndex)")

            // 更新组数显示
            updateCurrentSetDisplay()

            // 自动开始新练习
            startExercise()
        } else {
            print("🐛 DEBUG: No more different exercises to skip to, completing workout")
            // 没有更多不同练习，完成训练
            DispatchQueue.main.async {
                self.pauseExercise()
            }
        }
    }

    // 新增：公共方法用于跳过当前练习（保持向后兼容）
    func moveToNextExercise() {
        print("🐛 DEBUG: moveToNextExercise called - current index: \(currentExerciseIndex)")

        // 暂停当前练习
        pauseExercise()

        // 移动到下一个练习
        if currentExerciseIndex < workoutPlan.exercises.count - 1 {
            currentExerciseIndex += 1
            exerciseElapsedTime = 0 // 重置时间
            print("🐛 DEBUG: Skipped to next exercise. New index: \(currentExerciseIndex)")

            // 更新组数显示（这会重置为新练习的组数）
            updateCurrentSetDisplay()

            // 自动开始新练习
            startExercise()
        } else {
            print("🐛 DEBUG: No more exercises to skip to, completing workout")
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
        print("🐛 DEBUG: skipAllRemainingExercises called - marking all remaining exercises as completed")

        // 暂停当前练习
        pauseExercise()

        // 为当前及所有剩余的练习组添加跳过记录
        let totalSets = workoutPlan.exercises.count
        let currentExerciseSet = currentExerciseSet

        // 找到当前ExerciseSet在计划中的位置
        if let currentPosition = workoutPlan.exercises.firstIndex(where: { $0.id == currentExerciseSet.id }) {
            // 从当前位置开始，为所有剩余的练习组添加跳过记录
            for i in currentPosition..<totalSets {
                let exerciseSetToSkip = workoutPlan.exercises[i]
                let skippedSet = CompletedSet(
                    exerciseSetId: exerciseSetToSkip.id,
                    actualReps: 0,  // 跳过的组记为0次
                    actualWeight: 0,  // 跳过的组记为0重量
                    completedAt: Date()
                )
                completedSets.append(skippedSet)
                print("🐛 DEBUG: 添加跳过记录 - 练习: \(exerciseSetToSkip.exercise.name), 组ID: \(exerciseSetToSkip.id)")
            }
        }

        // 打印最终进度更新
        let finalProgress = completedSets.count > 0 ? (Double(completedSets.count) / Double(totalSets) * 100) : 0
        print("🐛 DEBUG: 跳过全部训练后进度更新 - 已完成组数: \(completedSets.count)/\(totalSets) = \(Int(finalProgress))%")

        // 更新进度 - 触发UI刷新
        objectWillChange.send()

        print("🐛 DEBUG: All exercises skipped, workout complete")
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

        print("🐛 DEBUG: 计时器已重置 - 总时长: \(elapsedTime)秒")
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
                        let previousTimeLeft = self.timeLeft
                        self.timeLeft -= 1

                        // 只在关键时间点打印日志
                        if previousTimeLeft % 10 == 0 || self.timeLeft <= 3 {
                            print("🐛 DEBUG: 休息时间剩余: \(self.timeLeft)秒")
                        }
                    } else {
                        print("🐛 DEBUG: 休息结束，开始下一个练习")
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
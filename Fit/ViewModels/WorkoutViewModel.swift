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

    init(workoutPlan: WorkoutPlan) {
        print("🐛 DEBUG: WorkoutViewModel initializing...")
        print("🐛 DEBUG: Workout plan: \(workoutPlan.name)")
        print("🐛 DEBUG: Exercise count: \(workoutPlan.exercises.count)")
        print("🐛 DEBUG: Exercise details: \(workoutPlan.exercises.map { $0.exercise.name })")

        self.workoutPlan = workoutPlan

        print("🐛 DEBUG: WorkoutViewModel initialization complete")
    }

    // MARK: - Computed Properties
    var currentExercise: Exercise {
        print("🐛 DEBUG: currentExerciseIndex = \(currentExerciseIndex), exercises.count = \(workoutPlan.exercises.count)")

        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: currentExerciseIndex (\(currentExerciseIndex)) >= exercises.count (\(workoutPlan.exercises.count))")
            if let firstExercise = workoutPlan.exercises.first {
                print("🔄 FALLBACK: Using first exercise")
                return firstExercise.exercise
            } else {
                print("💥 CRITICAL: No exercises available!")
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
        print("🐛 DEBUG: currentExerciseIndex = \(currentExerciseIndex), exercises.count = \(workoutPlan.exercises.count)")

        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: currentExerciseIndex (\(currentExerciseIndex)) >= exercises.count (\(workoutPlan.exercises.count))")
            if let firstExercise = workoutPlan.exercises.first {
                print("🔄 FALLBACK: Using first exercise set")
                return firstExercise
            } else {
                print("💥 CRITICAL: No exercise sets available!")
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

        print("🐛 DEBUG: Progress calculation - Completed sets: \(completedSetsCount)/\(totalSets) = \(progressValue) (clamped: \(clampedProgress))")
        return clampedProgress
    }

    var isWorkoutComplete: Bool {
        return currentExerciseIndex >= workoutPlan.exercises.count
    }

    // MARK: - Exercise Management
    func startExercise() {
        print("🐛 DEBUG: WorkoutViewModel.startExercise called")
        print("🐛 DEBUG: currentExerciseIndex = \(currentExerciseIndex)")
        print("🐛 DEBUG: exercises.count = \(workoutPlan.exercises.count)")

        // 安全检查
        guard currentExerciseIndex < workoutPlan.exercises.count else {
            print("🚨 ERROR: Cannot start exercise - invalid exercise index")
            return
        }

        print("🐛 DEBUG: Starting exercise: \(currentExercise.name)")
        exerciseElapsedTime = 0
        isExerciseActive = true
        isResting = false

        print("🐛 DEBUG: Starting exercise timer...")
        startExerciseTimer()
        print("🐛 DEBUG: Exercise started successfully")
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
        print("🐛 DEBUG: completeExerciseWith called - reps: \(actualReps), weight: \(actualWeight)")
        print("🐛 DEBUG: Thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("🐛 DEBUG: Before pause - isExerciseActive: \(isExerciseActive), isResting: \(isResting)")

        // 防护：检查训练是否已经完成
        let completedSetsCount = completedSets.count
        let totalSets = workoutPlan.exercises.count
        if completedSetsCount >= totalSets {
            print("⚠️ WARNING: Workout already completed! Ignoring additional completion.")
            return
        }

        pauseExercise()

        print("🐛 DEBUG: After pause - isExerciseActive: \(isExerciseActive), isResting: \(isResting)")

        // Record completed set with user-specified parameters
        let completedSet = CompletedSet(
            exerciseSetId: currentExerciseSet.id,
            actualReps: actualReps,
            actualWeight: actualWeight,
            completedAt: Date()
        )
        completedSets.append(completedSet)
        print("🐛 DEBUG: Completed set recorded. Total completed sets: \(completedSets.count)")

        // 更新进度 - 触发UI刷新
        print("🐛 DEBUG: Triggering UI refresh with objectWillChange.send()")
        objectWillChange.send()

        // 强制更新主线程上的UI
        DispatchQueue.main.async {
            print("🐛 DEBUG: UI refresh triggered on main thread")
        }

        // 检查是否还有更多的组需要完成
        let remainingSetsInWorkout = totalSets - completedSets.count
        print("🐛 DEBUG: Remaining sets in workout: \(remainingSetsInWorkout)")

        if remainingSetsInWorkout > 0 {
            // 进入休息状态，然后继续下一组/下一个动作
            print("🐛 DEBUG: Starting rest period...")
            startRest()
        } else {
            // 训练完成
            print("🐛 DEBUG: Workout completed!")
            pauseExercise()
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

    // 新增：获取当前练习的默认次数和重量
    func getDefaultParametersForCurrentExercise() -> (reps: Int, weight: Double) {
        let targetReps = currentExerciseSet.targetReps
        var targetWeight = currentExerciseSet.targetWeight

        // 如果目标重量为0，根据器械类型提供智能默认值
        if targetWeight == 0 {
            targetWeight = getSmartDefaultWeight(for: currentExercise)
        }

        return (targetReps, targetWeight)
    }

    // 新增：根据器械类型提供智能默认重量
    private func getSmartDefaultWeight(for exercise: Exercise) -> Double {
        switch exercise.equipment {
        case .none:
            return 0 // 自重练习
        case .dumbbells:
            return 10 // 哑铃默认10kg
        case .barbell:
            return 20 // 杠铃默认20kg
        case .kettlebell:
            return 8 // 壶铃默认8kg
        case .resistanceBands:
            return 5 // 弹力带等效重量
        case .pullUpBar:
            return 0 // 引体向上杠，自重
        case .bench:
            return 0 // 卧推架，本身不增加重量
        case .machine:
            return 15 // 器械默认15kg
        case .cable:
            return 10 // 拉力机默认10kg
        case .medicineBall:
            return 3 // 药球默认3kg
        case .foamRoller:
            return 0 // 泡沫轴，自重
        }
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
        print("🐛 DEBUG: startRest called")
        print("🐛 DEBUG: Thread: \(Thread.isMainThread ? "Main" : "Background")")

        // 确保在主线程上更新UI状态
        DispatchQueue.main.async {
            print("🐛 DEBUG: Updating rest state on main thread")
            self.isResting = true
            self.isExerciseActive = false
            self.timeLeft = self.currentExerciseSet.restTime

            // 更新当前练习索引到下一个动作
            self.moveToNextExerciseOrSet()

            print("🐛 DEBUG: Rest period started, timeLeft: \(self.timeLeft)")
            print("🐛 DEBUG: Before starting rest timer - isResting: \(self.isResting)")

            // 在主线程上启动休息计时器
            self.startRestTimer()

            print("🐛 DEBUG: Rest timer started - isResting: \(self.isResting)")
        }
    }

    // 新增：移动到下一个练习或组
    private func moveToNextExerciseOrSet() {
        print("🐛 DEBUG: Moving to next exercise/set. Current index: \(currentExerciseIndex)")

        // 简化逻辑：每次完成一组后移动到下一个ExerciseSet
        if currentExerciseIndex < workoutPlan.exercises.count - 1 {
            currentExerciseIndex += 1
            print("🐛 DEBUG: Moved to next exercise. New index: \(currentExerciseIndex)")
        } else {
            print("🐛 DEBUG: Already at last exercise")
        }
    }

    // 新增：公共方法用于跳过当前练习
    func moveToNextExercise() {
        print("🐛 DEBUG: moveToNextExercise called - current index: \(currentExerciseIndex)")

        // 暂停当前练习
        pauseExercise()

        // 移动到下一个练习
        if currentExerciseIndex < workoutPlan.exercises.count - 1 {
            currentExerciseIndex += 1
            currentSet = 1 // 重置组数
            exerciseElapsedTime = 0 // 重置时间
            print("🐛 DEBUG: Skipped to next exercise. New index: \(currentExerciseIndex)")

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

        print("🐛 DEBUG: Rest timer started, \(timeLeft) seconds")
        print("🐛 DEBUG: Thread: \(Thread.isMainThread ? "Main" : "Background")")

        // 确保在主线程上创建和启动计时器
        DispatchQueue.main.async {
            print("🐛 DEBUG: Creating rest timer on main thread")

            self.restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    print("🚨 ERROR: Timer callback after deallocation")
                    timer.invalidate()
                    return
                }

                // 确保UI更新在主线程上
                DispatchQueue.main.async {
                    if self.timeLeft > 0 {
                        let previousTimeLeft = self.timeLeft
                        self.timeLeft -= 1

                        // 只在时间变化时打印日志，减少日志量
                        if previousTimeLeft % 5 == 0 || self.timeLeft <= 5 {
                            print("🐛 DEBUG: Rest timer ticking: \(self.timeLeft)s remaining")
                        }
                    } else {
                        print("🐛 DEBUG: Rest timer finished, starting next exercise")
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
            print("🐛 DEBUG: Adding timer to runloop")
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
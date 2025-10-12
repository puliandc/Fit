//
//  WorkoutSessionViewModel.swift
//  Fit
//
//  Created by Jason Lu on 09:45:00 10/12/2025.
//

import SwiftUI
import Combine

class WorkoutSessionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0
    @Published var exerciseElapsedTime: Int = 0
    @Published var isExerciseActive: Bool = false
    @Published var isResting: Bool = false
    @Published var timeLeft: Int = 0
    @Published var sessionStatus: SessionStatus = .planned
    @Published var progress: Double = 0.0
    @Published var showSummary: Bool = false

    // MARK: - Private Properties
    private var trainingPlan: TrainingPlan
    private var session: TrainingSession
    private var exerciseTimer: Timer?
    private var restTimer: Timer?

    // MARK: - Computed Properties
    var currentExercise: TrainingExercise? {
        guard currentExerciseIndex < trainingPlan.exercises.count else { return nil }
        return trainingPlan.exercises[currentExerciseIndex]
    }

    var currentExerciseSet: TrainingSet? {
        guard let exercise = currentExercise,
              currentSetIndex < exercise.sets.count else { return nil }
        return exercise.sets[currentSetIndex]
    }

    var isWorkoutComplete: Bool {
        return currentExerciseIndex >= trainingPlan.exercises.count
    }

    var currentSetType: SetType {
        return currentExerciseSet?.setType ?? .working
    }

    // MARK: - Initialization
    init(trainingPlan: TrainingPlan) {
        self.trainingPlan = trainingPlan

        // 创建新的训练会话
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"

        self.session = TrainingSession(
            planName: trainingPlan.name,
            date: dateFormatter.string(from: Date()),
            startTime: Date()
        )

        print("🏋️‍♀️ WorkoutSessionViewModel 初始化完成")
        print("📋 训练计划: \(trainingPlan.name)")
        print("📊 练习数量: \(trainingPlan.exercises.count)")
    }

    // MARK: - Session Management
    func startWorkout() {
        sessionStatus = .inProgress
        moveToNextExercise()
    }

    func pauseWorkout() {
        sessionStatus = .paused
        pauseExercise()
    }

    func resumeWorkout() {
        sessionStatus = .inProgress
        if let _ = currentExercise {
            startExercise()
        }
    }

    func completeWorkout() {
        sessionStatus = .completed
        session.endTime = Date()
        cleanup()
        showSummary = true
    }

    func abandonWorkout(reason: String? = nil) {
        sessionStatus = .abandoned
        session.endTime = Date()
        session.notes = reason
        cleanup()
        showSummary = true
    }

    // MARK: - Exercise Management
    func startExercise() {
        guard let exercise = currentExercise else { return }

        print("🏃‍♂️ 开始练习: \(exercise.name)")

        exerciseElapsedTime = 0
        isExerciseActive = true
        isResting = false

        startExerciseTimer()
    }

    func pauseExercise() {
        isExerciseActive = false
        exerciseTimer?.invalidate()
    }

    func completeCurrentSet(actualReps: Int, actualWeight: Double) {
        guard let exerciseSet = currentExerciseSet,
              let exercise = currentExercise else { return }

        pauseExercise()

        // 创建组记录
        let setRecord = SetRecord(
            exerciseName: exercise.name,
            targetWeight: exerciseSet.targetWeight,
            targetReps: exerciseSet.targetReps,
            setOrder: currentSetIndex + 1,
            actualWeight: actualWeight,
            actualReps: actualReps,
            completedAt: Date()
        )

        session.setRecords.append(setRecord)

        // 移动到下一组或下一个练习
        moveToNext()
    }

    func skipCurrentExercise(reason: String? = nil) {
        guard let exercise = currentExercise else { return }

        print("⏭️ 跳过练习: \(exercise.name)")

        // 将剩余组标记为放弃
        if let exerciseSet = currentExerciseSet {
            for index in currentSetIndex..<exercise.sets.count {
                let abandonRecord = SetRecord(
                    exerciseName: exercise.name,
                    targetWeight: exerciseSet.targetWeight,
                    targetReps: exerciseSet.targetReps,
                    setOrder: index + 1,
                    actualWeight: 0,
                    actualReps: 0,
                    notes: "放弃",
                    completedAt: Date()
                )
                session.setRecords.append(abandonRecord)
            }
        }

        // 移动到下一个练习
        currentSetIndex = 0
        moveToNextExercise()
    }

    private func moveToNext() {
        guard let exercise = currentExercise else { return }

        // 检查是否还有下一组
        if currentSetIndex < exercise.sets.count - 1 {
            // 移动到下一组
            currentSetIndex += 1
            startRest()
        } else {
            // 当前练习完成，移动到下一个练习
            currentSetIndex = 0
            moveToNextExercise()
        }

        updateProgress()
    }

    private func moveToNextExercise() {
        pauseExercise()

        if currentExerciseIndex < trainingPlan.exercises.count - 1 {
            currentExerciseIndex += 1
            startRest()
        } else {
            // 训练完成
            completeWorkout()
        }
    }

    // MARK: - Rest Management
    func startRest() {
        guard let exerciseSet = currentExerciseSet else { return }

        isResting = true
        isExerciseActive = false
        timeLeft = exerciseSet.restTime

        print("😴 休息时间: \(exerciseSet.restTime)秒")
        startRestTimer()
    }

    func skipRest() {
        restTimer?.invalidate()
        isResting = false
        if let _ = currentExercise {
            startExercise()
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
        restTimer?.invalidate()

        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                self.restTimer?.invalidate()
                self.isResting = false
                if let _ = self.currentExercise {
                    self.startExercise()
                }
            }
        }
    }

    // MARK: - Progress Calculation
    private func updateProgress() {
        // 简化的进度计算：基于完成的练习数量
        let totalExercises = trainingPlan.exercises.count
        let completedExercises = currentExerciseIndex
        progress = totalExercises > 0 ? Double(completedExercises) / Double(totalExercises) : 0.0
    }

    // MARK: - Helper Methods
    func getDefaultParametersForCurrentSet() -> (reps: Int, weight: Double) {
        guard let set = currentExerciseSet else { return (0, 0) }
        return (set.targetReps, set.targetWeight)
    }

    func getCompletedSetsCount(for exercise: TrainingExercise) -> Int {
        return session.setRecords.filter { $0.exerciseName == exercise.name && !$0.notes.contains("放弃") }.count
    }

    func getRemainingSetsCount(for exercise: TrainingExercise) -> Int {
        let totalSets = exercise.sets.count
        let completedSets = getCompletedSetsCount(for: exercise)
        return max(0, totalSets - completedSets)
    }

    func getExerciseProgress(for exercise: TrainingExercise) -> Double {
        let totalSets = exercise.sets.count
        let completedSets = getCompletedSetsCount(for: exercise)
        return totalSets > 0 ? Double(completedSets) / Double(totalSets) : 0.0
    }

    func getCompletedVolume(for exercise: TrainingExercise) -> Double {
        return session.setRecords
            .filter { $0.exerciseName == exercise.name && !$0.notes.contains("放弃") }
            .map { Double($0.actualReps) * $0.actualWeight }
            .reduce(0, +)
    }

    // MARK: - Cleanup
    private func cleanup() {
        exerciseTimer?.invalidate()
        restTimer?.invalidate()
        isExerciseActive = false
        isResting = false
    }

    deinit {
        cleanup()
    }
}

// MARK: - Preview Helper
extension WorkoutSessionViewModel {
    static var preview: WorkoutSessionViewModel {
        // 创建简化版的训练计划进行预览
        let plan = TrainingPlan(
            name: "全身训练预览",
            description: "用于预览的简化训练计划",
            exercises: [
                TrainingExercise(
                    name: "俯卧撑",
                    sets: [
                        TrainingSet(setType: .warmup, targetReps: 8, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 12, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 10, targetWeight: 0)
                    ]
                ),
                TrainingExercise(
                    name: "深蹲",
                    sets: [
                        TrainingSet(setType: .warmup, targetReps: 10, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 15, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 12, targetWeight: 0)
                    ]
                )
            ]
        )
        return WorkoutSessionViewModel(trainingPlan: plan)
    }
}
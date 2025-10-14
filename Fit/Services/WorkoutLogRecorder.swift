//
//  WorkoutLogRecorder.swift
//  Fit
//
//  Created by Jason Lu on 14/10/2025.
//

import Foundation

// MARK: - Workout Log Recorder
class WorkoutLogRecorder {
    private let fileManager = EnhancedWorkoutLogFileManager()
    private var workoutStartTime: Date?
    private var currentExerciseStartTime: Date?
    private var logEntries: [WorkoutLogEntry] = []
    private var currentExerciseSetOrder = 1
    private var currentExerciseName: String = ""

    // 开始训练记录
    func startWorkout(workoutPlan: WorkoutPlan) {
        workoutStartTime = Date()
        currentExerciseSetOrder = 1
        logEntries.removeAll()

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
            restTime: Double(exerciseSet.restTime),
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
            restTime: Double(exerciseSet.restTime),
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

        let workoutDate = DateFormatter.dateDisplay.string(from: startTime)
        let startTimeString = DateFormatter.timeDisplay.string(from: startTime)
        let endTimeString = DateFormatter.timeDisplay.string(from: endTime)

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

    // 记录跳过的动作的所有组
    func recordSkippedExercise(exercise: Exercise, exerciseSets: [ExerciseSet]) {
        guard let firstSetIndex = exerciseSets.firstIndex(where: { $0.exercise.id == exercise.id }) else {
            return
        }

        // 从当前组开始，记录所有后续组为跳过
        for i in firstSetIndex..<exerciseSets.count {
            let exerciseSet = exerciseSets[i]
            if exerciseSet.exercise.id == exercise.id {
                recordSkippedSet(exerciseSet: exerciseSet)
            }
        }
    }
}
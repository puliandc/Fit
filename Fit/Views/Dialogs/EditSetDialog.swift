//
//  EditSetDialog.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-10-14 - Refactored to use UniversalDialog
//

import SwiftUI

// MARK: - Edit Set Dialog (Legacy Wrapper)

// DEPRECATED: This component should be replaced by direct UniversalDialog usage
struct EditSetDialog: View
{
    let exercise: Exercise
    let setIndex: Int
    let onDismiss: () -> Void
    let workoutViewModel: WorkoutViewModel

    var body: some View
    {
        let defaults = workoutViewModel.getDefaultParametersForCurrentExercise()
        let defaultNotes = workoutViewModel.currentExerciseSet.notes ?? ""
        return UniversalDialog(
            type: .input(
                title: "动作完成",
                subtitle: "请输入实际完成次数和重量",
                defaultReps: String(defaults.reps),
                defaultWeight: formatWeight(defaults.weight),
                defaultNotes: defaultNotes,
                onConfirm: { reps, weight, notes in
                    saveChanges(reps: reps, weight: weight, notes: notes)
                }
            ),
            onDismiss: onDismiss
        )
    }

    // 统一的重量格式化函数
    private func formatWeight(_ weight: Double) -> String
    {
        if weight == 0
        {
            return "自重"
        }
        else if abs(weight.truncatingRemainder(dividingBy: 1)) < 0.0001
        {
            return String(format: "%.0f", weight)
        }
        else
        {
            return String(format: "%.1f", weight)
        }
    }

    private func saveChanges(reps: String, weight: String, notes: String)
    {
        guard let actualReps = Int(reps)
        else
        {
            return
        }

        // 处理重量输入：如果是"自重"或空字符串，则设为0
        let actualWeight: Double
        if weight.lowercased() == "自重" || weight.isEmpty
        {
            actualWeight = 0.0
        }
        else
        {
            guard let weightValue = Double(weight)
            else
            {
                return
            }
            actualWeight = weightValue
        }

        // 使用WorkoutViewModel的增强方法保存参数并完成练习
        workoutViewModel.completeExerciseWith(actualReps: actualReps, actualWeight: actualWeight, notes: notes)
    }
}

// MARK: - Completion Dialog (Legacy Wrapper)

// DEPRECATED: This component should be replaced by direct UniversalDialog usage
struct CompletionDialog: View
{
    let onDismiss: () -> Void

    var body: some View
    {
        UniversalDialog(
            type: .input(
                title: "完成记录",
                subtitle: "请输入您实际完成的次数和重量",
                defaultReps: "",
                defaultWeight: "",
                defaultNotes: "",
                onConfirm: { reps, weight, _ in
                    saveCompletion(reps: reps, weight: weight)
                }
            ),
            onDismiss: onDismiss
        )
    }

    private func saveCompletion(reps _: String, weight _: String)
    {
        // 功能保留但标记为过时，建议直接使用UniversalDialog
    }
}

// MARK: - Quit Dialog (Legacy Wrapper)

// DEPRECATED: This component should be replaced by direct UniversalDialog usage
struct QuitDialog: View
{
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View
    {
        UniversalDialog(
            type: .confirmation(
                title: "放弃训练",
                message: "确定要放弃当前训练吗？\n\n您的进度将会丢失",
                icon: "exclamationmark.triangle",
                iconColor: .warning,
                onConfirm: onConfirm
            ),
            onDismiss: onCancel
        )
    }
}

// MARK: - Enhanced Quit Dialog (Legacy Wrapper)

// DEPRECATED: This component should be replaced by direct UniversalDialog usage
struct EnhancedQuitDialog: View
{
    let onQuitCurrentExercise: () -> Void
    let onQuitAll: () -> Void
    let onCancel: () -> Void
    let currentExerciseName: String

    var body: some View
    {
        UniversalDialog(
            type: .options(
                title: "放弃动作",
                message: "请选择如何结束训练",
                options: [
                    DialogOption(
                        title: "跳过当前动作",
                        description: "跳过「\(currentExerciseName)」，继续下一个动作",
                        icon: "forward.end.fill",
                        color: .warning,
                        action: onQuitCurrentExercise
                    ),
                    DialogOption(
                        title: "放弃全部训练",
                        description: "放弃所有训练，进度将丢失",
                        icon: "xmark.circle.fill",
                        color: .error,
                        action: onQuitAll
                    ),
                    DialogOption(
                        title: "继续训练",
                        description: "继续当前动作的训练",
                        icon: "play.circle.fill",
                        color: .success,
                        action: onCancel
                    )
                ]
            ),
            onDismiss: onCancel
        )
    }
}

// REMOVED: QuitOptionCard was redundant with UniversalDialog.optionCard
// Use UniversalDialog with .options type instead

// MARK: - Workout Complete Dialog (Legacy Wrapper)

// DEPRECATED: This component should be replaced by direct UniversalDialog usage
struct WorkoutCompleteDialog: View
{
    let onDismiss: () -> Void
    let workoutViewModel: WorkoutViewModel

    var body: some View
    {
        UniversalDialog(
            type: .completion(
                title: "训练完成!",
                message: "恭喜您完成了今天的训练！",
                stats: [
                    ("总时长:", formatTime(workoutViewModel.totalWorkoutTime)),
                    ("完成组数:", "\(workoutViewModel.completedSets.count) 组")
                ]
            ),
            onDismiss: onDismiss
        )
    }

    // Helper function to format time
    private func formatTime(_ seconds: Int) -> String
    {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Preview

#Preview
{
    UniversalDialog(
        type: .input(
            title: "动作完成",
            subtitle: "请输入实际完成次数和重量",
            defaultReps: "8",
            defaultWeight: "60",
            defaultNotes: "动作控制稳定",
            onConfirm: { _, _, _ in }
        ),
        onDismiss: { }
    )
    .preferredColorScheme(.dark)
}

//
//  EditSetDialog.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-10-14 - Refactored to use UniversalDialog
//

import SwiftUI

// MARK: - Edit Set Dialog (Legacy Wrapper)
struct EditSetDialog: View {
    let exercise: Exercise
    let setIndex: Int
    let onDismiss: () -> Void
    let workoutViewModel: WorkoutViewModel

    var body: some View {
        UniversalDialog(
            type: .input(
                title: "动作完成",
                subtitle: "请输入实际完成次数和重量",
                onConfirm: { reps, weight, notes in
                    saveChanges(reps: reps, weight: weight, notes: notes)
                }
            ),
            onDismiss: onDismiss
        )
    }

    private func saveChanges(reps: String, weight: String, notes: String) {
        print("💾 DEBUG: EditSetDialog saveChanges called - reps: \(reps), weight: \(weight), notes: \(notes)")

        guard let actualReps = Int(reps),
              let actualWeight = Double(weight) else {
            print("❌ ERROR: Invalid input parameters - reps: \(reps), weight: \(weight)")
            return
        }

        print("💾 DEBUG: EditSetDialog saving with validated parameters - reps: \(actualReps), weight: \(actualWeight), notes: \(notes)")
        print("🐛 DEBUG: Thread: \(Thread.isMainThread ? "Main" : "Background")")

        // 使用WorkoutViewModel的增强方法保存参数并完成练习
        workoutViewModel.completeExerciseWith(actualReps: actualReps, actualWeight: actualWeight, notes: notes)

        print("💾 DEBUG: EditSetDialog called completeExerciseWith")
    }
}

// MARK: - Completion Dialog (Legacy Wrapper)
struct CompletionDialog: View {
    let onDismiss: () -> Void

    var body: some View {
        UniversalDialog(
            type: .input(
                title: "完成记录",
                subtitle: "请输入您实际完成的次数和重量",
                onConfirm: { reps, weight, _ in
                    saveCompletion(reps: reps, weight: weight)
                }
            ),
            onDismiss: onDismiss
        )
    }

    private func saveCompletion(reps: String, weight: String) {
        print("Saving completion - Reps: \(reps), Weight: \(weight)")
    }
}

// MARK: - Quit Dialog (Legacy Wrapper)
struct QuitDialog: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
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
struct EnhancedQuitDialog: View {
    let onQuitCurrentExercise: () -> Void
    let onQuitAll: () -> Void
    let onCancel: () -> Void
    let currentExerciseName: String

    var body: some View {
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

// MARK: - Quit Option Card
struct QuitOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                        .multilineTextAlignment(.leading)

                    Text(description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.appTextTertiary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Workout Complete Dialog (Legacy Wrapper)
struct WorkoutCompleteDialog: View {
    let onDismiss: () -> Void
    let workoutViewModel: WorkoutViewModel

    var body: some View {
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
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Preview
#Preview {
    UniversalDialog(
        type: .input(
            title: "动作完成",
            subtitle: "请输入实际完成次数和重量",
            onConfirm: { _, _, _ in }
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
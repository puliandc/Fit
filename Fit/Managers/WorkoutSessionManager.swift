//
//  WorkoutSessionManager.swift
//  Fit
//
//  Created by Jason Lu on 15:15:00 10/14/2025.
//

import Combine
import SwiftUI

// MARK: - Workout Session Manager

// 专门负责训练会话管理，从NavigationManager中分离出来
class WorkoutSessionManager: ObservableObject
{
    @Published var currentWorkoutViewModel: WorkoutViewModel?

    init()
    {
        print("🎯 WorkoutSessionManager initialized")
    }

    // MARK: - Workout Session Methods

    func startWorkout(_ plan: WorkoutPlan)
    {
        print("🐛 DEBUG: WorkoutSessionManager.startWorkout called")
        print("🐛 DEBUG: Workout plan: \(plan.name)")
        print("🐛 DEBUG: Exercise count: \(plan.exercises.count)")

        // 安全验证
        guard !plan.exercises.isEmpty
        else
        {
            print("🚨 ERROR: Cannot start workout - no exercises available")
            return
        }

        // 每次都创建全新的WorkoutViewModel，确保状态完全重置
        print("🐛 DEBUG: Creating fresh WorkoutViewModel for plan: \(plan.name)")
        currentWorkoutViewModel = WorkoutViewModel(workoutPlan: plan)

        print("🐛 DEBUG: WorkoutSession created successfully")
    }

    func completeWorkout() -> Bool
    {
        // 保存训练日志
        if let viewModel = currentWorkoutViewModel
        {
            // 防止未完成时误调用
            guard viewModel.workoutFinished || viewModel.isWorkoutComplete
            else
            {
                print("⚠️ Workout not marked complete yet, skipping log save")
                return false
            }

            let logSaved = viewModel.finishWorkoutAndSaveLog()

            if logSaved
            {
                print("✅ Workout completed and log saved successfully")
            }
            else
            {
                print("❌ Workout completed but log saving failed")
            }

            // 注意：不要在这里立即清理currentWorkoutViewModel
            // 让ContentView先显示完成弹窗，弹窗关闭后再清理
            print("🐛 DEBUG: Workout completed, keeping currentWorkoutViewModel for dialog display")
            return logSaved
        }

        return false
    }

    // 新增：在弹窗显示完成后清理会话的方法
    func cleanupAfterWorkoutComplete()
    {
        print("🧹 DEBUG: Cleaning up currentWorkoutViewModel after dialog display")
        currentWorkoutViewModel = nil
    }

    func quitWorkout()
    {
        // 放弃训练并清理会话
        currentWorkoutViewModel = nil
        print("🏃 Workout session quit and cleaned up")
    }

    func pauseWorkout()
    {
        // Handle workout pause logic
        print("⏸️ Workout pause requested (not implemented yet)")
    }

    func resumeWorkout()
    {
        // Handle workout resume logic
        print("▶️ Workout resume requested (not implemented yet)")
    }

    func quitCurrentExercise()
    {
        // 放弃当前练习
        print("⏭️ Quit current exercise requested (not implemented yet)")
    }

    func quitRemainingExercises()
    {
        // 放弃剩余练习
        print("🏁 Quit remaining exercises requested (not implemented yet)")
    }
}

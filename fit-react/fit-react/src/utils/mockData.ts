//created by Jason Lu on 10:30:00 10/28/2025
// 最小化快速测试Mock数据
import type { WorkoutPlan } from '../types'

/**
 * 快速测试用的最小化WorkoutPlan
 * 仅包含一个基础动作用于测试WorkoutScreen功能
 */
export const mockWorkoutPlan: WorkoutPlan = {
  id: 'quick-test-001',
  name: '快速测试训练',
  description: '用于快速测试功能的简化训练计划',
  duration: 5,
  difficulty: 'beginner',
  exercises: [
    {
      id: 'exercise-001',
      exercise: {
        id: 'mock-exercise-001',
        name: '深蹲'
      },
      targetReps: 10,
      targetWeight: 20,
      restTime: 60,
      notes: '快速测试用动作'
    }
  ]
}

/**
 * 获取快速测试WorkoutPlan
 * @returns {WorkoutPlan} 预配置的最小化训练计划
 */
export const getQuickTestWorkoutPlan = (): WorkoutPlan => {
  return { ...mockWorkoutPlan }
}

/**
 * 检查快速测试模式是否启用
 * @returns {boolean} 是否启用快速测试功能
 */
export const isQuickTestEnabled = (): boolean => {
  return import.meta.env.VITE_ENABLE_QUICK_TEST === 'true'
}
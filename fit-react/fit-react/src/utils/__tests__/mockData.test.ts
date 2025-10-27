//created by Jason Lu on 10:40:00 10/28/2025
// Mock数据测试用例
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { getQuickTestWorkoutPlan, isQuickTestEnabled } from '../mockData'

describe('Mock Data Utils', () => {
  describe('getQuickTestWorkoutPlan', () => {
    it('应该返回有效的WorkoutPlan对象', () => {
      const plan = getQuickTestWorkoutPlan()

      expect(plan).toBeDefined()
      expect(plan.id).toBe('quick-test-001')
      expect(plan.name).toBe('快速测试训练')
      expect(plan.duration).toBe(5)
      expect(plan.exercises).toHaveLength(1)
    })

    it('应该返回一个新的对象实例', () => {
      const plan1 = getQuickTestWorkoutPlan()
      const plan2 = getQuickTestWorkoutPlan()

      expect(plan1).not.toBe(plan2)
      expect(plan1).toEqual(plan2)
    })

    it('应该包含完整的训练动作信息', () => {
      const plan = getQuickTestWorkoutPlan()
      const exercise = plan.exercises[0]

      expect(exercise.id).toBe('exercise-001')
      expect(exercise.exercise.name).toBe('深蹲')
      expect(exercise.targetReps).toBe(10)
      expect(exercise.targetWeight).toBe(20)
      expect(exercise.restTime).toBe(60)
    })
  })

  describe('isQuickTestEnabled', () => {
    let originalEnv: string | undefined

    beforeEach(() => {
      originalEnv = import.meta.env.VITE_ENABLE_QUICK_TEST
    })

    afterEach(() => {
      // 恢复原始环境变量
      if (originalEnv !== undefined) {
        import.meta.env.VITE_ENABLE_QUICK_TEST = originalEnv
      }
    })

    it('当环境变量为"true"时应该返回true', () => {
      import.meta.env.VITE_ENABLE_QUICK_TEST = 'true'
      expect(isQuickTestEnabled()).toBe(true)
    })

    it('当环境变量为"false"时应该返回false', () => {
      import.meta.env.VITE_ENABLE_QUICK_TEST = 'false'
      expect(isQuickTestEnabled()).toBe(false)
    })

    it('当环境变量未设置时应该返回false', () => {
      delete import.meta.env.VITE_ENABLE_QUICK_TEST
      expect(isQuickTestEnabled()).toBe(false)
    })
  })
})
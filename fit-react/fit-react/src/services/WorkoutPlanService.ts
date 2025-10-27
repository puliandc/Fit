//created by Jason Lu on 16:32:00 10/27/2025
// 训练计划数据管理服务

import type { WorkoutPlan } from '../types'

class WorkoutPlanService {
  private static instance: WorkoutPlanService
  private plans: WorkoutPlan[] = []

  static getInstance(): WorkoutPlanService {
    if (!WorkoutPlanService.instance) {
      WorkoutPlanService.instance = new WorkoutPlanService()
    }
    return WorkoutPlanService.instance
  }

  // 加载所有训练计划
  async loadWorkoutPlans(): Promise<WorkoutPlan[]> {
    try {
      // 从 localStorage 加载数据
      const stored = localStorage.getItem('workout_plans')
      if (stored) {
        this.plans = JSON.parse(stored).map((plan: any) => ({
          ...plan,
          created_at: new Date(plan.created_at),
          updated_at: plan.updated_at ? new Date(plan.updated_at) : undefined
        }))
        return this.plans
      }

      // 如果没有存储数据，返回默认示例计划
      this.plans = this.getDefaultPlans()
      await this.saveWorkoutPlans(this.plans)
      return this.plans
    } catch (error) {
      console.error('Failed to load workout plans:', error)
      return []
    }
  }

  // 保存训练计划
  async saveWorkoutPlan(plan: WorkoutPlan): Promise<void> {
    try {
      const existingIndex = this.plans.findIndex(p => p.id === plan.id)

      if (existingIndex >= 0) {
        // 更新现有计划
        this.plans[existingIndex] = {
          ...plan,
          updated_at: new Date()
        }
      } else {
        // 添加新计划
        this.plans.push({
          ...plan,
          id: crypto.randomUUID(),
          created_at: new Date()
        })
      }

      localStorage.setItem('workout_plans', JSON.stringify(this.plans))
    } catch (error) {
      console.error('Failed to save workout plan:', error)
    }
  }

  // 删除训练计划
  async deleteWorkoutPlan(id: string): Promise<void> {
    try {
      this.plans = this.plans.filter(plan => plan.id !== id)
      localStorage.setItem('workout_plans', JSON.stringify(this.plans))
    } catch (error) {
      console.error('Failed to delete workout plan:', error)
    }
  }

  // 保存所有计划
  async saveWorkoutPlans(plans: WorkoutPlan[]): Promise<void> {
    try {
      this.plans = plans
      localStorage.setItem('workout_plans', JSON.stringify(plans))
    } catch (error) {
      console.error('Failed to save workout plans:', error)
    }
  }

  // 获取计划详情
  async getWorkoutPlan(id: string): Promise<WorkoutPlan | null> {
    try {
      return this.plans.find(plan => plan.id === id) || null
    } catch (error) {
      console.error('Failed to get workout plan:', error)
      return null
    }
  }

  // 获取默认示例计划
  private getDefaultPlans(): WorkoutPlan[] {
    return [
      {
        id: crypto.randomUUID(),
        name: '胸部训练计划',
        description: '针对胸部肌群的全面训练计划',
        duration: 45,
        difficulty: 'intermediate' as any,
        created_at: new Date(),
        exercises: [
          {
            id: '1',
            exercise: { id: '1', name: '杠铃卧推' },
            targetReps: 12,
            targetWeight: 60,
            restTime: 90
          },
          {
            id: '2',
            exercise: { id: '2', name: '哑铃飞鸟' },
            targetReps: 15,
            targetWeight: 20,
            restTime: 60
          },
          {
            id: '3',
            exercise: { id: '3', name: '俯卧撑' },
            targetReps: 15,
            targetWeight: 0,
            restTime: 45
          }
        ]
      },
      {
        id: crypto.randomUUID(),
        name: '腿部训练计划',
        description: '深蹲和腿部肌群强化训练',
        duration: 60,
        difficulty: 'advanced' as any,
        created_at: new Date(),
        exercises: [
          {
            id: '4',
            exercise: { id: '4', name: '杠铃深蹲' },
            targetReps: 12,
            targetWeight: 80,
            restTime: 120
          },
          {
            id: '5',
            exercise: { id: '5', name: '腿举' },
            targetReps: 15,
            targetWeight: 40,
            restTime: 60
          },
          {
            id: '6',
            exercise: { id: '6', name: '提踵' },
            targetReps: 20,
            targetWeight: 0,
            restTime: 30
          }
        ]
      },
      {
        id: crypto.randomUUID(),
        name: 'HIIT有氧训练',
        description: '高强度间歇训练，提升心肺功能',
        duration: 30,
        difficulty: 'beginner' as any,
        created_at: new Date(),
        exercises: [
          {
            id: '7',
            exercise: { id: '7', name: '开合跳' },
            targetReps: 30,
            targetWeight: 0,
            restTime: 15
          },
          {
            id: '8',
            exercise: { id: '8', name: '高抬腿' },
            targetReps: 20,
            targetWeight: 0,
            restTime: 15
          },
          {
            id: '9',
            exercise: { id: '9', name: '波比跳' },
            targetReps: 25,
            targetWeight: 0,
            restTime: 20
          }
        ]
      }
    ]
  }

  // 获取所有计划（同步方法）
  getWorkoutPlans(): WorkoutPlan[] {
    return this.plans
  }
}

export default WorkoutPlanService
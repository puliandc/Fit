//created by Jason Lu on 16:30:00 10/27/2025
import React from 'react'
import { GlassCard, GlassButton } from './index'

interface WorkoutPlanListProps {
  workoutPlans: any[]
  onSelectPlan: (planId: string) => void
  onStartNewPlan: () => void
}

const WorkoutPlanList: React.FC<WorkoutPlanListProps> = ({
  workoutPlans,
  onSelectPlan,
  onStartNewPlan
}) => {
  return (
    <div className="space-y-6">
      {/* 标题区域 */}
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-white mb-4">
          训练计划
        </h2>
        <p className="text-gray-300">
          选择现有计划或创建新的训练计划
        </p>
      </div>

      {/* 新建计划按钮 */}
      <div className="mb-6">
        <GlassButton
          variant="secondary"
          size="lg"
          className="w-full"
          onClick={onStartNewPlan}
        >
          + 创建新计划
        </GlassButton>
      </div>

      {/* 计划列表 */}
      <div className="space-y-4">
        {workoutPlans.map((plan, index) => (
          <GlassCard
            key={plan.id}
            variant="default"
            padding="lg"
            hover={true}
            className="cursor-pointer"
            onClick={() => onSelectPlan(plan.id)}
          >
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="text-xl font-semibold text-white mb-2">
                  {plan.name}
                </h3>
                <p className="text-gray-300 text-sm">
                  训练时长: {plan.duration} 分钟
                </p>
              </div>
              <div className="text-right">
                <span className="text-blue-400 text-sm font-medium">
                  {plan.exercises?.length || 0} 个动作
                </span>
              </div>
            </div>

            {/* 动作预览 */}
            <div className="mb-4">
              <div className="flex flex-wrap gap-2">
                {plan.exercises?.slice(0, 3).map((exercise: any, idx: number) => (
                  <span
                    key={idx}
                    className="px-3 py-1 bg-blue-500/20 text-blue-300 rounded-full text-xs"
                  >
                    {exercise.exercise?.name || '未知动作'}
                  </span>
                ))}
                {plan.exercises?.length > 3 && (
                  <span className="px-3 py-1 bg-gray-500/20 text-gray-300 rounded-full text-xs">
                    +{plan.exercises.length - 3}
                  </span>
                )}
              </div>
            </div>

            {/* 操作按钮 */}
            <div className="flex gap-3">
              <GlassButton
                variant="primary"
                size="sm"
                className="flex-1"
                onClick={() => onSelectPlan(plan.id)}
              >
                开始训练
              </GlassButton>
              <GlassButton
                variant="secondary"
                size="sm"
                onClick={() => console.log('编辑计划:', plan.id)}
              >
                编辑
              </GlassButton>
            </div>
          </GlassCard>
        ))}
      </div>

      {/* 空状态 */}
      {workoutPlans.length === 0 && (
        <GlassCard variant="light" padding="lg" className="text-center">
          <div className="text-gray-400">
            <h3 className="text-lg font-medium mb-2">
              暂无训练计划
            </h3>
            <p className="text-sm mb-4">
              创建你的第一个训练计划，开始健身之旅
            </p>
            <GlassButton
              variant="primary"
              onClick={onStartNewPlan}
            >
              创建计划
            </GlassButton>
          </div>
        </GlassCard>
      )}
    </div>
  )
}

export default WorkoutPlanList
//created by Jason Lu on 16:50:00 10/27/2025
import React from 'react'
import { GlassCard, GlassButton } from './index'

interface ExerciseSet {
  id: string
  targetReps: number
  targetWeight: number
  actualReps?: number
  actualWeight?: number
  restTime: number
  completed: boolean
}

interface WorkoutSessionProps {
  workoutPlan: any
  onStartWorkout: () => void
  onPauseWorkout: () => void
  onEndWorkout: () => void
  onSkipExercise: (setId: string) => void
}

const WorkoutSession: React.FC<WorkoutSessionProps> = ({
  workoutPlan,
  onStartWorkout,
  onPauseWorkout,
  onEndWorkout,
  onSkipExercise
}) => {
  const [currentExerciseIndex, setCurrentExerciseIndex] = React.useState(0)
  const [currentSetIndex, setCurrentSetIndex] = React.useState(0)
  const [isResting, setIsResting] = React.useState(false)
  const [completedSets, setCompletedSets] = React.useState<number[]>([])

  // 计算当前动作
  const currentExercise = workoutPlan.exercises?.[currentExerciseIndex] || null

  // 计算当前组
  const currentSet = currentExercise?.sets?.[currentSetIndex] || null

  // 计算剩余时间
  const [restTimeRemaining, setRestTimeRemaining] = React.useState(0)

  // 休息倒计时
  React.useEffect(() => {
    if (isResting && restTimeRemaining > 0) {
      const timer = setTimeout(() => {
        setRestTimeRemaining(prev => prev - 1)
      }, 1000)

      return () => clearTimeout(timer)
    }
  }, [isResting, restTimeRemaining])

  // 处理动作完成
  const completeSet = () => {
    if (currentSet) {
      const newCompletedSets = [...completedSets, currentSet.id]
      setCompletedSets(newCompletedSets)

      // 进入休息时间
      setIsResting(true)
      setRestTimeRemaining(currentSet.restTime)
    }
  }

  // 跳到下一组（未使用，注释避免警告）
  // const skipToNextSet = () => {
  //   if (currentSetIndex < (currentExercise?.sets?.length || 0) - 1) {
  //     setCurrentSetIndex(currentSetIndex + 1)
  //   }
  // }

  // 跳到下一个动作
  const skipToNextExercise = () => {
    if (currentExerciseIndex < (workoutPlan.exercises?.length || 0) - 1) {
      setCurrentExerciseIndex(currentExerciseIndex + 1)
      setCurrentSetIndex(0)
      setCompletedSets([])
      setIsResting(false)
    }
  }

  // 开始训练（未使用，注释避免警告）
  // const startWorkout = () => {
  //   onStartWorkout()
  // }

  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 text-white p-4">
      {/* 顶部信息栏 */}
      <div className="mb-4">
        <GlassCard variant="dark" padding="md">
          <div className="flex justify-between items-center">
            <div className="text-white">
              <div className="font-semibold">{workoutPlan.name}</div>
              <div className="text-sm text-gray-300">{workoutPlan.duration} 分钟</div>
            </div>
            <div className="flex gap-2">
              <GlassButton
                variant="secondary"
                size="sm"
                onClick={onPauseWorkout}
              >
                {isResting ? '继续' : '暂停'}
              </GlassButton>
              <GlassButton
                variant="danger"
                size="sm"
                onClick={onEndWorkout}
              >
                结束
              </GlassButton>
            </div>
          </div>
        </GlassCard>
      </div>

      {/* 进度指示器 */}
      <div className="flex justify-center mb-6">
        <div className="text-center text-gray-300 mb-2">
          动作 {currentExerciseIndex + 1} / {workoutPlan.exercises?.length || 0}
        </div>
        <div className="w-64 bg-gray-700 rounded-full h-2 mb-6">
          <div
                className="bg-blue-500 h-2 rounded-full transition-all duration-500"
                style={{ width: `${((currentExerciseIndex + 1) / (workoutPlan.exercises?.length || 0)) * 100}%` }}
            ></div>
        </div>
      </div>

      {/* 当前动作卡片 */}
      {currentExercise && (
        <GlassCard variant="default" padding="lg" className="mb-6">
          <div className="flex justify-between items-start mb-4">
            <div>
              <h3 className="text-2xl font-bold text-white mb-2">
                {currentExercise.exercise.name}
              </h3>
              <div className="flex gap-4 mb-4">
                <span className="px-3 py-1 bg-blue-500/20 text-blue-300 rounded-full text-sm">
                  组数: {currentExercise.sets?.length || 0}
                </span>
                <span className="px-3 py-1 bg-green-500/20 text-green-300 rounded-full text-sm">
                  {currentExercise.sets?.reduce((sum, set) => sum + set.targetReps, 0)} 次
                </span>
              </div>
            </div>
            <div className="text-right">
              <span className="text-gray-400">目标: {currentExercise.targetReps} 次</span>
            </div>
          </div>

          {/* 组列表 */}
          <div className="space-y-3">
            {currentExercise.sets?.map((set: ExerciseSet, index: number) => (
              <div
                    key={set.id}
                    className={`flex justify-between items-center p-4 rounded-lg ${set.completed ? 'bg-green-500/20' : 'bg-gray-700'} transition-all duration-200`}
              >
                <div className="flex-1">
                  <div className="text-white">
                    <div className="font-medium">{set.actualReps || set.targetReps} 次</div>
                    <div className="text-sm text-gray-300">
                      {set.actualWeight || set.targetWeight}kg
                    </div>
                  </div>
                  <div className="flex gap-2">
                    {set.completed ? (
                      <span className="text-green-400">✓ 完成</span>
                    ) : (
                      <>
                        <GlassButton
                              variant="primary"
                              size="sm"
                              onClick={() => completeSet()}
                        >
                          完成
                        </GlassButton>
                        <GlassButton
                              variant="secondary"
                              size="sm"
                              onClick={() => setCurrentSetIndex(index)}
                        >
                          编辑
                        </GlassButton>
                      </>
                    )}
                  </div>
                </div>

                <div className="text-right text-gray-400">
                  <div className="text-sm">{currentExercise.restTime}s 休息</div>
                </div>
              </div>
            ))}
          </div>

          {/* 动作导航按钮 */}
          <div className="flex justify-between items-center pt-4">
            <GlassButton
              variant="secondary"
              onClick={() => skipToNextExercise()}
              disabled={currentExerciseIndex === 0}
            >
              ← 上一个动作
            </GlassButton>
            <GlassButton
              variant="primary"
              onClick={() => {
                if (currentExerciseIndex < (workoutPlan.exercises?.length || 0) - 1) {
                  skipToNextExercise()
                }
              }}
            >
              {currentExerciseIndex === (workoutPlan.exercises?.length || 0) - 1 ? '完成训练' : '下一个动作'}
            </GlassButton>
            <GlassButton
              variant="danger"
              size="sm"
              onClick={() => onSkipExercise(currentExercise.id)}
            >
              跳过
            </GlassButton>
          </div>
        </GlassCard>
      )}

      {/* 休息提示 */}
      {isResting && (
        <GlassCard variant="light" padding="lg" className="text-center">
          <div className="text-3xl mb-4">😴</div>
          <div className="text-xl font-medium text-white mb-2">
            休息时间
          </div>
          <div className="text-5xl font-bold text-blue-400 mb-4">
            {formatTime(restTimeRemaining)}
          </div>
          <div className="text-gray-300">
            准备下一组动作
          </div>
          <div className="mt-4">
            <GlassButton
              variant="primary"
              size="lg"
              onClick={() => {
                setIsResting(false)
                setCurrentSetIndex(currentSetIndex + 1)
                setRestTimeRemaining(0)
              }}
            >
              开始训练
            </GlassButton>
          </div>
        </GlassCard>
      )}
    </div>
  )
}

export default WorkoutSession
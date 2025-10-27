//created by Jason Lu on 10:52:00 10/27/2025
import React from 'react'
import { GlassCard, GlassButton } from './index'
import { useNavigation, useNavigationActions } from '../context/NavigationContext'

interface Exercise {
  id: string
  name: string
}

interface ExerciseSet {
  id: string
  exercise: Exercise
  targetReps: number
  targetWeight: number
  restTime: number
  notes?: string
}

interface WorkoutPlan {
  id: string
  name: string
  duration: number
  exercises: ExerciseSet[]
}

const WorkoutScreen: React.FC = () => {
  const { state } = useNavigation()
  const { goBack, goHome } = useNavigationActions()
  const workoutPlan: WorkoutPlan = state.workoutPlan

  // 训练状态管理
  const [currentExerciseIndex, setCurrentExerciseIndex] = React.useState(0)
  const [currentSetIndex, setCurrentSetIndex] = React.useState(0)
  const [isResting, setIsResting] = React.useState(false)
  const [exerciseElapsedTime, setExerciseElapsedTime] = React.useState(0)
  const [restTimeLeft, setRestTimeLeft] = React.useState(0)
  // const [completedSets, setCompletedSets] = React.useState<any[]>([])
  const [showEditDialog, setShowEditDialog] = React.useState(false)
  const [showQuitDialog, setShowQuitDialog] = React.useState(false)

  // 计时器相关
  const [timerInterval, setTimerInterval] = React.useState<number | null>(null)

  // 当前练习和组
  const currentExercise = workoutPlan?.exercises[currentExerciseIndex]
  const currentExerciseSets = React.useMemo(() => {
    if (!workoutPlan || !currentExercise) return []
    return workoutPlan.exercises.filter(ex => ex.exercise.name === currentExercise.exercise.name)
  }, [workoutPlan, currentExercise])

  const currentSet = currentExerciseSets[currentSetIndex]
  const totalSets = currentExerciseSets.length

  // 计算整个训练的总时长
  const [totalWorkoutTime, setTotalWorkoutTime] = React.useState(0)

  // 进度计算
  const progress = React.useMemo(() => {
    if (!workoutPlan || workoutPlan.exercises.length === 0) return 0
    const totalExercises = workoutPlan.exercises.length
    return (currentExerciseIndex + (currentSetIndex + 1) / totalSets) / totalExercises
  }, [currentExerciseIndex, currentSetIndex, totalSets, workoutPlan])

  // 时间格式化
  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  // 重量格式化
  const formatWeight = (weight: number): string => {
    if (weight === 0) return '自重'
    return weight % 1 === 0 ? `${weight}` : `${weight.toFixed(1)}`
  }

  // 开始计时器
  const startTimer = () => {
    if (timerInterval) clearInterval(timerInterval)

    const interval = setInterval(() => {
      setTotalWorkoutTime(prev => prev + 1)
      if (isResting) {
        setRestTimeLeft(prev => {
          if (prev <= 1) {
            setIsResting(false)
            setExerciseElapsedTime(0)
            return 0
          }
          return prev - 1
        })
      } else {
        setExerciseElapsedTime(prev => prev + 1)
      }
    }, 1000)

    setTimerInterval(interval)
  }

  // 停止计时器
  const stopTimer = () => {
    if (timerInterval) {
      clearInterval(timerInterval)
      setTimerInterval(null)
    }
  }

  // 完成当前组
  const handleCompleteSet = () => {
    if (!currentSet) return

    setShowEditDialog(true)
  }

  // 保存完成的组
  const saveCompletedSet = (actualReps: number, actualWeight: number, notes: string) => {
    if (!currentSet) return

    const completedSet = {
      id: `completed-${Date.now()}`,
      exerciseSetId: currentSet.id,
      actualReps,
      actualWeight,
      notes,
      completedAt: new Date().toISOString()
    }

    // setCompletedSets(prev => [...prev, completedSet]) // 暂时注释，未使用变量
    setShowEditDialog(false)

    // 移动到下一组
    moveToNextSet()
  }

  // 移动到下一组
  const moveToNextSet = () => {
    if (currentSetIndex < totalSets - 1) {
      setCurrentSetIndex(prev => prev + 1)
      setIsResting(true)
      setRestTimeLeft(currentExercise?.restTime || 60)
    } else {
      // 当前练习完成，移动到下一个练习
      moveToNextExercise()
    }
  }

  // 移动到下一个练习
  const moveToNextExercise = () => {
    if (currentExerciseIndex < workoutPlan.exercises.length - 1) {
      setCurrentExerciseIndex(prev => prev + 1)
      setCurrentSetIndex(0)
      setIsResting(false)
      setExerciseElapsedTime(0)
    } else {
      // 训练完成
      completeWorkout()
    }
  }

  // 完成训练
  const completeWorkout = () => {
    stopTimer()
    // 这里可以显示训练完成对话框
    alert('🎉 训练完成！')
    goHome()
  }

  // 放弃训练
  const handleQuitWorkout = () => {
    setShowQuitDialog(true)
  }

  const confirmQuitWorkout = () => {
    stopTimer()
    goBack()
  }

  // 跳过休息
  const handleSkipRest = () => {
    if (isResting) {
      setIsResting(false)
      setExerciseElapsedTime(0)
      setRestTimeLeft(0)
    }
  }

  // 获取下一组信息
  const getNextSetInfo = () => {
    if (currentSetIndex < totalSets - 1) {
      return `下一组: ${currentExercise.exercise.name}`
    }

    // 查找下一个不同的练习
    for (let i = currentExerciseIndex + 1; i < workoutPlan.exercises.length; i++) {
      if (workoutPlan.exercises[i].exercise.name !== currentExercise.exercise.name) {
        const nextExercise = workoutPlan.exercises[i]
        return `下一组: ${nextExercise.exercise.name} ${nextExercise.targetReps}次 × ${formatWeight(nextExercise.targetWeight)}kg`
      }
    }

    return null
  }

  // 启动训练
  React.useEffect(() => {
    startTimer()
    return () => stopTimer()
  }, [])

  // 组件挂载时的初始设置
  React.useEffect(() => {
    if (!workoutPlan || !currentExercise) {
      goBack()
      return
    }
  }, [workoutPlan, currentExercise])

  if (!workoutPlan || !currentExercise) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 flex items-center justify-center">
        <div className="text-white text-xl">
          加载训练数据中...
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900">
      {/* 顶部导航栏 */}
      <div className="bg-white/10 backdrop-blur-md border-b border-white/20">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <GlassButton
              variant="secondary"
              size="sm"
              onClick={handleQuitWorkout}
            >
              ← 返回
            </GlassButton>

            <div className="flex-1 text-center">
              <h1 className="text-lg font-semibold text-white">{workoutPlan.name}</h1>
              <div className="text-sm text-orange-400">{Math.round(progress * 100)}%</div>
            </div>

            <div className="w-16"></div>
          </div>

          {/* 简化的进度条 */}
          <div className="w-full bg-gray-700 rounded-full h-2 mt-2">
            <div
              className="bg-gradient-to-r from-orange-500 to-pink-500 h-2 rounded-full transition-all duration-300"
              style={{ width: `${progress * 100}%` }}
            />
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        {/* 休息时间模块 */}
        {isResting && (
          <GlassCard variant="default" padding="lg" className="mb-6 text-center transform transition-all duration-300">
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-blue-400 mb-2">休息时间</h2>
              <div className="text-4xl font-mono text-blue-300">{formatTime(restTimeLeft)}</div>
            </div>

            <GlassButton
              variant="primary"
              size="lg"
              className="w-full"
              onClick={handleSkipRest}
            >
              跳过休息
            </GlassButton>
          </GlassCard>
        )}

        {/* 运动信息卡片 */}
        <GlassCard variant="default" padding="lg">
          <div className="text-center mb-6">
            <h2 className="text-3xl font-bold text-white mb-4">
              {currentExercise.exercise.name}
            </h2>

            {/* 训练计时 */}
            {!isResting && (
              <div className="mb-6">
                <div className="text-lg text-gray-300 mb-2">动作时间</div>
                <div className="text-4xl font-mono text-orange-400">{formatTime(exerciseElapsedTime)}</div>
              </div>
            )}
          </div>

          <div className="grid grid-cols-2 gap-6 mb-6">
            {/* 当前组数 */}
            <div className="bg-blue-500/10 p-4 rounded-xl text-center">
              <div className="text-sm text-gray-300 mb-1">当前组数</div>
              <div className="text-2xl font-bold text-blue-400">
                {currentSetIndex + 1} / {totalSets}
              </div>
            </div>

            {/* 目标次数 */}
            <div className="bg-green-500/10 p-4 rounded-xl text-center">
              <div className="text-sm text-gray-300 mb-1">目标次数</div>
              <div className="text-2xl font-bold text-green-400">
                {currentExercise.targetReps}
              </div>
            </div>

            {/* 目标重量 */}
            <div className="bg-purple-500/10 p-4 rounded-xl text-center">
              <div className="text-sm text-gray-300 mb-1">目标重量</div>
              <div className="text-2xl font-bold text-purple-400">
                {formatWeight(currentExercise.targetWeight)}kg
              </div>
            </div>

            {/* 训练总时长 */}
            <div className="bg-orange-500/10 p-4 rounded-xl text-center">
              <div className="text-sm text-gray-300 mb-1">训练总时长</div>
              <div className="text-2xl font-bold text-orange-400">
                {formatTime(totalWorkoutTime)}
              </div>
            </div>
          </div>

          {/* 下一组提示 */}
          {getNextSetInfo() && (
            <div className="bg-purple-500/10 p-3 rounded-lg mb-6">
              <div className="flex items-center text-purple-300">
                <svg className="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414L13.414 9l1.293 1.293a1 1 0 010 1.414L11.414 13l1.293 1.293z" clipRule="evenodd" />
                </svg>
                {getNextSetInfo()}
              </div>
            </div>
          )}

          {/* 动作完成按钮 */}
          {!isResting && (
            <GlassButton
              variant="primary"
              size="lg"
              className="w-full text-lg font-semibold"
              onClick={handleCompleteSet}
            >
              动作完成
            </GlassButton>
          )}
        </GlassCard>

        {/* 底部安全区域 */}
        <div className="text-center mt-8">
          <div className="text-gray-400 text-sm">
            React + Capacitor + Tailwind CSS
          </div>
        </div>
      </div>

      {/* 编辑完成记录对话框 */}
      {showEditDialog && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
          <GlassCard variant="default" padding="lg" className="w-full max-w-md mx-4">
            <h3 className="text-xl font-semibold text-white mb-4">动作完成</h3>
            <p className="text-gray-300 mb-6">请输入实际完成次数和重量</p>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">实际次数</label>
                <input
                  type="number"
                  defaultValue={currentExercise.targetReps}
                  className="w-full px-4 py-2 bg-gray-800 text-white rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">实际重量 (kg)</label>
                <input
                  type="number"
                  step="0.5"
                  defaultValue={currentExercise.targetWeight}
                  className="w-full px-4 py-2 bg-gray-800 text-white rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">备注 (可选)</label>
                <textarea
                  rows={3}
                  className="w-full px-4 py-2 bg-gray-800 text-white rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none resize-none"
                />
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <GlassButton
                variant="secondary"
                className="flex-1"
                onClick={() => setShowEditDialog(false)}
              >
                取消
              </GlassButton>
              <GlassButton
                variant="primary"
                className="flex-1"
                onClick={() => {
                  // 获取输入值并保存
                  const inputs = document.querySelectorAll('input, textarea')
                  const actualReps = parseInt((inputs[0] as HTMLInputElement).value)
                  const actualWeight = parseFloat((inputs[1] as HTMLInputElement).value)
                  const notes = (inputs[2] as HTMLTextAreaElement).value
                  saveCompletedSet(actualReps, actualWeight, notes)
                }}
              >
                确认完成
              </GlassButton>
            </div>
          </GlassCard>
        </div>
      )}

      {/* 放弃训练确认对话框 */}
      {showQuitDialog && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
          <GlassCard variant="default" padding="lg" className="w-full max-w-md mx-4">
            <h3 className="text-xl font-semibold text-white mb-4">放弃训练？</h3>
            <p className="text-gray-300 mb-6">确定要放弃当前训练吗？已完成的训练记录将被保存。</p>

            <div className="flex gap-3">
              <GlassButton
                variant="secondary"
                className="flex-1"
                onClick={() => setShowQuitDialog(false)}
              >
                继续训练
              </GlassButton>
              <GlassButton
                variant="secondary"
                className="flex-1"
                onClick={confirmQuitWorkout}
              >
                确认放弃
              </GlassButton>
            </div>
          </GlassCard>
        </div>
      )}
    </div>
  )
}

export default WorkoutScreen
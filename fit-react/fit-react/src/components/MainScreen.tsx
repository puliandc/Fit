//created by Jason Lu on 10:50:00 10/27/2025
import React from 'react'
import { GlassCard, GlassButton } from './index'
import FileUploadButton from './FileUploadButton'
import { useNavigationActions } from '../context/NavigationContext'

interface WorkoutPlan {
  id: string
  name: string
  duration: number
  exercises: any[]
}

const MainScreen: React.FC = () => {
  const { navigateTo, setWorkoutPlan } = useNavigationActions()
  const [workoutPlan, setWorkoutPlanState] = React.useState<WorkoutPlan | null>(null)

  // 处理文件加载完成
  const handleFileLoaded = (plan: WorkoutPlan) => {
    console.log('训练计划加载成功:', plan)
    setWorkoutPlanState(plan)
    setWorkoutPlan(plan)
  }

  // 处理文件加载错误
  const handleError = (error: string) => {
    console.error('文件加载错误:', error)
    alert(error)
  }

  // 开始训练
  const handleStartWorkout = () => {
    if (workoutPlan) {
      navigateTo('workout', workoutPlan)
    }
  }

  // 计算统计信息
  const exerciseCount = workoutPlan ? new Set(workoutPlan.exercises.map(e => e.exercise?.name || e.name)).size : 0
  const totalSets = workoutPlan ? workoutPlan.exercises.length : 0

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900">
      <div className="container mx-auto px-4 py-8">
        {/* 头部Logo */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-white mb-4">
            Fit Training
          </h1>
          <p className="text-xl text-gray-300">
            专业健身训练记录应用
          </p>
        </div>

        {/* 主要功能区域 */}
        <div className="max-w-2xl mx-auto space-y-6">
          {/* 开始训练卡片 - 仅在已加载训练计划时显示 */}
          {workoutPlan && (
            <GlassCard variant="default" padding="lg" className="transform transition-all duration-300 hover:scale-105">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mr-4">
                  <svg className="w-6 h-6 text-green-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 00016zm1-11a1 1 0 10-2 0v2a1 1 0 102 0v-2zM9 9a1 1 0 012 0v2a1 1 0 11-2 0V9z" clipRule="evenodd" />
                  </svg>
                </div>
                <div className="flex-1">
                  <h2 className="text-2xl font-semibold text-white mb-1">
                    开始训练
                  </h2>
                  <p className="text-gray-300">
                    计划已准备就绪，开始今天的训练！
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4 mb-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-400">{exerciseCount}</div>
                  <div className="text-sm text-gray-400">动作数量</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-400">{totalSets}</div>
                  <div className="text-sm text-gray-400">总组数</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-orange-400">{workoutPlan.duration}</div>
                  <div className="text-sm text-gray-400">预估分钟</div>
                </div>
              </div>

              <GlassButton
                variant="primary"
                size="lg"
                className="w-full text-lg font-semibold"
                onClick={handleStartWorkout}
              >
                开始训练
              </GlassButton>
            </GlassCard>
          )}

          {/* 训练计划摘要卡片 - 显示已加载计划的详细信息 */}
          {workoutPlan && (
            <GlassCard variant="default" padding="lg">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mr-4">
                  <svg className="w-6 h-6 text-blue-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M6 2a2 2 0 00-2 2v11a2 2 0 002 2h8a2 2 0 002-2V4h2V3a1 1 0 00-1-1h-.5a1 1 0 00-1 .5v1z" clipRule="evenodd" />
                  </svg>
                </div>
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-white mb-1">
                    训练计划详情
                  </h3>
                  <p className="text-gray-300">
                    {workoutPlan.name}
                  </p>
                </div>
              </div>

              {/* 练习项目预览 */}
              <div className="mb-4">
                <div className="flex items-center justify-between mb-3">
                  <h4 className="text-sm font-medium text-gray-300">练习项目</h4>
                  <span className="text-xs text-gray-400">
                    显示前5个，共{workoutPlan.exercises.length}个
                  </span>
                </div>
                <div className="space-y-2">
                  {workoutPlan.exercises.slice(0, 5).map((exercise: any, index: number) => (
                    <div key={index} className="flex items-center justify-between p-2 bg-gray-800/30 rounded-lg">
                      <span className="text-sm text-gray-300">
                        {exercise.exercise?.name || exercise.name || '未知动作'}
                      </span>
                      <span className="text-xs text-gray-400">
                        {exercise.targetReps || exercise.reps}次 × {exercise.targetWeight || exercise.weight || 0}kg
                      </span>
                    </div>
                  ))}
                </div>
                {workoutPlan.exercises.length > 5 && (
                  <div className="text-center text-xs text-gray-400 mt-2">
                    ... 还有{workoutPlan.exercises.length - 5}个练习项目
                  </div>
                )}
              </div>
            </GlassCard>
          )}

          {/* 读取健身计划卡片 - 文件选择和JSON解析入口 */}
          <GlassCard variant="default" padding="lg" className="transform transition-all duration-300 hover:scale-105">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-blue-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-5L9 2H4z" clipRule="evenodd" />
                </svg>
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-semibold text-white mb-1">
                  读取健身计划
                </h3>
                <p className="text-gray-300">
                  {workoutPlan ? '重新读取训练计划' : '请选择JSON格式的训练计划文件'}
                </p>
              </div>
            </div>

            <FileUploadButton
              onFileLoaded={handleFileLoaded}
              onError={handleError}
              className="w-full"
            />
          </GlassCard>
        </div>

        {/* 功能预览卡片 */}
        <div className="max-w-2xl mx-auto grid md:grid-cols-2 gap-6 mt-8">
          <GlassCard variant="light" padding="md" className="transform transition-all duration-300 hover:scale-105">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-green-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 00016zm1-11a1 1 0 10-2 0v2a1 1 0 102 0v-2zM9 9a1 1 0 012 0v2a1 1 0 11-2 0V9z" clipRule="evenodd" />
                </svg>
              </div>
              <h3 className="text-lg font-semibold">训练记录</h3>
            </div>
            <p className="text-gray-300">
              查看历史训练数据和进度统计
            </p>
          </GlassCard>

          <GlassCard variant="light" padding="md" className="transform transition-all duration-300 hover:scale-105">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-purple-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M11.49 3.17c-.38-1.56-2.6-1.56-2.98 0a1.532 1.532 0 00-2.286.948c-.782.576-1.432 1.45-1.487 2.31l.547 1.93a2.311 2.311 0 01-.95 3.17l1.625.513a2.313 2.313 0 012.795 0l1.623-.513a2.316 2.316 0 01-.951-3.17z" clipRule="evenodd" />
                </svg>
              </div>
              <h3 className="text-lg font-semibold">应用设置</h3>
            </div>
            <p className="text-gray-300">
              个性化配置和偏好设置
            </p>
          </GlassCard>
        </div>

        {/* 底部安全区域 */}
        <div className="text-center text-gray-400 text-sm mt-12">
          <p>React + Capacitor + Tailwind CSS</p>
          <p className="text-xs mt-1">玻璃态设计系统 v1.0</p>
        </div>
      </div>
    </div>
  )
}

export default MainScreen
//created by Jason Lu on 16:45:00 10/27/2025
import React from 'react'
import { GlassCard, GlassButton } from './index'

interface WorkoutStatsProps {
  onBack: () => void
}

interface WorkoutStatistics {
  totalWorkouts: number
  totalDuration: number
  totalExercises: number
  totalVolume: number
  averageWorkoutDuration: number
  mostFrequentDay: string
  longestStreak: number
  currentStreak: number
}

const WorkoutStats: React.FC<WorkoutStatsProps> = ({ onBack }) => {
  // 模拟统计数据 - 实际应用中应该从状态管理或服务获取
  const [stats] = React.useState<WorkoutStatistics>({
    totalWorkouts: 12,
    totalDuration: 720, // 分钟
    totalExercises: 156,
    totalVolume: 8640, // 总重量 x 次数
    averageWorkoutDuration: 60,
    mostFrequentDay: '周一',
    longestStreak: 7,
    currentStreak: 3
  })

  const formatTime = (minutes: number): string => {
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    if (hours > 0) {
      return `${hours}小时${mins > 0 ? mins + '分钟' : ''}`
    }
    return `${mins}分钟`
  }

  const formatWeight = (weight: number): string => {
    if (weight >= 1000) {
      return `${(weight / 1000).toFixed(1)}吨`
    }
    return `${weight}kg`
  }

  const getStreakColor = (streak: number): string => {
    if (streak >= 7) return 'text-green-400'
    if (streak >= 3) return 'text-blue-400'
    return 'text-gray-400'
  }

  const getProgressPercentage = (current: number, total: number): number => {
    return total > 0 ? Math.min((current / total) * 100, 100) : 0
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 text-white p-4">
      {/* 顶部导航 */}
      <div className="mb-6">
        <GlassButton
          variant="secondary"
          onClick={onBack}
          className="mb-4"
        >
          ← 返回主页
        </GlassButton>
      </div>

      {/* 统计概览 */}
      <GlassCard variant="default" padding="lg" className="mb-6">
        <h2 className="text-2xl font-bold text-white mb-6 text-center">
          训练统计
        </h2>

        {/* 主要指标网格 */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <div className="text-center">
            <div className="text-3xl font-bold text-blue-400 mb-1">
              {stats.totalWorkouts}
            </div>
            <div className="text-sm text-gray-300">
              总训练次数
            </div>
          </div>

          <div className="text-center">
            <div className="text-3xl font-bold text-green-400 mb-1">
              {formatTime(stats.totalDuration)}
            </div>
            <div className="text-sm text-gray-300">
              总训练时长
            </div>
          </div>

          <div className="text-center">
            <div className="text-3xl font-bold text-purple-400 mb-1">
              {stats.totalExercises}
            </div>
            <div className="text-sm text-gray-300">
              总动作数
            </div>
          </div>

          <div className="text-center">
            <div className="text-3xl font-bold text-orange-400 mb-1">
              {formatWeight(stats.totalVolume)}
            </div>
            <div className="text-sm text-gray-300">
              总训练容量
            </div>
          </div>
        </div>

        {/* 连续训练天数 */}
        <div className="border-t border-gray-600 pt-6">
          <div className="flex justify-between items-center mb-4">
            <span className="text-gray-300">连续训练天数</span>
            <span className={`text-2xl font-bold ${getStreakColor(stats.currentStreak)}`}>
              {stats.currentStreak} 天
            </span>
          </div>

          {/* 进度条 */}
          <div className="w-full bg-gray-700 rounded-full h-3 mb-4">
            <div
              className="bg-gradient-to-r from-green-500 to-blue-500 h-3 rounded-full transition-all duration-500"
              style={{ width: `${getProgressPercentage(stats.currentStreak, stats.longestStreak)}%` }}
            ></div>
          </div>
          <div className="flex justify-between text-sm text-gray-400">
            <span>当前: {stats.currentStreak} 天</span>
            <span>最长: {stats.longestStreak} 天</span>
          </div>
        </div>
      </GlassCard>

      {/* 详细统计 */}
      <div className="grid md:grid-cols-2 gap-6 mb-6">
        {/* 平均数据 */}
        <GlassCard variant="default" padding="md">
          <h3 className="text-lg font-semibold text-white mb-4">
            平均数据
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-300">平均训练时长</span>
              <span className="text-white font-mono">
                {formatTime(stats.averageWorkoutDuration)}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-300">平均每周训练</span>
              <span className="text-white font-mono">
                {(stats.totalWorkouts / 4.33).toFixed(1)} 次
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-300">最常训练日</span>
              <span className="text-white font-mono">
                {stats.mostFrequentDay}
              </span>
            </div>
          </div>
        </GlassCard>

        {/* 月度统计 */}
        <GlassCard variant="default" padding="md">
          <h3 className="text-lg font-semibold text-white mb-4">
            本月统计
          </h3>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-300">本月训练次数</span>
              <span className="text-white font-mono">8 次</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-300">本月总时长</span>
              <span className="text-white font-mono">480 分钟</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-300">月度目标完成</span>
              <div className="flex items-center gap-2">
                <div className="w-20 bg-gray-700 rounded-full h-2">
                  <div
                    className="bg-green-500 h-2 rounded-full transition-all duration-500"
                    style={{ width: '66.67%' }} // 8/12 = 66.67%
                  ></div>
                </div>
                <span className="text-white text-sm">67%</span>
              </div>
            </div>
          </div>
        </GlassCard>
      </div>

      {/* 训练记录预览 */}
      <GlassCard variant="light" padding="md" className="mb-6">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold">
            最近训练
          </h3>
          <GlassButton
            variant="secondary"
            size="sm"
          >
            查看全部
          </GlassButton>
        </div>

        {/* 最近5次训练记录 */}
        <div className="space-y-2">
          {['胸部训练', '腿部训练', 'HIIT有氧', '全身训练', '瑜伽拉伸'].map((workout, index) => (
            <div
                  key={index}
                  className="flex justify-between items-center p-3 bg-gray-800/50 rounded-lg"
            >
              <div className="flex-1">
                <div className="font-medium text-white">{workout}</div>
                <div className="text-sm text-gray-400">
                  {['周一', '周三', '周四', '周六', '周日', '周一'][index]} · {45 + index * 5} 分钟
                </div>
              </div>
              <div className="text-right">
                <span className="text-xs text-gray-500">查看详情 →</span>
              </div>
            </div>
          ))}
        </div>
      </GlassCard>

      {/* 激励信息 */}
      <GlassCard variant="default" padding="md" className="text-center">
        <div className="mb-3">
          <span className="text-2xl">🎯</span>
        </div>
        <p className="text-white font-medium mb-2">
          坚持就是胜利！
        </p>
        <p className="text-gray-300 text-sm">
          继续保持训练习惯，你正在变得更强壮！
        </p>
      </GlassCard>
    </div>
  )
}

export default WorkoutStats
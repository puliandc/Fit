//created by Jason Lu on 10:35:00 10/28/2025
import React from 'react'
import { GlassButton } from './index'
import { useNavigationActions } from '../context/NavigationContext'
import { getQuickTestWorkoutPlan } from '../utils/mockData'

interface QuickTestButtonProps {
  className?: string
}

/**
 * 快速测试按钮组件
 * 提供最小化mock数据的直接跳转功能
 */
const QuickTestButton: React.FC<QuickTestButtonProps> = ({ className = '' }) => {
  const { navigateTo, setWorkoutPlan } = useNavigationActions()

  const handleQuickTest = () => {
    console.log('启动快速测试模式...')

    try {
      // 获取mock数据
      const mockPlan = getQuickTestWorkoutPlan()

      // 设置训练计划
      setWorkoutPlan(mockPlan)

      // 延迟一下确保状态更新后再跳转
      setTimeout(() => {
        navigateTo('workout', mockPlan)
      }, 100)

      console.log('快速测试训练计划已设置:', mockPlan.name)
    } catch (error) {
      console.error('快速测试启动失败:', error)
      alert('快速测试启动失败，请检查控制台')
    }
  }

  return (
    <GlassButton
      variant="secondary"
      size="md"
      className={`w-full text-sm font-medium ${className}`}
      onClick={handleQuickTest}
    >
      🚀 快速测试
    </GlassButton>
  )
}

export default QuickTestButton
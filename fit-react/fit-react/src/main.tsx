//created by Jason Lu on 10:55:00 10/27/2025
import React from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'
import './index.css'

// 导入导航和组件
import { NavigationProvider, useNavigation, useNavigationActions } from './context/NavigationContext'
import MainScreen from './components/MainScreen'
import WorkoutScreen from './components/WorkoutScreen'
import WorkoutPlanList from './components/WorkoutPlanList'
import WorkoutStats from './components/WorkoutStats'

// 应用内容组件
function AppContent() {
  const { state } = useNavigation()
  const { navigateTo } = useNavigationActions()

  // 根据当前页面渲染不同组件
  const renderCurrentPage = () => {
    switch (state.currentPage) {
      case 'main':
        return <MainScreen />

      case 'workout':
        return <WorkoutScreen />

      case 'settings':
        return (
          <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 flex items-center justify-center">
            <div className="text-white text-center">
              <h1 className="text-2xl font-bold mb-4">设置</h1>
              <p className="text-gray-300 mb-6">应用设置和配置选项</p>
              <button
                onClick={() => navigateTo('main')}
                className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                返回主页
              </button>
            </div>
          </div>
        )

      case 'history':
        return (
          <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 flex items-center justify-center">
            <div className="text-white text-center">
              <h1 className="text-2xl font-bold mb-4">历史记录</h1>
              <p className="text-gray-300 mb-6">查看您的训练历史和进度</p>
              <button
                onClick={() => navigateTo('main')}
                className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                返回主页
              </button>
            </div>
          </div>
        )

      default:
        return <MainScreen />
    }
  }

  return renderCurrentPage()
}

// 应用根组件
function App() {
  return (
    <NavigationProvider>
      <AppContent />
    </NavigationProvider>
  )
}

// 渲染应用
createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
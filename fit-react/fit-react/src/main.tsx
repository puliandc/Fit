//created by Jason Lu on 10:55:00 10/27/2025
import React from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'
import './index.css'

// 导入导航和组件
import { NavigationProvider, useNavigation, useNavigationActions } from './context/NavigationContext'
import MainScreen from './components/MainScreen'
import WorkoutScreen from './components/WorkoutScreen'
import MobileContainer from './components/MobileContainer'
import SafeAreaContainer from './components/SafeAreaContainer'

// 应用内容组件
function AppContent() {
  const { state } = useNavigation()
  const { navigateTo } = useNavigationActions()

  // 根据当前页面渲染不同组件 - 与Swift版本保持一致
  const renderCurrentPage = () => {
    switch (state.currentPage) {
      case 'main':
        return <MainScreen />

      case 'workout':
        return <WorkoutScreen />

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
      <SafeAreaContainer top bottom>
        <MobileContainer maxWidth="md" className="min-h-screen">
          <AppContent />
        </MobileContainer>
      </SafeAreaContainer>
    </NavigationProvider>
  )
}

// 渲染应用
createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
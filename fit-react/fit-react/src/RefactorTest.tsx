//created by Jason Lu on 10:50:00 10/27/2025
import React from 'react'
import { NavigationProvider } from '../src/context/NavigationContext'
import MainScreen from '../src/components/MainScreen'

// 简单的重构验证测试
const RefactorTest: React.FC = () => {
  return (
    <NavigationProvider>
      <div style={{ padding: '20px' }}>
        <h1>重构验证测试</h1>
        <p>测试MainScreen组件是否正常渲染</p>
        <div style={{ border: '1px solid #ccc', padding: '10px', marginTop: '20px' }}>
          <MainScreen />
        </div>
      </div>
    </NavigationProvider>
  )
}

export default RefactorTest
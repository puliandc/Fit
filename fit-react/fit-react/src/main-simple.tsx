//created by Jason Lu on 16:19:00 10/27/2025
import React from 'react'
import { createRoot } from 'react-dom/client'

console.log('🚀 开始加载React应用...')

// 简单的测试组件
function SimpleApp() {
  console.log('📦 SimpleApp组件正在渲染...')
  return React.createElement('div', {
    style: {
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #581c87 100%)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      color: 'white',
      padding: '2rem'
    }
  }, [
    React.createElement('h1', {
      key: 'title',
      style: {
        fontSize: '2.5rem',
        fontWeight: 'bold',
        marginBottom: '1rem',
        background: 'linear-gradient(to right, #60a5fa, #93c5fd)',
        WebkitBackgroundClip: 'text',
        backgroundClip: 'text',
        WebkitTextFillColor: 'transparent',
        color: 'transparent'
      }
    }, '🎉 React 应用运行成功！'),

    React.createElement('div', {
      key: 'status',
      style: {
        background: 'rgba(16, 185, 129, 0.1)',
        backdropFilter: 'blur(16px)',
        border: '1px solid rgba(16, 185, 129, 0.3)',
        borderRadius: '1rem',
        padding: '2rem',
        textAlign: 'center',
        maxWidth: '400px'
      }
    }, [
        React.createElement('h2', {
          key: 'subtitle',
          style: { marginBottom: '1rem', color: 'white' }
        }, '✅ React DOM 挂载成功'),

        React.createElement('p', {
          key: 'message',
          style: { marginBottom: '1rem', color: '#e2e8f0' }
        }, '所有核心功能已正常工作'),

        React.createElement('div', {
          key: 'details',
          style: { fontSize: '0.875rem', color: 'rgba(255, 255, 255, 0.7)' }
        }, [
          'React: ', React.version,
          React.createElement('br', { key: 'br1' }),
          'TypeScript: ✅',
          React.createElement('br', { key: 'br2' }),
          'Vite: ✅'
        ])
      ])
  ])
}

console.log('🎯 准备挂载React应用...')

try {
  const container = document.getElementById('root')
  console.log('📦 Root元素:', container)

  if (container) {
    const root = createRoot(container)
    console.log('🚀 React root创建成功')

    root.render(
      React.createElement(React.StrictMode, null,
        React.createElement(SimpleApp)
      )
    )
    console.log('✅ React应用挂载成功！')
  } else {
    console.error('❌ 找不到root元素')
  }
} catch (error) {
  console.error('❌ React应用挂载失败:', error)
}
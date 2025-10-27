//created by Jason Lu on 16:00:00 10/26/2025
import React from 'react'

const MinimalTest: React.FC = () => {
  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #581c87 100%)',
      padding: '2rem',
      fontFamily: 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
      color: 'white',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center'
    }}>
      <h1 style={{
        fontSize: '2.5rem',
        fontWeight: 'bold',
        marginBottom: '1rem',
        background: 'linear-gradient(to right, #60a5fa, #93c5fd)',
        WebkitBackgroundClip: 'text',
        backgroundClip: 'text',
        WebkitTextFillColor: 'transparent',
        color: 'transparent'
      }}>
        Fit Training React App
      </h1>

      <div style={{
        background: 'rgba(255, 255, 255, 0.15)',
        backdropFilter: 'blur(16px)',
        border: '1px solid rgba(255, 255, 255, 0.2)',
        borderRadius: '1rem',
        padding: '2rem',
        marginTop: '2rem',
        boxShadow: '0 8px 32px rgba(31, 38, 135, 0.37)',
        maxWidth: '400px'
      }}>
        <h2 style={{ color: 'white', marginBottom: '1rem' }}>
          React + Capacitor 项目状态
        </h2>

        <div style={{ marginBottom: '1rem', textAlign: 'center' }}>
          <span style={{
            display: 'inline-block',
            width: '12px',
            height: '12px',
            backgroundColor: '#60a5fa',
            borderRadius: '50%',
            marginRight: '8px'
          }}></span>
          <span style={{ color: '#e2e8f0', marginLeft: '8px' }}>✅ Vite 7.1.12 运行正常</span>
        </div>

        <div style={{ marginBottom: '1rem', textAlign: 'center' }}>
          <span style={{
            display: 'inline-block',
            width: '12px',
            height: '12px',
            backgroundColor: '#10b981',
            borderRadius: '50%',
            marginRight: '8px'
          }}></span>
          <span style={{ color: '#e2e8f0', marginLeft: '8px' }}>📱 React 19.2.0 导入正确</span>
        </div>

        <div style={{ marginBottom: '1rem', textAlign: 'center' }}>
          <span style={{
            display: 'inline-block',
            width: '12px',
            height: '12px',
            backgroundColor: '#f59e0b',
            borderRadius: '50%',
            marginRight: '8px'
          }}></span>
          <span style={{ color: '#e2e8f0', marginLeft: '8px' }}>🎨 玻璃态UI组件正常</span>
        </div>

        <div style={{ marginBottom: '1rem', textAlign: 'center' }}>
          <span style={{
            display: 'inline-block',
            width: '12px',
            height: '12px',
            backgroundColor: '#22c55e',
            borderRadius: '50%',
            marginRight: '8px'
          }}></span>
          <span style={{ color: '#e2e8f0', marginLeft: '8px' }}>🔧 热重载工作正常</span>
        </div>
      </div>

      <div style={{
        marginTop: '2rem',
        background: 'rgba(0, 0, 0, 0.2)',
        backdropFilter: 'blur(16px)',
        border: '1px solid rgba(255, 255, 255, 0.2)',
        borderRadius: '1rem',
        padding: '2rem',
        textAlign: 'center'
      }}>
        <button
          style={{
            background: 'rgba(255, 255, 255, 0.1)',
            backdropFilter: 'blur(8px)',
            border: '1px solid rgba(255, 255, 255, 0.2)',
            borderRadius: '0.75rem',
            padding: '0.75rem 1.5rem',
            color: 'white',
            fontWeight: '600',
            cursor: 'pointer',
            transition: 'all 0.2s ease-in-out',
            fontSize: '1rem',
            marginBottom: '1rem'
          }}
          onMouseOver={(e) => (e.target as HTMLElement).style.transform = 'scale(1.05)'}
          onMouseOut={(e) => (e.target as HTMLElement).style.transform = 'scale(1)'}
        >
          测试交互效果
        </button>
      </div>

      <div style={{
        marginTop: '2rem',
        textAlign: 'center',
        fontSize: '1.125rem',
        color: 'rgba(255, 255, 255, 0.6)'
      }}>
        <p>访问路径: http://localhost:3000/</p>
        <p>现在请打开这个URL直接访问最小化测试页面</p>
      </div>
    </div>
  )
}

export default MinimalTest
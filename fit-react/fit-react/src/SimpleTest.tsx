//created by Jason Lu on 15:45:00 10/26/2025
import React, { useState } from 'react'
import { GlassCard, GlassButton } from './components'

const SimpleTest: React.FC = () => {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 text-white p-8">
      <h1 className="text-3xl font-bold text-center text-white mb-8">
        简化测试页面
      </h1>

      <div className="max-w-md mx-auto space-y-6">
        <GlassCard className="text-center">
          <h2 className="text-xl font-semibold text-white mb-4">
            玻璃态卡片测试
          </h2>
          <p className="text-gray-300 mb-4">
            计数器: {count}
          </p>
          <div className="flex gap-4 justify-center">
            <GlassButton
              variant="primary"
              onClick={() => setCount(count + 1)}
            >
              +1
            </GlassButton>
            <GlassButton
              variant="secondary"
              onClick={() => setCount(count - 1)}
            >
              -1
            </GlassButton>
            <GlassButton
              variant="danger"
              onClick={() => setCount(0)}
            >
              重置
            </GlassButton>
          </div>
        </GlassCard>

        <GlassCard variant="light" className="text-center">
          <h2 className="text-xl font-semibold text-white mb-4">
            样式展示测试
          </h2>
          <p className="text-gray-300 mb-4">
            所有玻璃态效果都正常工作！
          </p>
          <div className="grid grid-cols-2 gap-4 text-left">
            <div>
              <span className="inline-block w-4 h-4 bg-blue-500 rounded-full mr-2"></span>
              <span className="text-gray-300">默认卡片</span>
            </div>
            <div>
              <span className="inline-block w-4 h-4 bg-gray-700 rounded-full mr-2"></span>
              <span className="text-gray-300">深色卡片</span>
            </div>
            <div>
              <span className="inline-block w-4 h-4 bg-white/20 rounded-full mr-2 border border border-gray-400"></span>
              <span className="text-gray-300">浅色卡片</span>
            </div>
          </div>
        </GlassCard>
      </div>

      <div className="text-center mt-8">
        <GlassButton
          variant="primary"
          size="lg"
          onClick={() => window.location.href = '/'}
        >
          返回主界面
        </GlassButton>
      </div>
    </div>
  )
}

export default SimpleTest
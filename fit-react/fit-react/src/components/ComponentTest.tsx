//created by Jason Lu on 15:30:00 10/26/2025
import React, { useState } from 'react'
import { GlassCard, GlassButton, GlassInput } from './index'

const ComponentTest: React.FC = () => {
  const [inputValue, setInputValue] = useState('')
  const [loading, setLoading] = useState(false)
  const [buttonVariant, setButtonVariant] = useState<'primary' | 'secondary' | 'danger'>('primary')

  const handleButtonClick = () => {
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      setButtonVariant(buttonVariant === 'primary' ? 'secondary' : 'primary')
    }, 2000)
  }

  return (
    <div className="min-h-screen p-8 space-y-8">
      <h1 className="text-3xl font-bold text-white text-center mb-8">UI 组件测试</h1>

      {/* GlassCard 测试 */}
      <div className="space-y-4">
        <h2 className="text-2xl font-semibold text-white">玻璃态卡片测试</h2>

        <div className="grid md:grid-cols-3 gap-4">
          <GlassCard variant="default" padding="md">
            <h3 className="text-white font-medium">默认卡片</h3>
            <p className="text-gray-300 text-sm">这是默认样式的玻璃态卡片</p>
          </GlassCard>

          <GlassCard variant="dark" padding="md">
            <h3 className="text-white font-medium">深色卡片</h3>
            <p className="text-gray-300 text-sm">这是深色样式的玻璃态卡片</p>
          </GlassCard>

          <GlassCard variant="light" padding="md" hover={true}>
            <h3 className="text-white font-medium">浅色卡片</h3>
            <p className="text-gray-300 text-sm">这是浅色样式的玻璃态卡片（带悬停）</p>
          </GlassCard>
        </div>
      </div>

      {/* GlassButton 测试 */}
      <div className="space-y-4">
        <h2 className="text-2xl font-semibold text-white">玻璃态按钮测试</h2>

        <div className="grid md:grid-cols-3 gap-4">
          <GlassButton
            variant="primary"
            size="sm"
            onClick={() => console.log('Primary Small clicked')}
          >
            主要按钮小
          </GlassButton>

          <GlassButton
            variant="secondary"
            size="md"
            onClick={() => console.log('Secondary Medium clicked')}
          >
            次要按钮中
          </GlassButton>

          <GlassButton
            variant="danger"
            size="lg"
            onClick={() => console.log('Danger Large clicked')}
          >
            危险按钮大
          </GlassButton>
        </div>

        <div className="flex space-x-4">
          <GlassButton
            variant={buttonVariant}
            loading={loading}
            onClick={handleButtonClick}
          >
            {loading ? '加载中...' : '点击切换状态'}
          </GlassButton>

          <GlassButton disabled>
            禁用按钮
          </GlassButton>
        </div>
      </div>

      {/* GlassInput 测试 */}
      <div className="space-y-4">
        <h2 className="text-2xl font-semibold text-white">玻璃态输入框测试</h2>

        <div className="grid md:grid-cols-2 gap-4">
          <GlassInput
            type="text"
            label="文本输入"
            placeholder="请输入文本..."
            value={inputValue}
            onChange={setInputValue}
          />

          <GlassInput
            type="number"
            label="数字输入"
            placeholder="请输入数字..."
            required
          />

          <GlassInput
            type="email"
            label="邮箱输入"
            placeholder="请输入邮箱..."
          />

          <GlassInput
            type="password"
            label="密码输入"
            placeholder="请输入密码..."
          />
        </div>

        <GlassInput
          type="text"
          label="错误状态输入框"
          placeholder="这里会显示错误..."
          error={true}
          errorMessage="这是错误提示信息"
        />
      </div>
    </div>
  )
}

export default ComponentTest
//created by Jason Lu on 14:55:00 10/27/2025
import { useState, useEffect } from 'react'
import { cn } from './utils'
import { useMobileDetection } from '../../hooks/use-mobile-detection'

interface MobileDevToolsProps {
  className?: string
}

/**
 * 移动端开发调试工具
 * 仅在开发环境下显示
 */
export function MobileDevTools({ className }: MobileDevToolsProps) {
  const [isVisible, setIsVisible] = useState(false)
  const { isMobile, screenWidth, screenHeight, orientation, safeArea } = useMobileDetection()

  useEffect(() => {
    // 只在开发环境显示
    if (process.env.NODE_ENV === 'development') {
      setIsVisible(true)
    }
  }, [])

  if (!isVisible || typeof window === 'undefined') {
    return null
  }

  return (
    <div
      className={cn(
        'fixed top-2 right-2 z-50 bg-black/80 text-white p-3 rounded-lg text-xs font-mono',
        'backdrop-blur-sm border border-white/20',
        'max-w-xs overflow-hidden',
        className
      )}
    >
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <span className="text-yellow-400">Mobile Dev Tools</span>
          <button
            onClick={() => setIsVisible(false)}
            className="text-red-400 hover:text-red-300 ml-2"
          >
            ✕
          </button>
        </div>

        <div className="border-t border-white/20 pt-2 space-y-1">
          <div className="flex justify-between">
            <span className="text-gray-400">Device:</span>
            <span className={cn(
              isMobile ? 'text-green-400' : 'text-orange-400'
            )}>
              {isMobile ? 'Mobile' : 'Desktop'}
            </span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-400">Screen:</span>
            <span>{screenWidth}×{screenHeight}</span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-400">Orientation:</span>
            <span>{orientation}</span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-400">Safe Area:</span>
            <span className="text-right">
              T:{safeArea.top} B:{safeArea.bottom}<br/>
              L:{safeArea.left} R:{safeArea.right}
            </span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-400">Pixel Ratio:</span>
            <span>{window.devicePixelRatio || 1}</span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-400">Touch:</span>
            <span className={cn(
              'ontouchstart' in window ? 'text-green-400' : 'text-red-400'
            )}>
              {'ontouchstart' in window ? 'Yes' : 'No'}
            </span>
          </div>
        </div>

        <div className="border-t border-white/20 pt-2">
          <button
            onClick={() => window.location.reload()}
            className="w-full bg-blue-600 hover:bg-blue-500 text-white py-1 px-2 rounded text-xs"
          >
            Reload
          </button>
        </div>
      </div>
    </div>
  )
}

interface DeviceFrameProps {
  children: React.ReactNode
  device?: 'iphone-se' | 'iphone-12' | 'iphone-14-pro-max' | 'android-small' | 'android-large'
  className?: string
}

/**
 * 设备框架组件
 * 用于在不同设备尺寸下测试界面
 */
export function DeviceFrame({
  children,
  device = 'iphone-14-pro-max',
  className
}: DeviceFrameProps) {
  const deviceConfigs = {
    'iphone-se': {
      width: '375px',
      height: '667px',
      borderRadius: '1.5rem',
      name: 'iPhone SE'
    },
    'iphone-12': {
      width: '390px',
      height: '844px',
      borderRadius: '2rem',
      name: 'iPhone 12'
    },
    'iphone-14-pro-max': {
      width: '430px',
      height: '932px',
      borderRadius: '2.5rem',
      name: 'iPhone 14 Pro Max'
    },
    'android-small': {
      width: '360px',
      height: '640px',
      borderRadius: '1rem',
      name: 'Android Small'
    },
    'android-large': {
      width: '412px',
      height: '892px',
      borderRadius: '1.5rem',
      name: 'Android Large'
    }
  }

  const config = deviceConfigs[device]

  if (process.env.NODE_ENV !== 'development') {
    return <>{children}</>
  }

  return (
    <div className={cn('flex items-center justify-center min-h-screen bg-gray-100 p-8', className)}>
      <div className="space-y-4">
        <div className="text-center">
          <h3 className="text-lg font-semibold text-gray-800">{config.name}</h3>
          <p className="text-sm text-gray-600">{config.width} × {config.height}</p>
        </div>

        <div
          className="relative bg-black shadow-2xl"
          style={{
            width: config.width,
            height: config.height,
            borderRadius: config.borderRadius
          }}
        >
          {/* 设备边框装饰 */}
          <div className="absolute inset-x-0 top-0 h-6 bg-black rounded-t-[inherit]" />
          <div className="absolute top-2 left-1/2 transform -translate-x-1/2 w-20 h-4 bg-black rounded-full" />

          {/* 屏幕内容区域 */}
          <div
            className="absolute inset-2 bg-white overflow-hidden"
            style={{
              borderRadius: `calc(${config.borderRadius} - 0.5rem)`
            }}
          >
            {children}
          </div>

          {/* Home indicator */}
          <div className="absolute bottom-2 left-1/2 transform -translate-x-1/2 w-32 h-1 bg-gray-600 rounded-full" />
        </div>
      </div>
    </div>
  )
}

interface ResponsiveTestProps {
  children: React.ReactNode
  className?: string
}

/**
 * 响应式测试工具
 * 显示当前断点和容器信息
 */
export function ResponsiveTest({ children, className }: ResponsiveTestProps) {
  const [breakpoint, setBreakpoint] = useState<string>('')
  const [containerWidth, setContainerWidth] = useState<number>(0)

  useEffect(() => {
    const updateBreakpoint = () => {
      const width = window.innerWidth
      let currentBreakpoint = ''

      if (width < 375) {
        currentBreakpoint = 'xs'
      } else if (width < 428) {
        currentBreakpoint = 'sm'
      } else if (width < 640) {
        currentBreakpoint = 'md'
      } else if (width < 768) {
        currentBreakpoint = 'lg'
      } else if (width < 1024) {
        currentBreakpoint = 'xl'
      } else {
        currentBreakpoint = '2xl'
      }

      setBreakpoint(currentBreakpoint)

      // 检测主容器宽度
      const mainContainer = document.querySelector('.mobile-container') as HTMLElement
      if (mainContainer) {
        setContainerWidth(mainContainer.offsetWidth)
      }
    }

    updateBreakpoint()
    window.addEventListener('resize', updateBreakpoint)
    return () => window.removeEventListener('resize', updateBreakpoint)
  }, [])

  if (process.env.NODE_ENV !== 'development') {
    return <>{children}</>
  }

  return (
    <div className={className}>
      {process.env.NODE_ENV === 'development' && (
        <div className="fixed bottom-4 left-4 z-50 bg-black/80 text-white p-2 rounded text-xs font-mono backdrop-blur-sm">
          <div>Breakpoint: <span className="text-yellow-400">{breakpoint}</span></div>
          <div>Container: <span className="text-green-400">{containerWidth}px</span></div>
        </div>
      )}
      {children}
    </div>
  )
}
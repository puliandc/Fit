//created by Jason Lu on 14:45:00 10/27/2025
import { useState, useEffect } from 'react'

interface DeviceInfo {
  isMobile: boolean
  isTablet: boolean
  isDesktop: boolean
  screenWidth: number
  screenHeight: number
  orientation: 'portrait' | 'landscape'
  safeArea: {
    top: number
    bottom: number
    left: number
    right: number
  }
}

/**
 * 移动端设备检测和屏幕信息钩子
 */
export function useMobileDetection(): DeviceInfo {
  const [deviceInfo, setDeviceInfo] = useState<DeviceInfo>(() => {
    if (typeof window === 'undefined') {
      return {
        isMobile: false,
        isTablet: false,
        isDesktop: true,
        screenWidth: 1920,
        screenHeight: 1080,
        orientation: 'landscape',
        safeArea: { top: 0, bottom: 0, left: 0, right: 0 }
      }
    }

    const width = window.innerWidth
    const height = window.innerHeight

    return {
      isMobile: width <= 768,
      isTablet: width > 768 && width <= 1024,
      isDesktop: width > 1024,
      screenWidth: width,
      screenHeight: height,
      orientation: width > height ? 'landscape' : 'portrait',
      safeArea: {
        top: getSafeAreaInset('top'),
        bottom: getSafeAreaInset('bottom'),
        left: getSafeAreaInset('left'),
        right: getSafeAreaInset('right')
      }
    }
  })

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth
      const height = window.innerHeight

      setDeviceInfo({
        isMobile: width <= 768,
        isTablet: width > 768 && width <= 1024,
        isDesktop: width > 1024,
        screenWidth: width,
        screenHeight: height,
        orientation: width > height ? 'landscape' : 'portrait',
        safeArea: {
          top: getSafeAreaInset('top'),
          bottom: getSafeAreaInset('bottom'),
          left: getSafeAreaInset('left'),
          right: getSafeAreaInset('right')
        }
      })
    }

    const handleOrientationChange = () => {
      // 延迟处理以确保屏幕尺寸更新完成
      setTimeout(handleResize, 100)
    }

    window.addEventListener('resize', handleResize)
    window.addEventListener('orientationchange', handleOrientationChange)

    return () => {
      window.removeEventListener('resize', handleResize)
      window.removeEventListener('orientationchange', handleOrientationChange)
    }
  }, [])

  return deviceInfo
}

/**
 * 获取安全区域插值
 */
function getSafeAreaInset(side: 'top' | 'bottom' | 'left' | 'right'): number {
  if (typeof window === 'undefined' || !window.getComputedStyle) {
    return 0
  }

  const testElement = document.createElement('div')
  testElement.style.position = 'fixed'
  testElement.style.left = '0'
  testElement.style.top = '0'
  testElement.style.bottom = '0'
  testElement.style.right = '0'
  testElement.style.transition = 'none'
  testElement.style.padding = `env(safe-area-inset-${side}) 0px 0px 0px`

  document.body.appendChild(testElement)

  const computedStyle = window.getComputedStyle(testElement)
  const inset = parseInt(computedStyle.paddingTop || '0', 10)

  document.body.removeChild(testElement)

  return inset || 0
}

/**
 * 触控设备检测
 */
export function useTouchDevice(): boolean {
  const [isTouch, setIsTouch] = useState(false)

  useEffect(() => {
    const checkTouch = () => {
      setIsTouch(
        'ontouchstart' in window ||
        navigator.maxTouchPoints > 0 ||
        // @ts-ignore
        navigator.msMaxTouchPoints > 0
      )
    }

    checkTouch()
    window.addEventListener('touchstart', checkTouch, { once: true })

    return () => {
      window.removeEventListener('touchstart', checkTouch)
    }
  }, [])

  return isTouch
}

/**
 * 移动端viewport优化钩子
 */
export function useViewportOptimization() {
  const { isMobile, screenWidth, screenHeight } = useMobileDetection()

  useEffect(() => {
    if (!isMobile || typeof document === 'undefined') {
      return
    }

    const viewport = document.querySelector('meta[name="viewport"]')
    if (viewport) {
      // 确保viewport标签正确设置
      viewport.setAttribute(
        'content',
        'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover'
      )
    }

    // 防止双击缩放
    let lastTouchEnd = 0
    const preventDoubleTapZoom = (event: TouchEvent) => {
      const now = Date.now()
      if (now - lastTouchEnd <= 300) {
        event.preventDefault()
      }
      lastTouchEnd = now
    }

    document.addEventListener('touchend', preventDoubleTapZoom, { passive: false })

    return () => {
      document.removeEventListener('touchend', preventDoubleTapZoom)
    }
  }, [isMobile])

  return {
    isMobile,
    screenWidth,
    screenHeight,
    aspectRatio: screenWidth / screenHeight
  }
}
//created by Jason Lu on 14:50:00 10/27/2025
import { cn } from './utils'
import React from 'react'

interface TouchTargetProps extends React.HTMLAttributes<HTMLDivElement> {
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
  as?: keyof JSX.IntrinsicElements
}

/**
 * 触控友好的目标组件
 * 确保所有交互元素都有足够的触控区域
 */
export function TouchTarget({
  children,
  className,
  size = 'md',
  as: Component = 'div',
  ...props
}: TouchTargetProps) {
  const sizeClasses = {
    sm: 'min-h-[44px] min-w-[44px]',
    md: 'min-h-[48px] min-w-[48px]',
    lg: 'min-h-[52px] min-w-[52px]'
  }

  const ComponentOrDiv = Component as any

  return (
    <ComponentOrDiv
      className={cn(
        'inline-flex items-center justify-center',
        'touch-manipulation', // 防止300ms点击延迟
        sizeClasses[size],
        className
      )}
      {...props}
    >
      {children}
    </ComponentOrDiv>
  )
}

interface TouchButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  size?: 'sm' | 'md' | 'lg'
  variant?: 'primary' | 'secondary' | 'outline'
  children: React.ReactNode
}

/**
 * 移动端优化的按钮组件
 */
export function TouchButton({
  children,
  className,
  size = 'md',
  variant = 'primary',
  ...props
}: TouchButtonProps) {
  const baseClasses = 'mobile-scale-hover mobile-transition font-medium rounded-xl'

  const sizeClasses = {
    sm: 'px-4 py-2.5 text-sm min-h-[44px]',
    md: 'px-6 py-3 text-base min-h-[48px]',
    lg: 'px-8 py-4 text-lg min-h-[52px]'
  }

  const variantClasses = {
    primary: 'bg-gradient-to-r from-orange-500 via-pink-500 to-purple-600 text-white border-0 shadow-lg',
    secondary: 'bg-white/50 dark:bg-gray-800/50 text-gray-700 dark:text-gray-300 border border-gray-200 dark:border-gray-700/50',
    outline: 'bg-transparent text-orange-600 dark:text-orange-400 border-2 border-orange-200 dark:border-orange-800/50'
  }

  return (
    <button
      className={cn(
        baseClasses,
        sizeClasses[size],
        variantClasses[variant],
        'touch-manipulation',
        className
      )}
      {...props}
    >
      {children}
    </button>
  )
}

interface SwipeableProps {
  children: React.ReactNode
  onSwipeLeft?: () => void
  onSwipeRight?: () => void
  onSwipeUp?: () => void
  onSwipeDown?: () => void
  threshold?: number
  className?: string
}

/**
 * 可滑动手势组件
 */
export function Swipeable({
  children,
  onSwipeLeft,
  onSwipeRight,
  onSwipeUp,
  onSwipeDown,
  threshold = 50,
  className
}: SwipeableProps) {
  const [touchStart, setTouchStart] = React.useState({ x: 0, y: 0 })
  const [touchEnd, setTouchEnd] = React.useState({ x: 0, y: 0 })

  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchEnd({ x: 0, y: 0 })
    setTouchStart({
      x: e.targetTouches[0].clientX,
      y: e.targetTouches[0].clientY
    })
  }

  const handleTouchMove = (e: React.TouchEvent) => {
    setTouchEnd({
      x: e.targetTouches[0].clientX,
      y: e.targetTouches[0].clientY
    })
  }

  const handleTouchEnd = () => {
    if (!touchStart.x || !touchEnd.x) return

    const distanceX = touchStart.x - touchEnd.x
    const distanceY = touchStart.y - touchEnd.y

    const isLeftSwipe = distanceX > threshold
    const isRightSwipe = distanceX < -threshold
    const isUpSwipe = distanceY > threshold
    const isDownSwipe = distanceY < -threshold

    if (isLeftSwipe && onSwipeLeft) {
      onSwipeLeft()
    }
    if (isRightSwipe && onSwipeRight) {
      onSwipeRight()
    }
    if (isUpSwipe && onSwipeUp) {
      onSwipeUp()
    }
    if (isDownSwipe && onSwipeDown) {
      onSwipeDown()
    }
  }

  return (
    <div
      className={cn('touch-none', className)}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {children}
    </div>
  )
}

interface HapticFeedbackProps {
  children: React.ReactNode
  type?: 'light' | 'medium' | 'heavy'
  pattern?: 'success' | 'warning' | 'error'
}

/**
 * 触觉反馈组件
 */
export function HapticFeedback({
  children,
  type = 'light',
  pattern
}: HapticFeedbackProps) {
  const triggerHaptic = React.useCallback(() => {
    if ('vibrate' in navigator) {
      if (pattern) {
        switch (pattern) {
          case 'success':
            navigator.vibrate([10, 50, 10])
            break
          case 'warning':
            navigator.vibrate([50, 30, 50])
            break
          case 'error':
            navigator.vibrate([100, 50, 100, 50, 100])
            break
        }
      } else {
        switch (type) {
          case 'light':
            navigator.vibrate(10)
            break
          case 'medium':
            navigator.vibrate(25)
            break
          case 'heavy':
            navigator.vibrate(50)
            break
        }
      }
    }
  }, [type, pattern])

  return (
    <div onClick={triggerHaptic} onTouchStart={triggerHaptic}>
      {children}
    </div>
  )
}
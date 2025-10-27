//created by Jason Lu on 23:35:00 10/27/2025
import React from 'react'

interface SafeAreaContainerProps {
  children: React.ReactNode
  className?: string
  top?: boolean
  bottom?: boolean
  left?: boolean
  right?: boolean
}

/**
 * 安全区域容器组件
 * 处理iOS刘海屏和底部手势区域的安全边距
 */
const SafeAreaContainer: React.FC<SafeAreaContainerProps> = ({
  children,
  className = '',
  top = true,
  bottom = true,
  left = false,
  right = false
}) => {
  const safeAreaClasses = [
    top && 'pt-safe-area-top',
    bottom && 'pb-safe-area-bottom',
    left && 'pl-safe-area-left',
    right && 'pr-safe-area-right',
    className
  ].filter(Boolean).join(' ')

  return (
    <div className={safeAreaClasses}>
      {children}
    </div>
  )
}

export default SafeAreaContainer
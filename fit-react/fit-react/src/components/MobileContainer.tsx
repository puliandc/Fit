//created by Jason Lu on 23:30:00 10/27/2025
import React from 'react'

interface MobileContainerProps {
  children: React.ReactNode
  className?: string
  maxWidth?: 'sm' | 'md' | 'lg' | 'xl'
}

/**
 * 移动端专用容器组件
 * 提供最大宽度限制和居中对齐
 */
const MobileContainer: React.FC<MobileContainerProps> = ({
  children,
  className = '',
  maxWidth = 'lg'
}) => {
  const maxWidthClasses = {
    sm: 'max-w-sm',    // 384px - iPhone SE
    md: 'max-w-md',    // 448px - iPhone 12
    lg: 'max-w-lg',    // 512px - 标准移动端
    xl: 'max-w-xl',    // 576px - 大屏手机
  }

  const baseClasses = [
    'w-full',
    'mx-auto',           // 居中对齐
    maxWidthClasses[maxWidth],
    'px-4',             // 移动端16px左右边距
    'sm:px-6',          // 小屏24px左右边距
    'md:px-8',          // 中等屏幕32px左右边距
    className
  ].filter(Boolean).join(' ')

  return (
    <div className={baseClasses}>
      {children}
    </div>
  )
}

export default MobileContainer
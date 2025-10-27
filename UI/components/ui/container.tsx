//created by Jason Lu on 14:30:00 10/27/2025
import { cn } from './utils'
import React from 'react'

interface ContainerProps extends React.HTMLAttributes<HTMLDivElement> {
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full'
  padding?: 'none' | 'sm' | 'md' | 'lg'
  centered?: boolean
}

/**
 * 响应式容器组件
 *
 * @param size - 最大宽度尺寸
 * @param padding - 内边距设置
 * @param centered - 是否居中显示
 */
export function Container({
  children,
  className,
  size = 'lg',
  padding = 'md',
  centered = true,
  ...props
}: ContainerProps) {
  const sizeClasses = {
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-lg',
    xl: 'max-w-xl',
    full: 'max-w-full'
  }

  const paddingClasses = {
    none: '',
    sm: 'px-4',
    md: 'px-6',
    lg: 'px-8'
  }

  const containerClasses = cn(
    'w-full',
    centered && 'mx-auto',
    sizeClasses[size],
    paddingClasses[padding],
    className
  )

  return (
    <div className={containerClasses} {...props}>
      {children}
    </div>
  )
}

/**
 * 移动端优化的安全区域容器
 * 自动处理iOS刘海屏和底部手势区域
 */
export function SafeAreaContainer({
  children,
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        'w-full h-full',
        // iOS 安全区域
        'pt-safe-top',
        'pb-safe-bottom',
        'pl-safe-left',
        'pr-safe-right',
        // 通用边距
        'px-4 sm:px-6',
        className
      )}
      {...props}
    >
      {children}
    </div>
  )
}

/**
 * 移动端专用容器
 * 针对移动设备优化的固定宽度容器
 */
export function MobileContainer({
  children,
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        'w-full',
        // 移动端最大宽度限制 (iPhone 14 Pro Max: 430px)
        'max-w-[430px]',
        // 居中对齐
        'mx-auto',
        // 移动端适配边距
        'px-4 sm:px-6',
        // 最小高度确保
        'min-h-screen',
        className
      )}
      {...props}
    >
      {children}
    </div>
  )
}

/**
 * 内容容器
 * 用于页面主要内容区域的包装
 */
export function ContentContainer({
  children,
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        'flex-1',
        'flex flex-col',
        'overflow-hidden',
        // 触控友好边距
        'py-4 sm:py-6',
        className
      )}
      {...props}
    >
      {children}
    </div>
  )
}
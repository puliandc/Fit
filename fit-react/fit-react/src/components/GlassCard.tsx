//created by Jason Lu on 15:23:00 10/26/2025
import React from 'react'

interface GlassCardProps {
  children: React.ReactNode
  className?: string
  variant?: 'default' | 'dark' | 'light'
  padding?: 'sm' | 'md' | 'lg'
  hover?: boolean
  onClick?: () => void
}

const GlassCard: React.FC<GlassCardProps> = ({
  children,
  className = '',
  variant = 'default',
  padding = 'md',
  hover = false,
  onClick
}) => {
  const baseClasses = 'glass-card'
  const variantClasses = {
    default: '',
    dark: 'glass-card-dark',
    light: 'glass-card-light'
  }

  const paddingClasses = {
    sm: 'p-4',
    md: 'p-6',
    lg: 'p-8'
  }

  const hoverClasses = hover ? 'glass-card-hover' : ''

  const classes = [
    baseClasses,
    variantClasses[variant],
    paddingClasses[padding],
    hoverClasses,
    className
  ].filter(Boolean).join(' ')

  return (
    <div
      className={classes}
      onClick={onClick}
      style={{
        cursor: onClick ? 'pointer' : 'default'
      }}
    >
      {children}
    </div>
  )
}

export default GlassCard
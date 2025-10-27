//created by Jason Lu on 15:23:00 10/26/2025
import React from 'react'

interface GlassButtonProps {
  children: React.ReactNode
  onClick?: () => void
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
  className?: string
  type?: 'button' | 'submit' | 'reset'
}

const GlassButton: React.FC<GlassButtonProps> = ({
  children,
  onClick,
  variant = 'primary',
  size = 'md',
  disabled = false,
  loading = false,
  className = '',
  type = 'button'
}) => {
  const baseClasses = 'glass-button'

  const variantClasses = {
    primary: 'glass-button-primary',
    secondary: 'glass-button-secondary',
    danger: 'glass-button-danger'
  }

  const sizeClasses = {
    sm: 'glass-button-sm',
    md: 'glass-button-md',
    lg: 'glass-button-lg'
  }

  const stateClasses = {
    disabled: 'glass-button-disabled',
    loading: 'glass-button-loading'
  }

  const classes = [
    baseClasses,
    variantClasses[variant],
    sizeClasses[size],
    disabled && stateClasses.disabled,
    loading && stateClasses.loading,
    className
  ].filter(Boolean).join(' ')

  return (
    <button
      type={type}
      className={classes}
      onClick={onClick}
      disabled={disabled || loading}
    >
      {loading ? (
        <div className="glass-button-spinner">
          <div className="spinner"></div>
        </div>
      ) : (
        children
      )}
    </button>
  )
}

export default GlassButton
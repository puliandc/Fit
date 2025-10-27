//created by Jason Lu on 15:24:00 10/26/2025
import React from 'react'

interface GlassInputProps {
  type?: 'text' | 'number' | 'email' | 'password'
  placeholder?: string
  value?: string | number
  onChange?: (value: string) => void
  onBlur?: () => void
  onFocus?: () => void
  disabled?: boolean
  error?: boolean
  errorMessage?: string
  label?: string
  required?: boolean
  className?: string
}

const GlassInput: React.FC<GlassInputProps> = ({
  type = 'text',
  placeholder,
  value,
  onChange,
  onBlur,
  onFocus,
  disabled = false,
  error = false,
  errorMessage,
  label,
  required = false,
  className = ''
}) => {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = type === 'number' ? e.target.value : e.target.value
    onChange?.(newValue)
  }

  return (
    <div className={`glass-input-container ${className}`}>
      {label && (
        <div className="glass-input-label">
          {label}
          {required && <span className="glass-input-required">*</span>}
        </div>
      )}
      <input
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={handleChange}
        onBlur={onBlur}
        onFocus={onFocus}
        disabled={disabled}
        className={`glass-input ${error ? 'glass-input-error' : ''}`}
      />
      {error && errorMessage && (
        <div className="glass-input-error-message">
          {errorMessage}
        </div>
      )}
    </div>
  )
}

export default GlassInput
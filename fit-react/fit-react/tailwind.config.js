//created by Jason Lu on 22:42:00 10/26/2025
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // 主要颜色系统 - 基于原有设计规范
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
        },
        // 背景渐变色
        'gray-900': '#111827',
        'blue-900': '#1e3a8a',
        'purple-900': '#581c87',
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      backdropBlur: {
        xs: '2px',
        sm: '4px',
        md: '8px',
        lg: '16px',
        xl: '24px',
        '2xl': '40px',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'scale-in': 'scaleIn 0.2s ease-out',
        'pulse-glow': 'pulseGlow 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        scaleIn: {
          '0%': { transform: 'scale(0.9)', opacity: '0' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
        pulseGlow: {
          '0%, 100%': { boxShadow: '0 0 20px rgba(59, 130, 246, 0.5)' },
          '50%': { boxShadow: '0 0 40px rgba(59, 130, 246, 0.8)' },
        },
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        // iOS 安全区域间距
        'safe-top': 'env(safe-area-inset-top)',
        'safe-bottom': 'env(safe-area-inset-bottom)',
        'safe-left': 'env(safe-area-inset-left)',
        'safe-right': 'env(safe-area-inset-right)',
      },
      borderRadius: {
        '4xl': '2rem',
      },
      boxShadow: {
        'glass': '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
        'glass-inset': 'inset 0 2px 4px 0 rgba(255, 255, 255, 0.1)',
        'glow': '0 0 20px rgba(59, 130, 246, 0.5)',
        'glow-large': '0 0 40px rgba(59, 130, 246, 0.8)',
      },
    },
  },
  plugins: [
    function({ addUtilities }) {
      const newUtilities = {
        '.safe-area-top': { 'padding-top': 'env(safe-area-inset-top)' },
        '.safe-area-bottom': { 'padding-bottom': 'env(safe-area-inset-bottom)' },
        '.safe-area-left': { 'padding-left': 'env(safe-area-inset-left)' },
        '.safe-area-right': { 'padding-right': 'env(safe-area-inset-right)' },
        '.pt-safe-area-top': { 'padding-top': 'env(safe-area-inset-top)' },
        '.pb-safe-area-bottom': { 'padding-bottom': 'env(safe-area-inset-bottom)' },
        '.pl-safe-area-left': { 'padding-left': 'env(safe-area-inset-left)' },
        '.pr-safe-area-right': { 'padding-right': 'env(safe-area-inset-right)' },
        '.mt-safe-area-top': { 'margin-top': 'env(safe-area-inset-top)' },
        '.mb-safe-area-bottom': { 'margin-bottom': 'env(safe-area-inset-bottom)' },
      }
      addUtilities(newUtilities)
    }
  ],
}
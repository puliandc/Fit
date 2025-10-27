//created by Jason Lu on 10:45:00 10/27/2025
import React, { createContext, useContext, useReducer, type ReactNode } from 'react'

// 页面类型定义 - 与Swift版本保持一致，仅包含核心功能页面
export type PageType = 'main' | 'workout'

// 导航状态定义
interface NavigationState {
  currentPage: PageType
  workoutPlan: any | null
  history: PageType[]
}

// 导航动作定义
type NavigationAction =
  | { type: 'NAVIGATE_TO'; page: PageType; workoutPlan?: any }
  | { type: 'GO_BACK' }
  | { type: 'GO_HOME' }
  | { type: 'SET_WORKOUT_PLAN'; workoutPlan: any }

// 初始状态
const initialState: NavigationState = {
  currentPage: 'main',
  workoutPlan: null,
  history: []
}

// Reducer函数
const navigationReducer = (state: NavigationState, action: NavigationAction): NavigationState => {
  switch (action.type) {
    case 'NAVIGATE_TO':
      return {
        ...state,
        currentPage: action.page,
        workoutPlan: action.workoutPlan || state.workoutPlan,
        history: [...state.history, state.currentPage]
      }

    case 'GO_BACK':
      if (state.history.length === 0) return state
      const previousPage = state.history[state.history.length - 1]
      const newHistory = state.history.slice(0, -1)
      return {
        ...state,
        currentPage: previousPage,
        history: newHistory
      }

    case 'GO_HOME':
      return {
        ...state,
        currentPage: 'main',
        history: []
      }

    case 'SET_WORKOUT_PLAN':
      return {
        ...state,
        workoutPlan: action.workoutPlan
      }

    default:
      return state
  }
}

// Context创建
const NavigationContext = createContext<{
  state: NavigationState
  dispatch: React.Dispatch<NavigationAction>
} | null>(null)

// Provider组件
export const NavigationProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(navigationReducer, initialState)

  return (
    <NavigationContext.Provider value={{ state, dispatch }}>
      {children}
    </NavigationContext.Provider>
  )
}

// Hook for using navigation
export const useNavigation = () => {
  const context = useContext(NavigationContext)
  if (!context) {
    throw new Error('useNavigation must be used within NavigationProvider')
  }
  return context
}

// 便捷导航函数
export const useNavigationActions = () => {
  const { dispatch } = useNavigation()

  const navigateTo = (page: PageType, workoutPlan?: any) => {
    dispatch({ type: 'NAVIGATE_TO', page, workoutPlan })
  }

  const goBack = () => {
    dispatch({ type: 'GO_BACK' })
  }

  const goHome = () => {
    dispatch({ type: 'GO_HOME' })
  }

  const setWorkoutPlan = (workoutPlan: any) => {
    dispatch({ type: 'SET_WORKOUT_PLAN', workoutPlan })
  }

  return {
    navigateTo,
    goBack,
    goHome,
    setWorkoutPlan
  }
}
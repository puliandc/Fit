//created by Jason Lu on 10:48:00 10/27/2025
import React from 'react'
import { GlassButton } from './index'

interface FileUploadButtonProps {
  onFileLoaded: (workoutPlan: any) => void
  onError: (error: string) => void
  className?: string
}

// Exercise数据结构
interface Exercise {
  id: string
  name: string
}

// ExerciseSet数据结构
interface ExerciseSet {
  id: string
  exercise: Exercise
  targetReps: number
  targetWeight: number
  restTime: number
  notes?: string
}

// WorkoutPlan数据结构
interface WorkoutPlan {
  id: string
  name: string
  duration: number
  exercises: ExerciseSet[]
}

const FileUploadButton: React.FC<FileUploadButtonProps> = ({
  onFileLoaded,
  onError,
  className = ''
}) => {
  const [isLoading, setIsLoading] = React.useState(false)

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // 验证文件类型
    if (!file.name.endsWith('.json')) {
      onError('请选择JSON格式的文件')
      return
    }

    setIsLoading(true)

    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const content = e.target?.result as string
        const data = JSON.parse(content)

        // 验证数据结构
        const workoutPlan = validateAndConvertWorkoutPlan(data)
        if (workoutPlan) {
          onFileLoaded(workoutPlan)
        } else {
          onError('JSON文件格式不正确，请检查数据结构')
        }
      } catch (error) {
        onError('JSON文件解析失败，请检查文件格式')
        console.error('JSON解析错误:', error)
      } finally {
        setIsLoading(false)
      }
    }

    reader.onerror = () => {
      onError('文件读取失败')
      setIsLoading(false)
    }

    reader.readAsText(file)
  }

  // 验证并转换WorkoutPlan数据结构
  const validateAndConvertWorkoutPlan = (data: any): WorkoutPlan | null => {
    try {
      // 基本字段验证
      if (!data.name || !data.exercises) {
        return null
      }

      // 转换exercises数组
      const exercises: ExerciseSet[] = data.exercises.map((exercise: any, index: number) => {
        // 处理不同的数据结构格式
        let exerciseData: Exercise
        let targetReps: number
        let targetWeight: number
        let restTime: number

        if (exercise.exercise) {
          // 格式: { exercise: { name: "...", id: "..." }, targetReps: ..., targetWeight: ... }
          exerciseData = {
            id: exercise.exercise.id || `exercise-${index}`,
            name: exercise.exercise.name
          }
          targetReps = exercise.targetReps || exercise.reps || 0
          targetWeight = exercise.targetWeight || exercise.weight || 0
          restTime = exercise.restTime || exercise.rest || 60
        } else {
          // 格式: { name: "...", targetReps: ..., targetWeight: ... }
          exerciseData = {
            id: exercise.id || `exercise-${index}`,
            name: exercise.name
          }
          targetReps = exercise.targetReps || exercise.reps || 0
          targetWeight = exercise.targetWeight || exercise.weight || 0
          restTime = exercise.restTime || exercise.rest || 60
        }

        return {
          id: `set-${index}`,
          exercise: exerciseData,
          targetReps,
          targetWeight,
          restTime
        }
      })

      return {
        id: data.id || `workout-${Date.now()}`,
        name: data.name,
        duration: data.duration || exercises.length * 5, // 默认每个动作5分钟
        exercises
      }
    } catch (error) {
      console.error('WorkoutPlan验证错误:', error)
      return null
    }
  }

  return (
    <div className={`relative ${className}`}>
      <input
        type="file"
        accept=".json"
        onChange={handleFileSelect}
        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
        disabled={isLoading}
      />
      <GlassButton
        variant="primary"
        size="lg"
        className="w-full"
        disabled={isLoading}
      >
        <div className="flex items-center justify-center">
          {isLoading ? (
            <>
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
              读取中...
            </>
          ) : (
            <>
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              选择JSON文件
            </>
          )}
        </div>
      </GlassButton>
    </div>
  )
}

export default FileUploadButton
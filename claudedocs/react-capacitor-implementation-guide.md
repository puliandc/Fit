# React+Capacitor技术实施指南

//created by Jason Lu on 09:45:00 10/26/2025

## 🚀 快速开始：项目初始化

### 1. 创建React+TypeScript项目

```bash
# 使用Vite创建项目（推荐）
npm create vite@latest fitness-app -- --template react-ts
cd fitness-app
npm install

# 或者使用Create React App
npx create-react-app fitness-app --template typescript
cd fitness-app
```

### 2. 安装Capacitor和相关依赖

```bash
# 安装Capacitor核心
npm install @capacitor/core @capacitor/cli
npm install @capacitor/ios @capacitor/android

# 安装Ionic UI框架（可选但推荐）
npm install @ionic/react @ionic/react-router
npm install ionicons

# 安装必要的插件
npm install @capacitor/haptics @capacitor/local-notifications @capacitor/storage
npm install @capacitor/status-bar @capacitor/splash-screen

# 状态管理
npm install zustand @tanstack/react-query

# 样式工具
npm install tailwindcss autoprefixer postcss
npx tailwindcss init -p
```

### 3. 初始化Capacitor项目

```bash
# 初始化Capacitor配置
npx cap init "Fit" "com.jasonlu.fitness"

# 添加iOS和Android平台
npx cap add ios
npx cap add android

# 构建并同步
npm run build
npx cap sync ios
npx cap sync android
```

## ⚙️ 项目配置

### package.json 配置

```json
{
  "name": "fitness-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "ios": "npm run build && npx cap open ios",
    "android": "npm run build && npx cap open android",
    "sync": "npm run build && npx cap sync",
    "test": "jest",
    "test:e2e": "detox test"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@ionic/react": "^7.0.0",
    "@ionic/react-router": "^7.0.0",
    "@capacitor/core": "^7.4.4",
    "@capacitor/cli": "^7.4.4",
    "@capacitor/haptics": "^7.4.4",
    "@capacitor/local-notifications": "^7.4.4",
    "@capacitor/storage": "^7.4.4",
    "@capacitor/status-bar": "^7.4.4",
    "@capacitor/splash-screen": "^7.4.4",
    "zustand": "^4.4.0",
    "@tanstack/react-query": "^4.0.0",
    "date-fns": "^2.30.0",
    "react-router-dom": "^6.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.0.0",
    "vite": "^4.4.0",
    "tailwindcss": "^3.3.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "@testing-library/react": "^13.0.0",
    "@testing-library/jest-dom": "^5.16.0",
    "jest": "^29.0.0",
    "detox": "^20.0.0"
  }
}
```

### Capacitor配置 (capacitor.config.ts)

```typescript
import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.jasonlu.fitness',
  appName: 'Fit',
  webDir: 'dist',
  bundledWebRuntime: false,
  server: {
    androidScheme: 'https',
    cleartext: true,
    allowNavigation: []
  },
  plugins: {
    // 本地通知配置
    LocalNotifications: {
      smallIcon: 'ic_stat_icon_config_sample',
      iconColor: '#488AFF',
      sound: 'beep.wav'
    },
    // 触觉反馈配置
    Haptics: {},
    // 状态栏配置
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#FFFFFF'
    },
    // 启动画面配置
    SplashScreen: {
      launchShowDuration: 2000,
      launchAutoHide: true,
      backgroundColor: '#FFFFFF',
      androidSplashResourceName: 'splash',
      androidScaleType: 'CENTER_CROP',
      showSpinner: true,
      spinnerStyle: 'large'
    },
    // 存储配置
    Storage: {
      migrate: true
    }
  },
  ios: {
    contentInset: 'automatic'
  },
  android: {
    allowMixedContent: true,
    inputType: 'resize'
  }
};

export default config;
```

### TailwindCSS配置 (tailwind.config.js)

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
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
        secondary: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        }
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      }
    },
  },
  plugins: [],
}
```

## 🏗️ 项目结构

### 推荐目录结构

```
fitness-app/
├── src/
│   ├── components/          # React组件
│   │   ├── ui/           # 基础UI组件
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Modal.tsx
│   │   │   └── index.ts
│   │   ├── workout/      # 训练相关组件
│   │   │   ├── WorkoutTimer.tsx
│   │   │   ├── SetCounter.tsx
│   │   │   ├── ExerciseSelector.tsx
│   │   │   └── WorkoutSummary.tsx
│   │   └── common/       # 通用组件
│   │       ├── Header.tsx
│   │       ├── Navigation.tsx
│   │       └── Loading.tsx
│   ├── pages/              # 页面组件
│   │   ├── Home.tsx
│   │   ├── Workout.tsx
│   │   ├── History.tsx
│   │   ├── Settings.tsx
│   │   └── Profile.tsx
│   ├── hooks/              # 自定义Hooks
│   │   ├── useWorkout.ts
│   │   ├── useTimer.ts
│   │   ├── useStorage.ts
│   │   └── useHaptics.ts
│   ├── services/           # 业务逻辑服务
│   │   ├── workoutService.ts
│   │   ├── notificationService.ts
│   │   ├── audioService.ts
│   │   └── storageService.ts
│   ├── stores/             # 状态管理
│   │   ├── workoutStore.ts
│   │   ├── settingsStore.ts
│   │   └── index.ts
│   ├── types/              # TypeScript类型
│   │   ├── workout.ts
│   │   ├── exercise.ts
│   │   └── api.ts
│   ├── utils/              # 工具函数
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   ├── constants.ts
│   │   └── helpers.ts
│   ├── assets/             # 静态资源
│   │   ├── images/
│   │   ├── icons/
│   │   └── sounds/
│   ├── styles/             # 样式文件
│   │   ├── globals.css
│   │   └── components.css
│   ├── App.tsx
│   ├── main.tsx
│   └── vite-env.d.ts
├── capacitor/
│   ├── ios/
│   └── android/
├── public/
│   ├── assets/
│   └── index.html
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.js
├── capacitor.config.ts
└── README.md
```

## 🎨 UI组件实现

### 基础Button组件

```typescript
// src/components/ui/Button.tsx
import React, { forwardRef } from 'react';
import { IonButton, IonSpinner } from '@ionic/react';
import cn from 'classnames';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  size?: 'small' | 'medium' | 'large';
  loading?: boolean;
  icon?: React.ReactNode;
  iconPosition?: 'start' | 'end';
  fullWidth?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      children,
      variant = 'primary',
      size = 'medium',
      loading = false,
      icon,
      iconPosition = 'start',
      fullWidth = false,
      className,
      disabled,
      ...props
    },
    ref
  ) => {
    const buttonClass = cn(
      'btn',
      `btn-${variant}`,
      `btn-${size}`,
      {
        'btn-full-width': fullWidth,
        'btn-loading': loading,
        'btn-icon-only': icon && !children,
      },
      className
    );

    return (
      <IonButton
        className={buttonClass}
        disabled={disabled || loading}
        ref={ref}
        {...props}
      >
        {loading && <IonSpinner className="btn-spinner" />}
        {!loading && icon && iconPosition === 'start' && (
          <span className="btn-icon btn-icon-start">{icon}</span>
        )}
        <span className="btn-text">{children}</span>
        {!loading && icon && iconPosition === 'end' && (
          <span className="btn-icon btn-icon-end">{icon}</span>
        )}
      </IonButton>
    );
  }
);

Button.displayName = 'Button';
```

### WorkoutTimer组件

```typescript
// src/components/workout/WorkoutTimer.tsx
import React, { useState, useEffect, useCallback } from 'react';
import { IonIcon, IonText } from '@ionic/react';
import { play, pause, refresh } from 'ionicons/icons';
import { Button } from '../ui/Button';
import { useHaptics } from '../../hooks/useHaptics';
import { useAudioService } from '../../hooks/useAudioService';

interface WorkoutTimerProps {
  duration: number; // 秒数
  onComplete?: () => void;
  onTick?: (remainingTime: number) => void;
  autoStart?: boolean;
  showControls?: boolean;
  size?: 'small' | 'medium' | 'large';
}

export const WorkoutTimer: React.FC<WorkoutTimerProps> = ({
  duration,
  onComplete,
  onTick,
  autoStart = false,
  showControls = true,
  size = 'medium'
}) => {
  const [remainingTime, setRemainingTime] = useState(duration);
  const [isRunning, setIsRunning] = useState(autoStart);
  const { hapticImpact } = useHaptics();
  const { playBeep } = useAudioService();

  // 计时器逻辑
  useEffect(() => {
    let intervalId: NodeJS.Timeout;

    if (isRunning && remainingTime > 0) {
      intervalId = setInterval(() => {
        setRemainingTime(prev => {
          const newTime = prev - 1;

          // 倒计时最后3秒语音提醒
          if (newTime <= 3 && newTime > 0) {
            playBeep();
            hapticImpact('light');
          }

          // 时间到了
          if (newTime === 0) {
            setIsRunning(false);
            hapticImpact('heavy');
            onComplete?.();
          }

          onTick?.(newTime);
          return newTime;
        });
      }, 1000);
    }

    return () => clearInterval(intervalId);
  }, [isRunning, remainingTime, onComplete, onTick, hapticImpact, playBeep]);

  // 重置计时器
  const handleReset = useCallback(() => {
    setRemainingTime(duration);
    setIsRunning(false);
    hapticImpact('medium');
  }, [duration, hapticImpact]);

  // 开始/暂停
  const toggleTimer = useCallback(() => {
    setIsRunning(prev => !prev);
    hapticImpact('light');
  }, [hapticImpact]);

  // 格式化时间显示
  const formatTime = useCallback((seconds: number): string => {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }, []);

  const sizeClasses = {
    small: 'text-2xl',
    medium: 'text-4xl',
    large: 'text-6xl'
  };

  return (
    <div className="flex flex-col items-center space-y-4 p-4">
      <IonText
        className={`font-mono font-bold text-primary-600 ${sizeClasses[size]}`}
      >
        {formatTime(remainingTime)}
      </IonText>

      {showControls && (
        <div className="flex space-x-2">
          <Button
            variant="primary"
            size={size === 'small' ? 'small' : size === 'large' ? 'large' : 'medium'}
            onClick={toggleTimer}
            icon={
              <IonIcon
                icon={isRunning ? pause : play}
                className={size === 'small' ? 'w-4 h-4' : size === 'large' ? 'w-8 h-8' : 'w-6 h-6'}
              />
            }
          >
            {isRunning ? '暂停' : '开始'}
          </Button>

          <Button
            variant="secondary"
            size={size === 'small' ? 'small' : size === 'large' ? 'large' : 'medium'}
            onClick={handleReset}
            icon={
              <IonIcon
                icon={refresh}
                className={size === 'small' ? 'w-4 h-4' : size === 'large' ? 'w-8 h-8' : 'w-6 h-6'}
              />
            }
          >
            重置
          </Button>
        </div>
      )}
    </div>
  );
};
```

## 🏪 状态管理

### Zustand Store配置

```typescript
// src/stores/workoutStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { Workout, WorkoutSet, Exercise } from '../types/workout';

interface WorkoutState {
  // 当前状态
  currentWorkout: Workout | null;
  isWorkoutActive: boolean;

  // 数据存储
  workouts: Workout[];
  exercises: Exercise[];
  recentExercises: Exercise[];

  // 统计数据
  totalWorkouts: number;
  totalVolume: number;
  currentStreak: number;

  // Actions
  startWorkout: (exercises?: Exercise[]) => void;
  completeWorkout: () => void;
  pauseWorkout: () => void;
  resumeWorkout: () => void;

  addSet: (exerciseId: string, weight: number, reps: number) => void;
  updateSet: (setId: string, updates: Partial<WorkoutSet>) => void;
  removeSet: (setId: string) => void;

  loadWorkouts: () => void;
  saveWorkout: (workout: Workout) => void;
  deleteWorkout: (workoutId: string) => void;

  loadExercises: () => void;
  addExercise: (exercise: Exercise) => void;
  updateExercise: (exerciseId: string, updates: Partial<Exercise>) => void;

  getRecentExercises: (limit?: number) => Exercise[];
  getWorkoutStats: (period?: 'week' | 'month' | 'year') => any;
}

export const useWorkoutStore = create<WorkoutState>()(
  persist(
    immer((set, get) => ({
      // 初始状态
      currentWorkout: null,
      isWorkoutActive: false,
      workouts: [],
      exercises: [],
      recentExercises: [],
      totalWorkouts: 0,
      totalVolume: 0,
      currentStreak: 0,

      // 开始训练
      startWorkout: (selectedExercises = []) => {
        set((state) => {
          state.currentWorkout = {
            id: `workout_${Date.now()}`,
            date: new Date().toISOString(),
            exercises: selectedExercises.map(exercise => ({
              id: exercise.id,
              name: exercise.name,
              sets: []
            })),
            totalDuration: 0,
            totalVolume: 0,
            completedAt: null,
            notes: ''
          };
          state.isWorkoutActive = true;
        });
      },

      // 完成训练
      completeWorkout: () => {
        set((state) => {
          if (state.currentWorkout) {
            state.currentWorkout.completedAt = new Date().toISOString();
            state.workouts.push(state.currentWorkout);
            state.currentWorkout = null;
            state.isWorkoutActive = false;
            state.totalWorkouts += 1;

            // 更新统计
            const lastWeekWorkout = state.workouts
              .filter(w => w.completedAt)
              .sort((a, b) => new Date(b.completedAt!).getTime() - new Date(a.completedAt!).getTime())[0];

            if (lastWeekWorkout) {
              state.currentStreak = calculateStreak(state.workouts);
            }
          }
        });
      },

      // 暂停训练
      pauseWorkout: () => {
        set((state) => {
          state.isWorkoutActive = false;
        });
      },

      // 恢复训练
      resumeWorkout: () => {
        set((state) => {
          state.isWorkoutActive = true;
        });
      },

      // 添加组数
      addSet: (exerciseId: string, weight: number, reps: number) => {
        set((state) => {
          if (state.currentWorkout) {
            const exercise = state.currentWorkout.exercises.find(e => e.id === exerciseId);
            if (exercise) {
              const newSet: WorkoutSet = {
                id: `set_${Date.now()}`,
                weight,
                reps,
                completedAt: new Date().toISOString()
              };
              exercise.sets.push(newSet);

              // 更新总体积
              state.totalVolume += weight * reps;
            }
          }
        });
      },

      // 更新组数
      updateSet: (setId: string, updates: Partial<WorkoutSet>) => {
        set((state) => {
          if (state.currentWorkout) {
            for (const exercise of state.currentWorkout.exercises) {
              const setIndex = exercise.sets.findIndex(s => s.id === setId);
              if (setIndex !== -1) {
                const oldSet = exercise.sets[setIndex];
                exercise.sets[setIndex] = { ...oldSet, ...updates };
                break;
              }
            }
          }
        });
      },

      // 删除组数
      removeSet: (setId: string) => {
        set((state) => {
          if (state.currentWorkout) {
            for (const exercise of state.currentWorkout.exercises) {
              const setIndex = exercise.sets.findIndex(s => s.id === setId);
              if (setIndex !== -1) {
                const removedSet = exercise.sets[setIndex];
                exercise.sets.splice(setIndex, 1);

                // 更新总体积
                state.totalVolume -= removedSet.weight * removedSet.reps;
                break;
              }
            }
          }
        });
      },

      // 加载训练记录
      loadWorkouts: async () => {
        try {
          const { Storage } = await import('@capacitor/storage');
          const { value } = await Storage.get({ key: 'workouts' });

          if (value) {
            set((state) => {
              state.workouts = JSON.parse(value);
              state.totalWorkouts = state.workouts.length;
              state.totalVolume = calculateTotalVolume(state.workouts);
            });
          }
        } catch (error) {
          console.error('Failed to load workouts:', error);
        }
      },

      // 保存训练记录
      saveWorkout: async (workout: Workout) => {
        try {
          const { Storage } = await import('@capacitor/storage');
          await Storage.set({
            key: 'workouts',
            value: JSON.stringify([workout])
          });
        } catch (error) {
          console.error('Failed to save workout:', error);
        }
      },

      // 加载动作库
      loadExercises: async () => {
        try {
          const { Storage } = await import('@capacitor/storage');
          const { value } = await Storage.get({ key: 'exercises' });

          if (value) {
            set((state) => {
              state.exercises = JSON.parse(value);
            });
          } else {
            // 加载默认动作库
            const defaultExercises = await loadDefaultExercises();
            set((state) => {
              state.exercises = defaultExercises;
            });
          }
        } catch (error) {
          console.error('Failed to load exercises:', error);
        }
      },

      // 添加动作
      addExercise: (exercise: Exercise) => {
        set((state) => {
          state.exercises.push(exercise);
        });
      },

      // 更新动作
      updateExercise: (exerciseId: string, updates: Partial<Exercise>) => {
        set((state) => {
          const index = state.exercises.findIndex(e => e.id === exerciseId);
          if (index !== -1) {
            state.exercises[index] = { ...state.exercises[index], ...updates };
          }
        });
      },

      // 获取最近训练的动作
      getRecentExercises: (limit = 10) => {
        const { workouts } = get();
        const exerciseMap = new Map<string, { count: number; lastUsed: Date }>();

        workouts.forEach(workout => {
          workout.exercises.forEach(exercise => {
            const existing = exerciseMap.get(exercise.id);
            exerciseMap.set(exercise.id, {
              count: (existing?.count || 0) + 1,
              lastUsed: new Date(existing?.lastUsed || workout.date)
            });
          });
        });

        return Array.from(exerciseMap.entries())
          .sort((a, b) => b[1].lastUsed.getTime() - a[1].lastUsed.getTime())
          .slice(0, limit)
          .map(([id]) => get().exercises.find(e => e.id === id))
          .filter(Boolean) as Exercise[];
      },

      // 获取训练统计
      getWorkoutStats: (period = 'week') => {
        const { workouts } = get();
        const now = new Date();
        const cutoffDate = new Date();

        switch (period) {
          case 'week':
            cutoffDate.setDate(now.getDate() - 7);
            break;
          case 'month':
            cutoffDate.setMonth(now.getMonth() - 1);
            break;
          case 'year':
            cutoffDate.setFullYear(now.getFullYear() - 1);
            break;
        }

        const filteredWorkouts = workouts.filter(w =>
          w.completedAt && new Date(w.completedAt) >= cutoffDate
        );

        return {
          count: filteredWorkouts.length,
          totalVolume: filteredWorkouts.reduce((sum, w) => sum + w.totalVolume, 0),
          averageDuration: filteredWorkouts.reduce((sum, w) => sum + w.totalDuration, 0) / filteredWorkouts.length || 0,
          mostFrequentExercise: getMostFrequentExercise(filteredWorkouts)
        };
      }
    })),
    {
      name: 'fitness-storage',
      partialize: (state) => ({
        workouts: state.workouts,
        exercises: state.exercises,
        totalWorkouts: state.totalWorkouts,
        totalVolume: state.totalVolume,
        currentStreak: state.currentStreak
      })
    }
  )
);

// 辅助函数
function calculateStreak(workouts: Workout[]): number {
  const completedWorkouts = workouts
    .filter(w => w.completedAt)
    .map(w => new Date(w.completedAt!).toDateString())
    .sort((a, b) => new Date(b).getTime() - new Date(a).getTime());

  let streak = 0;
  let currentDate = new Date();

  for (const workoutDate of completedWorkouts) {
    const workoutDateObj = new Date(workoutDate);
    const daysDiff = Math.floor((currentDate.getTime() - workoutDateObj.getTime()) / (1000 * 60 * 60 * 24));

    if (daysDiff === streak) {
      streak++;
      currentDate = new Date(currentDate.getTime() - 24 * 60 * 60 * 1000);
    } else {
      break;
    }
  }

  return streak;
}

function calculateTotalVolume(workouts: Workout[]): number {
  return workouts.reduce((sum, workout) => sum + workout.totalVolume, 0);
}

function getMostFrequentExercise(workouts: Workout[]): string {
  const exerciseCount = new Map<string, number>();

  workouts.forEach(workout => {
    workout.exercises.forEach(exercise => {
      exerciseCount.set(exercise.id, (exerciseCount.get(exercise.id) || 0) + 1);
    });
  });

  let maxCount = 0;
  let mostFrequent = '';

  for (const [id, count] of exerciseCount) {
    if (count > maxCount) {
      maxCount = count;
      mostFrequent = id;
    }
  }

  return mostFrequent;
}

async function loadDefaultExercises(): Promise<Exercise[]> {
  return [
    {
      id: 'squat',
      name: '深蹲',
      category: 'legs',
      muscleGroups: ['quadriceps', 'glutes', 'hamstrings'],
      equipment: ['barbell', 'dumbbell', 'bodyweight']
    },
    {
      id: 'bench_press',
      name: '卧推',
      category: 'chest',
      muscleGroups: ['chest', 'triceps', 'shoulders'],
      equipment: ['barbell', 'dumbbell']
    },
    {
      id: 'deadlift',
      name: '硬拉',
      category: 'back',
      muscleGroups: ['back', 'glutes', 'hamstrings'],
      equipment: ['barbell', 'dumbbell']
    },
    // ... 更多默认动作
  ];
}
```

## 🔧 自定义Hooks

### useWorkout Hook

```typescript
// src/hooks/useWorkout.ts
import { useCallback } from 'react';
import { useWorkoutStore } from '../stores/workoutStore';
import { useNotifications } from './useNotifications';
import { useAudioService } from './useAudioService';
import { Exercise } from '../types/workout';

export const useWorkout = () => {
  const {
    currentWorkout,
    isWorkoutActive,
    workouts,
    exercises,
    startWorkout,
    completeWorkout,
    pauseWorkout,
    resumeWorkout,
    addSet,
    updateSet,
    removeSet,
    loadWorkouts,
    saveWorkout
  } = useWorkoutStore();

  const { scheduleNotification } = useNotifications();
  const { playSound } = useAudioService();

  // 开始新训练
  const handleStartWorkout = useCallback(async (selectedExercises?: Exercise[]) => {
    startWorkout(selectedExercises);

    // 安排训练开始通知
    await scheduleNotification({
      id: 'workout-started',
      title: '训练开始',
      body: selectedExercises ? `开始${selectedExercises.length}个动作的训练` : '开始新的训练',
      schedule: { at: new Date() }
    });

    // 播放开始音效
    playSound('workout_start');
  }, [startWorkout, scheduleNotification, playSound]);

  // 完成训练
  const handleCompleteWorkout = useCallback(async () => {
    if (!currentWorkout) return;

    completeWorkout();

    // 安排训练完成通知
    await scheduleNotification({
      id: 'workout-completed',
      title: '训练完成！',
      body: `训练时长：${formatDuration(currentWorkout.totalDuration)}，总重量：${currentWorkout.totalVolume}kg`,
      schedule: { at: new Date() }
    });

    // 播放完成音效
    playSound('workout_complete');

    // 保存训练记录
    await saveWorkout(currentWorkout);
  }, [currentWorkout, completeWorkout, scheduleNotification, playSound, saveWorkout]);

  // 记录一组数据
  const handleAddSet = useCallback((
    exerciseId: string,
    weight: number,
    reps: number,
    autoRestTime?: number
  ) => {
    addSet(exerciseId, weight, reps);

    // 如果有自动休息时间，安排休息提醒
    if (autoRestTime && autoRestTime > 0) {
      setTimeout(async () => {
        await scheduleNotification({
          id: 'rest-complete',
          title: '休息结束',
          body: '开始下一组训练',
          schedule: { at: new Date() }
        });
        playSound('rest_complete');
      }, autoRestTime * 1000);
    }
  }, [addSet, scheduleNotification, playSound]);

  // 获取当前训练中的动作
  const getCurrentExercises = useCallback(() => {
    return currentWorkout?.exercises || [];
  }, [currentWorkout]);

  // 获取指定动作的组数记录
  const getExerciseSets = useCallback((exerciseId: string) => {
    const exercise = getCurrentExercises().find(e => e.id === exerciseId);
    return exercise?.sets || [];
  }, [getCurrentExercises]);

  // 计算训练进度
  const getWorkoutProgress = useCallback(() => {
    if (!currentWorkout) return 0;

    const totalSets = currentWorkout.exercises.reduce((sum, ex) => sum + ex.sets.length, 0);
    const targetSets = currentWorkout.exercises.length * 3; // 假设每个动作3组

    return Math.min((totalSets / targetSets) * 100, 100);
  }, [currentWorkout]);

  // 获取训练统计
  const getWorkoutStats = useCallback(() => {
    if (!currentWorkout) return null;

    const totalSets = currentWorkout.exercises.reduce((sum, ex) => sum + ex.sets.length, 0);
    const totalReps = currentWorkout.exercises.reduce((sum, ex) =>
      sum + ex.sets.reduce((setSum, set) => setSum + set.reps, 0), 0
    );
    const heaviestWeight = Math.max(
      ...currentWorkout.exercises.flatMap(ex =>
        ex.sets.map(set => set.weight)
      ), 0
    );

    return {
      totalSets,
      totalReps,
      totalVolume: currentWorkout.totalVolume,
      heaviestWeight,
      duration: currentWorkout.totalDuration
    };
  }, [currentWorkout]);

  return {
    // 状态
    currentWorkout,
    isWorkoutActive,
    workouts,
    exercises,

    // 操作方法
    startWorkout: handleStartWorkout,
    completeWorkout: handleCompleteWorkout,
    pauseWorkout,
    resumeWorkout,
    addSet: handleAddSet,
    updateSet,
    removeSet,
    loadWorkouts,

    // 辅助方法
    getCurrentExercises,
    getExerciseSets,
    getWorkoutProgress,
    getWorkoutStats
  };
};

// 辅助函数
function formatDuration(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;

  if (hours > 0) {
    return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  return `${minutes}:${secs.toString().padStart(2, '0')}`;
}
```

## 📱 原生功能集成

### 通知服务

```typescript
// src/services/notificationService.ts
import { LocalNotifications, PermissionStatus } from '@capacitor/local-notifications';

export class NotificationService {
  private static instance: NotificationService;

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  async requestPermission(): Promise<boolean> {
    try {
      const permission = await LocalNotifications.requestPermissions();
      return permission.display === 'granted';
    } catch (error) {
      console.error('Failed to request notification permission:', error);
      return false;
    }
  }

  async scheduleNotification(options: {
    id: string;
    title: string;
    body: string;
    schedule?: { at: Date };
    sound?: string;
    iconColor?: string;
  }): Promise<void> {
    try {
      await LocalNotifications.schedule({
        notifications: [{
          id: options.id,
          title: options.title,
          body: options.body,
          scheduleAt: options.schedule?.at,
          sound: options.sound || 'default',
          iconColor: options.iconColor || '#488AFF',
          smallIcon: 'ic_stat_icon_config_sample',
          largeIcon: 'ic_launcher'
        }]
      });
    } catch (error) {
      console.error('Failed to schedule notification:', error);
    }
  }

  async cancelNotification(id: string): Promise<void> {
    try {
      await LocalNotifications.cancel({ notifications: [{ id }] });
    } catch (error) {
      console.error('Failed to cancel notification:', error);
    }
  }

  async cancelAllNotifications(): Promise<void> {
    try {
      await LocalNotifications.cancel({});
    } catch (error) {
      console.error('Failed to cancel all notifications:', error);
    }
  }

  async getPendingNotifications(): Promise<any[]> {
    try {
      const { notifications } = await LocalNotifications.getPending();
      return notifications;
    } catch (error) {
      console.error('Failed to get pending notifications:', error);
      return [];
    }
  }

  // 注册通知监听器
  addListeners(): void {
    LocalNotifications.addListener(
      'localNotificationReceived',
      (notification) => {
        console.log('Notification received:', notification);
        this.handleNotificationReceived(notification);
      }
    );

    LocalNotifications.addListener(
      'localNotificationActionPerformed',
      (notificationAction) => {
        console.log('Notification action performed:', notificationAction);
        this.handleNotificationActionPerformed(notificationAction);
      }
    );
  }

  private handleNotificationReceived(notification: any): void {
    // 处理通知接收逻辑
    if (notification.id === 'rest-complete') {
      // 休息结束通知
      this.playNotificationSound('notification.wav');
    } else if (notification.id === 'workout-reminder') {
      // 训练提醒通知
      this.showWorkoutReminder(notification);
    }
  }

  private handleNotificationActionPerformed(notificationAction: any): void {
    // 处理通知点击操作
    if (notificationAction.notificationId === 'workout-reminder') {
      // 点击训练提醒，跳转到训练页面
      this.navigateToWorkout();
    }
  }

  private async playNotificationSound(soundFile: string): Promise<void> {
    try {
      const { AudioService } = await import('./audioService');
      const audioService = AudioService.getInstance();
      await audioService.playSound(soundFile);
    } catch (error) {
      console.error('Failed to play notification sound:', error);
    }
  }

  private showWorkoutReminder(notification: any): void {
    // 显示训练提醒UI
    console.log('Workout reminder:', notification.body);
  }

  private navigateToWorkout(): void {
    // 导航到训练页面
    window.location.href = '/workout';
  }
}

export const notificationService = NotificationService.getInstance();
```

### 音频服务

```typescript
// src/services/audioService.ts
import { Capacitor } from '@capacitor/core';

export class AudioService {
  private static instance: AudioService;
  private audioCache: Map<string, HTMLAudioElement> = new Map();

  static getInstance(): AudioService {
    if (!AudioService.instance) {
      AudioService.instance = new AudioService();
    }
    return AudioService.instance;
  }

  async playSound(soundName: string, options?: {
    volume?: number;
    loop?: boolean;
  }): Promise<void> {
    try {
      // 在Web环境中使用HTML5 Audio
      if (Capacitor.getPlatform() === 'web') {
        await this.playWebSound(soundName, options);
      } else {
        // 在原生环境中使用Capacitor插件
        await this.playNativeSound(soundName, options);
      }
    } catch (error) {
      console.error('Failed to play sound:', soundName, error);
    }
  }

  async stopSound(soundName: string): Promise<void> {
    try {
      const audio = this.audioCache.get(soundName);
      if (audio) {
        audio.pause();
        audio.currentTime = 0;
      }
    } catch (error) {
      console.error('Failed to stop sound:', soundName, error);
    }
  }

  async stopAllSounds(): Promise<void> {
    try {
      this.audioCache.forEach((audio) => {
        audio.pause();
        audio.currentTime = 0;
      });
    } catch (error) {
      console.error('Failed to stop all sounds:', error);
    }
  }

  private async playWebSound(soundName: string, options?: any): Promise<void> {
    let audio = this.audioCache.get(soundName);

    if (!audio) {
      audio = new Audio(`/assets/sounds/${soundName}`);
      audio.preload = 'auto';
      this.audioCache.set(soundName, audio);
    }

    audio.volume = options?.volume || 1;
    audio.loop = options?.loop || false;

    try {
      await audio.play();
    } catch (error) {
      console.error('Failed to play web audio:', error);
      // 处理自动播放限制
      if (error.name === 'NotAllowedError') {
        console.warn('Audio playback requires user interaction');
      }
    }
  }

  private async playNativeSound(soundName: string, options?: any): Promise<void> {
    try {
      // 这里可以使用原生插件或原生代码
      // 示例：使用 Capacitor 插件
      // await NativeAudio.play({
      //   assetId: soundName,
      //   volume: options?.volume || 1,
      //   loop: options?.loop || false
      // });

      // 暂时回退到 Web 音频
      await this.playWebSound(soundName, options);
    } catch (error) {
      console.error('Failed to play native audio:', error);
      // 回退到 Web 音频
      await this.playWebSound(soundName, options);
    }
  }

  // 预加载音频文件
  async preloadSounds(soundFiles: string[]): Promise<void> {
    const preloadPromises = soundFiles.map(async (soundFile) => {
      try {
        let audio = this.audioCache.get(soundFile);
        if (!audio) {
          audio = new Audio(`/assets/sounds/${soundFile}`);
          audio.preload = 'auto';
          await audio.load();
          this.audioCache.set(soundFile, audio);
        }
      } catch (error) {
        console.error(`Failed to preload sound: ${soundFile}`, error);
      }
    });

    await Promise.all(preloadPromises);
  }

  // 清理音频缓存
  clearCache(): void {
    this.audioCache.forEach((audio) => {
      audio.pause();
      audio.src = '';
    });
    this.audioCache.clear();
  }
}

export const audioService = AudioService.getInstance();
```

## 🧪 测试策略

### Jest配置

```json
// jest.config.json
{
  "preset": "ts-jest",
  "testEnvironment": "jsdom",
  "setupFilesAfterEnv": ["<rootDir>/src/setupTests.ts"],
  "moduleNameMapping": {
    "^@/(.*)$": "<rootDir>/src/$1",
    "\\.(css|less|scss|sass)$": "identity-obj-proxy"
  },
  "collectCoverageFrom": [
    "src/**/*.{ts,tsx}",
    "!src/**/*.d.ts",
    "!src/main.tsx",
    "!src/vite-env.d.ts"
  ],
  "coverageThreshold": {
    "global": {
      "branches": 70,
      "functions": 70,
      "lines": 70,
      "statements": 70
    }
  }
}
```

### 测试用例示例

```typescript
// src/components/workout/WorkoutTimer.test.tsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { WorkoutTimer } from './WorkoutTimer';
import { useHaptics } from '../../hooks/useHaptics';
import { useAudioService } from '../../hooks/useAudioService';

// Mock hooks
jest.mock('../../hooks/useHaptics');
jest.mock('../../hooks/useAudioService');

const mockUseHaptics = useHaptics as jest.MockedFunction<typeof useHaptics>;
const mockUseAudioService = useAudioService as jest.MockedFunction<typeof useAudioService>;

describe('WorkoutTimer', () => {
  const mockHapticImpact = jest.fn();
  const mockPlayBeep = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseHaptics.mockReturnValue({
      hapticImpact: mockHapticImpact
    });
    mockUseAudioService.mockReturnValue({
      playBeep: mockPlayBeep
    });
  });

  it('renders with initial duration', () => {
    render(<WorkoutTimer duration={60} />);
    expect(screen.getByText('01:00')).toBeInTheDocument();
  });

  it('starts and stops timer correctly', async () => {
    const onComplete = jest.fn();
    render(<WorkoutTimer duration={3} onComplete={onComplete} />);

    // 点击开始按钮
    const startButton = screen.getByText('开始');
    fireEvent.click(startButton);

    // 等待计时器运行
    await waitFor(() => {
      expect(screen.getByText('00:02')).toBeInTheDocument();
    }, { timeout: 1500 });

    // 点击暂停按钮
    const pauseButton = screen.getByText('暂停');
    fireEvent.click(pauseButton);

    // 验证触觉反馈被调用
    expect(mockHapticImpact).toHaveBeenCalledWith('light');
  });

  it('calls onComplete when timer reaches zero', async () => {
    const onComplete = jest.fn();
    render(<WorkoutTimer duration={1} onComplete={onComplete} />);

    // 快进时间
    jest.advanceTimersByTime(1000);

    await waitFor(() => {
      expect(onComplete).toHaveBeenCalled();
    });

    // 验证触觉反馈
    expect(mockHapticImpact).toHaveBeenCalledWith('heavy');
  });

  it('plays beep and haptic feedback in last 3 seconds', async () => {
    render(<WorkoutTimer duration={3} />);

    // 开始计时器
    fireEvent.click(screen.getByText('开始'));

    // 快进到2秒
    jest.advanceTimersByTime(1000);

    await waitFor(() => {
      expect(mockPlayBeep).toHaveBeenCalledTimes(1);
      expect(mockHapticImpact).toHaveBeenCalledWith('light');
    });

    // 快进到1秒
    jest.advanceTimersByTime(1000);

    await waitFor(() => {
      expect(mockPlayBeep).toHaveBeenCalledTimes(2);
    });
  });

  it('resets timer correctly', () => {
    render(<WorkoutTimer duration={60} />);

    // 开始计时器
    fireEvent.click(screen.getByText('开始'));
    jest.advanceTimersByTime(2000);

    // 点击重置按钮
    fireEvent.click(screen.getByText('重置'));

    // 验证时间重置
    expect(screen.getByText('01:00')).toBeInTheDocument();
    expect(mockHapticImpact).toHaveBeenCalledWith('medium');
  });
});
```

## 🚀 构建和部署

### Vite配置优化

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { viteSingleFile } from 'vite-plugin-singlefile';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    react({
      // 启用 Fast Refresh
      fastRefresh: true,
      // 优化 React 导入
      jsxImportSource: '@emotion/react'
    }),
    // 用于 Capacitor 构建优化
    viteSingleFile({
      removeViteModuleLoader: true,
      inlinePattern: []
    }),
    // 打包分析插件
    process.env.ANALYZE && visualizer({
      filename: 'dist/stats.html',
      open: true,
      gzipSize: true,
      brotliSize: true
    })
  ].filter(Boolean),

  build: {
    target: 'esnext',
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'terser',

    // 优化依赖打包
    rollupOptions: {
      output: {
        // 按模块分割代码
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ionic: ['@ionic/react', '@ionic/react-router'],
          capacitor: ['@capacitor/core', '@capacitor/haptics'],
          utils: ['date-fns', 'zustand']
        },

        // 优化文件名
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]'
      }
    },

    //  terser 优化选项
    terserOptions: {
      compress: {
        drop_console: true, // 移除 console.log
        drop_debugger: true  // 移除 debugger
      }
    },

    // 代码分割策略
    chunkSizeWarningLimit: 1000,

    // 资源内联阈值
    assetsInlineLimit: 4096
  },

  // 开发服务器配置
  server: {
    port: 3000,
    host: true,
    https: false,
    cors: true,

    // 代理配置（如果需要）
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  },

  // 预览服务器配置
  preview: {
    port: 4173,
    host: true
  },

  // CSS 配置
  css: {
    postcss: {
      plugins: [
        require('tailwindcss'),
        require('autoprefixer')
      ]
    },
    preprocessorOptions: {
      scss: {
        additionalData: `@import "@/styles/variables.scss";`
      }
    }
  },

  // 依赖优化
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      '@ionic/react',
      'zustand'
    ],
    exclude: [
      '@capacitor/core'
    ]
  },

  // 环境变量
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version)
  }
});
```

## 📊 性能优化

### React组件优化

```typescript
// src/components/OptimizedWorkoutList.tsx
import React, { memo, useMemo, useCallback } from 'react';
import { IonList, IonItem, IonLabel } from '@ionic/react';
import { Workout } from '../types/workout';

interface WorkoutListProps {
  workouts: Workout[];
  onSelect: (workout: Workout) => void;
  onDelete?: (workoutId: string) => void;
}

// 使用 memo 优化组件重渲染
export const OptimizedWorkoutList = memo<WorkoutListProps>(({
  workouts,
  onSelect,
  onDelete
}) => {
  // 使用 useMemo 缓存计算结果
  const sortedWorkouts = useMemo(() => {
    return workouts.sort((a, b) =>
      new Date(b.date).getTime() - new Date(a.date).getTime()
    );
  }, [workouts]);

  // 使用 useCallback 缓存事件处理函数
  const handleSelect = useCallback((workout: Workout) => {
    onSelect(workout);
  }, [onSelect]);

  const handleDelete = useCallback((workoutId: string) => {
    onDelete?.(workoutId);
  }, [onDelete]);

  return (
    <IonList>
      {sortedWorkouts.map((workout) => (
        <WorkoutListItem
          key={workout.id}
          workout={workout}
          onSelect={handleSelect}
          onDelete={onDelete ? handleDelete : undefined}
        />
      ))}
    </IonList>
  );
});

// 子组件也使用 memo 优化
const WorkoutListItem = memo<{
  workout: Workout;
  onSelect: (workout: Workout) => void;
  onDelete?: (workoutId: string) => void;
}>(({ workout, onSelect, onDelete }) => {
  const formatDate = useMemo(() => {
    return new Date(workout.date).toLocaleDateString('zh-CN');
  }, [workout.date]);

  return (
    <IonItem button onClick={() => onSelect(workout)}>
      <IonLabel>
        <h2>{formatDate}</h2>
        <p>总重量: {workout.totalVolume}kg</p>
      </IonLabel>
      {onDelete && (
        <IonItem slot="end" button onClick={() => onDelete(workout.id)}>
          删除
        </IonItem>
      )}
    </IonItem>
  );
});

WorkoutListItem.displayName = 'WorkoutListItem';
```

这个实施指南提供了从零开始构建React+Capacitor健身应用的完整技术栈，包括项目结构、组件开发、状态管理、原生功能集成、测试和性能优化等各个方面。
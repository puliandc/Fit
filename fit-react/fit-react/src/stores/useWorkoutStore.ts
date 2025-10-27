//created by Jason Lu on 22:48:00 10/26/2025
// Zustand状态管理 - 替换SwiftUI Environment Objects

import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import {
  WorkoutStatus
} from '../types';
import type {
  WorkoutPlan,
  WorkoutSessionData,
  WorkoutProgress,
  UserSettings,
  DialogState,
  NavigationState
} from '../types';

// 训练状态管理
interface WorkoutStore {
  // 当前训练状态
  currentWorkoutPlan: WorkoutPlan | null;
  currentWorkoutSession: WorkoutSessionData | null;
  workoutStatus: WorkoutStatus;
  workoutProgress: WorkoutProgress;

  // 导航状态
  navigationState: NavigationState;

  // 对话框状态
  dialogState: DialogState;

  // 用户设置
  userSettings: UserSettings;

  // 训练相关Actions
  startWorkout: (workoutPlan: WorkoutPlan) => void;
  pauseWorkout: () => void;
  resumeWorkout: () => void;
  completeCurrentSet: (actualReps: number, actualWeight: number) => void;
  nextExercise: () => void;
  previousExercise: () => void;
  finishWorkout: () => void;
  abandonWorkout: () => void;

  // 导航相关Actions
  setNavigationScreen: (screen: NavigationState['currentScreen']) => void;
  setWorkoutStatus: (status: WorkoutStatus) => void;

  // 对话框相关Actions
  openQuitDialog: () => void;
  closeQuitDialog: () => void;
  openEditSetDialog: (exerciseSetId: string, currentWeight: number, currentReps: number) => void;
  closeEditSetDialog: () => void;
  openWorkoutCompleteDialog: () => void;
  closeWorkoutCompleteDialog: () => void;

  // 设置相关Actions
  updateUserSettings: (settings: Partial<UserSettings>) => void;

  // 数据管理Actions
  loadWorkoutPlans: () => Promise<WorkoutPlan[]>;
  saveWorkoutPlan: (workoutPlan: WorkoutPlan) => Promise<void>;
  deleteWorkoutPlan: (id: string) => Promise<void>;
  loadWorkoutHistory: () => Promise<WorkoutSessionData[]>;
  saveWorkoutSession: (session: WorkoutSessionData) => Promise<void>;
}

// 创建store
export const useWorkoutStore = create<WorkoutStore>()(
  devtools(
    persist(
      (set, get) => ({
        // 初始状态
        currentWorkoutPlan: null,
        currentWorkoutSession: null,
        workoutStatus: WorkoutStatus.NOT_STARTED,
        workoutProgress: {
          currentExerciseIndex: 0,
          currentSetIndex: 0,
          totalExercises: 0,
          totalSets: 0,
          completedSets: 0,
          estimatedTimeRemaining: 0,
        },
        navigationState: {
          currentScreen: 'main',
          workoutStatus: WorkoutStatus.NOT_STARTED,
          hasActiveWorkout: false,
        },
        dialogState: {
          quitWorkout: false,
          editSet: false,
          workoutComplete: false,
          editSetData: undefined,
        },
        userSettings: {
          voiceEnabled: true,
          voiceVolume: 0.8,
          restTimeEnabled: true,
          autoStartNextSet: false,
          weightUnit: 'kg',
          soundEnabled: true,
        },

        // 训练相关Actions
        startWorkout: (workoutPlan: WorkoutPlan) => {
          const sessionId = crypto.randomUUID();
          const now = new Date();

          const session: WorkoutSessionData = {
            id: sessionId,
            workoutPlanId: workoutPlan.id,
            startedAt: now,
            completedSets: [],
            isCompleted: false,
          };

          const totalSets = workoutPlan.exercises.length;
          const estimatedTime = workoutPlan.duration * 60; // 转换为秒

          set({
            currentWorkoutPlan: workoutPlan,
            currentWorkoutSession: session,
            workoutStatus: WorkoutStatus.IN_PROGRESS,
            workoutProgress: {
              currentExerciseIndex: 0,
              currentSetIndex: 0,
              totalExercises: workoutPlan.exercises.length,
              totalSets,
              completedSets: 0,
              estimatedTimeRemaining: estimatedTime,
            },
            navigationState: {
              currentScreen: 'workout',
              workoutStatus: WorkoutStatus.IN_PROGRESS,
              hasActiveWorkout: true,
            },
          });
        },

        pauseWorkout: () => {
          set({
            workoutStatus: WorkoutStatus.PAUSED,
            navigationState: get().navigationState,
          });
        },

        resumeWorkout: () => {
          set({
            workoutStatus: WorkoutStatus.IN_PROGRESS,
            navigationState: get().navigationState,
          });
        },

        completeCurrentSet: (actualReps: number, actualWeight: number) => {
          const { currentWorkoutSession, workoutProgress } = get();

          if (!currentWorkoutSession) return;

          const completedSet = {
            id: crypto.randomUUID(),
            exerciseSetId: currentWorkoutSession.workoutPlanId,
            actualReps,
            actualWeight,
            completedAt: new Date(),
          };

          const updatedSession = {
            ...currentWorkoutSession,
            completedSets: [...currentWorkoutSession.completedSets, completedSet],
          };

          const newCompletedSets = workoutProgress.completedSets + 1;

          set({
            currentWorkoutSession: updatedSession,
            workoutProgress: {
              ...workoutProgress,
              completedSets: newCompletedSets,
            },
          });
        },

        nextExercise: () => {
          const { workoutProgress } = get();

          if (workoutProgress.currentExerciseIndex < workoutProgress.totalExercises - 1) {
            set({
              workoutProgress: {
                ...workoutProgress,
                currentExerciseIndex: workoutProgress.currentExerciseIndex + 1,
                currentSetIndex: 0,
              },
            });
          }
        },

        previousExercise: () => {
          const { workoutProgress } = get();

          if (workoutProgress.currentExerciseIndex > 0) {
            set({
              workoutProgress: {
                ...workoutProgress,
                currentExerciseIndex: workoutProgress.currentExerciseIndex - 1,
                currentSetIndex: 0,
              },
            });
          }
        },

        finishWorkout: () => {
          const { currentWorkoutSession } = get();

          if (currentWorkoutSession) {
            const completedSession = {
              ...currentWorkoutSession,
              endedAt: new Date(),
              isCompleted: true,
            };

            set({
              currentWorkoutSession: completedSession,
              workoutStatus: WorkoutStatus.COMPLETED,
              navigationState: {
                currentScreen: 'main',
                workoutStatus: WorkoutStatus.COMPLETED,
                hasActiveWorkout: false,
              },
              dialogState: {
                ...get().dialogState,
                workoutComplete: true,
              },
            });

            // 保存训练历史
            get().saveWorkoutSession(completedSession);
          }
        },

        abandonWorkout: () => {
          const { currentWorkoutSession } = get();

          if (currentWorkoutSession) {
            const abandonedSession = {
              ...currentWorkoutSession,
              endedAt: new Date(),
              isCompleted: false,
            };

            // 保存部分完成的训练
            get().saveWorkoutSession(abandonedSession);
          }

          set({
            currentWorkoutPlan: null,
            currentWorkoutSession: null,
            workoutStatus: WorkoutStatus.ABANDONED,
            navigationState: {
              currentScreen: 'main',
              workoutStatus: WorkoutStatus.ABANDONED,
              hasActiveWorkout: false,
            },
            dialogState: {
              quitWorkout: false,
              editSet: false,
              workoutComplete: false,
              editSetData: undefined,
            },
          });
        },

        // 导航相关Actions
        setNavigationScreen: (currentScreen) => {
          set({
            navigationState: {
              ...get().navigationState,
              currentScreen,
              hasActiveWorkout: currentScreen === 'workout',
            },
          });
        },

        setWorkoutStatus: (workoutStatus) => {
          set({
            workoutStatus,
            navigationState: {
              ...get().navigationState,
              workoutStatus,
              hasActiveWorkout: workoutStatus !== WorkoutStatus.NOT_STARTED && workoutStatus !== WorkoutStatus.COMPLETED,
            },
          });
        },

        // 对话框相关Actions
        openQuitDialog: () => {
          set({
            dialogState: {
              ...get().dialogState,
              quitWorkout: true,
            },
          });
        },

        closeQuitDialog: () => {
          set({
            dialogState: {
              ...get().dialogState,
              quitWorkout: false,
            },
          });
        },

        openEditSetDialog: (exerciseSetId, currentWeight, currentReps) => {
          set({
            dialogState: {
              ...get().dialogState,
              editSet: true,
              editSetData: {
                exerciseSetId,
                currentWeight,
                currentReps,
              },
            },
          });
        },

        closeEditSetDialog: () => {
          set({
            dialogState: {
              ...get().dialogState,
              editSet: false,
              editSetData: undefined,
            },
          });
        },

        openWorkoutCompleteDialog: () => {
          set({
            dialogState: {
              ...get().dialogState,
              workoutComplete: true,
            },
          });
        },

        closeWorkoutCompleteDialog: () => {
          set({
            dialogState: {
              ...get().dialogState,
              workoutComplete: false,
            },
          });
        },

        // 设置相关Actions
        updateUserSettings: (newSettings) => {
          set({
            userSettings: {
              ...get().userSettings,
              ...newSettings,
            },
          });
        },

        // 数据管理Actions
        loadWorkoutPlans: async () => {
          try {
            const stored = localStorage.getItem('workout_plans');
            if (stored) {
              return JSON.parse(stored);
            }
            return [];
          } catch (error) {
            console.error('Failed to load workout plans:', error);
            return [];
          }
        },

        saveWorkoutPlan: async (workoutPlan) => {
          try {
            const plans = await get().loadWorkoutPlans();
            const existingIndex = plans.findIndex(p => p.id === workoutPlan.id);

            if (existingIndex >= 0) {
              plans[existingIndex] = workoutPlan;
            } else {
              plans.push(workoutPlan);
            }

            localStorage.setItem('workout_plans', JSON.stringify(plans));
          } catch (error) {
            console.error('Failed to save workout plan:', error);
          }
        },

        deleteWorkoutPlan: async (id) => {
          try {
            const plans = await get().loadWorkoutPlans();
            const filteredPlans = plans.filter(p => p.id !== id);
            localStorage.setItem('workout_plans', JSON.stringify(filteredPlans));
          } catch (error) {
            console.error('Failed to delete workout plan:', error);
          }
        },

        loadWorkoutHistory: async () => {
          try {
            const stored = localStorage.getItem('workout_sessions');
            if (stored) {
              return JSON.parse(stored).map((session: any) => ({
                ...session,
                startedAt: new Date(session.startedAt),
                endedAt: session.endedAt ? new Date(session.endedAt) : undefined,
              }));
            }
            return [];
          } catch (error) {
            console.error('Failed to load workout history:', error);
            return [];
          }
        },

        saveWorkoutSession: async (session) => {
          try {
            const sessions = await get().loadWorkoutHistory();
            const existingIndex = sessions.findIndex(s => s.id === session.id);

            if (existingIndex >= 0) {
              sessions[existingIndex] = session;
            } else {
              sessions.push(session);
            }

            localStorage.setItem('workout_sessions', JSON.stringify(sessions));
          } catch (error) {
            console.error('Failed to save workout session:', error);
          }
        },
      }),
      {
        name: 'workout-store',
        version: 1,
      }
    )
  )
);
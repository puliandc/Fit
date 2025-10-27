//created by Jason Lu on 22:47:00 10/26/2025
// 数据模型定义 - 从SwiftUI迁移到TypeScript

/// 锻练动作模型（简化版）
export interface Exercise {
  id: string;
  name: string;
}

/// 锻炼组数模型
export interface ExerciseSet {
  id: string;
  exercise: Exercise;     // 关联的训练动作
  targetReps: number;    // 目标次数
  targetWeight: number;   // 目标重量
  restTime: number;      // 休息时间（秒）
  notes?: string;        // 备注（可选）
}

/// 锻炼计划模型
export interface WorkoutPlan {
  id: string;
  name: string;
  description?: string;   // 训练描述（可选）
  duration: number;       // 训练时长（分钟）
  difficulty?: string;    // 难度等级（可选）
  created_at?: Date;     // 创建时间（可选）
  updated_at?: Date;     // 更新时间（可选）
  exercises: ExerciseSet[];  // 训练动作组数列表
}

/// 完成组数记录模型
export interface CompletedSet {
  id: string;
  exerciseSetId: string;  // 关联的ExerciseSet ID
  actualReps: number;     // 实际完成次数
  actualWeight: number;    // 实际使用重量
  completedAt: Date;      // 完成时间
  notes?: string;         // 备注
}

/// 训练会话模型
export interface WorkoutSessionData {
  id: string;
  workoutPlanId: string;  // 关联的训练计划ID
  startedAt: Date;       // 开始时间
  endedAt?: Date;        // 结束时间（可选）
  completedSets: CompletedSet[];  // 完成的组数记录
  isCompleted: boolean;  // 是否完成
}

/// 训练状态枚举
export enum WorkoutStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  ABANDONED = 'abandoned'
}

/// 当前训练进度状态
export interface WorkoutProgress {
  currentExerciseIndex: number;
  currentSetIndex: number;
  totalExercises: number;
  totalSets: number;
  completedSets: number;
  estimatedTimeRemaining: number; // 秒
}

/// 应用导航状态
export interface NavigationState {
  currentScreen: 'main' | 'workout' | 'history' | 'settings';
  workoutStatus: WorkoutStatus;
  hasActiveWorkout: boolean;
}


/// 用户设置
export interface UserSettings {
  voiceEnabled: boolean;
  voiceVolume: number;        // 0-1
  restTimeEnabled: boolean;
  autoStartNextSet: boolean;
  weightUnit: 'kg' | 'lbs';
  soundEnabled: boolean;
}

/// 语音播报内容类型
export enum VoicePromptType {
  WORKOUT_START = 'workout_start',
  REST_START = 'rest_start',
  REST_END_WARNING = 'rest_end_warning',
  REST_END = 'rest_end',
  NEXT_EXERCISE = 'next_exercise',
  WORKOUT_COMPLETE = 'workout_complete',
  SET_COMPLETE = 'set_complete'
}

/// 对话框状态
export interface DialogState {
  quitWorkout: boolean;
  editSet: boolean;
  workoutComplete: boolean;
  editSetData?: {
    exerciseSetId: string;
    currentWeight: number;
    currentReps: number;
  };
}

/// 错误类型
export enum AppError {
  WORKOUT_PLAN_LOAD_FAILED = 'workout_plan_load_failed',
  WORKOUT_SESSION_CREATE_FAILED = 'workout_session_create_failed',
  VOICE_PLAYBACK_FAILED = 'voice_playback_failed',
  DATA_SAVE_FAILED = 'data_save_failed',
  INVALID_WORKOUT_PLAN = 'invalid_workout_plan'
}

/// API响应类型
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: AppError;
  message?: string;
}

/// 本地存储键名
export enum StorageKeys {
  WORKOUT_PLANS = 'workout_plans',
  WORKOUT_SESSIONS = 'workout_sessions',
  USER_SETTINGS = 'user_settings'
}

/// 训练计划导入格式（JSON）
export interface WorkoutPlanImport {
  name: string;
  description?: string;
  duration: number;
  exercises: {
    name: string;
    targetReps: number;
    targetWeight: number;
    restTime: number;
    notes?: string;
  }[];
}
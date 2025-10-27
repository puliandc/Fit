import { useState, useEffect } from 'react';
import { MainScreen } from './components/MainScreen';
import { WorkoutScreen } from './components/WorkoutScreen';
import { MobileContainer } from './components/ui/container';
import './styles/mobile.css';

export type WorkoutExercise = {
  id: string;
  name: string;
  image: string;
  sets: number;
  reps: number;
  weight: number;
  restTime: number; // seconds - 组间休息时间
  exerciseRestTime?: number; // seconds - 动作间休息时间（可选，默认为30秒）
};

export type WorkoutPlan = {
  name: string;
  exercises: WorkoutExercise[];
};

export type AppScreen = 'main' | 'workout';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<AppScreen>('main');
  const [workoutPlan, setWorkoutPlan] = useState<WorkoutPlan | null>(null);
  const [planStatus, setPlanStatus] = useState<'none' | 'success' | 'error'>('none');
  const [errorCode, setErrorCode] = useState<string>('');

  // 模拟健身计划数据
  const mockWorkoutPlan: WorkoutPlan = {
    name: "快速训练计划",
    exercises: [
      {
        id: "1",
        name: "杠铃卧推",
        image: "https://images.unsplash.com/photo-1733747660804-5a02541ba8dc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXNzJTIwd29ya291dCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTY2ODQ3Mnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        sets: 2,
        reps: 10,
        weight: 60,
        restTime: 10,
        exerciseRestTime: 15 // 动作间休息15秒
      },
      {
        id: "2", 
        name: "哑铃飞鸟",
        image: "https://images.unsplash.com/photo-1733747660804-5a02541ba8dc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXNzJTIwd29ya291dCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTY2ODQ3Mnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        sets: 2,
        reps: 12,
        weight: 20,
        restTime: 10,
        exerciseRestTime: 15 // 动作间休息15秒
      }
    ]
  };

  const readWorkoutPlan = async () => {
    // 直接读取健身计划
    setWorkoutPlan(mockWorkoutPlan);
    setPlanStatus('success');
  };

  const startWorkout = () => {
    if (workoutPlan) {
      setCurrentScreen('workout');
    }
  };

  const finishWorkout = () => {
    setCurrentScreen('main');
  };

  return (
    <MobileContainer className="size-full bg-background safe-area-top safe-area-bottom">
      {currentScreen === 'main' && (
        <MainScreen
          onReadPlan={readWorkoutPlan}
          onStartWorkout={startWorkout}
          planStatus={planStatus}
          errorCode={errorCode}
          hasWorkoutPlan={!!workoutPlan}
          workoutPlan={workoutPlan}
        />
      )}

      {currentScreen === 'workout' && workoutPlan && (
        <WorkoutScreen
          workoutPlan={workoutPlan}
          onFinish={finishWorkout}
        />
      )}
    </MobileContainer>
  );
}
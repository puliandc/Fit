import { useState, useEffect } from 'react';
import { MainScreen } from './components/MainScreen';
import { WorkoutScreen } from './components/WorkoutScreen';

export type WorkoutExercise = {
  id: string;
  name: string;
  image: string;
  sets: number;
  reps: number;
  weight: number;
  restTime: number; // seconds
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
        restTime: 10
      },
      {
        id: "2", 
        name: "哑铃飞鸟",
        image: "https://images.unsplash.com/photo-1733747660804-5a02541ba8dc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXNzJTIwd29ya291dCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTY2ODQ3Mnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
        sets: 2,
        reps: 12,
        weight: 20,
        restTime: 10
      }
    ]
  };

  const readWorkoutPlan = async () => {
    // 模拟读取iOS备忘录
    try {
      // 模拟网络延迟
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // 50%概率成功，50%概率失败
      if (Math.random() > 0.5) {
        setWorkoutPlan(mockWorkoutPlan);
        setPlanStatus('success');
      } else {
        setPlanStatus('error');
        setErrorCode('ERR_NOTE_NOT_FOUND_001');
      }
    } catch (error) {
      setPlanStatus('error');
      setErrorCode('ERR_SYSTEM_ERROR_002');
    }
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
    <div className="size-full max-w-[393px] mx-auto bg-background">
      {currentScreen === 'main' && (
        <MainScreen
          onReadPlan={readWorkoutPlan}
          onStartWorkout={startWorkout}
          planStatus={planStatus}
          errorCode={errorCode}
          hasWorkoutPlan={!!workoutPlan}
        />
      )}
      
      {currentScreen === 'workout' && workoutPlan && (
        <WorkoutScreen
          workoutPlan={workoutPlan}
          onFinish={finishWorkout}
        />
      )}
    </div>
  );
}
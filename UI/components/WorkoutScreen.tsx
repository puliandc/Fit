import { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Progress } from './ui/progress';
import { ArrowLeft, Timer, Dumbbell, Hash, Weight, Clock, Edit, ChevronRight, Zap } from 'lucide-react';
import { WorkoutPlan } from '../App';
import { CompletionDialog } from './CompletionDialog';
import { QuitDialog } from './QuitDialog';
import { SkipRestDialog } from './SkipRestDialog';
import { EditSetDialog } from './EditSetDialog';
import { WorkoutCompleteDialog } from './WorkoutCompleteDialog';
import { motion, AnimatePresence } from 'motion/react';

interface WorkoutScreenProps {
  workoutPlan: WorkoutPlan;
  onFinish: () => void;
}

export function WorkoutScreen({ workoutPlan, onFinish }: WorkoutScreenProps) {
  const [currentExerciseIndex, setCurrentExerciseIndex] = useState(0);
  const [currentSet, setCurrentSet] = useState(1);
  const [timeLeft, setTimeLeft] = useState(0);
  const [isResting, setIsResting] = useState(false);
  const [isExerciseRest, setIsExerciseRest] = useState(false); // 区分动作间休息
  const [showCompletionDialog, setShowCompletionDialog] = useState(false);
  const [showQuitDialog, setShowQuitDialog] = useState(false);
  const [showSkipRestDialog, setShowSkipRestDialog] = useState(false);
  const [showEditSetDialog, setShowEditSetDialog] = useState(false);
  const [showWorkoutCompleteDialog, setShowWorkoutCompleteDialog] = useState(false);
  const [exerciseStartTime, setExerciseStartTime] = useState<number>(Date.now());
  const [exerciseElapsedTime, setExerciseElapsedTime] = useState(0);
  const [workoutStartTime] = useState<number>(Date.now());
  const [totalWorkoutTime, setTotalWorkoutTime] = useState('');
  const [totalWorkoutElapsedTime, setTotalWorkoutElapsedTime] = useState(0);
  
  // 当前组的修改后参数
  const [currentSetReps, setCurrentSetReps] = useState(0);
  const [currentSetWeight, setCurrentSetWeight] = useState(0);

  const currentExercise = workoutPlan.exercises[currentExerciseIndex];
  const isLastExercise = currentExerciseIndex === workoutPlan.exercises.length - 1;
  const isLastSet = currentSet === currentExercise.sets;

  // 初始化当前组的参数
  useEffect(() => {
    setCurrentSetReps(currentExercise.reps);
    setCurrentSetWeight(currentExercise.weight);
  }, [currentExercise.reps, currentExercise.weight, currentExerciseIndex, currentSet]);

  // Timer effects
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (timeLeft > 0 && isResting) {
      interval = setInterval(() => {
        setTimeLeft((prev) => prev - 1);
      }, 1000);
    } else if (timeLeft === 0 && isResting) {
      setIsResting(false);
      if (isExerciseRest) {
        // 动作间休息结束，切换到下一个动作
        setIsExerciseRest(false);
        setCurrentExerciseIndex(prev => prev + 1);
        setCurrentSet(1);
        setExerciseStartTime(Date.now());
        setExerciseElapsedTime(0);
      } else {
        // 组间休息结束，继续同一动作
        setExerciseStartTime(Date.now());
      }
    }
    return () => clearInterval(interval);
  }, [timeLeft, isResting, isExerciseRest]);

  // Exercise timer effect
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (!isResting && exerciseStartTime) {
      interval = setInterval(() => {
        setExerciseElapsedTime(Math.floor((Date.now() - exerciseStartTime) / 1000));
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [exerciseStartTime, isResting]);

  // Total workout timer effect
  useEffect(() => {
    const interval = setInterval(() => {
      setTotalWorkoutElapsedTime(Math.floor((Date.now() - workoutStartTime) / 1000));
    }, 1000);
    return () => clearInterval(interval);
  }, [workoutStartTime]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  // 计算下一组的信息
  const getNextSetInfo = () => {
    if (isLastSet) {
      // 如果是最后一组，下一组是下一个动作的第一组
      if (!isLastExercise) {
        const nextExercise = workoutPlan.exercises[currentExerciseIndex + 1];
        return {
          name: nextExercise.name,
          reps: nextExercise.reps,
          weight: nextExercise.weight
        };
      }
      return null; // 没有下一组了
    } else {
      // 不是最后一组，下一组是当前动作的下一组
      return {
        name: currentExercise.name,
        reps: currentExercise.reps,
        weight: currentExercise.weight
      };
    }
  };

  const nextSetInfo = getNextSetInfo();

  const handleExerciseComplete = (completedReps: number, completedWeight: number) => {
    setShowCompletionDialog(false);
    
    if (isLastSet && isLastExercise) {
      // 最后一个动作的最后一组，训练完成
      const totalTime = Math.floor((Date.now() - workoutStartTime) / 1000);
      const minutes = Math.floor(totalTime / 60);
      const seconds = totalTime % 60;
      setTotalWorkoutTime(`${minutes}:${seconds.toString().padStart(2, '0')}`);
      setShowWorkoutCompleteDialog(true);
    } else if (isLastSet) {
      // 当前动作的最后一组，进入动作间休息
      const exerciseRestTime = currentExercise.exerciseRestTime || 30; // 默认30秒
      setTimeLeft(exerciseRestTime);
      setIsResting(true);
      setIsExerciseRest(true);
    } else {
      // 不是最后一组，进入组间休息
      setCurrentSet(prev => prev + 1);
      setTimeLeft(currentExercise.restTime);
      setIsResting(true);
      setIsExerciseRest(false);
    }
  };

  const handleQuitAction = () => {
    setShowQuitDialog(false);
    onFinish();
  };

  const handleSkipRest = () => {
    setShowSkipRestDialog(false);
    setIsResting(false);
    setTimeLeft(0);
    
    if (isExerciseRest) {
      // 跳过动作间休息，立即切换到下一个动作
      setIsExerciseRest(false);
      setCurrentExerciseIndex(prev => prev + 1);
      setCurrentSet(1);
      setExerciseStartTime(Date.now());
      setExerciseElapsedTime(0);
    } else {
      // 跳过组间休息，继续当前动作
      setExerciseStartTime(Date.now());
    }
  };

  const handleEditSet = (newReps: number, newWeight: number) => {
    setCurrentSetReps(newReps);
    setCurrentSetWeight(newWeight);
    setShowEditSetDialog(false);
  };

  const handleWorkoutComplete = () => {
    setShowWorkoutCompleteDialog(false);
    onFinish();
  };

  // Calculate overall progress
  const totalSets = workoutPlan.exercises.reduce((sum, ex) => sum + ex.sets, 0);
  const completedSets = workoutPlan.exercises.slice(0, currentExerciseIndex).reduce((sum, ex) => sum + ex.sets, 0) + (currentSet - 1);
  const progress = Math.round((completedSets / totalSets) * 100);

  return (
    <div className="h-screen flex flex-col bg-gradient-to-br from-orange-50/30 via-pink-50/20 to-purple-50/30 dark:from-gray-900 dark:via-gray-900 dark:to-gray-900 relative overflow-hidden mobile-padding">
      {/* Animated Background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute w-96 h-96 bg-gradient-to-br from-orange-300/20 to-pink-300/20 dark:from-orange-500/10 dark:to-pink-500/10 rounded-full blur-3xl"
          animate={{
            x: [0, 100, 0],
            y: [0, -50, 0],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: "easeInOut",
          }}
          style={{ top: '-10%', right: '-20%' }}
        />
        <motion.div
          className="absolute w-96 h-96 bg-gradient-to-br from-purple-300/20 to-blue-300/20 dark:from-purple-500/10 dark:to-blue-500/10 rounded-full blur-3xl"
          animate={{
            x: [0, -60, 0],
            y: [0, 80, 0],
          }}
          transition={{
            duration: 18,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 2
          }}
          style={{ bottom: '20%', left: '-10%' }}
        />
      </div>

      {/* Header */}
      <motion.div
        className="pt-4 pb-4 bg-white/80 dark:bg-gray-800/80 backdrop-blur-xl border-b border-gray-200/50 dark:border-gray-700/50 relative z-10 shadow-sm mobile-top-nav"
        initial={{ y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ type: "spring", stiffness: 300, damping: 30 }}
      >
        <div className="flex items-center gap-3 mb-3">
          <motion.div
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
          >
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setShowQuitDialog(true)}
              className="w-10 h-10 p-0 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 touch-target"
            >
              <ArrowLeft className="w-5 h-5 text-gray-700 dark:text-gray-300" />
            </Button>
          </motion.div>
          <h2 className="flex-1 font-semibold text-gray-900 dark:text-white">
            {workoutPlan.name}
          </h2>
          <span className="text-sm font-medium text-orange-600 dark:text-orange-400">
            {progress}%
          </span>
        </div>
        <div className="relative h-1.5 bg-gray-200/80 dark:bg-gray-700/80 rounded-full overflow-hidden">
          <motion.div
            className="absolute top-0 left-0 h-full bg-gradient-to-r from-orange-500 via-pink-500 to-purple-500 rounded-full"
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.5, ease: "easeOut" }}
          />
        </div>
      </motion.div>

      {/* Rest Timer Overlay */}
      <AnimatePresence>
        {isResting && (
          <motion.div
            className="mt-3 relative z-10"
            initial={{ opacity: 0, y: -20, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -20, scale: 0.95 }}
          >
            <motion.div
              className={`p-4 rounded-2xl cursor-pointer bg-white/90 dark:bg-gray-800/90 backdrop-blur-xl shadow-lg border border-gray-200/50 dark:border-gray-700/50 ${
                isExerciseRest 
                  ? 'ring-2 ring-purple-400/50 dark:ring-purple-500/50' 
                  : 'ring-2 ring-orange-400/50 dark:ring-orange-500/50'
              }`}
              onClick={() => setShowSkipRestDialog(true)}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <div className="flex flex-col items-center gap-1.5">
                <div className="flex items-center gap-2">
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                  >
                    <Timer className={`w-4 h-4 ${isExerciseRest ? 'text-purple-500' : 'text-orange-500'}`} />
                  </motion.div>
                  <span className={`text-sm font-semibold ${isExerciseRest ? 'text-purple-600 dark:text-purple-400' : 'text-orange-600 dark:text-orange-400'}`}>
                    {isExerciseRest ? '动作间休息' : '组间休息'}
                  </span>
                </div>
                <motion.div 
                  className={`font-mono text-2xl font-bold ${isExerciseRest ? 'text-purple-600 dark:text-purple-400' : 'text-orange-600 dark:text-orange-400'}`}
                  animate={{ scale: [1, 1.05, 1] }}
                  transition={{ duration: 1, repeat: Infinity }}
                >
                  {formatTime(timeLeft)}
                </motion.div>
                <span className="text-xs text-gray-500 dark:text-gray-400">点击跳过休息</span>
                {isExerciseRest && workoutPlan.exercises[currentExerciseIndex + 1] && (
                  <motion.div
                    className="mt-1 px-3 py-1 bg-purple-50 dark:bg-purple-900/20 rounded-lg"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.3 }}
                  >
                    <span className="text-xs text-purple-700 dark:text-purple-300">
                      下一个：{workoutPlan.exercises[currentExerciseIndex + 1]?.name}
                    </span>
                  </motion.div>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Exercise Content */}
      <div className="flex-1 mobile-scroll-hide-scrollbar py-3 space-y-3 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          key={currentExerciseIndex}
          transition={{ duration: 0.4 }}
        >
          {/* 主卡片 */}
          <div className="p-5 rounded-2xl bg-white/90 dark:bg-gray-800/90 backdrop-blur-xl shadow-lg border border-gray-200/50 dark:border-gray-700/50 space-y-4">
            {/* 动作名称 */}
            <motion.div
              className="text-center"
              initial={{ scale: 0.95 }}
              animate={{ scale: 1 }}
              transition={{ type: "spring", stiffness: 300, damping: 20 }}
            >
              <h3 className="text-2xl font-bold bg-gradient-to-r from-orange-600 via-pink-600 to-purple-600 bg-clip-text text-transparent">
                {currentExercise.name}
              </h3>
            </motion.div>
            
            {/* 动作计时器 */}
            {!isResting && (
              <motion.div 
                className="flex items-center justify-center gap-2.5 p-3 bg-gradient-to-r from-orange-500/10 to-pink-500/10 dark:from-orange-500/20 dark:to-pink-500/20 rounded-xl border border-orange-200 dark:border-orange-800/50"
                initial={{ scale: 0.95 }}
                animate={{ scale: 1 }}
                transition={{ duration: 0.3 }}
              >
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                >
                  <Clock className="w-5 h-5 text-orange-500" />
                </motion.div>
                <span className="text-xs font-medium text-gray-700 dark:text-gray-300">动作时间</span>
                <span className="text-xl font-mono font-bold text-orange-600 dark:text-orange-400">
                  {formatTime(exerciseElapsedTime)}
                </span>
              </motion.div>
            )}

            {/* 组数横条 */}
            <motion.div 
              className="flex items-center justify-center gap-2.5 p-3 bg-gradient-to-r from-blue-500/10 to-cyan-500/10 dark:from-blue-500/20 dark:to-cyan-500/20 rounded-xl border border-blue-200 dark:border-blue-800/50"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
            >
              <Hash className="w-5 h-5 text-blue-500" />
              <span className="text-xs font-medium text-gray-700 dark:text-gray-300">当前组数</span>
              <div className="flex items-baseline gap-1">
                <span className="text-xl font-bold text-blue-600 dark:text-blue-400">{currentSet}</span>
                <span className="text-base text-gray-400 dark:text-gray-500">/</span>
                <span className="text-base font-semibold text-gray-500 dark:text-gray-400">{currentExercise.sets}</span>
              </div>
            </motion.div>
            
            {/* 次数和重量 */}
            <div className="grid grid-cols-2 gap-3">
              {/* 次数 */}
              <motion.div 
                className="p-4 bg-gradient-to-br from-green-500/10 to-emerald-500/10 dark:from-green-500/20 dark:to-emerald-500/20 rounded-xl cursor-pointer border-2 border-green-200 dark:border-green-800/50 active:border-green-400"
                onClick={() => setShowEditSetDialog(true)}
                whileHover={{ scale: 1.03, y: -2 }}
                whileTap={{ scale: 0.97 }}
                transition={{ type: "spring", stiffness: 400, damping: 25 }}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
              >
                <div className="flex flex-col items-center gap-1.5">
                  <Dumbbell className="w-4 h-4 text-green-600 dark:text-green-400" />
                  <span className="text-xs font-medium text-gray-600 dark:text-gray-400">目标次数</span>
                  <motion.span 
                    className="text-2xl font-bold text-green-600 dark:text-green-400"
                    key={currentSetReps}
                    initial={{ scale: 1.3 }}
                    animate={{ scale: 1 }}
                    transition={{ type: "spring", stiffness: 500, damping: 20 }}
                  >
                    {currentSetReps}
                  </motion.span>
                </div>
              </motion.div>

              {/* 重量 */}
              <motion.div 
                className="p-4 bg-gradient-to-br from-purple-500/10 to-pink-500/10 dark:from-purple-500/20 dark:to-pink-500/20 rounded-xl cursor-pointer border-2 border-purple-200 dark:border-purple-800/50 active:border-purple-400"
                onClick={() => setShowEditSetDialog(true)}
                whileHover={{ scale: 1.03, y: -2 }}
                whileTap={{ scale: 0.97 }}
                transition={{ type: "spring", stiffness: 400, damping: 25 }}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
              >
                <div className="flex flex-col items-center gap-1.5">
                  <Weight className="w-4 h-4 text-purple-600 dark:text-purple-400" />
                  <span className="text-xs font-medium text-gray-600 dark:text-gray-400">目标重量</span>
                  <div className="flex items-baseline gap-1">
                    <motion.span 
                      className="text-2xl font-bold text-purple-600 dark:text-purple-400"
                      key={currentSetWeight}
                      initial={{ scale: 1.3 }}
                      animate={{ scale: 1 }}
                      transition={{ type: "spring", stiffness: 500, damping: 20 }}
                    >
                      {currentSetWeight}
                    </motion.span>
                    <span className="text-xs font-medium text-gray-500 dark:text-gray-400">kg</span>
                  </div>
                </div>
              </motion.div>
            </div>

            {/* 底部信息模块 */}
            <div className="space-y-2 pt-3 border-t border-gray-200/30 dark:border-gray-700/30">
              {/* 下一组动作提示 */}
              {nextSetInfo && (
                <motion.div
                  className="px-3 py-2 bg-gray-50/50 dark:bg-gray-800/30 rounded-lg"
                  initial={{ opacity: 0, y: 5 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.4 }}
                >
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex items-center gap-1.5 flex-shrink-0">
                      <ChevronRight className="w-3.5 h-3.5 text-gray-400 dark:text-gray-500" />
                      <span className="text-xs text-gray-500 dark:text-gray-400">下一组</span>
                    </div>
                    <div className="flex items-center gap-1.5 flex-1 justify-end">
                      <span className="text-xs font-medium text-gray-600 dark:text-gray-400 truncate">
                        {nextSetInfo.name}
                      </span>
                      <span className="text-xs text-gray-500 dark:text-gray-500 flex-shrink-0">
                        {nextSetInfo.reps} 次
                      </span>
                      {nextSetInfo.weight > 0 && (
                        <>
                          <span className="text-xs text-gray-400 dark:text-gray-600">×</span>
                          <span className="text-xs text-gray-500 dark:text-gray-500 flex-shrink-0">
                            {nextSetInfo.weight} kg
                          </span>
                        </>
                      )}
                    </div>
                  </div>
                </motion.div>
              )}

              {/* 训练总计时 */}
              <motion.div
                className="px-3 py-2 bg-gray-50/50 dark:bg-gray-800/30 rounded-lg"
                initial={{ opacity: 0, y: 5 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.45 }}
              >
                <div className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-1.5">
                    <Zap className="w-3.5 h-3.5 text-gray-400 dark:text-gray-500" />
                    <span className="text-xs text-gray-500 dark:text-gray-400">训练总计时</span>
                  </div>
                  <span className="text-xs font-mono font-medium text-gray-600 dark:text-gray-400">
                    {formatTime(totalWorkoutElapsedTime)}
                  </span>
                </div>
              </motion.div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Bottom Action Buttons */}
      <motion.div
        className="pb-5 pt-3 bg-white/80 dark:bg-gray-800/80 backdrop-blur-xl border-t border-gray-200/50 dark:border-gray-700/50 space-y-2.5 relative z-10 mobile-bottom-bar"
        initial={{ y: 100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ type: "spring", stiffness: 300, damping: 30, delay: 0.2 }}
      >
        <motion.div
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
        >
          <Button
            size="lg"
            onClick={() => setShowCompletionDialog(true)}
            disabled={isResting}
            className="mobile-button-primary bg-gradient-to-r from-green-500 via-emerald-500 to-green-600 hover:from-green-600 hover:via-emerald-600 hover:to-green-700 disabled:opacity-40 disabled:cursor-not-allowed relative overflow-hidden"
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
              animate={{ x: ['-100%', '100%'] }}
              transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
            />
            <span className="relative z-10">动作完成</span>
          </Button>
        </motion.div>
        
        <motion.div
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
        >
          <Button
            size="lg"
            variant="outline"
            onClick={() => setShowQuitDialog(true)}
            className="mobile-button-secondary border-2 border-red-200 dark:border-red-800/50 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20"
          >
            放弃动作
          </Button>
        </motion.div>
      </motion.div>

      {/* Dialogs */}
      <CompletionDialog
        open={showCompletionDialog}
        onClose={() => setShowCompletionDialog(false)}
        onConfirm={handleExerciseComplete}
        defaultReps={currentSetReps}
        defaultWeight={currentSetWeight}
      />

      <QuitDialog
        open={showQuitDialog}
        onClose={() => setShowQuitDialog(false)}
        onConfirm={handleQuitAction}
      />

      <SkipRestDialog
        open={showSkipRestDialog}
        onClose={() => setShowSkipRestDialog(false)}
        onConfirm={handleSkipRest}
        timeLeft={timeLeft}
        isExerciseRest={isExerciseRest}
        nextExerciseName={isExerciseRest && currentExerciseIndex < workoutPlan.exercises.length - 1 ? workoutPlan.exercises[currentExerciseIndex + 1]?.name : undefined}
      />

      <EditSetDialog
        open={showEditSetDialog}
        onClose={() => setShowEditSetDialog(false)}
        onConfirm={handleEditSet}
        currentReps={currentSetReps}
        currentWeight={currentSetWeight}
        exerciseName={currentExercise.name}
      />

      <WorkoutCompleteDialog
        open={showWorkoutCompleteDialog}
        onClose={handleWorkoutComplete}
        totalTime={totalWorkoutTime}
      />
    </div>
  );
}

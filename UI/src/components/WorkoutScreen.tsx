import { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Progress } from './ui/progress';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { ArrowLeft, Timer, Dumbbell, Hash, Weight, Clock, Edit } from 'lucide-react';
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
  const [showCompletionDialog, setShowCompletionDialog] = useState(false);
  const [showQuitDialog, setShowQuitDialog] = useState(false);
  const [showSkipRestDialog, setShowSkipRestDialog] = useState(false);
  const [showEditSetDialog, setShowEditSetDialog] = useState(false);
  const [showWorkoutCompleteDialog, setShowWorkoutCompleteDialog] = useState(false);
  const [exerciseStartTime, setExerciseStartTime] = useState<number>(Date.now());
  const [exerciseElapsedTime, setExerciseElapsedTime] = useState(0);
  const [workoutStartTime] = useState<number>(Date.now());
  const [totalWorkoutTime, setTotalWorkoutTime] = useState('');
  
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
      setExerciseStartTime(Date.now());
    }
    return () => clearInterval(interval);
  }, [timeLeft, isResting]);

  // Exercise timer effect
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (!isResting) {
      interval = setInterval(() => {
        setExerciseElapsedTime(Math.floor((Date.now() - exerciseStartTime) / 1000));
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [exerciseStartTime, isResting]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleExerciseComplete = (completedReps: number, completedWeight: number) => {
    setShowCompletionDialog(false);
    
    if (isLastSet && isLastExercise) {
      const totalTime = Math.floor((Date.now() - workoutStartTime) / 1000);
      const minutes = Math.floor(totalTime / 60);
      const seconds = totalTime % 60;
      setTotalWorkoutTime(`${minutes}:${seconds.toString().padStart(2, '0')}`);
      setShowWorkoutCompleteDialog(true);
    } else if (isLastSet) {
      setCurrentExerciseIndex(prev => prev + 1);
      setCurrentSet(1);
      setExerciseStartTime(Date.now());
      setExerciseElapsedTime(0);
    } else {
      setCurrentSet(prev => prev + 1);
      setTimeLeft(currentExercise.restTime);
      setIsResting(true);
    }
  };

  const handleSkipRest = () => {
    setShowSkipRestDialog(false);
    setIsResting(false);
    setTimeLeft(0);
    setExerciseStartTime(Date.now());
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

  const handleQuitAction = (action: 'all' | 'exercise') => {
    setShowQuitDialog(false);
    
    if (action === 'all') {
      onFinish();
    } else {
      if (isLastExercise) {
        onFinish();
      } else {
        setCurrentExerciseIndex(prev => prev + 1);
        setCurrentSet(1);
        setIsResting(false);
        setTimeLeft(0);
        setExerciseStartTime(Date.now());
        setExerciseElapsedTime(0);
      }
    }
  };

  const progress = ((currentExerciseIndex * currentExercise.sets + currentSet - 1) / 
    (workoutPlan.exercises.reduce((total, ex) => total + ex.sets, 0))) * 100;

  return (
    <div className="h-full flex flex-col bg-gradient-to-br from-orange-50 via-pink-50 to-purple-100 dark:from-gray-900 dark:to-gray-800 relative overflow-hidden">
      {/* Animated background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute w-96 h-96 bg-gradient-to-br from-orange-300/20 to-pink-300/20 rounded-full blur-3xl"
          animate={{
            x: [0, 100, 0],
            y: [0, 50, 0],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: "easeInOut"
          }}
          style={{ top: '10%', right: '-20%' }}
        />
        <motion.div
          className="absolute w-80 h-80 bg-gradient-to-br from-purple-300/20 to-blue-300/20 rounded-full blur-3xl"
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
        className="glass-card dark:glass-card-dark px-4 py-3 shadow-lg border-b-0 rounded-b-3xl relative z-10"
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
              className="hover:bg-white/50 dark:hover:bg-gray-800/50 rounded-xl"
            >
              <ArrowLeft className="w-4 h-4" />
            </Button>
          </motion.div>
          <h2 className="flex-1 text-base bg-gradient-to-r from-orange-600 to-pink-600 bg-clip-text text-transparent">
            {workoutPlan.name}
          </h2>
        </div>
        <div className="relative">
          <Progress value={progress} className="h-2 bg-gray-200/50 dark:bg-gray-700/50" />
          <motion.div
            className="absolute top-0 left-0 h-2 bg-gradient-to-r from-orange-500 to-pink-500 rounded-full"
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
            className="glass-card dark:glass-card-dark text-orange-600 dark:text-orange-400 px-4 py-4 text-center cursor-pointer relative z-10 mx-4 mt-4 rounded-2xl shadow-xl overflow-hidden"
            onClick={() => setShowSkipRestDialog(true)}
            initial={{ opacity: 0, y: -50, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -50, scale: 0.9 }}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-orange-500/10 to-pink-500/10"
              animate={{ opacity: [0.3, 0.6, 0.3] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            <div className="flex items-center justify-center gap-2 relative z-10">
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
              >
                <Timer className="w-5 h-5" />
              </motion.div>
              <span className="font-semibold">休息时间: {formatTime(timeLeft)}</span>
              <span className="text-xs opacity-70">(点击跳过)</span>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Exercise Content - 使用 flex-1 确保占据剩余空间 */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 relative z-10">
        {/* Exercise Image */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          key={currentExerciseIndex}
          transition={{ duration: 0.4 }}
        >
          <Card className="glass-card dark:glass-card-dark border-0 overflow-hidden shadow-xl">
            <div className="aspect-[4/3] h-48 bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800 relative overflow-hidden">
              <ImageWithFallback
                src={currentExercise.image}
                alt={currentExercise.name}
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
            </div>
          </Card>
        </motion.div>

        {/* Exercise Info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <Card className="glass-card dark:glass-card-dark border-0 shadow-xl">
            <CardContent className="p-4 space-y-4">
              <h3 className="text-center bg-gradient-to-r from-orange-600 to-pink-600 bg-clip-text text-transparent">
                {currentExercise.name}
              </h3>
              
              {/* 动作计时器 */}
              {!isResting && (
                <motion.div 
                  className="flex items-center justify-center gap-2 p-3 bg-gradient-to-r from-orange-50/80 to-pink-50/80 dark:from-orange-900/20 dark:to-pink-900/20 rounded-xl backdrop-blur-sm border border-orange-200/50 dark:border-orange-800/50"
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
                  <span className="text-sm text-gray-600 dark:text-gray-400">动作时间：</span>
                  <span className="font-mono font-semibold text-orange-600 dark:text-orange-400">{formatTime(exerciseElapsedTime)}</span>
                </motion.div>
              )}
              
              <div className="grid grid-cols-2 gap-3 text-center">
                <motion.div 
                  className="flex flex-col items-center gap-1 p-3 bg-gradient-to-br from-blue-50/80 to-cyan-50/80 dark:from-blue-900/20 dark:to-cyan-900/20 rounded-xl backdrop-blur-sm border border-blue-200/50 dark:border-blue-800/50"
                  whileHover={{ scale: 1.05 }}
                  transition={{ type: "spring", stiffness: 400, damping: 25 }}
                >
                  <Hash className="w-4 h-4 text-blue-500" />
                  <span className="text-xs text-gray-600 dark:text-gray-400">组数</span>
                  <span className="text-sm font-semibold text-blue-600 dark:text-blue-400">{currentSet} / {currentExercise.sets}</span>
                </motion.div>
                
                <motion.div 
                  className="flex flex-col items-center gap-1 p-3 bg-gradient-to-br from-green-50/80 to-emerald-50/80 dark:from-green-900/20 dark:to-emerald-900/20 rounded-xl cursor-pointer backdrop-blur-sm border border-green-200/50 dark:border-green-800/50"
                  onClick={() => setShowEditSetDialog(true)}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  transition={{ type: "spring", stiffness: 400, damping: 25 }}
                >
                  <div className="flex items-center gap-1">
                    <Dumbbell className="w-4 h-4 text-green-500" />
                    <Edit className="w-3 h-3 text-green-400" />
                  </div>
                  <span className="text-xs text-gray-600 dark:text-gray-400">次数</span>
                  <span className="text-sm font-semibold text-green-600 dark:text-green-400">{currentSetReps}</span>
                </motion.div>
              </div>

              {currentSetWeight > 0 && (
                <motion.div 
                  className="flex items-center justify-center gap-2 p-3 bg-gradient-to-r from-purple-50/80 to-pink-50/80 dark:from-purple-900/20 dark:to-pink-900/20 rounded-xl cursor-pointer backdrop-blur-sm border border-purple-200/50 dark:border-purple-800/50"
                  onClick={() => setShowEditSetDialog(true)}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.2 }}
                >
                  <Weight className="w-4 h-4 text-purple-500" />
                  <Edit className="w-3 h-3 text-purple-400" />
                  <span className="text-sm text-gray-600 dark:text-gray-400">重量：</span>
                  <span className="text-sm font-semibold text-purple-600 dark:text-purple-400">{currentSetWeight} kg</span>
                </motion.div>
              )}
            </CardContent>
          </Card>
        </motion.div>
      </div>

      {/* iOS风格底部按钮区域 - 固定在底部 */}
      <motion.div 
        className="glass-card dark:glass-card-dark border-t-0 rounded-t-3xl p-4 pb-6 space-y-3 relative z-10 shadow-2xl"
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
            className="w-full h-14 bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white border-0 shadow-xl rounded-2xl disabled:opacity-50 disabled:cursor-not-allowed relative overflow-hidden group"
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0"
              animate={{ x: ['-100%', '100%'] }}
              transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
            />
            <span className="relative z-10 font-semibold">动作完成</span>
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
            className="w-full h-12 glass-button border-red-200/50 text-red-600 hover:bg-red-50/50 dark:border-red-800/50 dark:text-red-400 dark:hover:bg-red-900/20 rounded-2xl shadow-lg"
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
        totalExercises={workoutPlan.exercises.length}
      />
    </div>
  );
}

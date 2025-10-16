import { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Activity, FileText, Dumbbell, Clock, Hash, ChevronDown, ChevronUp } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

export type WorkoutExercise = {
  id: string;
  name: string;
  image: string;
  sets: number;
  reps: number;
  weight: number;
  restTime: number;
  exerciseRestTime?: number;
};

export type WorkoutPlan = {
  name: string;
  exercises: WorkoutExercise[];
};

interface MainScreenProps {
  onReadPlan: () => void;
  onStartWorkout: () => void;
  planStatus: 'none' | 'success' | 'error';
  errorCode: string;
  hasWorkoutPlan: boolean;
  workoutPlan: WorkoutPlan | null;
}

export function MainScreen({ 
  onReadPlan, 
  onStartWorkout, 
  planStatus, 
  errorCode, 
  hasWorkoutPlan,
  workoutPlan
}: MainScreenProps) {
  const [showStep, setShowStep] = useState<1 | 2>(1);
  const [isExercisesExpanded, setIsExercisesExpanded] = useState(false);

  const handleReadPlan = () => {
    onReadPlan();
    setShowStep(2);
  };

  return (
    <div className="h-full flex flex-col bg-gradient-to-br from-orange-50 via-pink-50 to-purple-100 dark:from-gray-900 dark:to-gray-800 relative overflow-hidden">
      {/* Animated background blobs */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute w-96 h-96 bg-gradient-to-br from-orange-300/30 to-pink-300/30 rounded-full blur-3xl"
          animate={{
            x: [0, 100, 0],
            y: [0, 80, 0],
            scale: [1, 1.2, 1],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: "easeInOut"
          }}
          style={{ top: '-10%', left: '-10%' }}
        />
        <motion.div
          className="absolute w-80 h-80 bg-gradient-to-br from-purple-300/30 to-blue-300/30 rounded-full blur-3xl"
          animate={{
            x: [0, -80, 0],
            y: [0, 100, 0],
            scale: [1, 1.3, 1],
          }}
          transition={{
            duration: 18,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 2
          }}
          style={{ bottom: '-10%', right: '-10%' }}
        />
      </div>

      {/* Header */}
      <motion.div 
        className="pt-14 pb-6 px-6 relative z-10"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
      >
        <motion.div 
          className="flex items-center justify-center mb-5"
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ 
            type: "spring", 
            stiffness: 260, 
            damping: 20,
            delay: 0.2 
          }}
        >
          <motion.div 
            className="w-24 h-24 bg-gradient-to-br from-orange-500 to-pink-500 rounded-full flex items-center justify-center shadow-xl relative"
            animate={{ 
              rotate: [0, 10, -10, 0],
            }}
            transition={{
              duration: 3,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-orange-400 to-pink-400 rounded-full"
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.5, 0, 0.5]
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            />
            <Activity className="w-12 h-12 text-white relative z-10" />
          </motion.div>
        </motion.div>
        
        <motion.h1 
          className="text-6xl text-center bg-gradient-to-r from-orange-600 via-pink-600 to-purple-600 bg-clip-text text-transparent mb-3 tracking-tight"
          style={{ fontFamily: "'Rounded Mplus 1c', 'Nunito', -apple-system, BlinkMacSystemFont, 'SF Pro Rounded', system-ui, sans-serif", fontWeight: 800 }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
        >
          FIT
        </motion.h1>
        
        <motion.p 
          className="text-center text-base bg-gradient-to-r from-orange-500 via-pink-500 to-purple-500 bg-clip-text text-transparent"
          style={{ fontFamily: "'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif", fontWeight: 600 }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
        >
          今天的燃动开始了
        </motion.p>
      </motion.div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col px-6 pb-8 space-y-4 relative z-10">
        {showStep === 1 ? (
        // 步骤1：只显示读取计划卡片
        <motion.div
          key="step1-only"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7 }}
        >
          <Card className="glass-card dark:glass-card-dark border-0 shadow-2xl overflow-hidden relative">
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-pink-500/10 to-purple-500/10"
              animate={{
                opacity: [0.3, 0.6, 0.3]
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            />
            <CardContent className="p-6 relative z-10">
              <div className="flex items-start gap-3 mb-4">
                <motion.div 
                  className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0"
                  animate={{
                    rotate: [0, 5, -5, 0]
                  }}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  <FileText className="w-5 h-5 text-white" />
                </motion.div>
                <div className="flex-1">
                  <h3 className="mb-1 bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent">
                    读取健身计划
                  </h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    {hasWorkoutPlan ? '计划已准备就绪' : '请先读取您的健身计划'}
                  </p>
                </div>
              </div>
              
              <motion.div
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <Button
                  size="lg"
                  onClick={handleReadPlan}
                  className="w-full h-14 bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 text-white border-0 shadow-xl rounded-2xl relative overflow-hidden group"
                >
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                    animate={{
                      x: ['-100%', '100%']
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "linear"
                    }}
                  />
                  <span className="relative z-10 flex items-center justify-center gap-2">
                    <FileText className="w-5 h-5" />
                    {hasWorkoutPlan ? '重新获取' : '读取健身计划'}
                  </span>
                </Button>
              </motion.div>
            </CardContent>
          </Card>
        </motion.div>
        ) : (
        // 步骤2：显示开始健身卡片和读取计划卡片（在下方）
        <>
          {/* 步骤2：开始健身 */}
          <motion.div
            key="step2-workout"
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, ease: "easeOut" }}
          >
            <Card className="glass-card dark:glass-card-dark border-0 shadow-2xl overflow-hidden relative">
              <motion.div
                className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-pink-500/10 to-purple-500/10"
                animate={{
                  opacity: [0.3, 0.6, 0.3]
                }}
                transition={{
                  duration: 3,
                  repeat: Infinity,
                  ease: "easeInOut"
                }}
              />
              <CardContent className="p-6 relative z-10">
                <div className="flex items-start gap-3 mb-4">
                  <motion.div 
                    className="w-10 h-10 bg-gradient-to-br from-orange-500 to-pink-500 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0"
                    animate={{
                      rotate: [0, 5, -5, 0]
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "easeInOut"
                    }}
                  >
                    <Activity className="w-5 h-5 text-white" />
                  </motion.div>
                  <div className="flex-1">
                    <h3 className="mb-1 bg-gradient-to-r from-orange-600 to-pink-600 bg-clip-text text-transparent">
                      开始健身
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      准备开始您的训练
                    </p>
                  </div>
                </div>

                <motion.div
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <Button
                    size="lg"
                    onClick={onStartWorkout}
                    className="w-full h-14 bg-gradient-to-r from-orange-500 via-pink-500 to-purple-600 hover:from-orange-600 hover:via-pink-600 hover:to-purple-700 text-white border-0 shadow-xl rounded-2xl relative overflow-hidden group"
                  >
                    <motion.div
                      className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                      animate={{
                        x: ['-100%', '100%']
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "linear"
                      }}
                    />
                    <span className="relative z-10 flex items-center justify-center gap-2">
                      <Activity className="w-5 h-5" />
                      开始健身
                    </span>
                  </Button>
                </motion.div>
              </CardContent>
            </Card>
          </motion.div>

          {/* 训练计划摘要 */}
          {workoutPlan && (
            <motion.div
              key="plan-summary"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1, ease: "easeOut" }}
            >
              <Card className="glass-card dark:glass-card-dark border-0 shadow-2xl overflow-hidden relative">
                <motion.div
                  className="absolute inset-0 bg-gradient-to-br from-green-500/10 via-emerald-500/10 to-teal-500/10"
                  animate={{
                    opacity: [0.3, 0.6, 0.3]
                  }}
                  transition={{
                    duration: 3,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                />
                <CardContent className="p-6 relative z-10">
                  <div className="flex items-start gap-3 mb-4">
                    <motion.div 
                      className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0"
                      animate={{
                        rotate: [0, 5, -5, 0]
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "easeInOut"
                      }}
                    >
                      <Dumbbell className="w-5 h-5 text-white" />
                    </motion.div>
                    <div className="flex-1">
                      <h3 className="mb-1 bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                        训练计划
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        A组卧推深蹲-线性进阶
                      </p>
                    </div>
                  </div>

                  {/* 统计信息 */}
                  <div className="grid grid-cols-3 gap-3 mb-4">
                    <div className="bg-white/50 dark:bg-gray-800/50 rounded-xl p-3 text-center">
                      <div className="flex items-center justify-center gap-1 mb-1">
                        <Hash className="w-4 h-4 text-green-600" />
                      </div>
                      <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">动作数量</p>
                      <p className="bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">{workoutPlan.exercises.length}</p>
                    </div>
                    <div className="bg-white/50 dark:bg-gray-800/50 rounded-xl p-3 text-center">
                      <div className="flex items-center justify-center gap-1 mb-1">
                        <Dumbbell className="w-4 h-4 text-green-600" />
                      </div>
                      <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">总组数</p>
                      <p className="bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                        {workoutPlan.exercises.reduce((sum, ex) => sum + ex.sets, 0)}
                      </p>
                    </div>
                    <div className="bg-white/50 dark:bg-gray-800/50 rounded-xl p-3 text-center">
                      <div className="flex items-center justify-center gap-1 mb-1">
                        <Clock className="w-4 h-4 text-green-600" />
                      </div>
                      <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">预估时长</p>
                      <p className="bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                        {Math.ceil(
                          workoutPlan.exercises.reduce((total, ex) => {
                            const setTime = 30; // 每组训练30秒
                            const restTime = (ex.sets - 1) * ex.restTime;
                            const exerciseRest = ex.exerciseRestTime || 30;
                            return total + (ex.sets * setTime) + restTime + exerciseRest;
                          }, 0) / 60
                        )}分钟
                      </p>
                    </div>
                  </div>

                  {/* 训练动作列表 */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between mb-2">
                      <p className="text-xs text-gray-500 dark:text-gray-400">训练动作</p>
                      <button
                        onClick={() => setIsExercisesExpanded(!isExercisesExpanded)}
                        className="flex items-center gap-1 text-xs text-green-600 dark:text-green-400 hover:text-green-700 dark:hover:text-green-300 transition-colors"
                      >
                        <span>{isExercisesExpanded ? '收起' : '展开'}</span>
                        {isExercisesExpanded ? (
                          <ChevronUp className="w-3.5 h-3.5" />
                        ) : (
                          <ChevronDown className="w-3.5 h-3.5" />
                        )}
                      </button>
                    </div>
                    <AnimatePresence>
                      {isExercisesExpanded && (
                        <motion.div
                          initial={{ height: 0, opacity: 0 }}
                          animate={{ height: 'auto', opacity: 1 }}
                          exit={{ height: 0, opacity: 0 }}
                          transition={{ duration: 0.3, ease: 'easeInOut' }}
                          className="overflow-hidden"
                        >
                          <div className="space-y-2">
                            {workoutPlan.exercises.map((exercise, index) => (
                              <div 
                                key={exercise.id}
                                className="flex items-center gap-2 bg-white/50 dark:bg-gray-800/50 rounded-lg p-2"
                              >
                                <div className="w-6 h-6 bg-gradient-to-br from-green-500 to-emerald-500 rounded-md flex items-center justify-center flex-shrink-0">
                                  <span className="text-xs text-white">{index + 1}</span>
                                </div>
                                <div className="flex-1 min-w-0">
                                  <p className="text-sm text-gray-800 dark:text-gray-200 truncate">{exercise.name}</p>
                                </div>
                                <div className="text-xs text-gray-500 dark:text-gray-400 flex-shrink-0">
                                  {exercise.sets}组×{exercise.reps}次
                                </div>
                              </div>
                            ))}
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          )}

          {/* 步骤1：读取计划（在下方） */}
          <motion.div
            key="step1-below"
            initial={{ y: -280 }}
            animate={{ y: 0 }}
            transition={{ duration: 0.5, ease: "easeOut" }}
          >
            <Card className="glass-card dark:glass-card-dark border-0 shadow-2xl overflow-hidden relative">
              <motion.div
                className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-pink-500/10 to-purple-500/10"
                animate={{
                  opacity: [0.3, 0.6, 0.3]
                }}
                transition={{
                  duration: 3,
                  repeat: Infinity,
                  ease: "easeInOut"
                }}
              />
              <CardContent className="p-6 relative z-10">
                <div className="flex items-start gap-3 mb-4">
                  <motion.div 
                    className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0"
                    animate={{
                      rotate: [0, 5, -5, 0]
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "easeInOut"
                    }}
                  >
                    <FileText className="w-5 h-5 text-white" />
                  </motion.div>
                  <div className="flex-1">
                    <h3 className="mb-1 bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent">
                      读取健身计划
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      计划已准备就绪
                    </p>
                  </div>
                </div>
                
                <motion.div
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <Button
                    size="lg"
                    onClick={handleReadPlan}
                    className="w-full h-14 bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 text-white border-0 shadow-xl rounded-2xl relative overflow-hidden group"
                  >
                    <motion.div
                      className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                      animate={{
                        x: ['-100%', '100%']
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "linear"
                      }}
                    />
                    <span className="relative z-10 flex items-center justify-center gap-2">
                      <FileText className="w-5 h-5" />
                      {hasWorkoutPlan ? '重新获取' : '读取健身计划'}
                    </span>
                  </Button>
                </motion.div>
              </CardContent>
            </Card>
          </motion.div>
        </>
        )}
      </div>
    </div>
  );
}

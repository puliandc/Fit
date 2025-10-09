import { useState } from 'react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Activity, FileText, CheckCircle, XCircle, Sparkles, Zap } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface MainScreenProps {
  onReadPlan: () => void;
  onStartWorkout: () => void;
  planStatus: 'none' | 'success' | 'error';
  errorCode: string;
  hasWorkoutPlan: boolean;
}

export function MainScreen({ 
  onReadPlan, 
  onStartWorkout, 
  planStatus, 
  errorCode, 
  hasWorkoutPlan 
}: MainScreenProps) {
  const [isReading, setIsReading] = useState(false);

  const handleReadPlan = async () => {
    setIsReading(true);
    await onReadPlan();
    setIsReading(false);
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
        className="pt-12 pb-6 px-6 relative z-10"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
      >
        <motion.div 
          className="flex items-center justify-center mb-4"
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
            className="w-16 h-16 bg-gradient-to-br from-orange-500 to-pink-500 rounded-full flex items-center justify-center shadow-xl relative"
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
            <Activity className="w-8 h-8 text-white relative z-10" />
          </motion.div>
        </motion.div>
        
        <motion.h1 
          className="text-center bg-gradient-to-r from-orange-600 via-pink-600 to-purple-600 bg-clip-text text-transparent mb-2"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
        >
          健身助手
        </motion.h1>
        
        <motion.p 
          className="text-center text-gray-600 dark:text-gray-300 text-sm"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
        >
          开始您的健身之旅
        </motion.p>
      </motion.div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col px-6 pb-8 space-y-4 relative z-10">
        {/* Step indicator */}
        <motion.div 
          className="flex items-center justify-center gap-2 mb-2"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
        >
          <motion.div 
            className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-semibold ${
              hasWorkoutPlan 
                ? 'bg-gradient-to-br from-green-400 to-emerald-500 text-white shadow-lg' 
                : 'bg-gradient-to-br from-orange-400 to-pink-500 text-white shadow-lg'
            }`}
            animate={!hasWorkoutPlan ? {
              scale: [1, 1.1, 1],
              boxShadow: [
                '0 4px 6px rgba(0,0,0,0.1)',
                '0 10px 20px rgba(251,146,60,0.4)',
                '0 4px 6px rgba(0,0,0,0.1)'
              ]
            } : {}}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          >
            1
          </motion.div>
          <motion.div 
            className="h-1 w-12 rounded-full bg-gradient-to-r from-orange-300 to-pink-300 dark:from-orange-700 dark:to-pink-700"
            initial={{ scaleX: 0 }}
            animate={{ scaleX: hasWorkoutPlan ? 1 : 0.5 }}
            transition={{ duration: 0.5 }}
          />
          <motion.div 
            className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-semibold ${
              hasWorkoutPlan 
                ? 'bg-gradient-to-br from-orange-400 to-pink-500 text-white shadow-lg' 
                : 'bg-gray-200 dark:bg-gray-700 text-gray-400 dark:text-gray-500'
            }`}
            animate={hasWorkoutPlan ? {
              scale: [1, 1.1, 1],
              boxShadow: [
                '0 4px 6px rgba(0,0,0,0.1)',
                '0 10px 20px rgba(251,146,60,0.4)',
                '0 4px 6px rgba(0,0,0,0.1)'
              ]
            } : {}}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          >
            2
          </motion.div>
        </motion.div>

        {/* Read Plan Section - 更突出 */}
        <motion.div
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
                    步骤 1：读取健身计划
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
                  disabled={isReading || hasWorkoutPlan}
                  className="w-full h-14 bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 text-white border-0 shadow-xl rounded-2xl disabled:opacity-50 disabled:cursor-not-allowed relative overflow-hidden group"
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
                    {isReading ? (
                      <>
                        <motion.div
                          animate={{ rotate: 360 }}
                          transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                        >
                          <Sparkles className="w-5 h-5" />
                        </motion.div>
                        读取中...
                      </>
                    ) : hasWorkoutPlan ? (
                      <>
                        <CheckCircle className="w-5 h-5" />
                        已读取成功
                      </>
                    ) : (
                      <>
                        <FileText className="w-5 h-5" />
                        读取健身计划
                      </>
                    )}
                  </span>
                </Button>
              </motion.div>
              
              {/* Status Display */}
              <AnimatePresence mode="wait">
                {planStatus === 'success' && (
                  <motion.div 
                    className="flex items-center gap-2 text-green-600 dark:text-green-400 bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 p-3 rounded-xl mt-3 backdrop-blur-sm border border-green-200/50 dark:border-green-800/50"
                    initial={{ opacity: 0, y: -10, scale: 0.95 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={{ opacity: 0, y: -10, scale: 0.95 }}
                    transition={{ type: "spring", stiffness: 500, damping: 30 }}
                  >
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ type: "spring", stiffness: 500, damping: 25, delay: 0.1 }}
                    >
                      <CheckCircle className="w-5 h-5" />
                    </motion.div>
                    <span>读取成功</span>
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                    >
                      <Sparkles className="w-4 h-4 ml-auto" />
                    </motion.div>
                  </motion.div>
                )}
                
                {planStatus === 'error' && (
                  <motion.div 
                    className="flex items-center gap-2 text-red-600 dark:text-red-400 bg-gradient-to-r from-red-50 to-orange-50 dark:from-red-900/20 dark:to-orange-900/20 p-3 rounded-xl mt-3 backdrop-blur-sm border border-red-200/50 dark:border-red-800/50"
                    initial={{ opacity: 0, y: -10, scale: 0.95 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={{ opacity: 0, y: -10, scale: 0.95 }}
                  >
                    <XCircle className="w-5 h-5" />
                    <span>读取失败：{errorCode}</span>
                  </motion.div>
                )}
              </AnimatePresence>
            </CardContent>
          </Card>
        </motion.div>

        {/* Divider with animation */}
        <motion.div 
          className="flex items-center gap-3 py-2"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8 }}
        >
          <motion.div 
            className="flex-1 h-0.5 bg-gradient-to-r from-transparent via-gray-300 to-transparent dark:via-gray-600"
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ duration: 0.6, delay: 0.8 }}
          />
        </motion.div>

        {/* Start Workout Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9 }}
        >
          <Card className="glass-card dark:glass-card-dark border-0 shadow-2xl overflow-hidden relative">
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-pink-500/10 to-purple-500/10"
              animate={{
                opacity: hasWorkoutPlan ? [0.3, 0.6, 0.3] : 0.2
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
                  className={`w-10 h-10 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0 ${
                    hasWorkoutPlan 
                      ? 'bg-gradient-to-br from-orange-500 to-pink-500' 
                      : 'bg-gray-300 dark:bg-gray-700'
                  }`}
                  animate={hasWorkoutPlan ? {
                    rotate: [0, 5, -5, 0]
                  } : {}}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  <Activity className={`w-5 h-5 ${hasWorkoutPlan ? 'text-white' : 'text-gray-500'}`} />
                </motion.div>
                <div className="flex-1">
                  <h3 className={hasWorkoutPlan 
                    ? "mb-1 bg-gradient-to-r from-orange-600 to-pink-600 bg-clip-text text-transparent" 
                    : "mb-1 text-gray-400 dark:text-gray-500"
                  }>
                    步骤 2：开始健身
                  </h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    {hasWorkoutPlan ? '准备开始您的训练' : '请先完成步骤 1'}
                  </p>
                </div>
              </div>

              <motion.div
                whileHover={hasWorkoutPlan ? { scale: 1.02 } : {}}
                whileTap={hasWorkoutPlan ? { scale: 0.98 } : {}}
              >
                <Button
                  size="lg"
                  onClick={onStartWorkout}
                  disabled={!hasWorkoutPlan}
                  className="w-full h-16 bg-gradient-to-r from-orange-500 via-pink-500 to-purple-600 hover:from-orange-600 hover:via-pink-600 hover:to-purple-700 text-white border-0 shadow-xl rounded-2xl disabled:opacity-40 disabled:cursor-not-allowed relative overflow-hidden group"
                >
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                    animate={hasWorkoutPlan ? {
                      x: ['-100%', '100%']
                    } : {}}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "linear"
                    }}
                  />
                  <div className="flex flex-col items-center gap-1 relative z-10">
                    <div className="flex items-center gap-2">
                      <Activity className="w-6 h-6" />
                      <Zap className="w-5 h-5" />
                    </div>
                    <span className="font-semibold">开始健身</span>
                  </div>
                </Button>
              </motion.div>

              {!hasWorkoutPlan && (
                <motion.p 
                  className="text-center text-gray-500 dark:text-gray-400 mt-3 text-sm"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 1 }}
                >
                  请先读取健身计划后再开始训练
                </motion.p>
              )}
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}

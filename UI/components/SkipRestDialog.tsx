import { Button } from './ui/button';
import { DialogOverlay, DialogPortal, DialogTitle, DialogDescription } from './ui/dialog';
import { Timer, ArrowRight } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import * as DialogPrimitive from '@radix-ui/react-dialog@1.1.6';
import * as VisuallyHidden from '@radix-ui/react-visually-hidden@1.1.0';

interface SkipRestDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  timeLeft: number;
  isExerciseRest?: boolean;
  nextExerciseName?: string;
}

export function SkipRestDialog({ 
  open, 
  onClose, 
  onConfirm, 
  timeLeft, 
  isExerciseRest = false, 
  nextExerciseName 
}: SkipRestDialogProps) {
  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <DialogPrimitive.Root open={open} onOpenChange={onClose}>
      <DialogPortal>
        <DialogOverlay />
        <DialogPrimitive.Content
          className="fixed top-[50%] left-[50%] z-50 w-full max-w-[361px] -translate-x-[50%] -translate-y-[50%] p-0 outline-none"
        >
          <AnimatePresence>
            {open && (
              <motion.div
                initial={{ opacity: 0, scale: 0.95, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: 20 }}
                transition={{ 
                  type: "spring", 
                  stiffness: 400, 
                  damping: 30,
                  mass: 0.8
                }}
                className="glass-card dark:glass-card-dark border-0 shadow-2xl rounded-3xl overflow-hidden relative"
              >
                {/* 背景渐变动画 */}
                <motion.div
                  className={`absolute inset-0 ${
                    isExerciseRest 
                      ? 'bg-gradient-to-br from-purple-500/10 via-blue-500/10 to-indigo-500/10'
                      : 'bg-gradient-to-br from-blue-500/10 via-cyan-500/10 to-teal-500/10'
                  }`}
                  animate={{
                    opacity: [0.3, 0.6, 0.3]
                  }}
                  transition={{
                    duration: 3,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                />

                <div className="p-6 relative z-10">
                  {/* Accessible Title and Description (visually hidden) */}
                  <VisuallyHidden.Root>
                    <DialogTitle>
                      {isExerciseRest ? '跳过动作间休息' : '跳过组间休息'}
                    </DialogTitle>
                    <DialogDescription>
                      还剩 {formatTime(timeLeft)} {isExerciseRest ? '动作间' : '组间'}休息时间，确定要跳过吗？
                    </DialogDescription>
                  </VisuallyHidden.Root>

                  {/* Header */}
                  <div className="flex items-start gap-3 mb-6">
                    <motion.div 
                      className={`w-10 h-10 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0 ${
                        isExerciseRest 
                          ? 'bg-gradient-to-br from-purple-500 to-blue-600' 
                          : 'bg-gradient-to-br from-blue-500 to-cyan-600'
                      }`}
                      initial={{ scale: 0, rotate: -180 }}
                      animate={{ 
                        scale: 1, 
                        rotate: 0,
                      }}
                      transition={{ 
                        type: "spring", 
                        stiffness: 500, 
                        damping: 25,
                        delay: 0.1
                      }}
                    >
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                      >
                        <Timer className="w-5 h-5 text-white" />
                      </motion.div>
                    </motion.div>
                    <motion.div 
                      className="flex-1"
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.15 }}
                    >
                      <h3 className={`mb-1 bg-clip-text text-transparent ${
                        isExerciseRest 
                          ? 'bg-gradient-to-r from-purple-600 to-blue-600' 
                          : 'bg-gradient-to-r from-blue-600 to-cyan-600'
                      }`}>
                        {isExerciseRest ? '跳过动作间休息' : '跳过组间休息'}
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        还剩 {formatTime(timeLeft)} {isExerciseRest ? '动作间' : '组间'}休息时间
                      </p>
                    </motion.div>
                  </div>

                  {/* 倒计时显示 */}
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                    className={`p-6 rounded-2xl border-2 text-center mb-4 ${
                      isExerciseRest 
                        ? 'bg-gradient-to-br from-purple-500/10 to-blue-500/10 border-purple-200/50 dark:border-purple-800/50' 
                        : 'bg-gradient-to-br from-blue-500/10 to-cyan-500/10 border-blue-200/50 dark:border-blue-800/50'
                    }`}
                  >
                    <motion.div
                      className={`font-mono text-5xl font-bold bg-clip-text text-transparent ${
                        isExerciseRest 
                          ? 'bg-gradient-to-r from-purple-600 to-blue-600' 
                          : 'bg-gradient-to-r from-blue-600 to-cyan-600'
                      }`}
                      animate={{ scale: [1, 1.05, 1] }}
                      transition={{ duration: 1, repeat: Infinity }}
                    >
                      {formatTime(timeLeft)}
                    </motion.div>
                    <motion.p 
                      className="text-sm text-gray-600 dark:text-gray-400 mt-2"
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: 0.3 }}
                    >
                      剩余{isExerciseRest ? '动作间' : '组间'}休息时间
                    </motion.p>
                  </motion.div>

                  {/* 下一个动作提示 */}
                  {isExerciseRest && nextExerciseName && (
                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.25 }}
                      className="mb-4 p-4 bg-purple-50/80 dark:bg-purple-900/20 rounded-xl border border-purple-200/50 dark:border-purple-800/50"
                    >
                      <div className="flex items-center justify-center gap-2">
                        <span className="text-sm text-gray-600 dark:text-gray-400">下一个动作</span>
                        <ArrowRight className="w-4 h-4 text-purple-500" />
                        <span className="text-sm font-semibold text-purple-700 dark:text-purple-300">
                          {nextExerciseName}
                        </span>
                      </div>
                    </motion.div>
                  )}

                  {/* Buttons */}
                  <motion.div 
                    className="flex gap-3"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.3 }}
                  >
                    <motion.div 
                      className="flex-1"
                      whileHover={{ scale: 1.02, y: -2 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    >
                      <Button 
                        onClick={onClose} 
                        className="w-full h-14 glass-button border-gray-200/50 dark:border-gray-700/50 hover:bg-white/80 dark:hover:bg-gray-800/80 rounded-xl shadow-sm transition-all duration-200"
                        variant="outline"
                      >
                        继续休息
                      </Button>
                    </motion.div>
                    <motion.div 
                      className="flex-1"
                      whileHover={{ scale: 1.02, y: -2 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    >
                      <Button 
                        onClick={onConfirm} 
                        className={`w-full h-14 text-white border-0 shadow-xl rounded-xl relative overflow-hidden group transition-all duration-200 ${
                          isExerciseRest 
                            ? 'bg-gradient-to-r from-purple-500 to-blue-600 hover:from-purple-600 hover:to-blue-700' 
                            : 'bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700'
                        }`}
                      >
                        <motion.div
                          className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                          animate={{ x: ['-100%', '100%'] }}
                          transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                        />
                        <span className="relative z-10">立即跳过</span>
                      </Button>
                    </motion.div>
                  </motion.div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </DialogPrimitive.Content>
      </DialogPortal>
    </DialogPrimitive.Root>
  );
}

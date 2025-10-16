import { Button } from './ui/button';
import { DialogOverlay, DialogPortal, DialogTitle, DialogDescription } from './ui/dialog';
import { Trophy, Star, CheckCircle, Zap, Timer } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import * as DialogPrimitive from '@radix-ui/react-dialog@1.1.6';
import * as VisuallyHidden from '@radix-ui/react-visually-hidden@1.1.0';

interface WorkoutCompleteDialogProps {
  open: boolean;
  onClose: () => void;
  totalTime: string;
  totalExercises: number;
}

export function WorkoutCompleteDialog({ open, onClose, totalTime, totalExercises }: WorkoutCompleteDialogProps) {
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
                  className="absolute inset-0 bg-gradient-to-br from-yellow-500/10 via-orange-500/10 to-amber-500/10"
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
                    <DialogTitle>训练完成</DialogTitle>
                    <DialogDescription>
                      恭喜你完成了今天的训练！总共完成了{totalExercises}个动作，用时{totalTime}。
                    </DialogDescription>
                  </VisuallyHidden.Root>

                  {/* 背景装饰星星 */}
                  <motion.div 
                    className="absolute top-8 left-8"
                    initial={{ scale: 0, rotate: 0 }}
                    animate={{ 
                      scale: [0, 1, 0.8, 1],
                      rotate: [0, 180, 360],
                    }}
                    transition={{
                      duration: 0.8,
                      delay: 0.3,
                      repeat: Infinity,
                      repeatDelay: 2
                    }}
                  >
                    <Star className="w-4 h-4 text-yellow-400 fill-yellow-400" />
                  </motion.div>
                  
                  <motion.div 
                    className="absolute top-12 right-10"
                    initial={{ scale: 0, rotate: 0 }}
                    animate={{ 
                      scale: [0, 1, 0.8, 1],
                      rotate: [0, 180, 360],
                    }}
                    transition={{
                      duration: 0.8,
                      delay: 0.8,
                      repeat: Infinity,
                      repeatDelay: 2
                    }}
                  >
                    <Star className="w-3 h-3 text-yellow-400 fill-yellow-400" />
                  </motion.div>
                  
                  <motion.div 
                    className="absolute bottom-20 left-10"
                    initial={{ scale: 0 }}
                    animate={{ 
                      scale: [0, 1, 1.1, 1],
                      rotate: [0, 15, -15, 0]
                    }}
                    transition={{
                      duration: 1,
                      delay: 1.3,
                      repeat: Infinity,
                      repeatDelay: 2
                    }}
                  >
                    <Star className="w-3 h-3 text-orange-400 fill-orange-400" />
                  </motion.div>

                  {/* Header with Trophy Icon */}
                  <div className="flex items-start gap-3 mb-6">
                    <motion.div 
                      className="w-10 h-10 bg-gradient-to-br from-yellow-500 to-orange-600 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0"
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
                        animate={{ 
                          scale: [1, 1.2, 1],
                        }}
                        transition={{
                          duration: 2,
                          repeat: Infinity,
                          ease: "easeInOut"
                        }}
                      >
                        <Trophy className="w-5 h-5 text-white" />
                      </motion.div>
                    </motion.div>
                    <motion.div 
                      className="flex-1"
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.15 }}
                    >
                      <h3 className="mb-1 bg-gradient-to-r from-yellow-600 to-orange-600 bg-clip-text text-transparent">
                        训练完成！
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        恭喜你完成了今天的训练
                      </p>
                    </motion.div>
                  </div>

                  {/* 庆祝和鼓励区域 */}
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                    className="mb-6"
                  >
                    {/* 大奖杯图标 */}
                    <div className="flex justify-center mb-4">
                      <motion.div
                        className="relative"
                        initial={{ scale: 0, y: 50 }}
                        animate={{ scale: 1, y: 0 }}
                        transition={{ 
                          type: "spring", 
                          stiffness: 300, 
                          damping: 20,
                          delay: 0.25
                        }}
                      >
                        {/* 外圈光晕 */}
                        <motion.div
                          className="absolute inset-0 bg-gradient-to-br from-yellow-400 to-orange-500 rounded-full blur-2xl"
                          animate={{
                            scale: [1, 1.2, 1],
                            opacity: [0.3, 0.5, 0.3]
                          }}
                          transition={{
                            duration: 2,
                            repeat: Infinity,
                            ease: "easeInOut"
                          }}
                        />
                        {/* 主图标 */}
                        <motion.div
                          className="relative w-24 h-24 bg-gradient-to-br from-yellow-500 to-orange-600 rounded-full flex items-center justify-center shadow-2xl"
                          animate={{
                            rotate: [0, 5, -5, 0]
                          }}
                          transition={{
                            duration: 3,
                            repeat: Infinity,
                            ease: "easeInOut"
                          }}
                        >
                          <Trophy className="w-12 h-12 text-white" strokeWidth={2} />
                        </motion.div>
                      </motion.div>
                    </div>

                    {/* 鼓励文字 */}
                    <motion.div
                      className="p-4 bg-gradient-to-br from-yellow-50/80 to-orange-50/80 dark:from-yellow-900/20 dark:to-orange-900/20 rounded-2xl border-2 border-yellow-200/50 dark:border-yellow-800/50 text-center mb-4"
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.3 }}
                    >
                      <motion.div 
                        className="flex items-center justify-center gap-2 mb-2"
                        animate={{ scale: [1, 1.05, 1] }}
                        transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                      >
                        <Star className="w-4 h-4 text-yellow-600 dark:text-yellow-400 fill-yellow-600 dark:fill-yellow-400" />
                        <span className="text-sm text-yellow-700 dark:text-yellow-300">
                          完美表现
                        </span>
                        <Star className="w-4 h-4 text-yellow-600 dark:text-yellow-400 fill-yellow-600 dark:fill-yellow-400" />
                      </motion.div>
                      <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
                        你的努力没有白费<br />
                        每一滴汗水都值得骄傲
                      </p>
                    </motion.div>

                    {/* 训练统计 */}
                    <motion.div 
                      className="grid grid-cols-2 gap-3"
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: 0.35 }}
                    >
                      <motion.div 
                        className="p-4 bg-gradient-to-br from-green-50/80 to-emerald-50/80 dark:from-green-900/20 dark:to-emerald-900/20 rounded-2xl border-2 border-green-200/50 dark:border-green-800/50 text-center"
                        whileHover={{ scale: 1.05, y: -2 }}
                        transition={{ type: "spring", stiffness: 400, damping: 25 }}
                      >
                        <CheckCircle className="w-6 h-6 text-green-600 dark:text-green-400 mx-auto mb-2" />
                        <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">完成动作</p>
                        <p className="text-xl bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                          {totalExercises}个
                        </p>
                      </motion.div>
                      
                      <motion.div 
                        className="p-4 bg-gradient-to-br from-blue-50/80 to-cyan-50/80 dark:from-blue-900/20 dark:to-cyan-900/20 rounded-2xl border-2 border-blue-200/50 dark:border-blue-800/50 text-center"
                        whileHover={{ scale: 1.05, y: -2 }}
                        transition={{ type: "spring", stiffness: 400, damping: 25 }}
                      >
                        <motion.div
                          animate={{ rotate: 360 }}
                          transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                        >
                          <Timer className="w-6 h-6 text-blue-600 dark:text-blue-400 mx-auto mb-2" />
                        </motion.div>
                        <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">用时</p>
                        <p className="text-xl bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent">
                          {totalTime}
                        </p>
                      </motion.div>
                    </motion.div>
                  </motion.div>

                  {/* 确认按钮 */}
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.4 }}
                  >
                    <motion.div
                      whileHover={{ scale: 1.02, y: -2 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    >
                      <Button 
                        onClick={onClose} 
                        className="w-full h-14 bg-gradient-to-r from-yellow-500 to-orange-600 hover:from-yellow-600 hover:to-orange-700 text-white border-0 shadow-xl rounded-xl relative overflow-hidden group transition-all duration-200"
                      >
                        <motion.div
                          className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                          animate={{ x: ['-100%', '100%'] }}
                          transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                        />
                        <span className="relative z-10">太棒了！</span>
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

import { Button } from './ui/button';
import { DialogOverlay, DialogPortal, DialogTitle, DialogDescription } from './ui/dialog';
import { AlertTriangle, Heart, TrendingUp } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import * as DialogPrimitive from '@radix-ui/react-dialog@1.1.6';
import * as VisuallyHidden from '@radix-ui/react-visually-hidden@1.1.0';

interface QuitDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: (action: 'all' | 'exercise') => void;
}

export function QuitDialog({ open, onClose, onConfirm }: QuitDialogProps) {
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
                  className="absolute inset-0 bg-gradient-to-br from-red-500/10 via-orange-500/10 to-amber-500/10"
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
                    <DialogTitle>确认放弃</DialogTitle>
                    <DialogDescription>坚持下去，每一次努力都是成长的积累</DialogDescription>
                  </VisuallyHidden.Root>

                  {/* Header */}
                  <div className="flex items-start gap-3 mb-6">
                    <motion.div 
                      className="w-10 h-10 bg-gradient-to-br from-red-500 to-orange-600 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0"
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
                        <AlertTriangle className="w-5 h-5 text-white" />
                      </motion.div>
                    </motion.div>
                    <motion.div 
                      className="flex-1"
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.15 }}
                    >
                      <h3 className="mb-1 bg-gradient-to-r from-red-600 to-orange-600 bg-clip-text text-transparent">
                        确认放弃
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        请选择您想要执行的操作
                      </p>
                    </motion.div>
                  </div>

                  {/* 鼓励话语区域 */}
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                    className="mb-6"
                  >
                    {/* 大图标展示 */}
                    <div className="flex justify-center mb-4">
                      <motion.div
                        className="relative"
                        initial={{ scale: 0, rotate: -180 }}
                        animate={{ scale: 1, rotate: 0 }}
                        transition={{ 
                          type: "spring", 
                          stiffness: 300, 
                          damping: 20,
                          delay: 0.25
                        }}
                      >
                        {/* 外圈光晕 */}
                        <motion.div
                          className="absolute inset-0 bg-gradient-to-br from-orange-400 to-red-500 rounded-full blur-2xl"
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
                          className="relative w-24 h-24 bg-gradient-to-br from-orange-500 to-red-600 rounded-full flex items-center justify-center shadow-2xl"
                          animate={{
                            rotate: [0, 5, -5, 0]
                          }}
                          transition={{
                            duration: 3,
                            repeat: Infinity,
                            ease: "easeInOut"
                          }}
                        >
                          <motion.div
                            animate={{
                              scale: [1, 1.1, 1]
                            }}
                            transition={{
                              duration: 2,
                              repeat: Infinity,
                              ease: "easeInOut"
                            }}
                          >
                            <TrendingUp className="w-12 h-12 text-white" strokeWidth={2.5} />
                          </motion.div>
                        </motion.div>
                      </motion.div>
                    </div>

                    {/* 鼓励文字 */}
                    <motion.div
                      className="p-4 bg-gradient-to-br from-orange-50/80 to-red-50/80 dark:from-orange-900/20 dark:to-red-900/20 rounded-2xl border-2 border-orange-200/50 dark:border-orange-800/50 text-center"
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.3 }}
                    >
                      <motion.div 
                        className="flex items-center justify-center gap-2 mb-2"
                        animate={{ scale: [1, 1.05, 1] }}
                        transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                      >
                        <Heart className="w-4 h-4 text-orange-600 dark:text-orange-400 fill-orange-600 dark:fill-orange-400" />
                        <span className="text-sm text-orange-700 dark:text-orange-300">
                          坚持就是胜利
                        </span>
                        <Heart className="w-4 h-4 text-orange-600 dark:text-orange-400 fill-orange-600 dark:fill-orange-400" />
                      </motion.div>
                      <p className="text-xs text-gray-600 dark:text-gray-400 leading-relaxed">
                        每一次努力都是成长的积累<br />
                        不要轻易放弃这个动作
                      </p>
                    </motion.div>
                  </motion.div>

                  {/* Action Buttons */}
                  <motion.div 
                    className="space-y-3 mb-4"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                  >
                    {/* 放弃该动作 - 最高权重 */}
                    <motion.div
                      whileHover={{ scale: 1.02, y: -2 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    >
                      <Button
                        onClick={() => onConfirm('exercise')}
                        className="w-full h-14 bg-gradient-to-r from-red-500 to-orange-600 hover:from-red-600 hover:to-orange-700 text-white border-0 shadow-xl rounded-xl relative overflow-hidden group transition-all duration-200"
                      >
                        <motion.div
                          className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                          animate={{ x: ['-100%', '100%'] }}
                          transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                        />
                        <span className="relative z-10">放弃该动作</span>
                      </Button>
                    </motion.div>

                    {/* 放弃后续全部 - 第二权重 */}
                    <motion.div
                      whileHover={{ scale: 1.02, y: -2 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    >
                      <Button
                        onClick={() => onConfirm('all')}
                        className="w-full h-14 glass-button border-2 border-orange-200/50 dark:border-orange-800/50 text-orange-600 dark:text-orange-400 hover:bg-orange-50/80 dark:hover:bg-orange-900/20 rounded-xl shadow-sm transition-all duration-200"
                        variant="outline"
                      >
                        放弃后续全部
                      </Button>
                    </motion.div>
                  </motion.div>

                  {/* Cancel Button - 最低权重 */}
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.25 }}
                  >
                    <motion.div
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                    >
                      <Button 
                        variant="ghost" 
                        onClick={onClose} 
                        className="w-full hover:bg-gray-100/50 dark:hover:bg-gray-800/50"
                      >
                        取消
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

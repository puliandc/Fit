import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogOverlay, DialogPortal, DialogTitle, DialogDescription } from './ui/dialog';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { CheckCircle, Dumbbell, Weight } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import * as DialogPrimitive from '@radix-ui/react-dialog@1.1.6';
import * as VisuallyHidden from '@radix-ui/react-visually-hidden@1.1.0';

interface CompletionDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: (reps: number, weight: number) => void;
  defaultReps: number;
  defaultWeight: number;
}

export function CompletionDialog({ 
  open, 
  onClose, 
  onConfirm, 
  defaultReps, 
  defaultWeight 
}: CompletionDialogProps) {
  const [reps, setReps] = useState(defaultReps.toString());
  const [weight, setWeight] = useState(defaultWeight.toString());

  // 修复：当props变化时同步更新state
  useEffect(() => {
    if (open) {
      setReps(defaultReps.toString());
      setWeight(defaultWeight.toString());
    }
  }, [defaultReps, defaultWeight, open]);

  const handleConfirm = () => {
    const repsNum = parseInt(reps) || 0;
    const weightNum = parseFloat(weight) || 0;
    onConfirm(repsNum, weightNum);
  };

  const handleCancel = () => {
    onClose();
  };

  return (
    <DialogPrimitive.Root open={open} onOpenChange={handleCancel}>
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

                <div className="p-6 relative z-10">
                  {/* Accessible Title and Description (visually hidden) */}
                  <VisuallyHidden.Root>
                    <DialogTitle>记录完成情况</DialogTitle>
                    <DialogDescription>请输入您实际完成的次数和重量</DialogDescription>
                  </VisuallyHidden.Root>

                  {/* Header */}
                  <div className="flex items-start gap-3 mb-6">
                    <motion.div 
                      className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl flex items-center justify-center shadow-lg flex-shrink-0"
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
                        <CheckCircle className="w-5 h-5 text-white" />
                      </motion.div>
                    </motion.div>
                    <motion.div 
                      className="flex-1"
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.15 }}
                    >
                      <h3 className="mb-1 bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                        记录完成情况
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        请输入您实际完成的次数和重量
                      </p>
                    </motion.div>
                  </div>

                  {/* Form */}
                  <motion.div 
                    className="space-y-4"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                  >
                    {/* 次数输入 */}
                    <motion.div 
                      className="space-y-2"
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.25 }}
                    >
                      <Label htmlFor="reps" className="text-gray-700 dark:text-gray-300 flex items-center gap-2">
                        <Dumbbell className="w-4 h-4 text-green-600 dark:text-green-400" />
                        完成次数
                      </Label>
                      <motion.div
                        whileHover={{ scale: 1.01 }}
                        whileTap={{ scale: 0.99 }}
                      >
                        <Input
                          id="reps"
                          type="number"
                          value={reps}
                          onChange={(e) => setReps(e.target.value)}
                          min="0"
                          className="h-14 text-center text-2xl font-bold glass-button border-green-200/50 dark:border-green-800/50 focus:border-green-400 dark:focus:border-green-600 rounded-xl shadow-sm transition-all duration-200"
                        />
                      </motion.div>
                    </motion.div>
                    
                    {/* 重量输入 */}
                    {defaultWeight > 0 && (
                      <motion.div 
                        className="space-y-2"
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.3 }}
                      >
                        <Label htmlFor="weight" className="text-gray-700 dark:text-gray-300 flex items-center gap-2">
                          <Weight className="w-4 h-4 text-purple-600 dark:text-purple-400" />
                          完成重量 (kg)
                        </Label>
                        <motion.div
                          whileHover={{ scale: 1.01 }}
                          whileTap={{ scale: 0.99 }}
                        >
                          <Input
                            id="weight"
                            type="number"
                            step="0.5"
                            value={weight}
                            onChange={(e) => setWeight(e.target.value)}
                            min="0"
                            className="h-14 text-center text-2xl font-bold glass-button border-purple-200/50 dark:border-purple-800/50 focus:border-purple-400 dark:focus:border-purple-600 rounded-xl shadow-sm transition-all duration-200"
                          />
                        </motion.div>
                      </motion.div>
                    )}
                  </motion.div>

                  {/* Buttons */}
                  <motion.div 
                    className="flex gap-3 mt-6"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.35 }}
                  >
                    <motion.div 
                      className="flex-1"
                      whileHover={{ scale: 1.02, y: -2 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    >
                      <Button 
                        onClick={handleCancel} 
                        className="w-full h-14 glass-button border-gray-200/50 dark:border-gray-700/50 hover:bg-white/80 dark:hover:bg-gray-800/80 rounded-xl shadow-sm transition-all duration-200"
                        variant="outline"
                      >
                        取消
                      </Button>
                    </motion.div>
                    <motion.div 
                      className="flex-1"
                      whileHover={{ scale: 1.02, y: -2 }}
                      whileTap={{ scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    >
                      <Button 
                        onClick={handleConfirm} 
                        className="w-full h-14 bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white border-0 shadow-xl rounded-xl relative overflow-hidden group transition-all duration-200"
                      >
                        <motion.div
                          className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0"
                          animate={{ x: ['-100%', '100%'] }}
                          transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                        />
                        <span className="relative z-10">确认</span>
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

import { Dialog, DialogContent, DialogTitle, DialogDescription } from './ui/dialog';
import { Button } from './ui/button';
import { Trophy, Star, CheckCircle, Zap } from 'lucide-react';
import { motion } from 'motion/react';

interface WorkoutCompleteDialogProps {
  open: boolean;
  onClose: () => void;
  totalTime: string;
  totalExercises: number;
}

export function WorkoutCompleteDialog({ open, onClose, totalTime, totalExercises }: WorkoutCompleteDialogProps) {
  const sparkleVariants = {
    initial: { scale: 0, rotate: 0 },
    animate: { 
      scale: [0, 1, 0.8, 1],
      rotate: [0, 180, 360],
      transition: {
        duration: 0.8,
        delay: 0.3,
        repeat: Infinity,
        repeatDelay: 2
      }
    }
  };

  const trophyVariants = {
    initial: { scale: 0, y: 50 },
    animate: { 
      scale: 1,
      y: 0,
      transition: {
        type: "spring",
        stiffness: 300,
        damping: 20,
        delay: 0.2
      }
    }
  };

  const textVariants = {
    initial: { opacity: 0, y: 20 },
    animate: { 
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.5,
        delay: 0.5
      }
    }
  };

  const statsVariants = {
    initial: { opacity: 0, scale: 0.8 },
    animate: { 
      opacity: 1,
      scale: 1,
      transition: {
        duration: 0.4,
        delay: 0.7
      }
    }
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="mx-4 max-w-[350px] text-center border-0 bg-gradient-to-br from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20">
        <DialogTitle className="sr-only">训练完成</DialogTitle>
        <DialogDescription className="sr-only">
          恭喜你完成了今天的训练！总共完成了{totalExercises}个动作，用时{totalTime}。
        </DialogDescription>
        <div className="relative py-6">
          {/* 背景装饰星星 */}
          <motion.div 
            className="absolute top-4 left-6"
            variants={sparkleVariants}
            initial="initial"
            animate="animate"
          >
            <Star className="w-4 h-4 text-yellow-400 fill-yellow-400" />
          </motion.div>
          
          <motion.div 
            className="absolute top-8 right-8"
            variants={sparkleVariants}
            initial="initial"
            animate="animate"
            style={{ animationDelay: '0.5s' }}
          >
            <Star className="w-3 h-3 text-yellow-400 fill-yellow-400" />
          </motion.div>
          
          <motion.div 
            className="absolute bottom-8 left-8"
            variants={sparkleVariants}
            initial="initial"
            animate="animate"
            style={{ animationDelay: '1s' }}
          >
            <Zap className="w-4 h-4 text-orange-400 fill-orange-400" />
          </motion.div>

          {/* 奖杯图标 */}
          <motion.div 
            className="flex justify-center mb-4"
            variants={trophyVariants}
            initial="initial"
            animate="animate"
          >
            <div className="w-20 h-20 bg-gradient-to-br from-yellow-400 to-orange-500 rounded-full flex items-center justify-center shadow-lg">
              <Trophy className="w-10 h-10 text-white" />
            </div>
          </motion.div>

          {/* 标题和描述 */}
          <motion.div
            variants={textVariants}
            initial="initial"
            animate="animate"
          >
            <h2 className="text-2xl mb-2 bg-gradient-to-r from-yellow-600 to-orange-600 bg-clip-text text-transparent">
              训练完成！
            </h2>
            <p className="text-gray-600 dark:text-gray-300 mb-6">
              恭喜你完成了今天的训练！
            </p>
          </motion.div>

          {/* 训练统计 */}
          <motion.div 
            className="grid grid-cols-2 gap-4 mb-6"
            variants={statsVariants}
            initial="initial"
            animate="animate"
          >
            <div className="bg-white/80 dark:bg-gray-800/80 p-4 rounded-lg">
              <CheckCircle className="w-6 h-6 text-green-500 mx-auto mb-2" />
              <p className="text-sm text-gray-600 dark:text-gray-400">完成动作</p>
              <p className="text-lg text-green-600 dark:text-green-400">{totalExercises}个</p>
            </div>
            
            <div className="bg-white/80 dark:bg-gray-800/80 p-4 rounded-lg">
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              >
                <Star className="w-6 h-6 text-blue-500 mx-auto mb-2" />
              </motion.div>
              <p className="text-sm text-gray-600 dark:text-gray-400">用时</p>
              <p className="text-lg text-blue-600 dark:text-blue-400">{totalTime}</p>
            </div>
          </motion.div>

          {/* 按钮 */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1 }}
          >
            <Button 
              onClick={onClose} 
              className="w-full bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white border-0"
            >
              太棒了！
            </Button>
          </motion.div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
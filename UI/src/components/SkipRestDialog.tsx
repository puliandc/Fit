import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from './ui/dialog';
import { Button } from './ui/button';
import { Timer } from 'lucide-react';
import { motion } from 'motion/react';

interface SkipRestDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  timeLeft: number;
}

export function SkipRestDialog({ open, onClose, onConfirm, timeLeft }: SkipRestDialogProps) {
  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="mx-4 max-w-[350px] glass-card dark:glass-card-dark border-0">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <motion.div 
              className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400 to-cyan-500 flex items-center justify-center shadow-lg"
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: "spring", stiffness: 500, damping: 25 }}
            >
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
              >
                <Timer className="w-5 h-5 text-white" />
              </motion.div>
            </motion.div>
            <span className="bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent">
              跳过休息
            </span>
          </DialogTitle>
          <DialogDescription>
            还剩 {formatTime(timeLeft)} 休息时间，确定要跳过吗？
          </DialogDescription>
        </DialogHeader>
        
        <motion.div
          className="py-2"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.1 }}
        >
          <div className="p-4 bg-gradient-to-r from-blue-50/80 to-cyan-50/80 dark:from-blue-900/20 dark:to-cyan-900/20 rounded-xl border border-blue-200/50 dark:border-blue-800/50 text-center">
            <motion.div
              className="text-3xl font-mono font-bold bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent"
              animate={{ scale: [1, 1.05, 1] }}
              transition={{ duration: 1, repeat: Infinity }}
            >
              {formatTime(timeLeft)}
            </motion.div>
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">剩余休息时间</p>
          </div>
        </motion.div>
        
        <DialogFooter className="flex-col gap-2 sm:flex-row">
          <motion.div 
            className="w-full"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button variant="outline" onClick={onClose} className="w-full glass-button border-gray-200/50 dark:border-gray-700/50">
              继续休息
            </Button>
          </motion.div>
          <motion.div 
            className="w-full"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button onClick={onConfirm} className="w-full bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 border-0 shadow-lg relative overflow-hidden group">
              <motion.div
                className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0"
                animate={{ x: ['-100%', '100%'] }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              />
              <span className="relative z-10">跳过休息</span>
            </Button>
          </motion.div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

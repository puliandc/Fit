import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from './ui/dialog';
import { Button } from './ui/button';
import { AlertTriangle } from 'lucide-react';
import { motion } from 'motion/react';

interface QuitDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: (action: 'all' | 'exercise') => void;
}

export function QuitDialog({ open, onClose, onConfirm }: QuitDialogProps) {
  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="mx-4 max-w-[350px] glass-card dark:glass-card-dark border-0">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <motion.div 
              className="w-10 h-10 rounded-full bg-gradient-to-br from-orange-400 to-red-500 flex items-center justify-center shadow-lg"
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: "spring", stiffness: 500, damping: 25 }}
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
            <span className="bg-gradient-to-r from-orange-600 to-red-600 bg-clip-text text-transparent">
              确认放弃
            </span>
          </DialogTitle>
          <DialogDescription>
            请选择您想要执行的操作
          </DialogDescription>
        </DialogHeader>
        
        <motion.div 
          className="py-4"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <div className="space-y-3">
            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <Button
                variant="destructive"
                onClick={() => onConfirm('all')}
                className="w-full h-12 bg-gradient-to-r from-red-500 to-orange-500 hover:from-red-600 hover:to-orange-600 border-0 shadow-lg relative overflow-hidden group"
              >
                <motion.div
                  className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0"
                  animate={{ x: ['-100%', '100%'] }}
                  transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                />
                <span className="relative z-10">放弃后续全部</span>
              </Button>
            </motion.div>
            
            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <Button
                variant="outline"
                onClick={() => onConfirm('exercise')}
                className="w-full h-12 glass-button border-orange-200/50 text-orange-600 hover:bg-orange-50/50 dark:border-orange-800/50 dark:text-orange-400 dark:hover:bg-orange-900/20 shadow-lg"
              >
                放弃该动作
              </Button>
            </motion.div>
          </div>
        </motion.div>
        
        <DialogFooter>
          <motion.div 
            className="w-full"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button variant="ghost" onClick={onClose} className="w-full hover:bg-gray-100/50 dark:hover:bg-gray-800/50">
              取消
            </Button>
          </motion.div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

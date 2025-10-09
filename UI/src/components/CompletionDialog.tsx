import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from './ui/dialog';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { CheckCircle } from 'lucide-react';
import { motion } from 'motion/react';

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
    <Dialog open={open} onOpenChange={handleCancel}>
      <DialogContent className="mx-4 max-w-[350px] glass-card dark:glass-card-dark border-0">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <motion.div 
              className="w-8 h-8 rounded-full bg-gradient-to-br from-green-400 to-emerald-500 flex items-center justify-center"
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: "spring", stiffness: 500, damping: 25 }}
            >
              <CheckCircle className="w-4 h-4 text-white" />
            </motion.div>
            <span className="bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
              记录完成情况
            </span>
          </DialogTitle>
          <DialogDescription>
            请输入您实际完成的次数和重量
          </DialogDescription>
        </DialogHeader>
        
        <motion.div 
          className="space-y-4 py-4"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <div className="space-y-2">
            <Label htmlFor="reps">完成次数</Label>
            <Input
              id="reps"
              type="number"
              value={reps}
              onChange={(e) => setReps(e.target.value)}
              min="0"
              className="text-center glass-button border-green-200/50 dark:border-green-800/50 focus:border-green-400 dark:focus:border-green-600"
            />
          </div>
          
          {defaultWeight > 0 && (
            <div className="space-y-2">
              <Label htmlFor="weight">完成重量 (kg)</Label>
              <Input
                id="weight"
                type="number"
                step="0.5"
                value={weight}
                onChange={(e) => setWeight(e.target.value)}
                min="0"
                className="text-center glass-button border-green-200/50 dark:border-green-800/50 focus:border-green-400 dark:focus:border-green-600"
              />
            </div>
          )}
        </motion.div>
        
        <DialogFooter className="flex-col gap-2 sm:flex-row">
          <motion.div 
            className="w-full"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button variant="outline" onClick={handleCancel} className="w-full glass-button border-gray-200/50 dark:border-gray-700/50">
              取消
            </Button>
          </motion.div>
          <motion.div 
            className="w-full"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button onClick={handleConfirm} className="w-full bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 border-0 shadow-lg relative overflow-hidden group">
              <motion.div
                className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0"
                animate={{ x: ['-100%', '100%'] }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              />
              <span className="relative z-10">确认</span>
            </Button>
          </motion.div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

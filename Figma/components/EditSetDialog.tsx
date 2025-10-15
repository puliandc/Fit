import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from './ui/dialog';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Edit3 } from 'lucide-react';
import { motion } from 'motion/react';

interface EditSetDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: (reps: number, weight: number) => void;
  currentReps: number;
  currentWeight: number;
  exerciseName: string;
}

export function EditSetDialog({ 
  open, 
  onClose, 
  onConfirm, 
  currentReps, 
  currentWeight, 
  exerciseName 
}: EditSetDialogProps) {
  const [reps, setReps] = useState(currentReps.toString());
  const [weight, setWeight] = useState(currentWeight.toString());

  const handleConfirm = () => {
    const repsNum = parseInt(reps) || 0;
    const weightNum = parseFloat(weight) || 0;
    onConfirm(repsNum, weightNum);
    onClose();
  };

  const handleCancel = () => {
    onClose();
    setReps(currentReps.toString());
    setWeight(currentWeight.toString());
  };

  // Update local state when props change
  useEffect(() => {
    setReps(currentReps.toString());
    setWeight(currentWeight.toString());
  }, [currentReps, currentWeight, open]);

  return (
    <Dialog open={open} onOpenChange={handleCancel}>
      <DialogContent className="mx-4 max-w-[350px] glass-card dark:glass-card-dark border-0">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <motion.div 
              className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-pink-500 flex items-center justify-center shadow-lg"
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: "spring", stiffness: 500, damping: 25 }}
            >
              <motion.div
                animate={{ rotate: [0, -10, 10, -10, 0] }}
                transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
              >
                <Edit3 className="w-5 h-5 text-white" />
              </motion.div>
            </motion.div>
            <span className="bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
              修改训练参数
            </span>
          </DialogTitle>
          <DialogDescription>
            修改 {exerciseName} 当前这组的次数和重量
          </DialogDescription>
        </DialogHeader>
        
        <motion.div 
          className="space-y-4 py-4"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <div className="space-y-2">
            <Label htmlFor="edit-reps">目标次数</Label>
            <Input
              id="edit-reps"
              type="number"
              value={reps}
              onChange={(e) => setReps(e.target.value)}
              min="0"
              className="text-center glass-button border-purple-200/50 dark:border-purple-800/50 focus:border-purple-400 dark:focus:border-purple-600"
            />
          </div>
          
          {currentWeight > 0 && (
            <div className="space-y-2">
              <Label htmlFor="edit-weight">目标重量 (kg)</Label>
              <Input
                id="edit-weight"
                type="number"
                step="0.5"
                value={weight}
                onChange={(e) => setWeight(e.target.value)}
                min="0"
                className="text-center glass-button border-purple-200/50 dark:border-purple-800/50 focus:border-purple-400 dark:focus:border-purple-600"
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
            <Button onClick={handleConfirm} className="w-full bg-gradient-to-r from-purple-500 to-pink-600 hover:from-purple-600 hover:to-pink-700 border-0 shadow-lg relative overflow-hidden group">
              <motion.div
                className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0"
                animate={{ x: ['-100%', '100%'] }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              />
              <span className="relative z-10">确认修改</span>
            </Button>
          </motion.div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

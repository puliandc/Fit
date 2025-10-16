interface ExerciseListItemProps {
  index: number;
  name: string;
  sets: number;
  reps: number;
  gradientFrom?: string;
  gradientTo?: string;
}

export function ExerciseListItem({ 
  index, 
  name, 
  sets, 
  reps,
  gradientFrom = 'green-500',
  gradientTo = 'emerald-500'
}: ExerciseListItemProps) {
  return (
    <div className="flex items-center gap-2 bg-white/50 dark:bg-gray-800/50 rounded-lg p-2">
      <div className={`w-6 h-6 bg-gradient-to-br from-${gradientFrom} to-${gradientTo} rounded-md flex items-center justify-center flex-shrink-0`}>
        <span className="text-xs text-white">{index}</span>
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm text-gray-800 dark:text-gray-200 truncate">{name}</p>
      </div>
      <div className="text-xs text-gray-500 dark:text-gray-400 flex-shrink-0">
        {sets}组×{reps}次
      </div>
    </div>
  );
}

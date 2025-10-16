import { LucideIcon } from 'lucide-react';

interface StatCardProps {
  icon: LucideIcon;
  label: string;
  value: string | number;
  gradientFrom?: string;
  gradientTo?: string;
}

export function StatCard({ 
  icon: Icon, 
  label, 
  value,
  gradientFrom = 'green-600',
  gradientTo = 'emerald-600'
}: StatCardProps) {
  return (
    <div className="bg-white/50 dark:bg-gray-800/50 rounded-xl p-3 text-center">
      <div className="flex items-center justify-center gap-1 mb-1">
        <Icon className={`w-4 h-4 text-${gradientFrom.split('-')[0]}-600`} />
      </div>
      <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">{label}</p>
      <p className={`bg-gradient-to-r from-${gradientFrom} to-${gradientTo} bg-clip-text text-transparent`}>
        {value}
      </p>
    </div>
  );
}

import { motion } from 'motion/react';
import { Card, CardContent } from './ui/card';
import { LucideIcon } from 'lucide-react';
import { ReactNode } from 'react';

interface FeatureCardProps {
  // 图标和文字
  icon: LucideIcon;
  title: string;
  description: string;
  
  // 颜色主题
  gradientFrom: string;      // 例如: "orange-500"
  gradientTo: string;        // 例如: "pink-500"
  gradientVia?: string;      // 可选中间色
  
  // 按钮/操作区域
  action?: ReactNode;
  
  // 额外内容
  children?: ReactNode;
  
  // 动画配置
  animateOnMount?: boolean;
  initialY?: number;
  delay?: number;
}

export function FeatureCard({
  icon: Icon,
  title,
  description,
  gradientFrom,
  gradientTo,
  gradientVia,
  action,
  children,
  animateOnMount = true,
  initialY = 20,
  delay = 0
}: FeatureCardProps) {
  const gradientClass = gradientVia
    ? `from-${gradientFrom} via-${gradientVia} to-${gradientTo}`
    : `from-${gradientFrom} to-${gradientTo}`;

  const bgGradientClass = gradientVia
    ? `from-${gradientFrom}/10 via-${gradientVia}/10 to-${gradientTo}/10`
    : `from-${gradientFrom}/10 to-${gradientTo}/10`;

  return (
    <motion.div
      initial={animateOnMount ? { opacity: 0, y: initialY } : undefined}
      animate={animateOnMount ? { opacity: 1, y: 0 } : undefined}
      transition={animateOnMount ? { duration: 0.5, delay, ease: 'easeOut' } : undefined}
    >
      <Card className="glass-card dark:glass-card-dark border-0 shadow-2xl overflow-hidden relative">
        {/* 动画背景层 */}
        <motion.div
          className={`absolute inset-0 bg-gradient-to-br ${bgGradientClass}`}
          animate={{
            opacity: [0.3, 0.6, 0.3]
          }}
          transition={{
            duration: 3,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        
        {/* 内容层 */}
        <CardContent className="p-6 relative z-10">
          {/* 标题区域 */}
          <div className="flex items-start gap-3 mb-4">
            <motion.div 
              className={`w-10 h-10 bg-gradient-to-br ${gradientClass} rounded-xl flex items-center justify-center shadow-lg flex-shrink-0`}
              animate={{
                rotate: [0, 5, -5, 0]
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            >
              <Icon className="w-5 h-5 text-white" />
            </motion.div>
            <div className="flex-1">
              <h3 className={`mb-1 bg-gradient-to-r ${gradientClass} bg-clip-text text-transparent`}>
                {title}
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                {description}
              </p>
            </div>
          </div>

          {/* 额外内容 */}
          {children}

          {/* 操作按钮 */}
          {action && (
            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              {action}
            </motion.div>
          )}
        </CardContent>
      </Card>
    </motion.div>
  );
}

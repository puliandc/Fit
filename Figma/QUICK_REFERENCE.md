# 快速参考 - WorkoutScreen 样式

## 🎯 核心设计理念

**白色卡片 + 彩色模块 + 清晰边框 = 高可读性**

---

## 📋 复制文件清单

### 要实现相同的设计，需要这些文件：

#### 1. 核心组件 (必需)
```
/components/WorkoutScreen.tsx          ← 主界面组件 ⭐
/components/CompletionDialog.tsx       ← 完成对话框
/components/EditSetDialog.tsx          ← 编辑对话框
/components/QuitDialog.tsx             ← 退出对话框
/components/SkipRestDialog.tsx         ← 跳过休息对话框
/components/WorkoutCompleteDialog.tsx  ← 训练完成对话框
```

#### 2. 数据类型定义
```typescript
// 从 App.tsx 复制这些类型定义
export type WorkoutExercise = {
  id: string;
  name: string;
  image: string;
  sets: number;
  reps: number;
  weight: number;
  restTime: number;              // 组间休息时间（秒）
  exerciseRestTime?: number;     // 动作间休息时间（秒，可选）
};

export type WorkoutPlan = {
  name: string;
  exercises: WorkoutExercise[];
};
```

#### 3. UI 基础组件 (从 shadcn/ui)
```
/components/ui/button.tsx
/components/ui/card.tsx
/components/ui/dialog.tsx
/components/ui/progress.tsx
/components/ui/input.tsx
/components/ui/label.tsx
```

#### 4. 全局样式
```
/styles/globals.css               ← 包含玻璃态样式定义
```

---

## 🎨 核心样式速查

### 白色卡片（主容器）
```tsx
className="p-6 rounded-2xl bg-white/90 dark:bg-gray-800/90 backdrop-blur-xl shadow-lg border border-gray-200/50 dark:border-gray-700/50"
```

### 彩色横条模块
```tsx
// 橙色 - 动作时间
className="flex items-center justify-center gap-3 p-4 bg-gradient-to-r from-orange-500/10 to-pink-500/10 dark:from-orange-500/20 dark:to-pink-500/20 rounded-xl border border-orange-200 dark:border-orange-800/50"

// 蓝色 - 组数
className="... bg-gradient-to-r from-blue-500/10 to-cyan-500/10 ... border border-blue-200 dark:border-blue-800/50"

// 绿色 - 次数
className="... bg-gradient-to-br from-green-500/10 to-emerald-500/10 ... border-2 border-green-200 dark:border-green-800/50"

// 紫色 - 重量
className="... bg-gradient-to-br from-purple-500/10 to-pink-500/10 ... border-2 border-purple-200 dark:border-purple-800/50"
```

### 顶部/底部栏
```tsx
// Header
className="px-6 pt-4 pb-4 bg-white/80 dark:bg-gray-800/80 backdrop-blur-xl border-b border-gray-200/50 dark:border-gray-700/50"

// Footer
className="px-6 pb-6 pt-4 bg-white/80 dark:bg-gray-800/80 backdrop-blur-xl border-t border-gray-200/50 dark:border-gray-700/50"
```

### 主要按钮
```tsx
// 绿色主按钮
className="w-full h-14 bg-gradient-to-r from-green-500 via-emerald-500 to-green-600 hover:from-green-600 hover:via-emerald-600 hover:to-green-700 text-white font-semibold text-base border-0 shadow-lg rounded-xl"

// 红色次要按钮
className="w-full h-12 bg-white/50 dark:bg-gray-800/50 border-2 border-red-200 dark:border-red-800/50 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 font-medium rounded-xl"
```

---

## 📏 关键尺寸

| 元素 | 尺寸 |
|------|------|
| 页面左右边距 | `px-6` (24px) |
| 主卡片圆角 | `rounded-2xl` (16px) |
| 模块圆角 | `rounded-xl` (12px) |
| 主卡片内边距 | `p-6` (24px) |
| 横条模块内边距 | `p-4` (16px) |
| 次数/重量内边距 | `p-5` (20px) |
| 主按钮高度 | `h-14` (56px) |
| 次要按钮高度 | `h-12` (48px) |
| 超大数字 | `text-3xl` (30px) |
| 大标题 | `text-2xl` (24px) |

---

## 🎭 常用动画

```tsx
// 悬停放大
whileHover={{ scale: 1.02 }}
whileTap={{ scale: 0.98 }}

// 卡片点击（更明显）
whileHover={{ scale: 1.03, y: -2 }}
whileTap={{ scale: 0.97 }}

// 数值变化
key={value}
initial={{ scale: 1.3 }}
animate={{ scale: 1 }}
transition={{ type: "spring", stiffness: 500, damping: 20 }}
```

---

## 🌈 颜色映射

| 功能 | 颜色主题 | 用途 |
|------|----------|------|
| 动作时间 | 橙色-粉色 | 计时器显示 |
| 组间休息 | 橙色-粉色 | 休息倒计时 |
| 动���间休息 | 紫色-蓝色 | 动作切换休息 |
| 当前组数 | 蓝色-青色 | 组数进度 |
| 目标次数 | 绿色-翡翠 | 可编辑卡片 |
| 目标重量 | 紫色-粉色 | 可编辑卡片 |
| 完成按钮 | 绿色渐变 | 主操作 |
| 放弃按钮 | 红色描边 | 次要操作 |

---

## ✨ 视觉层次

```
层级 1: 大绿色按钮 "动作完成" (最重要)
层级 2: 白色卡片上的超大数字 (次数/重量)
层级 3: 彩色横条的关键信息 (组数/时间)
层级 4: 灰色小字标签 (说明文字)
层级 5: 红色描边按钮 "放弃动作" (最不重要)
```

---

## 📱 布局公式

```
固定 Header (白色栏)
  ↓
可选 休息倒计时 (mx-6 mt-4)
  ↓
滚动内容区 (px-6 py-4)
  - 白色主卡片 (p-6, space-y-5)
    - 动作名称
    - 动作时间横条
    - 组数横条
    - 2列网格 (次数 | 重量)
  ↓
固定 Footer (白色栏)
  - 动作完成按钮 (h-14)
  - 放弃动作按钮 (h-12)
```

---

## 🔍 关键差异点

### ❌ 旧设计问题
- Header 用 `rounded-b-3xl` 导致不对齐
- 使用纯色背景，可读性差
- 组数和次数混在一起
- 没有明确的边框区分

### ✅ 新设计优势
- 统一白色背景 + 毛玻璃
- 所有元素 `px-6` 完美对齐
- 组数独立横条（不可点击）
- 次数/重量并排（都可点击）
- 清晰的边框系统
- 深色文字高���比度

---

## 💡 5 秒记住的口诀

**"白卡六距，彩条清边，大字深色，绿钮突出"**

- **白卡**: 白色卡片背景
- **六距**: px-6 统一边距
- **彩条**: 彩色渐变模块
- **清边**: 清晰边框
- **大字**: text-3xl 数字
- **深色**: 深色文字
- **绿钮**: 绿色主按钮
- **突出**: h-14 大尺寸

---

## 📞 遇到问题？

查看完整文档: `/WORKOUT_DESIGN_SPEC.md`
查看实现代码: `/components/WorkoutScreen.tsx`

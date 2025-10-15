# 健身训练应用 - WorkoutScreen 设计规范

## 📱 目标平台
- **设备**: iPhone 16
- **屏幕宽度**: 393px
- **设计风格**: iOS 16 现代简约风格
- **主题色**: 橙色/粉色/紫色渐变系统

---

## 🎨 设计系统

### 颜色方案

#### 主题色
```css
/* 橙色主题 - 用于动作时间、休息倒计时 */
from-orange-500 to-pink-500

/* 蓝色主题 - 用于组数信息 */
from-blue-500 to-cyan-500

/* 绿色主题 - 用于次数、完成按钮 */
from-green-500 to-emerald-500

/* 紫色主题 - 用于重量、动作间休息 */
from-purple-500 to-pink-500
```

#### 背景系统
```css
/* 页面背景 */
bg-gradient-to-br from-orange-50/30 via-pink-50/20 to-purple-50/30
dark:from-gray-900 dark:via-gray-900 dark:to-gray-900

/* 卡片背景（高可读性） */
bg-white/90 dark:bg-gray-800/90
backdrop-blur-xl
border border-gray-200/50 dark:border-gray-700/50

/* 模块背景（彩色） */
/* 橙色模块 */
bg-gradient-to-r from-orange-500/10 to-pink-500/10
border border-orange-200 dark:border-orange-800/50

/* 蓝色模块 */
bg-gradient-to-r from-blue-500/10 to-cyan-500/10
border border-blue-200 dark:border-blue-800/50

/* 绿色模块 */
bg-gradient-to-br from-green-500/10 to-emerald-500/10
border-2 border-green-200 dark:border-green-800/50

/* 紫��模块 */
bg-gradient-to-br from-purple-500/10 to-pink-500/10
border-2 border-purple-200 dark:border-purple-800/50
```

#### 文字颜色
```css
/* 主标题 */
text-gray-900 dark:text-white

/* 渐变标题 */
bg-gradient-to-r from-orange-600 via-pink-600 to-purple-600 bg-clip-text text-transparent

/* 正文 */
text-gray-700 dark:text-gray-300

/* 次要文字 */
text-gray-600 dark:text-gray-400
text-gray-500 dark:text-gray-500

/* 彩色文字 */
text-orange-600 dark:text-orange-400
text-blue-600 dark:text-blue-400
text-green-600 dark:text-green-400
text-purple-600 dark:text-purple-400
```

---

### 间距系统

#### 统一边距
```css
/* 页面左右边距 */
px-6

/* 卡片内边距 */
p-6  /* 主卡片 */
p-5  /* 次数/重量卡片 */
p-4  /* 横条模块 */

/* 垂直间距 */
space-y-4  /* 页面内模块间距 */
space-y-5  /* 卡片内模块间距 */
space-y-3  /* 底部按钮间距 */
```

#### 圆角系统
```css
rounded-2xl  /* 主卡片 (16px) */
rounded-xl   /* 内部模块、按钮 (12px) */
rounded-full /* 圆形按钮 */
```

---

### 字体大小

```css
/* 超大数字 */
text-3xl font-bold  /* 48px - 次数/重量数值 */

/* 大号标题 */
text-2xl font-bold  /* 24px - 动作名称、倒计时 */

/* 标准文字 */
text-base font-semibold  /* 16px - 按钮文字 */
text-sm font-medium      /* 14px - 标签文�� */
text-xs font-medium      /* 12px - 次要说明 */
```

---

## 📐 布局结构

### 整体布局
```
┌─────────────────────────────────┐
│  Header (固定顶部)               │ - 白色背景，毛玻璃
│  - 返回按钮 + 标题 + 进度%       │ - px-6 pt-4 pb-4
│  - 进度条                        │
├─────────────────────────────────┤
│  休息倒计时 (条件显示)           │ - mx-6 mt-4
│  - 大号时间显示                  │ - 白色卡片 + 彩色环
├─────────────────────────────────┤
│                                 │
│  主内容区 (滚动)                 │ - px-6 py-4
│  ┌───────────────────────────┐ │
│  │ 动作名称                   │ │
│  ├───────────────────────────┤ │
│  │ 动作时间 (橙色横条)        │ │
│  ├───────────────────────────┤ │
│  │ 当前组数 (蓝色横条)        │ │
│  ├───────────────────────────┤ │
│  │ ┌─────────┬─────────┐    │ │
│  │ │ 次数    │ 重量    │    │ │
│  │ │ (绿色)  │ (紫色)  │    │ │
│  │ └─────────┴─────────┘    │ │
│  └───────────────────────────┘ │
│                                 │
├─────────────────────────────────┤
│  底部按钮 (固定底部)             │ - 白色背景，毛玻璃
│  - 动作完成 (大绿色按钮)         │ - px-6 pb-6 pt-4
│  - 放弃动作 (红色描边按钮)       │
└─────────────────────────────────┘
```

---

## 🧩 组件详细规范

### 1. Header 顶栏

```tsx
<div className="px-6 pt-4 pb-4 bg-white/80 dark:bg-gray-800/80 backdrop-blur-xl border-b border-gray-200/50 dark:border-gray-700/50">
  <div className="flex items-center gap-3 mb-3">
    {/* 返回按钮 - 圆形 */}
    <Button className="w-9 h-9 p-0 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700">
      <ArrowLeft className="w-5 h-5 text-gray-700 dark:text-gray-300" />
    </Button>
    
    {/* 标题 */}
    <h2 className="flex-1 font-semibold text-gray-900 dark:text-white">
      快速训练计划
    </h2>
    
    {/* 进度百分比 */}
    <span className="text-sm font-medium text-orange-600 dark:text-orange-400">
      50%
    </span>
  </div>
  
  {/* 进度条 */}
  <div className="relative h-1.5 bg-gray-200/80 dark:bg-gray-700/80 rounded-full overflow-hidden">
    <div className="absolute top-0 left-0 h-full bg-gradient-to-r from-orange-500 via-pink-500 to-purple-500 rounded-full" 
         style={{ width: '50%' }} />
  </div>
</div>
```

**要点:**
- 白色背景 + 毛玻璃效果
- 统一 `px-6` 左右边距
- 进度条使用渐变色
- 返回按钮为圆形


### 2. 休息倒计时卡片

```tsx
{/* 组间休息 - 橙色环 */}
<div className="mx-6 mt-4">
  <div className="p-5 rounded-2xl bg-white/90 dark:bg-gray-800/90 backdrop-blur-xl shadow-lg border border-gray-200/50 dark:border-gray-700/50 ring-2 ring-orange-400/50">
    <div className="flex flex-col items-center gap-2">
      <div className="flex items-center gap-2">
        <Timer className="w-5 h-5 text-orange-500" />
        <span className="font-semibold text-orange-600 dark:text-orange-400">
          组间休息
        </span>
      </div>
      <div className="font-mono text-3xl font-bold text-orange-600 dark:text-orange-400">
        0:15
      </div>
      <span className="text-sm text-gray-500 dark:text-gray-400">
        点击跳过休息
      </span>
    </div>
  </div>
</div>

{/* 动作间休息 - 紫色环 */}
<div className="ring-2 ring-purple-400/50">
  {/* 添加下一个动作预告 */}
  <div className="mt-2 px-3 py-1.5 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
    <span className="text-sm text-purple-700 dark:text-purple-300">
      下一个：哑铃飞鸟
    </span>
  </div>
</div>
```

**要点:**
- `ring-2` 彩色环区分类型
- 白色卡片背景保证可读性
- 超大号时间显示 `text-3xl`
- 动作间休息显示下一个动作


### 3. 主内容卡片

```tsx
<div className="px-6 py-4">
  <div className="p-6 rounded-2xl bg-white/90 dark:bg-gray-800/90 backdrop-blur-xl shadow-lg border border-gray-200/50 dark:border-gray-700/50 space-y-5">
    
    {/* 动作名称 */}
    <h3 className="text-2xl font-bold text-center bg-gradient-to-r from-orange-600 via-pink-600 to-purple-600 bg-clip-text text-transparent">
      杠铃卧推
    </h3>
    
    {/* 动作时间 - 橙色横条 */}
    <div className="flex items-center justify-center gap-3 p-4 bg-gradient-to-r from-orange-500/10 to-pink-500/10 dark:from-orange-500/20 dark:to-pink-500/20 rounded-xl border border-orange-200 dark:border-orange-800/50">
      <Clock className="w-6 h-6 text-orange-500" />
      <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
        动作时间
      </span>
      <span className="text-2xl font-mono font-bold text-orange-600 dark:text-orange-400">
        0:45
      </span>
    </div>
    
    {/* 组数 - 蓝色横条 */}
    <div className="flex items-center justify-center gap-3 p-4 bg-gradient-to-r from-blue-500/10 to-cyan-500/10 dark:from-blue-500/20 dark:to-cyan-500/20 rounded-xl border border-blue-200 dark:border-blue-800/50">
      <Hash className="w-6 h-6 text-blue-500" />
      <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
        当前组数
      </span>
      <div className="flex items-baseline gap-1">
        <span className="text-2xl font-bold text-blue-600 dark:text-blue-400">1</span>
        <span className="text-lg text-gray-400 dark:text-gray-500">/</span>
        <span className="text-lg font-semibold text-gray-500 dark:text-gray-400">2</span>
      </div>
    </div>
    
    {/* 次数和重量 - 2列网格 */}
    <div className="grid grid-cols-2 gap-3">
      {/* 次数 - 绿色卡片 */}
      <div className="p-5 bg-gradient-to-br from-green-500/10 to-emerald-500/10 dark:from-green-500/20 dark:to-emerald-500/20 rounded-xl cursor-pointer border-2 border-green-200 dark:border-green-800/50">
        <div className="flex flex-col items-center gap-2">
          <div className="flex items-center gap-1.5">
            <Dumbbell className="w-5 h-5 text-green-600 dark:text-green-400" />
            <Edit className="w-3.5 h-3.5 text-green-500 dark:text-green-400" />
          </div>
          <span className="text-xs font-medium text-gray-600 dark:text-gray-400">
            目标次数
          </span>
          <span className="text-3xl font-bold text-green-600 dark:text-green-400">
            10
          </span>
        </div>
      </div>
      
      {/* 重量 - 紫色卡片 */}
      <div className="p-5 bg-gradient-to-br from-purple-500/10 to-pink-500/10 dark:from-purple-500/20 dark:to-pink-500/20 rounded-xl cursor-pointer border-2 border-purple-200 dark:border-purple-800/50">
        <div className="flex flex-col items-center gap-2">
          <div className="flex items-center gap-1.5">
            <Weight className="w-5 h-5 text-purple-600 dark:text-purple-400" />
            <Edit className="w-3.5 h-3.5 text-purple-500 dark:text-purple-400" />
          </div>
          <span className="text-xs font-medium text-gray-600 dark:text-gray-400">
            目标重量
          </span>
          <div className="flex items-baseline gap-1">
            <span className="text-3xl font-bold text-purple-600 dark:text-purple-400">
              60
            </span>
            <span className="text-sm font-medium text-gray-500 dark:text-gray-400">
              kg
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

**要点:**
- 白色主卡片，`space-y-5` 内部间距
- 横条模块：渐变背景 + 边框 + 图标居左
- 次数/重量：`border-2` 强调可点击
- 超大数字 `text-3xl` 突出显示


### 4. 底部按钮区

```tsx
<div className="px-6 pb-6 pt-4 bg-white/80 dark:bg-gray-800/80 backdrop-blur-xl border-t border-gray-200/50 dark:border-gray-700/50 space-y-3">
  
  {/* 动作完成 - 主按钮 */}
  <Button className="w-full h-14 bg-gradient-to-r from-green-500 via-emerald-500 to-green-600 hover:from-green-600 hover:via-emerald-600 hover:to-green-700 text-white font-semibold text-base border-0 shadow-lg rounded-xl">
    <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/30 to-white/0" />
    <span className="relative z-10">动作完成</span>
  </Button>
  
  {/* 放弃动作 - 次要按钮 */}
  <Button className="w-full h-12 bg-white/50 dark:bg-gray-800/50 border-2 border-red-200 dark:border-red-800/50 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 font-medium rounded-xl">
    放弃动作
  </Button>
</div>
```

**要点:**
- 主按钮：绿色渐变 + `h-14` + 光泽动画
- 次要按钮：描边设计 + `h-12` + 红色主题
- 统一 `px-6` 对齐
- 白色背景 + 顶部边框

---

## 🎭 动画效果

### 页面进入动画
```tsx
// Header 从上滑入
initial={{ y: -100, opacity: 0 }}
animate={{ y: 0, opacity: 1 }}
transition={{ type: "spring", stiffness: 300, damping: 30 }}

// 内容淡入上移
initial={{ opacity: 0, y: 20 }}
animate={{ opacity: 1, y: 0 }}
transition={{ duration: 0.4 }}

// 底部按钮从下滑入
initial={{ y: 100, opacity: 0 }}
animate={{ y: 0, opacity: 1 }}
transition={{ type: "spring", stiffness: 300, damping: 30, delay: 0.2 }}
```

### 交互动画
```tsx
// 按钮点击
whileHover={{ scale: 1.02 }}
whileTap={{ scale: 0.98 }}

// 卡片点击（次数/重量）
whileHover={{ scale: 1.03, y: -2 }}
whileTap={{ scale: 0.97 }}

// 数值变化
key={currentSetReps}
initial={{ scale: 1.3 }}
animate={{ scale: 1 }}
transition={{ type: "spring", stiffness: 500, damping: 20 }}

// 倒计时脉动
animate={{ scale: [1, 1.05, 1] }}
transition={{ duration: 1, repeat: Infinity }}

// 按钮光泽扫过
animate={{ x: ['-100%', '100%'] }}
transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
```

---

## 📦 需要的核心文件

### 必需文件列表

1. **主应用逻辑**
   - `/App.tsx` - 应用入口，包含数据结构定义
   - `/components/WorkoutScreen.tsx` - 训练界面主组件

2. **对话框组件**
   - `/components/CompletionDialog.tsx` - 动作完成对话框
   - `/components/EditSetDialog.tsx` - 编辑组数对话框
   - `/components/QuitDialog.tsx` - 放弃确认对话框
   - `/components/SkipRestDialog.tsx` - 跳过休息对话框
   - `/components/WorkoutCompleteDialog.tsx` - 训练完成对话框

3. **UI 基础组件**
   - `/components/ui/button.tsx`
   - `/components/ui/card.tsx`
   - `/components/ui/dialog.tsx`
   - `/components/ui/progress.tsx`
   - `/components/ui/input.tsx`
   - `/components/ui/label.tsx`

4. **样式文件**
   - `/styles/globals.css` - 全局样式和玻璃态效果

---

## 🎨 全局样式 (globals.css)

```css
/* 玻璃态卡片 - 保持原有定义 */
.glass-card {
  @apply bg-white/70 backdrop-blur-md;
}

.glass-card-dark {
  @apply dark:bg-gray-800/70;
}

/* 玻璃态按钮 */
.glass-button {
  @apply backdrop-blur-sm bg-white/50 dark:bg-gray-800/50;
}
```

---

## 🔧 技术栈

- **React** - UI 框架
- **TypeScript** - 类型安全
- **Tailwind CSS v4** - 样式系统
- **Motion (Framer Motion)** - 动画库
- **Lucide React** - 图标库
- **shadcn/ui** - UI 组件库

---

## 📱 响应式设计

当前设计专为 **iPhone 16 (393px 宽度)** 优化。

关键断点:
- 最大宽度: `max-w-[393px] mx-auto`
- 全屏高度: `h-screen`
- 固定顶部和底部，中间内容可滚动

---

## ✅ 设计检查清单

- [ ] 所有卡片使用白色背景 + 毛玻璃效果
- [ ] 统一使用 `px-6` 左右边距
- [ ] 圆角统一为 `rounded-2xl` 或 `rounded-xl`
- [ ] 文字颜色深色确保可读性
- [ ] 彩色模块使用 10-20% 透明度渐变
- [ ] 边框清晰区分不同区域
- [ ] 主按钮绿色渐变 `h-14`
- [ ] 次要按钮描边设计 `h-12`
- [ ] 数字使用 `text-3xl` 或 `text-2xl`
- [ ] 动画使用 spring 效果

---

## 📞 设计原则

1. **对齐优先** - 所有元素严格左右对齐
2. **高对比度** - 深色文字 + 浅色背景
3. **视觉层次** - 用大小、颜色、边框区分重要性
4. **一致性** - 统一的间距、圆角、颜色系统
5. **可操作性** - 明确哪些可点击（编辑图标、边框加粗）
6. **iOS 风格** - 简洁、优雅、流畅的动画

---

## 💡 与其他前端沟通要点

当向其他开发者说明设计时，重点强调:

1. **"白色卡片背景系统"** - 所有主要内容都在白色卡片上，确保可读性
2. **"统一 px-6 边距"** - Header、内容、底部按钮都对齐
3. **"彩色渐变 + 边框"** - 不是纯色填充，是淡渐变 + 明确边框
4. **"大号数字优先"** - 重要数据用 text-3xl 或 text-2xl
5. **"固定头尾 + 滚动内容"** - 经典的 iOS 三段式布局

---

**最后更新**: 2025-10-15
**设计师**: AI Assistant
**适配设备**: iPhone 16 (393px)

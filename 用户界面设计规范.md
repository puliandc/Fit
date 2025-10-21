# Fit 健身训练记录应用 - 用户界面设计规范

//created by Jason Lu on 11:45:00 10/21/2025

## 🎨 设计理念

### 核心原则

- **极简主义**：只保留最必要的界面元素，去除一切干扰
- **专注高效**：让用户能够专注于训练本身，而非操作界面
- **无感交互**：最小化用户操作步骤，实现近乎自动化的体验
- **个人定制**：针对单一用户的使用习惯进行深度优化

### 设计目标

- 让用户在 30 秒内开始训练
- 训练过程中几乎不需要查看屏幕
- 记录数据的操作步骤不超过 2 步

## 🎯 视觉设计系统

### 配色方案（深色主题优先）

基于 Tailwind CSS 规范的现代化深色主题

#### 主色调

- **主色**：`#6366F1` (Indigo-500) - 主要按钮和强调元素
- **主色变体**：`#818CF8` (Indigo-400) - 悬停状态
- **主色深色**：`#4F46E5` (Indigo-600) - 按下状态

#### 功能色彩

- **成功/完成**：`#22C55E` (Green-500) - 训练完成、成功操作
- **警告/注意**：`#F97316` (Orange-500) - 休息时间、提醒状态
- **错误/危险**：`#EF4444` (Red-500) - 错误提示、危险操作
- **信息/提示**：`#3B82F6` (Blue-500) - 辅助信息

#### 背景系统

- **主背景**：`#09090B` (Zinc-950) - 深色主背景
- **卡片背景**：`#18181B` (Zinc-900) - 卡片和容器背景
- **表面背景**：`#27272A` (Zinc-800) - 次级表面
- **高亮表面**：`#3F3F46` (Zinc-700) - 可交互表面

#### 文本色彩

- **主文本**：`#FAFAFA` (Zinc-50) - 主要文字内容
- **次级文本**：`#A1A1AA` (Zinc-400) - 辅助说明文字
- **三级文本**：`#71717A` (Zinc-500) - 补充信息文字
- **禁用文本**：`#52525B` (Zinc-600) - 禁用状态文字

### 字体系统

#### 字体族

- **主要字体**：SF Pro Display (iOS 系统字体)
- **数字字体**：SF Mono (用于显示重量、次数等数字)
- **备用字体**：PingFang SC (中文支持)

#### 字体大小层级

- **标题大**：32pt / Bold - 页面主标题
- **标题中**：24pt / Semibold - 区块标题
- **标题小**：20pt / Medium - 卡片标题
- **正文大**：17pt / Regular - 主要内容
- **正文**：16pt / Regular - 标准内容
- **正文小**：14pt / Regular - 补充内容
- **说明文字**：12pt / Regular - 帮助说明

### 间距系统

#### 基础间距单位

- **基础单位**：4pt (0.25rem)
- **常用间距**：8pt, 16pt, 24pt, 32pt
- **大间距**：48pt, 64pt

#### 间距应用

- **组件内边距**：16pt (标准)
- **卡片间距**：24pt (舒适)
- **区块间距**：32pt (清晰)
- **页面边距**：24pt (移动端适配)

## 📱 界面布局规范

### 主界面 (MainScreen.swift) 布局结构

#### 整体架构
```swift
ZStack {
    SafeAreaBackground()  // 安全区域背景
    AnimatedBackground()  // 动态背景效果

    ScrollView {
        VStack(spacing: 32) {  // 主垂直布局
            // LogoHeader区域
            VStack(spacing: 24) { ... }

            // 训练计划卡片区域
            FeatureCard(...)  // 功能卡片

            Spacer(minLength: 40)  // 最小间距40pt
        }
        .padding(.horizontal, 20)  // 水平边距20pt
    }
}
```

#### LogoHeader 组件布局
```swift
VStack(spacing: 24) {
    // Logo图标
    Image("fit-logo")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 120, height: 120)

    // 应用标题
    VStack(spacing: 8) {
        Text("Fit")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.appTextPrimary)

        Text("健身训练记录")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.appTextSecondary)
    }
}
```

#### 训练计划展示区域
```swift
VStack(spacing: 20) {
    // 读取健身计划 FeatureCard
    FeatureCard(
        icon: "doc.text.fill",
        title: "读取健身计划",
        subtitle: "从JSON文件导入训练计划",
        action: { showFileImporter = true }
    )

    // 加载状态指示器
    if isLoading {
        HStack {
            ProgressView()
            Text("正在读取...")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // 开始训练按钮
    ModernButton(...)
}
.padding(24)  // 卡片内边距24pt
```

### 训练界面 (WorkoutScreen.swift) 布局结构

#### 整体架构
```swift
ZStack {
    SafeAreaBackground()  // 安全区域背景

    VStack(spacing: 0) {  // 全屏垂直布局
        // 顶部动作信息区域
        VStack(spacing: 16) { ... }
        .padding(.horizontal, 16)
        .padding(.top, 16)

        Spacer()  // 弹性间距

        // 休息时间/动作时间显示区域
        VStack(spacing: 10) { ... }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)

        // 完成组数按钮区域
        VStack(spacing: 16) { ... }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)

        Spacer()  // 弹性间距
    }
}
```

#### 动作信息卡片 (CompactExerciseInfoCard)
```swift
VStack(spacing: 16) {
    // 动作名称和图片
    HStack(alignment: .top, spacing: 16) {
        // 动作图片
        ZStack { ... }

        // 动作信息
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)  // 动作名称
            Text("第\(currentSetIndex + 1)组，共\(exerciseSets.count)组")  // 组数信息
        }

        Spacer()
    }

    // 重量和次数信息
    HStack(spacing: 12) {
        // 重量显示
        VStack(spacing: 4) { ... }

        // 次数显示
        VStack(spacing: 4) { ... }

        Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
}
```

#### 计时器显示区域
```swift
VStack(spacing: 12) {
    // 休息时间计时器 (CompactTimerView)
    if inRestPhase {
        HStack(spacing: 10) {
            // 时间显示
            VStack(spacing: 4) { ... }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // 动作时间计时器 (ActionTimerView)
    if inWorkoutPhase && hasTimeLimit {
        VStack(spacing: 12) { ... }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
}
```

#### 完成组数按钮区域
```swift
VStack(spacing: 16) {
    // 主要完成按钮
    ModernButton(
        text: "完成这组",
        action: { showEditSetDialog = true },
        style: .primary,
        fullWidth: true
    )

    // 次要操作按钮
    HStack(spacing: 12) {
        // 跳过休息按钮
        ModernButton("跳过休息", ...)

        // 放弃训练按钮
        ModernButton("放弃训练", ...)
    }
}
.padding(.horizontal, 20)
.padding(.vertical, 16)
```

### 对话框布局系统

#### 编辑组数对话框 (EditSetDialog)
```swift
VStack(spacing: 12) {
    // 标题区域
    VStack(spacing: 12) {
        HStack {
            Text("完成这组")
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // 输入区域
    HStack(spacing: 12) {
        // 重量输入
        VStack(spacing: 8) { ... }
        .padding(.vertical, 17)

        // 次数输入
        VStack(spacing: 8) { ... }
        .padding(.vertical, 17)

        Spacer()
    }

    // 底部按钮
    HStack {
        Spacer()
        // 确认按钮组
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
}
```

#### 放弃训练对话框 (EnhancedQuitDialog)
```swift
VStack(spacing: 6) {
    // 标题
    Text("放弃训练？")
        .font(.system(size: 24, weight: .bold))

    // 选项按钮
    VStack(spacing: 0) { ... }
}
```

### 布局间距规范

#### 基础间距值
```swift
// 常用间距 (基于Tailwind CSS)
let spacing_xs: CGFloat = 4    // 0.25rem
let spacing_sm: CGFloat = 8    // 0.5rem
let spacing_md: CGFloat = 16   // 1rem
let spacing_lg: CGFloat = 24   // 1.5rem
let spacing_xl: CGFloat = 32   // 2rem
let spacing_2xl: CGFloat = 40  // 2.5rem
```

#### 页面级边距
```swift
// 标准页面边距
.page-padding-horizontal: 20pt  // px-5
.page-padding-vertical: 16pt    // py-4

// 卡片级内边距
.card-padding: 24pt              // p-6
.dialog-padding: 20pt           // p-5
```

#### 组件级间距
```swift
// VStack 间距
.vstack-spacing-tight: 8pt      // space-y-2
.vstack-spacing-normal: 12pt    // space-y-3
.vstack-spacing-comfortable: 16pt // space-y-4
.vstack-spacing-section: 24pt   // space-y-6
.vstack-spacing-page: 32pt      // space-y-8

// HStack 间距
.hstack-spacing-tight: 6pt      // gap-1.5
.hstack-spacing-normal: 8pt     // gap-2
.hstack-spacing-comfortable: 12pt // gap-3
.hstack-spacing-section: 16pt   // gap-4
```

### 屏幕适配策略

#### 响应式断点
```swift
// iPhone 屏幕适配
struct ScreenSize {
    static let min = CGSize(width: 320, height: 568)   // iPhone SE
    static let standard = CGSize(width: 390, height: 844) // iPhone 13
    static let max = CGSize(width: 428, height: 926)   // iPhone 13 Pro Max
}

// 动态间距计算
let dynamicSpacing = min(max(screenWidth * 0.05, 16), 32)
```

#### 安全区域处理
```swift
// 安全区域适配
SafeAreaBackground()
    .edgesIgnoringSafeArea(.all)

// 内容区域适配
VStack {
    // 主要内容
}
.padding(.horizontal, max(16, (screenWidth - 380) / 2)) // 大屏幕适配
```

### 布局性能优化

#### 懒加载策略
```swift
// 大量数据列表
LazyVStack(spacing: 16) {
    ForEach(workoutPlans) { plan in
        WorkoutPlanCard(plan: plan)
    }
}
```

#### 布局缓存
```swift
// 减少重复计算
@State private var cardHeight: CGFloat = 0

.overlay(
    GeometryReader { geometry in
        Color.clear.onAppear {
            cardHeight = geometry.size.height
        }
    }
)
```

## 🎛️ 组件设计规范

### 按钮组件

#### 主要按钮 (Primary Button)

```swift
// 设计规格
- 高度: 60pt
- 圆角: 16pt
- 背景: Indigo-500 到 Indigo-600 渐变
- 文字: 白色, 17pt, Semibold
- 状态: 默认/悬停/按下/禁用
```

**使用场景**：开始训练、完成训练等主要操作

#### 次要按钮 (Secondary Button)

```swift
// 设计规格
- 高度: 48pt
- 圆角: 12pt
- 背景: 透明
- 边框: Zinc-700, 2pt
- 文字: Zinc-50, 16pt, Medium
- 状态: 默认/悬停/按下/禁用
```

**使用场景**：添加组数、跳过休息等次要操作

#### 危险按钮 (Destructive Button)

```swift
// 设计规格
- 高度: 40pt
- 圆角: 8pt
- 背景: 透明
- 边框: Red-500, 1pt
- 文字: Red-500, 14pt, Medium
```

**使用场景**：删除记录、取消操作等

### 卡片组件

#### 主要卡片 (Primary Card)

```swift
// 设计规格
- 背景: Zinc-900
- 圆角: 20pt
- 内边距: 24pt
- 阴影: 深色阴影效果
- 边框: Zinc-800, 1pt
```

#### 信息卡片 (Info Card)

```swift
// 设计规格
- 背景: Zinc-800
- 圆角: 16pt
- 内边距: 20pt
- 阴影: 轻微阴影
```

### 输入组件

#### 数字输入框

```swift
// 设计规格
- 高度: 48pt
- 圆角: 12pt
- 背景: Zinc-800
- 边框: Zinc-700, 1pt
- 文字: Zinc-50, 20pt, Semibold
- 键盘: 数字键盘
```

#### 时间显示

```swift
// 设计规格
- 字体: SF Mono
- 大小: 48pt / Medium (大显示)
- 大小: 32pt / Medium (中显示)
- 大小: 24pt / Medium (小显示)
- 颜色: Zinc-50 (主色) / Orange-500 (警告)
```

## ✨ 动画与过渡

### 页面转场

```swift
// 主要转场效果
- 进入: .move(edge: .trailing) + .opacity
- 退出: .move(edge: .leading) + .opacity
- 持续时间: 0.3秒
- 缓动函数: .easeInOut
```

### 按钮交互

```swift
// 按钮状态动画
- 按下: scale(0.95) + opacity(0.8)
- 释放: scale(1.0) + opacity(1.0)
- 持续时间: 0.1秒
- 缓动函数: .spring
```

### 数值变化

```swift
// 数值动画效果
- 重量/次数变化: 数字滚动效果
- 时间倒计时: 平滑递减动画
- 进度条: 渐进式填充动画
- 持续时间: 0.5秒
```

### 加载状态

```swift
// 加载动画
- 旋转指示器: 简单旋转动画
- 骨架屏: 渐进式加载效果
- 持续时间: 1.0秒 (循环)
```

## 🔔 反馈系统

### 视觉反馈

- **成功操作**: 绿色闪烁 + √ 图标
- **错误提示**: 红色闪烁 + ⚠️ 图标
- **加载状态**: 旋转指示器
- **空状态**: 友好的插画 + 引导文字

### 触觉反馈

- **按钮按下**: 轻微震动反馈
- **操作完成**: 确认震动反馈
- **错误发生**: 警告震动反馈
- **时间提醒**: 节奏性震动提醒

### 声音反馈

- **休息开始**: 轻柔提示音
- **休息结束前 3 秒**: 倒计时声音
- **训练完成**: 庆祝音效
- **操作错误**: 错误提示音

## 📐 响应式设计

### iPhone 适配

```swift
// 屏幕尺寸适配
- iPhone SE: 320pt × 568pt (最小)
- iPhone 13: 390pt × 844pt (标准)
- iPhone 13 Pro Max: 428pt × 926pt (最大)

// 适配策略
- 使用相对布局 (VStack, HStack, GeometryReader)
- 动态字体大小调整
- 安全区域适配
- 横竖屏锁定 (仅竖屏)
```

### 可访问性

- **VoiceOver 支持**: 完整的屏幕阅读器支持
- **动态字体**: 支持系统字体大小调整
- **高对比度**: 支持系统高对比度模式
- **减少动画**: 支持减少动画设置
- **语音控制**: 支持语音导航控制

## 🔗 相关文档

### 产品文档
- [产品需求文档](产品需求文档.md) - 产品需求和用户故事
- [功能规格说明书](功能规格说明书.md) - 详细的功能实现规格
- [用户体验流程](用户体验流程.md) - 完整的用户旅程地图

### 技术文档
- [组件设计文档](docs/components/ui-components.md)
- [技术架构文档](docs/architecture/ui-architecture.md)
- [交互设计规范](docs/architecture/interaction-patterns.md)

### 实现代码
- [MainScreen.swift](Fit/Views/MainScreen.swift) - 主界面布局实现
- [WorkoutScreen.swift](Fit/Views/WorkoutScreen.swift) - 训练界面布局实现

---

**文档版本：** v1.0
**创建时间：** 2025 年 10 月 21 日
**最后更新：** 2025 年 10 月 21 日
**设计规范：** 基于 Tailwind CSS + iOS Human Interface Guidelines
**负责人：** 产品经理

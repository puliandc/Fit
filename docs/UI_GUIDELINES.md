# Fit 健身训练记录应用 - UI 指南

// updated: 2025-10-30

本指南反映当前代码里的实际 UI 实现（MainScreen、WorkoutScreen、FilePickerView、AnimatedBackground 等），用于保持视觉和交互一致。

## 设计方向
- **轻量专注**：主背景使用温暖的浅色渐变（`SafeAreaBackground` / `AnimatedBackground`），搭配少量模糊球动效。
- **高对比 CTA**：动作按钮、导入按钮使用渐变色和清晰的阴影，确保一眼可见。
- **单列布局**：主界面为纵向滚动的卡片组，训练界面为顶部信息 + 中部状态 + 底部操作区。
- **语音友好**：主操作按钮面积大、文案清晰，便于在语音播报后快速点击。

## 颜色与主题
- 基础调色（`ColorExtensions.swift`）
  - 主色：`appPrimary #6366F1` / 浅变体 `appPrimaryLight #818CF8`
  - 强调：`appAccent #F97316`（卡片/Logo 发光）、`success #22C55E`、`warning #F59E0B`、`error #EF4444`
  - 深色背景备用：`appBackground #09090B`、`appSurface #18181B`（仅在局部需要深色承载时使用）
- 实际背景：`SafeAreaBackground` 使用浅色渐变 `#FFF7ED → #FCE7F3 → #F3E8FF`，`AnimatedBackground` 在左上叠加低透明橙/粉模糊球。
- 文本对比：正文使用 `appText`，辅助文案使用 `appTextSecondary`。

## 字体
- 来源：`FontExtensions.swift`
  - 标题：`displayLarge` (56/Bold) 用于 Logo “FIT”
  - 功能标题/正文：`featureTitle` (20/Bold)、`featureBody` (16/Medium)
  - 按钮：`uiLarge` (20/Medium) 及 `buttonTextStyle` 扩展
- 字重与行高保持与扩展定义一致，避免自定义未声明的字体。

## 布局与间距
- 主界面 (`MainScreen`)
  - 外层 `ScrollView` 水平边距 20pt，垂直分组间距 24–32pt。
  - `LogoHeader` 顶部留白 40pt，内部元素垂直间距紧凑（8–12pt）。
  - `FeatureCard` 与训练计划卡片统一内边距 24pt，圆角 24pt，卡片间距 24pt。
- 训练界面 (`WorkoutScreen`)
  - 顶部标题栏/计时区水平 16pt，底部操作区水平 24pt。
  - 底部操作区使用 `ExtendedFooterBackground`，需延伸至安全区域并保留轻微阴影。
  - 主体模块间距 16pt；休息计时器与动作信息卡使用相同的左右边距。

## 组件要点
- **LogoHeader**：渐变文本 + 跑步图标发光动画，保持现有动画节奏（1s 往返）和 96pt 圆形底。
- **AnimatedBackground / SafeAreaBackground**：保持全屏覆盖，不裁剪安全区域；低电量或减少动效时可关闭模糊球。
- **FeatureCard & ModernButton**（定义在 `MainScreen.swift`）
  - 图标容器 56pt，圆角 16pt，使用主色或强调色渐变。
  - 按钮状态：主按钮 `.primary`，导入按钮 `.readPlan`，二级按钮 `.secondary`；禁用时降低透明度即可。
  - 加载态使用 `ProgressView` + “正在读取...” 文案。
- **WorkoutScreen 交互**
  - 休息态显示 `CompactTimerView`；非休息态显示 “动作完成” 主按钮 + “放弃动作” 次按钮。
  - 对话框（`EditSetDialog` / `EnhancedQuitDialog`）带超薄材质背景，点击遮罩可关闭。
  - 颜色保持浅色背景 + 白色半透明蒙层，避免回退到深色主题。

## 动效与反馈
- Logo、卡片脉冲动画周期 2s；背景模糊球 30s 往返，低电量/减少动画时需禁用。
- 按钮点击使用轻微缩放 + 阴影变化即可，避免复杂弹跳。
- 休息/完成提示依赖 `VoiceManager` 语音播报，保持文案简洁。

## 可访问性
- 主要按钮需可通过 VoiceOver 读出（示例见 `WorkoutScreen` 的辅助标签）。
- 保持大字号可读性（按钮 20pt，正文 16pt）；确保浅色背景下对比度足够。
- 关闭动画时（`reduceMotion`），禁用 `AnimatedBackground` 的模糊球并保留静态渐变。

## 文件与资源
- 仅在需要新增品牌色或字号时更新 `ColorExtensions.swift` / `FontExtensions.swift`；避免在视图里直接硬编码色值。
- 背景、按钮、卡片的风格以现有组件为准，新增页面请复用这些组件或保持相同的圆角/间距/渐变方案。

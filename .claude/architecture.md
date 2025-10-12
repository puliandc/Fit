# Fit 应用 AI战术手册

//created by Jason Lu on 14:35:00 10/12/2025

## 🎯 AI助手专用架构指南

本文档为AI助手提供Fit项目的详细架构信息，确保AI能够准确理解项目结构和设计决策。

## 🗺️ 项目架构概览

### 技术栈
- **UI框架**: SwiftUI
- **架构模式**: MVVM + 单一状态管理
- **数据层**: Codable + MockDataProvider
- **平台**: iOS 15.0+
- **语言**: Swift 5.7+

### 项目文件结构
```
Fit/
├── Fit/                           # 主要源代码
│   ├── FitApp.swift               # 应用入口点
│   ├── ContentView.swift          # 根视图
│   ├── NavigationManager.swift    # 导航状态管理
│   │
│   ├── Models/                    # 数据模型
│   │   └── MockData.swift         # 模拟数据提供者
│   │
│   ├── ViewModels/                # 视图模型
│   │   └── WorkoutViewModel.swift  # 训练业务逻辑
│   │
│   ├── Views/                     # 视图组件
│   │   ├── MainScreen.swift       # 主界面
│   │   ├── WorkoutScreen.swift    # 训练界面
│   │   └── Dialogs/
│   │       └── EditSetDialog.swift # 编辑对话框
│   │
│   ├── Components/                # 可复用组件
│   │   ├── ActionButton.swift     # 操作按钮
│   │   ├── GlassCard.swift        # 玻璃卡片
│   │   └── CompatibleNavigationView.swift # 导航组件
│   │
│   └── DesignSystem/              # 设计系统
│       ├── ColorExtensions.swift  # 颜色扩展
│       ├── FontExtensions.swift   # 字体扩展
│       └── AnimationExtensions.swift # 动画扩展
│
├── scripts/                       # 构建脚本
├── docs/                          # 项目文档
├── .claude/                       # AI配置（本目录）
└── claudedocs/                    # Claude文档缓存
```

## 🏗️ 核心架构模式

### 1. MVVM架构实现

**Model层**：
```swift
// 数据模型定义
struct Workout: Identifiable, Codable {
    let id: UUID
    let date: Date
    let sets: [WorkoutSet]
    let duration: TimeInterval
}

struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    let weight: Double
    let reps: Int
    let timestamp: Date
}
```

**ViewModel层**：
```swift
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var sets: [WorkoutSet] = []
    @Published var isWorkoutActive = false

    func startWorkout() {
        // 业务逻辑处理
    }

    func addSet(weight: Double, reps: Int) {
        // 添加训练组数
    }

    func completeWorkout() {
        // 完成训练
    }
}
```

**View层**：
```swift
struct WorkoutScreen: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        // UI实现
    }
}
```

### 2. 状态管理策略

**局部状态**：
- 使用@Published属性在ViewModel中管理状态
- 使用@StateObject在View中创建ViewModel实例
- 使用@ObservedObject观察外部ViewModel状态

**全局状态**：
- NavigationManager管理导航状态
- 通过EnvironmentObject传递全局状态
- 未来可扩展AppState管理更多全局状态

### 3. 数据流模式

```
用户交互 → View → ViewModel → Model
    ↑                           ↓
UI更新 ← @Published ← 状态变更
```

## 🎨 SwiftUI最佳实践

### 1. 视图组织原则

**单一职责**：
- 每个视图只负责一个主要功能
- 复杂界面拆分为多个子视图
- 组件化设计提高复用性

**状态管理**：
- @State用于视图内部状态
- @StateObject用于视图拥有的对象
- @ObservedObject用于外部对象
- @EnvironmentObject用于全局状态

### 2. 性能优化策略

**避免不必要重绘**：
- 使用计算属性而不是@State
- 合理使用onAppear/onDisappear
- 避免在View中进行复杂计算

**内存管理**：
- 及时释放不需要的资源
- 避免循环引用
- 使用weak引用处理回调

### 3. 组件设计模式

```swift
// 按钮组件示例
struct ActionButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(10)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .blue
        case .secondary:
            return .gray
        case .danger:
            return .red
        }
    }
}
```

## 📦 数据管理

### 1. 数据模型设计

**核心实体**：
- Workout: 训练记录
- WorkoutSet: 训练组数
- Exercise: 训练动作（未来扩展）

**数据验证**：
```swift
struct WorkoutValidator {
    static func validate(weight: Double) -> Result<Void, ValidationError> {
        guard weight >= 0 else { return .failure(.invalidWeight) }
        guard weight <= 1000 else { return .failure(.weightTooHeavy) }
        return .success(())
    }

    static func validate(reps: Int) -> Result<Void, ValidationError> {
        guard reps > 0 else { return .failure(.invalidReps) }
        guard reps <= 1000 else { return .failure(.tooManyReps) }
        return .success(())
    }
}
```

### 2. 数据持久化策略

**当前阶段（MVP）**：
- 使用MockDataProvider提供模拟数据
- 数据仅在应用生命周期内保存

**未来规划**：
- Core Data本地存储
- iCloud同步
- 数据导入导出功能

## 🎭 用户界面设计

### 1. 设计系统

**颜色规范**：
- 主色：#007AFF（系统蓝）
- 背景：#F2F2F7（浅灰）
- 文字：#000000（黑色）
- 成功：#34C759（绿色）
- 警告：#FF9500（橙色）
- 错误：#FF3B30（红色）

**字体规范**：
- 标题：32pt, Bold
- 副标题：24pt, Semibold
- 正文：16pt, Regular
- 说明：14pt, Regular

**间距规范**：
- 基础单位：8pt
- 常用间距：8pt, 16pt, 24pt, 32pt

### 2. 界面布局

**主界面结构**：
```
┌─────────────────────────┐
│        导航栏            │
├─────────────────────────┤
│    今日训练概览卡片       │
├─────────────────────────┤
│    快速开始按钮          │
├─────────────────────────┤
│    历史记录入口          │
├─────────────────────────┤
│    进度统计              │
└─────────────────────────┘
```

**训练界面结构**：
```
┌─────────────────────────┐
│    导航栏（返回按钮）     │
├─────────────────────────┤
│    当前训练项目显示       │
├─────────────────────────┤
│    训练组数列表          │
│    ┌─────────────────┐   │
│    │ 重量 | 次数 | 删除 │   │
│    └─────────────────┘   │
├─────────────────────────┤
│    添加组数按钮          │
├─────────────────────────┤
│    完成训练按钮          │
└─────────────────────────┘
```

## 🔄 业务逻辑流程

### 1. 训练流程

```
开始训练
    ↓
创建Workout实例
    ↓
进入训练界面
    ↓
添加训练组数
    ↓
验证输入数据
    ↓
保存训练组数
    ↓
完成训练
    ↓
保存训练记录
    ↓
返回主界面
```

### 2. 数据验证流程

```
用户输入
    ↓
实时验证
    ↓
显示错误提示（如果需要）
    ↓
用户确认
    ↓
最终验证
    ↓
保存数据
    ↓
更新UI
```

## 🧪 测试策略

### 1. 单元测试重点

**ViewModel测试**：
- 状态变更逻辑
- 数据验证逻辑
- 业务规则实现

**Model测试**：
- 数据模型验证
- 序列化/反序列化
- 边界条件处理

### 2. UI测试重点

**用户流程测试**：
- 完整训练流程
- 数据输入验证
- 界面导航

**组件测试**：
- 按钮交互
- 输入框行为
- 错误提示显示

## 🚀 AI开发指导原则

### 1. 代码生成原则

**遵循现有模式**：
- 保持与现有代码风格一致
- 使用已建立的组件和模式
- 遵循MVVM架构原则

**质量标准**：
- 包含适当的错误处理
- 添加必要的注释
- 确保代码可测试性

### 2. 功能实现顺序

**优先级排序**：
1. 核心功能（训练记录）
2. 数据验证
3. 用户界面优化
4. 性能优化
5. 高级功能

**实现策略**：
- 先实现基本功能
- 逐步增加复杂度
- 确保每步都可测试

### 3. 常见任务模式

**添加新功能**：
1. 更新数据模型（如需要）
2. 在ViewModel中添加业务逻辑
3. 创建或更新View组件
4. 添加相应的测试
5. 更新文档

**修复Bug**：
1. 识别问题根本原因
2. 修复核心逻辑
3. 添加防护措施
4. 增加测试覆盖
5. 验证修复效果

## 📋 AI检查清单

### 开发前检查
- [ ] 理解需求背景和目标
- [ ] 查看相关现有代码
- [ ] 确定实现方案
- [ ] 识别潜在风险点

### 开发中检查
- [ ] 遵循项目架构模式
- [ ] 保持代码风格一致
- [ ] 添加适当错误处理
- [ ] 确保状态管理正确

### 开发后检查
- [ ] 代码质量检查
- [ ] 添加必要测试
- [ ] 更新相关文档
- [ ] 验证功能完整性

## 🔧 开发工具配置

### SwiftLint规则
```yaml
line_length:
  warning: 120
  error: 150

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500
```

### 构建脚本
- `scripts/build.sh` - 主构建脚本
- `scripts/dev-setup.sh` - 开发环境设置
- `scripts/test.sh` - 测试脚本

---

这份AI战术手册为AI助手提供了完整的项目架构指南，确保AI能够准确理解项目结构并生成符合项目标准的代码。
# Fit - iOS 健身训练记录应用

//created by Jason Lu on 21:10:00 10/30/2025

[![Swift](https://img.shields.io/badge/Swift-5.8+-FA7343.svg?style=flat-square)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000.svg?style=flat-square)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-007AFF.svg?style=flat-square)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-Private-red.svg?style=flat-square)](LICENSE)

> **极简主义的个人健身训练记录应用**
> 基于 SwiftUI 构建，专注于提供专注高效的训练数据记录体验

## 📋 目录

- [🎯 项目概述](#-项目概述)
- [🏗️ 系统架构](#️-系统架构)
- [💻 技术栈](#-技术栈)
- [🚀 快速开始](#-快速开始)
- [📁 项目结构](#-项目结构)
- [🛠️ 开发指南](#️-开发指南)
- [🧪 测试策略](#-测试策略)
- [📊 性能指标](#-性能指标)
- [🔒 安全性](#-安全性)
- [📚 文档资源](#-文档资源)
- [🤝 维护指南](#-维护指南)

## 🎯 项目概述

### 核心价值主张

- **专注训练体验**：30秒内开始训练，训练过程中几乎无需查看屏幕
- **极简操作设计**：减少干扰，让用户专注于训练本身
- **智能化语音提示**：通过语音指导整个训练流程
- **本地数据存储**：所有数据仅存储在用户设备，保护隐私

### 目标用户画像

**主要用户**：Jason Lue (项目开发者) - 健身爱好者，需要高效的个人训练记录解决方案

### 产品特色

- **30秒快速启动**：从打开应用到开始训练，不超过30秒
- **语音指导系统**：全程语音提示，减少屏幕交互
- **外部计划支持**：支持JSON格式训练计划导入
- **专注模式设计**：训练界面最小化干扰元素

## 🏗️ 系统架构

### 架构概览

Fit 应用采用 **MVVM + Environment Object** 架构模式，结合现代化的 SwiftUI 声明式UI框架，实现清晰的分层架构和响应式数据流。

```
┌─────────────────────────────────────────────────────────────────┐
│                        Fit 应用架构                              │
├─────────────────────────────────────────────────────────────────┤
│  📱 Presentation Layer (SwiftUI Views)                        │
│  ├── MainScreen           - 主界面和训练计划管理                 │
│  ├── WorkoutScreen        - 训练执行界面                         │
│  ├── Component Library    - 可复用UI组件库                      │
│  └── Dialog System        - 模态对话框管理                       │
├─────────────────────────────────────────────────────────────────┤
│  🧠 Business Logic Layer                                      │
│  ├── WorkoutSessionManager - 训练会话状态管理                   │
│  ├── ExternalTrainingPlanService - 外部计划解析服务             │
│  ├── VoiceManager        - 语音播报服务                         │
│  └── NavigationManager   - 导航状态管理                         │
├─────────────────────────────────────────────────────────────────┤
│  💾 Data Layer                                                    │
│  ├── WorkoutPlan Model   - 训练计划数据模型                     │
│  ├── Exercise Model      - 训练动作数据模型                     │
│  ├── ExerciseSet Model   - 训练组数数据模型                     │
│  └── CompletedSet Model  - 完成记录数据模型                     │
├─────────────────────────────────────────────────────────────────┤
│  🎨 Environment & State Management                              │
│  ├── DialogManager       - 对话框状态管理                       │
│  ├── WorkoutViewModel    - 训练视图模型                         │
│  └── NavigationState     - 导航状态管理                         │
└─────────────────────────────────────────────────────────────────┘
```

### 核心架构决策

#### 1. MVVM + Environment Object 模式
- **选择理由**：SwiftUI 原生支持，提供响应式数据绑定
- **优势**：代码结构清晰，状态管理统一，UI自动响应数据变化
- **适用场景**：中小型应用，数据流相对简单

#### 2. 服务层分离
- **设计原则**：单一职责，业务逻辑与UI解耦
- **服务组成**：
  - `ExternalTrainingPlanService`：外部文件解析
  - `WorkoutSessionManager`：训练会话管理
  - `VoiceManager`：语音播报控制
  - `NavigationManager`：导航状态管理

#### 3. 响应式数据流
- **数据流向**：Model → ViewModel → View
- **状态同步**：通过 `@StateObject` 和 `@EnvironmentObject`
- **异步处理**：使用 `async/await` 处理异步操作

### 数据流架构

```
训练计划导入流程：
用户选择文件 → FileImporter → ExternalTrainingPlanService
→ WorkoutPlan模型 → UI更新

训练执行流程：
用户操作 → WorkoutSessionManager → 状态更新
→ ViewModel → UI自动更新 → 语音提示

数据保存流程：
训练完成 → CompletedSet创建 → 本地存储
→ UI状态持久化
```

## 💻 技术栈

### 核心技术

| 技术 | 版本 | 用途 | 说明 |
|------|------|------|------|
| **Swift** | 5.8+ | 核心开发语言 | 现代、安全、高性能 |
| **SwiftUI** | 4.0+ | UI框架 | 声明式界面开发 |
| **iOS** | 15.0+ | 目标平台 | 支持最新iOS特性 |
| **Xcode** | 15.0+ | 开发工具 | 完整开发环境 |

### 系统框架

| 框架 | 用途 | 核心功能 |
|------|------|----------|
| **SwiftUI** | 用户界面 | 声明式UI、数据绑定、动画 |
| **Combine** | 响应式编程 | 数据流处理、异步操作 |
| **AVFoundation** | 音频处理 | 语音播报、声音效果 |
| **Foundation** | 基础功能 | 数据模型、文件处理 |
| **Core Graphics** | 图形渲染 | 自定义绘制、动画效果 |

### 开发工具链

| 工具 | 版本 | 配置 | 用途 |
|------|------|------|------|
| **SwiftFormat** | latest | `.swiftformat` | 代码格式化 |
| **SwiftLint** | latest | `.swiftlint.yml` | 代码规范检查 |
| **Docker** | latest | `Dockerfile` | 容器化构建环境 |

### 设计系统

#### 配色方案 (基于 Tailwind CSS)
```swift
// 主色调
let appPrimary = Color(red: 0.39, green: 0.40, blue: 0.95)  // Indigo-500
let appPrimaryHover = Color(red: 0.51, green: 0.55, blue: 0.97)  // Indigo-400

// 深色主题背景
let appBackground = Color(red: 0.04, green: 0.04, blue: 0.04)  // Zinc-950
let appCardBackground = Color(red: 0.09, green: 0.09, blue: 0.11)  // Zinc-900
let appSurface = Color(red: 0.15, green: 0.15, blue: 0.16)  // Zinc-800

// 文本颜色
let appTextPrimary = Color(red: 0.98, green: 0.98, blue: 0.98)  // Zinc-50
let appTextSecondary = Color(red: 0.63, green: 0.63, blue: 0.67)  // Zinc-400
```

#### 字体系统
```swift
// 标题层级
let fontTitleLarge = Font.system(size: 32, weight: .bold)
let fontTitleMedium = Font.system(size: 24, weight: .semibold)
let fontTitleSmall = Font.system(size: 20, weight: .medium)

// 正文字体
let fontBodyLarge = Font.system(size: 17, weight: .regular)
let fontBody = Font.system(size: 16, weight: .regular)
let fontBodySmall = Font.system(size: 14, weight: .regular)

// 数字字体 (用于重量、次数显示)
let fontNumberLarge = Font.system(size: 48, weight: .medium, design: .monospaced)
let fontNumberMedium = Font.system(size: 32, weight: .medium, design: .monospaced)
```

## 🚀 快速开始

### 环境要求

- **macOS**: 14.0+ (Sonoma 或更高版本)
- **Xcode**: 15.0+
- **iOS**: 15.0+ (目标设备)
- **Swift**: 5.8+
- **Apple Developer Account**: 设备测试需要

### 安装步骤

#### 1. 克隆项目
```bash
git clone <repository-url>
cd Fit
```

#### 2. 安装开发依赖
```bash
# 安装 SwiftFormat 和 SwiftLint
brew install swiftformat swiftlint

# 验证安装
swiftformat --version
swiftlint version
```

#### 3. 配置开发环境
```bash
# 加载开发别名
source .dev-aliases

# 运行预构建检查
fit-check

# 打开项目
fit-open
```

#### 4. 构建和运行
```bash
# 调试构建
fit-build-debug

# 运行应用 (模拟器)
fit-run

# 或者直接在 Xcode 中构建
# ⌘+B 构建项目
# ⌘+R 运行项目
```

### 首次运行设置

1. **选择开发团队**：在 Xcode 项目设置中选择你的 Apple Developer Team
2. **配置 Bundle Identifier**：确保 Bundle ID 唯一性
3. **设置签名证书**：配置开发和发布证书
4. **导入训练计划**：使用应用中的"读取健身计划"功能导入 `10202028.JSON`

## 📁 项目结构

```
Fit/
├── README.md                      # 项目主文档
├── 产品需求文档.md                 # 原始产品需求 (中文)
├── .dev-aliases                   # 开发命令别名
├── .swiftformat                   # Swift格式化配置
├── .swiftlint.yml                 # Swift代码检查配置
├── Dockerfile                     # Docker构建配置
├── 10202028.JSON                  # 示例训练计划数据
├── docs/                          # 文档目录
│   ├── README.md                  # 文档索引
│   ├── FUNCTIONAL_SPECS.md        # 功能规格说明书
│   ├── UX_FLOWS.md                # 用户体验流程
│   ├── UI_GUIDELINES.md           # 用户界面设计规范
│   ├── api/                       # API文档目录 (待完善)
│   ├── architecture/              # 架构文档目录 (待完善)
│   └── components/                # 组件文档目录 (待完善)
├── Fit/                           # iOS应用主目录
│   ├── App/                       # 应用入口和主要配置
│   │   ├── FitApp.swift           # 应用主入口
│   │   └── ContentView.swift       # 根视图
│   ├── Models/                    # 数据模型
│   │   ├── WorkoutPlan.swift      # 训练计划模型
│   │   ├── Exercise.swift         # 训练动作模型
│   │   ├── ExerciseSet.swift      # 训练组数模型
│   │   └── CompletedSet.swift     # 完成记录模型
│   ├── Views/                     # SwiftUI 视图
│   │   ├── MainScreen.swift       # 主界面
│   │   ├── WorkoutScreen.swift    # 训练界面
│   │   └── Components/            # 可复用组件
│   │       ├── FeatureCard.swift          # 功能卡片
│   │       ├── CompleteWorkoutPlanCard.swift # 完整训练计划卡片
│   │       ├── CompactExerciseInfoCard.swift # 紧凑动作信息卡片
│   │       ├── CompactTimerView.swift      # 紧凑计时器视图
│   │       ├── ModernButton.swift          # 现代化按钮
│   │       ├── LogoHeader.swift            # Logo头部组件
│   │       ├── SafeAreaBackground.swift    # 安全区域背景
│   │       ├── AnimatedBackground.swift    # 动态背景效果
│   │       └── Dialogs/                   # 对话框组件
│   │           ├── EnhancedQuitDialog.swift  # 放弃训练对话框
│   │           ├── WorkoutCompleteDialog.swift # 训练完成对话框
│   │           └── EditSetDialog.swift       # 编辑组数对话框
│   ├── Services/                  # 业务逻辑服务
│   │   ├── ExternalTrainingPlanService.swift # 外部训练计划服务
│   │   ├── WorkoutSessionManager.swift      # 训练会话管理
│   │   ├── VoiceManager.swift              # 语音播报服务
│   │   └── NavigationManager.swift         # 导航管理服务
│   ├── Managers/                  # 应用管理器
│   │   ├── DialogManager.swift             # 对话框管理
│   │   ├── WorkoutViewModel.swift          # 训练视图模型
│   │   └── NavigationManager.swift         # 导航状态管理
│   ├── DesignSystem/             # 设计系统
│   │   ├── Colors.swift          # 颜色定义
│   │   ├── Fonts.swift           # 字体定义
│   │   ├── Spacing.swift         # 间距定义
│   │   └── Extensions/           # 扩展方法
│   │       ├── Color+Extensions.swift
│   │       ├── Font+Extensions.swift
│   │       └── View+Extensions.swift
│   └── Resources/               # 资源文件
│       ├── Assets.xcassets     # 图片资源
│       └── Localizable.strings  # 本地化字符串
├── FitTests/                    # 单元测试
│   ├── Models/                  # 模型测试
│   ├── Services/                # 服务测试
│   └── Views/                   # 视图测试
├── scripts/                     # 开发脚本
│   ├── build.sh                 # 构建脚本
│   ├── pre-build-check.sh       # 预构建检查
│   └── deploy.sh               # 部署脚本
└── ForAI/                       # AI相关配置
    └── prompt-templates/        # 提示词模板
```

### 核心模块说明

#### Models (数据模型层)
- **WorkoutPlan**: 训练计划数据模型，包含名称、时长、动作列表
- **Exercise**: 训练动作模型，简化为ID和名称两个核心字段
- **ExerciseSet**: 训练组数模型，包含目标重量、次数、休息时间
- **CompletedSet**: 完成记录模型，用于存储实际的训练数据

#### Views (视图层)
- **MainScreen**: 主界面，负责训练计划导入和快速启动
- **WorkoutScreen**: 训练执行界面，提供完整的训练流程管理
- **Components**: 可复用UI组件库，包含卡片、按钮、计时器等

#### Services (服务层)
- **ExternalTrainingPlanService**: 解析JSON格式的训练计划文件
- **WorkoutSessionManager**: 管理训练会话状态和数据保存
- **VoiceManager**: 提供语音播报功能，减少屏幕交互

#### Managers (管理层)
- **DialogManager**: 统一管理应用中的对话框状态
- **WorkoutViewModel**: 训练视图模型，处理训练相关的业务逻辑
- **NavigationManager**: 导航状态管理，处理界面切换

## 🛠️ 开发指南

### 代码规范

#### Swift 代码风格
```bash
# 格式化代码
swiftformat Fit/

# 代码规范检查
swiftlint

# 格式化 + 规范检查
fit-format-lint
```

#### 代码组织原则
- **单一职责**：每个类/结构体只负责一个明确的功能
- **依赖注入**：通过协议和依赖注入提高可测试性
- **响应式编程**：使用 Combine 框架处理异步数据流
- **错误处理**：使用 Swift 的 Result 类型处理错误

### 构建流程

#### 开发构建
```bash
# 调试模式构建
fit-build-debug

# 发布模式构建
fit-build-release

# 清理构建
fit-build-clean
```

#### 构建脚本说明
```bash
#!/bin/bash
# scripts/build.sh

# 参数：
# $1: 构建配置 (Debug|Release)
# $2: 目标设备 (可选)
# $3: 是否清理 (true|false)

# 示例：
# ./scripts/build.sh Debug "platform=iOS Simulator,name=iPhone 16e" false
```

### 开发工作流

#### 1. 功能开发流程
```bash
# 1. 创建功能分支
git checkout -b feature/new-feature

# 2. 开发和测试
fit-build-debug
fit-test

# 3. 代码质量检查
fit-format-lint

# 4. 提交代码
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

#### 2. 代码审查清单
- [ ] 代码符合 Swift 编码规范
- [ ] 单元测试覆盖率 > 80%
- [ ] UI 响应时间 < 200ms
- [ ] 内存使用合理，无内存泄漏
- [ ] 错误处理完善，不会崩溃

### 调试指南

#### 日志系统
```swift
// 使用 os_log 进行结构化日志
import os.log

let logger = Logger(subsystem: "com.jason.fit", category: "WorkoutSession")

// 记录不同级别的日志
logger.info("Workout session started")
logger.error("Failed to load workout plan: \(error.localizedDescription)")
```

#### 常用调试命令
```bash
# 查看构建日志
fit-logs

# 查看错误日志
fit-error-logs

# 清理所有构建产物
fit-clean-all
```

### 性能优化

#### UI 性能
- **视图更新优化**：使用 `@State` 和 `@StateObject` 合理管理状态
- **列表性能**：使用 `LazyVStack` 处理大量数据
- **动画优化**：使用 SwiftUI 原生动画，避免 Core Animation 过度使用

#### 内存管理
- **弱引用**：避免循环引用，使用 `weak` 和 `unowned`
- **图片缓存**：合理使用图片缓存，避免内存泄漏
- **大对象处理**：及时释放不需要的大对象

## 🧪 测试策略

### 测试金字塔

```
                /\
               /  \
              / E2E \ ← 端到端测试 (最少)
             /______\
            /        \
           /Integration\ ← 集成测试 (适中)
          /__________\
         /            \
        /   Unit Tests   \ ← 单元测试 (最多)
       /________________\
```

### 单元测试

#### 测试覆盖率目标
- **Models**: 100% 覆盖
- **Services**: 90% 覆盖
- **ViewModels**: 85% 覆盖
- **Views**: 70% 覆盖 (重点测试交互逻辑)

#### 测试结构
```swift
import XCTest
@testable import Fit

class WorkoutPlanTests: XCTestCase {
    var workoutPlan: WorkoutPlan!

    override func setUp() {
        super.setUp()
        workoutPlan = MockData.createWorkoutPlan()
    }

    func testWorkoutPlanInitialization() {
        XCTAssertNotNil(workoutPlan)
        XCTAssertEqual(workoutPlan.exercises.count, 5)
    }

    func testWorkoutPlanSerialization() {
        // 测试 JSON 序列化/反序列化
    }
}
```

### UI 测试

#### 关键用户流程测试
- **训练计划导入**：测试文件选择和解析
- **训练执行**：测试完整的训练流程
- **数据记录**：测试组数数据的保存和验证

#### UI 测试示例
```swift
import XCTest

class FitUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testWorkoutPlanImport() {
        // 测试训练计划导入流程
        app.buttons["读取健身计划"].tap()
        // ... 其他测试步骤
    }
}
```

### 性能测试

#### 响应时间基准
```swift
func testWorkoutSessionStartPerformance() {
    measure {
        // 测试训练会话启动性能
        let sessionManager = WorkoutSessionManager()
        sessionManager.startWorkout(plan: workoutPlan)
    }
}
```

## 📊 性能指标

### 响应性能要求

| 操作 | 目标时间 | 实际时间 | 状态 |
|------|----------|----------|------|
| 应用启动 | < 3秒 | 待测试 | ⏳ |
| 界面切换 | < 200ms | 待测试 | ⏳ |
| 数据保存 | < 100ms | 待测试 | ⏳ |
| 语音播报 | < 500ms | 待测试 | ⏳ |

### 内存使用指标

| 场景 | 内存使用 | 目标 | 状态 |
|------|----------|------|------|
| 启动内存 | < 50MB | 待测试 | ⏳ |
| 训练过程 | < 100MB | 待测试 | ⏳ |
| 后台运行 | < 30MB | 待测试 | ⏳ |

### 电池优化

- **目标**：训练过程中电池消耗 < 10%/小时
- **策略**：优化传感器使用、减少后台任务
- **监控**：使用 Xcode Energy Log 监控电池使用

### 稳定性指标

- **崩溃率**： < 0.1%
- **ANR 率**： < 0.05%
- **成功率**：训练完成率 > 99%

## 🔒 安全性

### 数据隐私

#### 隐私原则
- **本地存储优先**：所有数据默认存储在设备本地
- **最小权限原则**：只请求必要的系统权限
- **透明性**：清晰告知用户数据用途
- **用户控制**：用户完全控制数据的导出和删除

#### 数据保护措施
```swift
// 敏感数据加密存储
let encryptedData = try JSONEncoder().encode(workoutSession)
let secureData = encryptedData.aesEncrypt(key: userDeviceKey)

// 本地数据库加密
let database = try Realm(configuration: Realm.Configuration(
    encryptionKey: deriveKeyFromUserDevice(),
    readOnly: false
))
```

### 网络安全

- **无网络依赖**：核心功能完全离线工作
- **可选同步**：未来版本考虑 iCloud 同步（用户可选）
- **数据传输加密**：如需网络传输，使用 HTTPS + 证书验证

### 权限管理

#### 必要权限
- **麦克风权限**：语音训练指导（可选）
- **文件访问权限**：读取训练计划文件
- **振动权限**：训练提醒（可选）

#### 权限申请流程
```swift
// 权限检查和申请
if !AVAudioSession.sharedInstance.recordPermission == .granted {
    AVAudioSession.sharedInstance.requestRecordPermission { granted in
        if granted {
            // 启用语音功能
        }
    }
}
```

## 📚 文档资源

### 核心文档

| 文档 | 描述 | 目标读者 |
|------|------|----------|
| [功能规格说明书](docs/FUNCTIONAL_SPECS.md) | 详细功能实现规格 | 开发者 |
| [用户体验流程](docs/UX_FLOWS.md) | 完整用户旅程地图 | 设计师、产品经理 |
| [界面设计规范](docs/UI_GUIDELINES.md) | UI设计标准和组件 | UI开发者 |

### 技术文档 (待完善)

| 文档 | 状态 | 描述 |
|------|------|------|
| API 文档 | 📝 计划中 | 服务接口规格 |
| 架构设计文档 | 📝 计划中 | 系统架构详细说明 |
| 组件使用指南 | 📝 计划中 | 可复用组件使用方法 |
| 数据库设计文档 | 📝 计划中 | 数据模型和关系设计 |

### 开发资源

#### 外部资源
- [SwiftUI 官方文档](https://developer.apple.com/documentation/swiftui/)
- [Swift 编程语言指南](https://docs.swift.org/swift-book/)
- [iOS 人机界面指南](https://developer.apple.com/design/human-interface-guidelines/)

#### 内部工具
- **开发别名**：`.dev-aliases` 中的命令别名
- **构建脚本**：`scripts/` 目录中的自动化脚本
- **代码规范**：`.swiftformat` 和 `.swiftlint.yml` 配置

## 🤝 维护指南

### 版本管理

#### 版本号规范
```
主版本.次版本.修订版本 (MAJOR.MINOR.PATCH)
- MAJOR: 重大功能更新或架构变更
- MINOR: 新功能添加，向后兼容
- PATCH: Bug 修复和小改进
```

#### 当前版本状态
- **当前版本**: 1.0.0
- **开发状态**: 活跃开发中
- **发布策略**: 功能稳定后发布到 App Store (私人使用)

### 代码维护

#### 依赖更新策略
```bash
# 定期检查依赖更新
brew outdated
brew upgrade swiftformat swiftlint

# Xcode 版本更新后检查兼容性
xcodebuild -version
```

#### 重构指南
- **定期重构**：每个迭代进行小规模重构
- **技术债务管理**：使用 GitHub Issues 跟踪技术债务
- **代码审查**：提交前进行自我代码审查

### 监控和分析

#### 崩溃监控 (未来版本)
```swift
// 集成崩溃报告系统 (可选)
// Firebase Crashlytics 或类似服务
```

#### 性能监控
- **启动性能**：监控应用启动时间
- **内存使用**：监控内存泄漏和峰值使用
- **电池消耗**：监控电池使用情况

### 备份和恢复

#### 开发环境备份
```bash
# 备份关键配置文件
cp .dev-aliases ~/.fit-dev-aliases
cp .swiftformat ~/.fit-swiftformat
cp .swiftlint.yml ~/.fit-swiftlint
```

#### 数据备份
- **训练数据**：提供数据导出功能
- **应用配置**：设置项备份和恢复
- **用户偏好**：界面偏好和个性化设置

### 问题排查

#### 常见问题

**Q: 应用无法启动**
```bash
# 清理构建缓存
fit-clean-all

# 重新生成项目文件
xcodebuild -project Fit.xcodeproj -scheme Fit clean
```

**Q: 语音功能不工作**
```bash
# 检查设备权限
# 设置 -> 隐私与安全性 -> 麦克风 -> Fit (允许)
```

**Q: 训练计划导入失败**
```bash
# 验证 JSON 格式
python3 -m json.tool 10202028.JSON

# 检查文件编码
file 10202028.JSON
```

#### 日志收集
```bash
# 收集系统日志
log show --predicate 'subsystem == "com.jason.fit"' --last 1d

# 收集应用崩溃日志
~/Library/Logs/DiagnosticReports/Fit-*.crash
```

---

## 📞 联系信息

**开发者**: Jason Lu
**邮箱**: [your-email@example.com]
**项目主页**: [GitHub Repository URL]
**文档更新**: 2025年10月30日

---

**版权声明**: © 2025 Jason Lu. 保留所有权利。
**许可证**: 私人项目，仅供个人使用。
**免责声明**: 本软件按"原样"提供，不提供任何明示或暗示的担保。
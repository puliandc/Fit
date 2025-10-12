# Fit 应用架构文档

//created by Jason Lu on 09:17:00 10/12/2025

## 🗺️ AI的地图：应用架构概览

### 架构模式选择

**主要架构模式**：MVVM + 单一状态管理

**选择理由**：
- MVVM提供清晰的职责分离
- 单一状态管理简化数据流
- SwiftUI天然支持响应式架构
- 便于测试和维护

## 🏗️ 模块分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (Views)                        │
├─────────────────────────────────────────────────────────────┤
│                Business Logic (ViewModels)                 │
├─────────────────────────────────────────────────────────────┤
│                   Data Access Layer                        │
├─────────────────────────────────────────────────────────────┤
│                 Infrastructure Layer                       │
└─────────────────────────────────────────────────────────────┘
```

### 1. UI Layer (表现层)

**职责**：
- 渲染用户界面
- 处理用户交互
- 展示数据状态

**核心组件**：
- `ContentView` - 根视图
- `MainScreen` - 主界面
- `WorkoutScreen` - 训练界面
- `EditSetDialog` - 编辑对话框

**设计原则**：
- 保持UI层轻量
- 所有业务逻辑在ViewModel中
- 使用@StateObject和@ObservedObject管理状态

### 2. Business Logic Layer (业务逻辑层)

**职责**：
- 处理业务规则
- 管理应用状态
- 协调数据流

**核心组件**：
- `WorkoutViewModel` - 训练业务逻辑
- `NavigationManager` - 导航状态管理
- `AppState` - 全局应用状态（未来扩展）

**设计模式**：
```swift
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var sets: [WorkoutSet] = []

    func addSet(weight: Double, reps: Int) {
        // 业务逻辑处理
    }

    func completeWorkout() {
        // 完成训练逻辑
    }
}
```

### 3. Data Access Layer (数据访问层)

**职责**：
- 数据持久化
- 数据验证
- 数据转换

**核心组件**：
- `Workout` - 训练数据模型
- `WorkoutSet` - 组数数据模型
- `MockDataProvider` - 模拟数据提供者
- `DataRepository` - 数据仓库（未来扩展）

**数据模型设计**：
```swift
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

### 4. Infrastructure Layer (基础设施层)

**职责**：
- 系统服务集成
- 工具类和扩展
- 第三方库管理

**核心组件**：
- `DesignSystem/` - 设计系统扩展
- `Components/` - 可复用UI组件
- `Extensions/` - 系统扩展（颜色、字体、动画）

## 🔄 数据流架构

### 1. 单向数据流

```
User Action → ViewModel → Data Layer → UI Update
     ↑                                        ↓
UI ← @Published Properties ← Business Logic
```

**数据流转过程**：
1. 用户在UI中执行操作
2. UI调用ViewModel方法
3. ViewModel更新业务状态
4. ViewModel调用Data Layer处理数据
5. Data Layer返回结果给ViewModel
6. ViewModel通过@Published属性更新UI

### 2. 状态管理模式

**局部状态**：
- 每个ViewModel管理自己的状态
- 使用@Published属性自动更新UI
- 支持状态依赖和计算属性

**全局状态**：
- NavigationManager管理导航状态
- 未来可引入AppState管理全局配置
- 通过EnvironmentObject传递全局状态

## 🎯 关键设计模式

### 1. MVVM模式实现

```swift
// Model
struct WorkoutSet: Codable {
    let id: UUID
    let weight: Double
    let reps: Int
}

// ViewModel
class WorkoutViewModel: ObservableObject {
    @Published var sets: [WorkoutSet] = []

    func addSet(weight: Double, reps: Int) {
        let newSet = WorkoutSet(id: UUID(), weight: weight, reps: reps)
        sets.append(newSet)
    }
}

// View
struct WorkoutScreen: View {
    @StateObject private var viewModel = WorkoutViewModel()

    var body: some View {
        VStack {
            ForEach(viewModel.sets) { set in
                WorkoutSetView(set: set)
            }
        }
    }
}
```

### 2. Repository模式（准备实现）

```swift
protocol WorkoutRepository {
    func saveWorkout(_ workout: Workout) async throws
    func loadWorkouts() async throws -> [Workout]
}

class MockWorkoutRepository: WorkoutRepository {
    func saveWorkout(_ workout: Workout) async throws {
        // Mock实现
    }

    func loadWorkouts() async throws -> [Workout] {
        // Mock数据返回
        return mockWorkouts
    }
}
```

### 3. Dependency Injection模式

```swift
@main
struct FitApp: App {
    @StateObject private var navigationManager = NavigationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationManager)
        }
    }
}
```

## 📚 第三方库管理

### 当前依赖

**系统框架**：
- SwiftUI - UI框架
- Combine - 响应式编程
- Foundation - 基础功能

**开发工具**：
- SwiftLint - 代码风格检查
- SwiftFormat - 代码格式化

### 未来可能的扩展

**数据持久化**：
- Core Data - 本地数据库
- SwiftData - Swift原生数据框架

**网络通信**：
- URLSession - 网络请求
- Alamofire - 网络库（可选）

**动画库**：
- Lottie - 复杂动画
- 系统动画API

## 🚀 部署架构

### 1. 构建配置

**Debug配置**：
- 启用调试信息
- 禁用优化
- 开启断言

**Release配置**：
- 启用优化
- 禁用调试信息
- 生产环境配置

### 2. 持续集成

**GitHub Actions工作流**：
- 代码质量检查
- 自动化测试
- 构建和部署

### 3. 部署目标

**TestFlight**：
- 内部测试版本
- 邀请制测试
- 快速迭代

**App Store**：
- 正式发布版本
- 审核流程
- 用户分发

## 🔧 架构决策记录

### ADR-001: 选择MVVM架构

**决策**：采用MVVM架构模式

**理由**：
- SwiftUI原生支持
- 清晰的职责分离
- 便于单元测试
- 社区成熟度高

**替代方案考虑**：
- MVC：过于简单，职责不清晰
- MVP：与SwiftUI不太契合
- VIPER：过于复杂，对小型应用过度设计

### ADR-002: 选择Mock数据作为初始数据源

**决策**：使用MockDataProvider作为初始数据源

**理由**：
- 快速开发原型
- 不依赖外部存储
- 便于UI开发和测试

**未来计划**：
- 实现Core Data持久化
- 支持iCloud同步
- 添加数据导入导出功能

### ADR-003: 采用SwiftUI作为UI框架

**决策**：使用SwiftUI作为UI框架

**理由**：
- 声明式UI开发
- 代码简洁易维护
- 原生性能支持
- 未来技术趋势

## 🎯 架构演进路线图

### Phase 1: MVP阶段（当前）
- [x] 基础MVVM架构
- [x] Mock数据支持
- [x] 核心训练功能

### Phase 2: 数据持久化
- [ ] Core Data集成
- [ ] 数据仓库实现
- [ ] 本地存储支持

### Phase 3: 高级功能
- [ ] 数据同步功能
- [ ] 云端备份
- [ ] 数据分析功能

### Phase 4: 扩展功能
- [ ] 社交功能
- [ ] 训练计划
- [ ] 数据可视化

---

这份架构文档为Fit应用提供了全面的技术地图，指导开发团队理解和维护应用的架构设计。
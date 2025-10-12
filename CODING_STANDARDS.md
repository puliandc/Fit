# Fit 应用编码规范

//created by Jason Lu on 09:17:00 10/12/2025

## 📝 命名规范

### 1. 文件命名

**Swift文件**：
- 使用PascalCase（首字母大写）
- 文件名与主要类型保持一致
- 视图文件以View结尾
- ViewModel文件以ViewModel结尾

```
Good:
- WorkoutScreen.swift
- WorkoutViewModel.swift
- NavigationManager.swift

Bad:
- workout_screen.swift
- workoutviewmodel.swift
- navigation_manager.swift
```

### 2. 类型和结构体命名

**使用PascalCase**：
```swift
// 结构体
struct WorkoutSet { }
struct UserProfile { }

// 类
class WorkoutViewModel: ObservableObject { }
class DataRepository { }

// 枚举
enum WorkoutState { }
enum AppError { }
```

### 3. 属性和方法命名

**使用camelCase**：
```swift
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var workoutSets: [WorkoutSet] = []

    func addWorkoutSet(weight: Double, reps: Int) {
        // 实现
    }

    private func validateInput(_ value: String) -> Bool {
        // 实现
    }
}
```

### 4. 常量命名

**使用camelCase，以k开头或全大写**：
```swift
// 推荐
let kMaxWorkoutSets = 100
let kDefaultRestTime = 60.0

// 或者
let MAX_WORKOUT_SETS = 100
let DEFAULT_REST_TIME = 60.0
```

### 5. 协议命名

**以Protocol结尾或描述性名称**：
```swift
protocol WorkoutRepositoryProtocol { }
protocol DataValidatable { }
```

## 🎨 SwiftUI使用规范

### 1. 视图组织

**单一职责原则**：
```swift
Good:
struct WorkoutSetView: View {
    let workoutSet: WorkoutSet
    var body: some View {
        // 只负责显示单个训练组
    }
}

Bad:
struct WorkoutAndHistoryView: View {
    // 混合了太多职责
}
```

### 2. 状态管理

**使用适当的状态管理器**：
```swift
struct WorkoutScreen: View {
    // 环境对象 - 全局状态
    @EnvironmentObject var navigationManager: NavigationManager

    // 状态对象 - 视图拥有的对象
    @StateObject private var viewModel = WorkoutViewModel()

    // 状态值 - 简单值
    @State private var showingEditDialog = false

    // 观察对象 - 外部对象
    @ObservedObject var workout: Workout
}
```

### 3. 视图修饰符链

**合理的修饰符分组**：
```swift
Text("开始训练")
    .font(.title2)
    .fontWeight(.semibold)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .frame(height: 50)
    .background(Color.blue)
    .cornerRadius(10)
    .padding(.horizontal)
```

### 4. 条件视图

**使用if-else而不是三元运算符**：
```swift
Good:
if viewModel.isLoading {
    ProgressView()
} else {
    WorkoutContentView()
}

Bad:
viewModel.isLoading ? ProgressView() : WorkoutContentView()
```

## 🏗️ 代码组织规范

### 1. 文件结构

```swift
//
//  FileName.swift
//  Fit
//
//  Created by 作者名 on 日期.
//

import SwiftUI
import Combine

// MARK: - Properties
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    // MARK: - Body
    var body: some View {
        // 视图内容
    }
}

// MARK: - Private Methods
private extension ContentView {
    func somePrivateMethod() {
        // 私有方法
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### 2. 代码分组

使用MARK注释组织代码：
```swift
// MARK: - Properties
// MARK: - Public Properties
// MARK: - Private Properties
// MARK: - Body
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Subviews
// MARK: - Computed Properties
// MARK: - Preview
```

### 3. 导入顺序

```swift
// 1. 系统框架
import SwiftUI
import Combine
import Foundation

// 2. 第三方框架
import Alamofire

// 3. 项目模块（如果有）
```

## 📐 格式化规范

### 1. 缩进

**使用4个空格，不使用Tab**：
```swift
struct WorkoutSet {
    let id: UUID
    let weight: Double
    let reps: Int

    func isValid() -> Bool {
        return weight >= 0 && reps > 0
    }
}
```

### 2. 行长度

**建议每行不超过100个字符**：
```swift
Good:
func addWorkoutSet(weight: Double, reps: Int) -> Bool {
    return validateWeight(weight) && validateReps(reps)
}

Bad:
func addWorkoutSetWithVeryLongParameterName(weight: Double, reps: Int, timestamp: Date, notes: String) -> Bool {
    return validateWeight(weight) && validateReps(reps) && validateTimestamp(timestamp) && validateNotes(notes)
}
```

### 3. 空行使用

**逻辑分组之间使用空行**：
```swift
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var sets: [WorkoutSet] = []

    // 公共方法
    func startWorkout() {
        // 实现
    }

    func addSet(weight: Double, reps: Int) {
        // 实现
    }

    // 私有方法
    private func validateInput() -> Bool {
        // 实现
    }
}
```

## 🔒 访问控制规范

### 1. 默认私有化

**使用最严格的访问级别**：
```swift
class WorkoutViewModel: ObservableObject {
    // 私有属性
    @Published private var sets: [WorkoutSet] = []

    // 私有方法
    private func validateWeight(_ weight: Double) -> Bool {
        return weight >= 0
    }

    // 公开接口
    func addSet(weight: Double, reps: Int) {
        if validateWeight(weight) && validateReps(reps) {
            // 添加组数
        }
    }
}
```

### 2. 访问级别选择

**private**: 只在当前类/结构体中使用
**fileprivate**: 只在当前文件中使用
**internal**: 模块内使用（默认）
**public**: 模块外使用

```swift
public struct Workout {
    public let id: UUID
    public let date: Date
    internal let sets: [WorkoutSet]
    fileprivate var metadata: [String: Any]
    private var internalState: String
}
```

## 🎯 特定场景规范

### 1. 错误处理

**使用Result类型**：
```swift
enum WorkoutError: Error, LocalizedError {
    case invalidWeight
    case invalidReps
    case workoutNotStarted

    var errorDescription: String? {
        switch self {
        case .invalidWeight:
            return "重量必须大于等于0"
        case .invalidReps:
            return "次数必须大于0"
        case .workoutNotStarted:
            return "请先开始训练"
        }
    }
}

func addSet(weight: Double, reps: Int) -> Result<Void, WorkoutError> {
    guard weight >= 0 else { return .failure(.invalidWeight) }
    guard reps > 0 else { return .failure(.invalidReps) }

    // 添加组数逻辑
    return .success(())
}
```

### 2. 网络请求（未来）

**使用async/await**：
```swift
func loadWorkouts() async throws -> [Workout] {
    guard let url = URL(string: "api/workouts") else {
        throw WorkoutError.invalidURL
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Workout].self, from: data)
}
```

### 3. 数据验证

**集中验证逻辑**：
```swift
struct WorkoutValidator {
    static func validate(weight: Double) -> Result<Void, WorkoutError> {
        guard weight >= 0 else { return .failure(.invalidWeight) }
        guard weight <= 1000 else { return .failure(.weightTooHeavy) }
        return .success(())
    }

    static func validate(reps: Int) -> Result<Void, WorkoutError> {
        guard reps > 0 else { return .failure(.invalidReps) }
        guard reps <= 1000 else { return .failure(.tooManyReps) }
        return .success(())
    }
}
```

## 🧪 测试代码规范

### 1. 单元测试

**测试命名**：
```swift
class WorkoutViewModelTests: XCTestCase {
    func testAddSet_WithValidData_ShouldAddSet() {
        // Given
        let viewModel = WorkoutViewModel()
        let weight = 50.0
        let reps = 10

        // When
        viewModel.addSet(weight: weight, reps: reps)

        // Then
        XCTAssertEqual(viewModel.sets.count, 1)
        XCTAssertEqual(viewModel.sets.first?.weight, weight)
        XCTAssertEqual(viewModel.sets.first?.reps, reps)
    }

    func testAddSet_WithInvalidWeight_ShouldNotAddSet() {
        // Given
        let viewModel = WorkoutViewModel()

        // When
        viewModel.addSet(weight: -10.0, reps: 10)

        // Then
        XCTAssertEqual(viewModel.sets.count, 0)
    }
}
```

### 2. UI测试

**测试命名和结构**：
```swift
class WorkoutScreenUITests: XCTestCase {
    func testStartWorkoutButton_ShouldNavigateToWorkoutScreen() {
        // Given
        let app = XCUIApplication()
        app.launch()

        // When
        app.buttons["开始训练"].tap()

        // Then
        XCTAssertTrue(app.navigationBars["训练记录"].exists)
    }
}
```

## 🔧 工具配置

### 1. SwiftLint配置

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional

line_length:
  warning: 100
  error: 120

function_body_length:
  warning: 50
  error: 100
```

### 2. SwiftFormat配置

```swift
// .swiftformat
--indent 4
--linebreaks crlf
--maxwidth 100
--commas always
--semicolons never
--self insert
```

## 📋 代码审查清单

### 提交前检查

- [ ] 代码符合命名规范
- [ ] 方法长度不超过50行
- [ ] 类/结构体职责单一
- [ ] 有适当的错误处理
- [ ] 有必要的注释
- [ ] 通过所有测试
- [ ] 通过SwiftLint检查
- [ ] 格式化代码

### 设计原则检查

- [ ] 遵循SOLID原则
- [ ] 依赖关系清晰
- [ ] 接口设计合理
- [ ] 状态管理正确
- [ ] 性能考虑合理

---

这份编码规范确保Fit项目代码的一致性、可读性和可维护性，为团队协作提供了统一的开发标准。
# Fit 应用 SwiftUI 设计指南

//created by Jason Lu on 14:45:00 10/12/2025

## 🎨 设计理念

Fit应用的设计理念是"专注、简洁、高效"，为用户提供无干扰的训练记录体验。

### 核心原则
- **专注训练**：界面元素服务于训练记录核心功能
- **操作简化**：减少用户认知负担，快速完成操作
- **反馈及时**：每个操作都有明确的视觉反馈
- **一致性**：保持整个应用的视觉和交互一致性

## 🎯 SwiftUI最佳实践

### 1. 视图架构原则

#### 单一职责原则
```swift
// ✅ 推荐：职责单一的视图
struct WorkoutSetRow: View {
    let workoutSet: WorkoutSet
    let onDelete: (WorkoutSet) -> Void

    var body: some View {
        // 只负责显示单个训练组数
    }
}

// ❌ 不推荐：职责混合的视图
struct WorkoutAndHistoryView: View {
    // 同时处理训练显示和历史记录，职责过多
}
```

#### 视图组合模式
```swift
// 复杂视图的组合示例
struct WorkoutScreen: View {
    @StateObject private var viewModel = WorkoutViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航区域
            WorkoutHeaderView(workout: viewModel.currentWorkout)

            // 主要内容区域
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 当前训练信息
                    CurrentExerciseView(exercise: viewModel.currentExercise)

                    // 训练组数列表
                    WorkoutSetsListView(sets: viewModel.sets)

                    // 操作按钮区域
                    ActionButtonsView(
                        onAddSet: viewModel.addSet,
                        onCompleteWorkout: viewModel.completeWorkout
                    )
                }
                .padding()
            }

            // 底部安全区域处理
            Color.clear.frame(height: safeAreaInsets.bottom)
        }
        .background(Color.systemBackground)
        .navigationBarHidden(true)
    }
}
```

### 2. 状态管理最佳实践

#### 状态来源选择指南
```swift
// @State - 视图内部状态
struct CounterView: View {
    @State private var count = 0  // 只在当前视图使用

    var body: some View {
        Button("+1") { count += 1 }
    }
}

// @StateObject - 视图拥有的对象
struct WorkoutScreen: View {
    @StateObject private var viewModel = WorkoutViewModel()
    // 视图创建并拥有ViewModel

    var body: some View {
        // UI实现
    }
}

// @ObservedObject - 外部对象
struct WorkoutSetRow: View {
    @ObservedObject var workoutSet: WorkoutSet
    // 对象由外部传入，视图只观察

    var body: some View {
        // UI实现
    }
}

// @EnvironmentObject - 全局环境对象
struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    // 全局共享的状态管理器

    var body: some View {
        // UI实现
    }
}
```

#### 计算属性优化
```swift
// ✅ 推荐：使用计算属性避免不必要的状态
struct WorkoutStatsView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var totalSets: Int {
        viewModel.sets.count
    }

    var totalVolume: Double {
        viewModel.sets.reduce(0) { $0 + $1.weight * Double($1.reps) }
    }

    var averageWeight: Double {
        guard !viewModel.sets.isEmpty else { return 0 }
        return viewModel.sets.map(\.weight).reduce(0, +) / Double(viewModel.sets.count)
    }

    var body: some View {
        VStack {
            StatItem(title: "组数", value: "\(totalSets)")
            StatItem(title: "总容量", value: "\(totalVolume, specifier: "%.1f")kg")
            StatItem(title: "平均重量", value: "\(averageWeight, specifier: "%.1f")kg")
        }
    }
}

// ❌ 不推荐：使用@State存储计算结果
struct WorkoutStatsView_Bad: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var totalSets: Int = 0  // 不必要的状态

    var body: some View {
        // 需要手动同步，容易出错
    }
}
```

### 3. 性能优化策略

#### 视图更新优化
```swift
// ✅ 推荐：避免不必要的视图重绘
struct OptimizedWorkoutList: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        List {
            ForEach(viewModel.sets) { set in
                WorkoutSetRow(set: set)
                    .id(set.id) // 明确指定id优化更新
            }
        }
    }
}

// ✅ 推荐：使用onAppear/onDisappear管理资源
struct ResourceManagedView: View {
    @StateObject private var dataLoader = DataLoader()

    var body: some View {
        VStack {
            if dataLoader.isLoading {
                ProgressView()
            } else {
                ContentView(data: dataLoader.data)
            }
        }
        .onAppear {
            dataLoader.load()
        }
        .onDisappear {
            dataLoader.cleanup()
        }
    }
}
```

#### 懒加载和分页
```swift
// ✅ 推荐：使用LazyVStack处理长列表
struct LazyWorkoutHistoryView: View {
    @StateObject private var viewModel = WorkoutHistoryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.workouts) { workout in
                    WorkoutHistoryRow(workout: workout)
                        .onAppear {
                            // 分页加载逻辑
                            if workout.id == viewModel.workouts.last?.id {
                                viewModel.loadMore()
                            }
                        }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }
}
```

## 🎨 设计系统实现

### 1. 颜色系统

#### 系统颜色适配
```swift
extension Color {
    // 系统背景色
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    // 系统文字色
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)

    // 应用主题色
    static let primary = Color.blue
    static let secondary = Color.gray
    static let accent = Color.orange

    // 状态色
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
}
```

#### 动态颜色支持
```swift
// 支持暗色模式的颜色定义
extension Color {
    static let adaptiveBackground = Color(
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemGray6
                : UIColor.systemBackground
        }
    )

    static let adaptiveText = Color(
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor.black
        }
    )
}
```

### 2. 字体系统

#### 字体层级定义
```swift
extension Font {
    // 标题字体
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)

    // 正文字体
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption

    // 特殊用途字体
    static let button = Font.headline.weight(.medium)
    static let input = Font.body
}
```

#### 动态字体支持
```swift
// 支持动态字体大小的文本组件
struct AdaptiveText: View {
    let text: String
    let style: Font.TextStyle

    var body: some View {
        Text(text)
            .font(.system(style))
            .minimumScaleFactor(0.8)
            .lineLimit(nil)
    }
}
```

### 3. 间距系统

#### 标准间距定义
```swift
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // 组件特定间距
    static let componentPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let buttonHeight: CGFloat = 50
    static let cornerRadius: CGFloat = 10
}
```

### 4. 组件库实现

#### 按钮组件
```swift
struct ActionButton: View {
    let title: String
    let style: Style
    let action: () -> Void
    @State private var isPressed = false

    enum Style {
        case primary    // 主要操作
        case secondary  // 次要操作
        case danger     // 危险操作
        case text       // 文本按钮

        var backgroundColor: Color {
            switch self {
            case .primary:
                return .primary
            case .secondary:
                return .secondary
            case .danger:
                return .error
            case .text:
                return .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .danger:
                return .white
            case .secondary:
                return .white
            case .text:
                return .primary
            }
        }

        var borderColor: Color? {
            switch self {
            case .text:
                return .primary
            default:
                return nil
            }
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.button)
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.buttonHeight)
                .background(style.backgroundColor)
                .cornerRadius(Spacing.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                        .stroke(style.borderColor ?? Color.clear, lineWidth: style.borderColor != nil ? 1 : 0)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
}
```

#### 输入框组件
```swift
struct NumberInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let validator: (String) -> Bool

    @State private var isValid = true
    @FocusState private var isFocused: Bool

    init(
        title: String,
        value: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .numberPad,
        validator: @escaping (String) -> Bool = { _ in true }
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.validator = validator
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondaryLabel)

            TextField(placeholder, text: $value)
                .font(.input)
                .keyboardType(keyboardType)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondarySystemBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValid ? Color.gray : Color.error, lineWidth: 1)
                        )
                )
                .focused($isFocused)
                .onChange(of: value) { newValue in
                    isValid = validator(newValue)
                }
        }
    }
}
```

#### 卡片组件
```swift
struct InfoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            content
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .fill(Color.secondarySystemBackground)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
```

## 🎭 交互设计模式

### 1. 导航模式

#### 程序化导航
```swift
struct NavigationManager: ObservableObject {
    @Published var currentScreen: Screen = .main
    @Published var navigationPath = NavigationPath()

    enum Screen {
        case main
        case workout(Workout)
        case history
        case settings
    }

    func navigate(to screen: Screen) {
        navigationPath.append(screen)
        currentScreen = screen
    }

    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

// 使用示例
struct MainScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            VStack {
                ActionButton(title: "开始训练", style: .primary) {
                    navigationManager.navigate(to: .workout(newWorkout))
                }
            }
            .navigationDestination(for: NavigationManager.Screen.self) { screen in
                switch screen {
                case .workout(let workout):
                    WorkoutScreen(workout: workout)
                case .history:
                    WorkoutHistoryView()
                default:
                    EmptyView()
                }
            }
        }
    }
}
```

### 2. 状态反馈模式

#### 加载状态
```swift
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondaryLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

#### 错误状态
```swift
struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.error)

            Text("出现错误")
                .font(.title2)
                .fontWeight(.semibold)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondaryLabel)
                .multilineTextAlignment(.center)

            ActionButton(title: "重试", style: .secondary, action: retry)
        }
        .padding(Spacing.lg)
    }
}
```

#### 空状态
```swift
struct EmptyStateView: View {
    let title: String
    let description: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        description: String,
        systemImage: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundColor(.tertiaryLabel)

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondaryLabel)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle,
               let action = action {
                ActionButton(title: actionTitle, style: .primary, action: action)
                    .padding(.top, Spacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }
}
```

### 3. 手势交互

#### 滑动删除
```swift
struct SwipeToDeleteRow: View {
    let item: WorkoutSet
    let onDelete: (WorkoutSet) -> Void

    var body: some View {
        WorkoutSetRow(set: item)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("删除") {
                    onDelete(item)
                }
                .tint(.error)
            }
    }
}
```

#### 长按上下文菜单
```swift
struct ContextMenuRow: View {
    let workoutSet: WorkoutSet
    let onEdit: (WorkoutSet) -> Void
    let onDelete: (WorkoutSet) -> Void

    var body: some View {
        WorkoutSetRow(set: workoutSet)
            .contextMenu {
                Button("编辑") {
                    onEdit(workoutSet)
                }

                Button("删除", role: .destructive) {
                    onDelete(workoutSet)
                }
            }
    }
}
```

## 📱 响应式设计

### 1. 屏幕适配

#### 尺寸类别检测
```swift
struct SizeClassReader: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            CompactLayoutView()
        } else {
            RegularLayoutView()
        }
    }
}
```

#### 自适应布局
```swift
struct AdaptiveGridView: View {
    let items: [WorkoutSet]
    @State private var columns: [GridItem] = []

    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: adaptiveColumns(for: geometry.size.width), spacing: Spacing.md) {
                ForEach(items) { item in
                    WorkoutSetCard(set: item)
                }
            }
        }
    }

    private func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let minItemWidth: CGFloat = 150
        let spacing: CGFloat = Spacing.md
        let columnCount = max(1, Int((width + spacing) / (minItemWidth + spacing)))

        return Array(repeating: GridItem(.flexible()), count: columnCount)
    }
}
```

### 2. 可访问性支持

#### VoiceOver支持
```swift
struct AccessibleWorkoutSetRow: View {
    let workoutSet: WorkoutSet

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(workoutSet.weight, specifier: "%.1f") kg")
                    .font(.headline)
                Text("\(workoutSet.reps) 次")
                    .font(.subheadline)
            }

            Spacer()

            Text(workoutSet.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondaryLabel)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("训练组数：重量 \(workoutSet.weight) 公斤，次数 \(workoutSet.reps)")
        .accessibilityHint("双击编辑，长按删除")
    }
}
```

#### 动态字体支持
```swift
struct DynamicFontText: View {
    let text: String
    let style: Font.TextStyle
    let maximumScaleFactor: CGFloat

    init(
        _ text: String,
        style: Font.TextStyle,
        maximumScaleFactor: CGFloat = 0.8
    ) {
        self.text = text
        self.style = style
        self.maximumScaleFactor = maximumScaleFactor
    }

    var body: some View {
        Text(text)
            .font(.system(style))
            .minimumScaleFactor(maximumScaleFactor)
            .lineLimit(1)
    }
}
```

## 🎯 动画和过渡

### 1. 页面转场动画
```swift
struct SlideTransition: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: isActive ? 0 : 300)
            .opacity(isActive ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

extension View {
    func slideTransition(isActive: Bool) -> some View {
        modifier(SlideTransition(isActive: isActive))
    }
}
```

### 2. 微交互动画
```swift
struct InteractiveButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.button)
                .foregroundColor(.white)
                .frame(width: 120, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(isPressed ? Color.blue.opacity(0.8) : Color.blue)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}
```

---

这份SwiftUI设计指南为Fit应用提供了完整的UI开发规范，确保应用界面的一致性、可访问性和用户体验的优秀性。
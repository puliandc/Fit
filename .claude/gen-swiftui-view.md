# SwiftUI 视图生成模板

//created by Jason Lu on 14:50:00 10/12/2025

## 📋 视图生成模板集合

本文档提供了Fit应用中常用SwiftUI视图的生成模板，帮助AI助手快速生成符合项目标准的代码。

## 🏗️ 基础视图模板

### 1. 简单视图模板

#### 模板：基础信息显示视图
```swift
struct [ViewName]: View {
    let [data]: [DataType]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text([title])
                .font(.headline)

            Text([content])
                .font(.body)
                .foregroundColor(.secondaryLabel)
        }
        .padding(Spacing.md)
    }
}

// 使用示例
struct WorkoutInfoView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(workout.date, style: .date)
                .font(.headline)

            Text("\(workout.sets.count) 组训练")
                .font(.body)
                .foregroundColor(.secondaryLabel)
        }
        .padding(Spacing.md)
    }
}
```

#### 模板：可交互视图
```swift
struct [ViewName]: View {
    @State private var [stateName]: [StateType]
    let [parameter]: [ParameterType]
    let [callback]: ([CallbackType]) -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            // 视图内容

            ActionButton(title: [buttonTitle], style: .primary) {
                [action]()
            }
        }
        .padding()
    }
}

// 使用示例
struct AddSetView: View {
    @State private var weight = ""
    @State private var reps = ""
    let onAdd: (Double, Int) -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            NumberInputField(
                title: "重量",
                value: $weight,
                placeholder: "请输入重量",
                keyboardType: .decimalPad
            )

            NumberInputField(
                title: "次数",
                value: $reps,
                placeholder: "请输入次数",
                keyboardType: .numberPad
            )

            ActionButton(title: "添加组数", style: .primary) {
                if let weightValue = Double(weight),
                   let repsValue = Int(reps) {
                    onAdd(weightValue, repsValue)
                }
            }
        }
        .padding()
    }
}
```

### 2. 列表视图模板

#### 模板：基础列表
```swift
struct [ListViewName]: View {
    let [items]: [ItemType]
    let [onDelete]: ((ItemType) -> Void)?

    var body: some View {
        List {
            ForEach([items]) { [item] in
                [RowView]([item])
                    .swipeActions(edge: .trailing) {
                        if let onDelete = onDelete {
                            Button("删除", role: .destructive) {
                                onDelete([item])
                            }
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

// 使用示例
struct WorkoutSetsList: View {
    let workoutSets: [WorkoutSet]
    let onDelete: (WorkoutSet) -> Void

    var body: some View {
        List {
            ForEach(workoutSets) { workoutSet in
                WorkoutSetRow(set: workoutSet)
                    .swipeActions(edge: .trailing) {
                        Button("删除", role: .destructive) {
                            onDelete(workoutSet)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}
```

#### 模板：懒加载列表
```swift
struct [LazyListViewName]: View {
    @StateObject private var viewModel = [ViewModelName]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.[items]) { [item] in
                    [RowView]([item])
                        .onAppear {
                            if [item].id == viewModel.[items].last?.id {
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
            .padding()
        }
        .onAppear {
            viewModel.loadInitial()
        }
    }
}

// 使用示例
struct WorkoutHistoryList: View {
    @StateObject private var viewModel = WorkoutHistoryViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.workouts) { workout in
                    WorkoutHistoryRow(workout: workout)
                        .onAppear {
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
            .padding()
        }
        .onAppear {
            viewModel.loadInitial()
        }
    }
}
```

### 3. 表单视图模板

#### 模板：输入表单
```swift
struct [FormViewName]: View {
    @State private var [field1]: String = ""
    @State private var [field2]: String = ""
    @State private var [field3]: [Type] = [defaultValue]

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case [field1Name]
        case [field2Name]
        case [field3Name]
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text([sectionTitle])) {
                    TextField([placeholder1], text: $[field1])
                        .focused($focusedField, equals: .[field1Name])

                    TextField([placeholder2], text: $[field2])
                        .focused($focusedField, equals: .[field2Name])

                    Picker([pickerTitle], selection: $[field3]) {
                        ForEach([options], id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .focused($focusedField, equals: .[field3Name])
                }
            }
            .navigationTitle([formTitle])
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("[submitTitle]") {
                        [submitAction]()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        ![field1].isEmpty && ![field2].isEmpty
    }

    private func [submitAction]() {
        // 提交逻辑
    }
}

// 使用示例
struct NewWorkoutForm: View {
    @State private var workoutName = ""
    @State private var selectedDate = Date()
    @State private var notes = ""

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name
        case notes
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("训练名称", text: $workoutName)
                        .focused($focusedField, equals: .name)

                    DatePicker("训练日期", selection: $selectedDate, displayedComponents: .date)

                    TextField("备注", text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("新建训练")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveWorkout()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !workoutName.isEmpty
    }

    private func saveWorkout() {
        // 保存逻辑
    }
}
```

## 🎨 组件化模板

### 1. 卡片组件模板

#### 模板：信息卡片
```swift
struct [CardName]: View {
    let [data]: [DataType]
    let [action]: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 卡片头部
            HStack {
                Text([title])
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if let action = [action] {
                    Button(action: action) {
                        Image(systemName: [systemImageName])
                            .foregroundColor(.secondary)
                    }
                }
            }

            // 卡片内容
            VStack(alignment: .leading, spacing: Spacing.xs) {
                [contentItems]
            }

            // 卡片底部（可选）
            if ![footerContent].isEmpty {
                Divider()

                HStack {
                    Text([footerText])
                        .font(.caption)
                        .foregroundColor(.secondaryLabel)

                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .fill(Color.secondarySystemBackground)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// 使用示例
struct WorkoutCard: View {
    let workout: Workout
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 卡片头部
            HStack {
                Text(workout.date, style: .date)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: onTap) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }

            // 卡片内容
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Label("\(workout.sets.count) 组", systemImage: "list.bullet")
                    Spacer()
                    Label(formatDuration(workout.duration), systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundColor(.secondaryLabel)

                if let notes = workout.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.tertiaryLabel)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .fill(Color.secondarySystemBackground)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}
```

### 2. 统计组件模板

#### 模板：数据统计卡片
```swift
struct [StatCardName]: View {
    let title: String
    let value: String
    let subtitle: String?
    let trend: Trend?
    let color: Color

    enum Trend {
        case up, down, stable

        var systemImage: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "minus"
            }
        }

        var color: Color {
            switch self {
            case .up: return .success
            case .down: return .error
            case .stable: return .secondary
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondaryLabel)

                Spacer()

                if let trend = trend {
                    Image(systemName: trend.systemImage)
                        .font(.caption)
                        .foregroundColor(trend.color)
                }
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.tertiaryLabel)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .fill(Color.secondarySystemBackground)
        )
    }
}

// 使用示例
struct WorkoutStatsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let trend: StatCard.Trend?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondaryLabel)

                Spacer()

                if let trend = trend {
                    Image(systemName: trend.systemImage)
                        .font(.caption)
                        .foregroundColor(trend.color)
                }
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.tertiaryLabel)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Spacing.cornerRadius)
                .fill(Color.secondarySystemBackground)
        )
    }
}
```

### 3. 对话框组件模板

#### 模板：确认对话框
```swift
struct [AlertDialogName]: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: Spacing.lg) {
                // 图标
                Image(systemName: [systemImageName])
                    .font(.system(size: 48))
                    .foregroundColor([iconColor])

                // 标题和消息
                VStack(spacing: Spacing.sm) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.body)
                        .foregroundColor(.secondaryLabel)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                }

                Spacer()

                // 按钮组
                VStack(spacing: Spacing.sm) {
                    ActionButton(title: primaryButtonTitle, style: .primary) {
                        primaryAction()
                        dismiss()
                    }

                    if let secondaryButtonTitle = secondaryButtonTitle,
                       let secondaryAction = secondaryAction {
                        ActionButton(title: secondaryButtonTitle, style: .secondary) {
                            secondaryAction()
                            dismiss()
                        }
                    }
                }
            }
            .padding(Spacing.lg)
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// 使用示例
struct DeleteWorkoutAlert: View {
    let workout: Workout
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: Spacing.lg) {
                // 图标
                Image(systemName: "trash")
                    .font(.system(size: 48))
                    .foregroundColor(.error)

                // 标题和消息
                VStack(spacing: Spacing.sm) {
                    Text("删除训练")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("确定要删除这次训练记录吗？此操作无法撤销。")
                        .font(.body)
                        .foregroundColor(.secondaryLabel)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                }

                Spacer()

                // 按钮组
                VStack(spacing: Spacing.sm) {
                    ActionButton(title: "删除", style: .danger) {
                        onDelete()
                        dismiss()
                    }

                    ActionButton(title: "取消", style: .secondary) {
                        dismiss()
                    }
                }
            }
            .padding(Spacing.lg)
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
```

## 🔄 ViewModel模板

### 1. 基础ViewModel模板
```swift
@MainActor
class [ViewModelName]: ObservableObject {
    // Published Properties
    @Published var [items]: [ItemType] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Private Properties
    private let [service]: [ServiceType]
    private var [task]: Task<Void, Never>?

    // Initialization
    init([service]: [ServiceType] = [ServiceType]()) {
        self.[service] = [service]
        loadInitialData()
    }

    deinit {
        [task]?.cancel()
    }

    // Public Methods
    func loadInitialData() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        [task] = Task {
            do {
                let result = try await [service].[method]()
                await MainActor.run {
                    self.[items] = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func [actionMethod]([parameters]) {
        // 方法实现
    }

    func refresh() {
        [task]?.cancel()
        loadInitialData()
    }
}

// 使用示例
@MainActor
class WorkoutHistoryViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let workoutService: WorkoutServiceProtocol
    private var loadTask: Task<Void, Never>?

    init(workoutService: WorkoutServiceProtocol = MockWorkoutService()) {
        self.workoutService = workoutService
        loadInitialData()
    }

    deinit {
        loadTask?.cancel()
    }

    func loadInitialData() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        loadTask = Task {
            do {
                let result = try await workoutService.getWorkoutHistory(
                    limit: 20,
                    offset: 0,
                    startDate: nil,
                    endDate: nil
                )
                await MainActor.run {
                    self.workouts = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func deleteWorkout(_ workout: Workout) {
        Task {
            do {
                try await workoutService.deleteWorkout(id: workout.id)
                await MainActor.run {
                    workouts.removeAll { $0.id == workout.id }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func refresh() {
        loadTask?.cancel()
        loadInitialData()
    }
}
```

## 📋 使用指南

### 1. 模板选择原则

**简单视图**：
- 使用基础视图模板
- 优先选择静态内容模板
- 避免过度复杂的状态管理

**复杂视图**：
- 使用组件化模板
- 拆分为多个子组件
- 合理使用ViewModel

**列表视图**：
- 数据量大时使用懒加载
- 考虑分页加载
- 添加加载状态和错误处理

### 2. 命名约定

**视图命名**：
- 使用描述性名称
- 以View结尾
- 遵循项目命名规范

**ViewModel命名**：
- 以ViewModel结尾
- 与对应视图名称匹配
- 体现业务逻辑职责

### 3. 性能考虑

**状态管理**：
- 合理使用@Published
- 避免不必要的视图更新
- 使用@State和@StateObject正确

**内存管理**：
- 及时取消异步任务
- 避免循环引用
- 合理使用@EnvironmentObject

---

这些模板为Fit应用的SwiftUI视图开发提供了标准化的起点，确保代码的一致性和质量。
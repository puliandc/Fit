# 健身应用 iOS UI 需求文档

## 1. 项目概述

### 1.1 应用简介
健身助手是一款基于 iOS 平台的健身训练应用，主要功能包括：
- 从 iOS 备忘录读取健身计划
- 执行结构化的训练计划
- 实时跟踪训练进度和时间
- 提供直观的用户界面和流畅的用户体验

### 1.2 目标平台
- **操作系统**: iOS 15.0+
- **设备**: iPhone (适配不同屏幕尺寸)
- **框架**: SwiftUI
- **设计语言**: 现代 iOS 设计规范

### 1.3 核心用户流程
1. **启动应用** → 显示主界面
2. **读取健身计划** → 从 iOS 备忘录获取训练数据
3. **开始训练** → 进入训练执行界面
4. **执行训练** → 完成各项动作训练
5. **训练完成** → 返回主界面

### 1.4 Q&A
**技术规格**:
  1. **iOS部署目标** - 无所谓，我的iPhone上是iOS 26.0版
  2. **设备支持** - 不需要支持iPad
  3. **性能要求** - 和react界面的动画流畅度类似即可
  **功能优先级**:
  4. **备忘录集成** - 可以后续版本添加，这个版本只实现UI界面和动画，达成figma 的React效果
  5. **数据持久化** - 需要本地存储训练历史
  6. **离线功能** - 应用全程都可以离线工作，不需要联网

  **内容资源**:
  7. **动作图片** - 动作图片后续我会提供
  8. **示例数据** - 下面是我 初步的健身计划模板，你看看还有什么需要补足的吗？
    - name: "杠铃卧推"
      type: "热身"
      sets: 1
      reps: "8"
      rest: 30
    - name: "杠铃卧推"
      type: "正式"
      sets: 4
      reps: "8"
      rest: 90
    - name: "哑铃飞鸟"
      sets: 3
      reps: "10"
      rest: 60
	——我需要能够区分三种类型：”热身组“，”正式组“，”超级组“。每个组之间还应该有组间休息，每个动作之间会有一个动作间休息（为了调整器械重量）
  7. **图标资源** - 我还没有应用图标和其他图标

  **用户体验**:
  8. **错误处理** - 备忘录读取失败时的用户体验流程。如果不存在名为GymPlan-Active的备忘录，则新建一个含示范模板的GymPlan-Active备忘录。如果已经有这个备忘录，但是读取出去的话，则将报错信息提示给用户。
  9. **空状态** - 没有读取成功健身计划则不允许开始健身计划。
  10. **引导流程** - 没有用户引导
      
    
   一切的核心都是为了确保下一个版本需求明确，内容最小，确保可以build成功。

## 2. UI 结构分析

### 2.1 应用架构
```
App (根视图)
├── MainScreen (主界面)
└── WorkoutScreen (训练界面)
    ├── CompletionDialog (完成记录对话框)
    ├── QuitDialog (放弃确认对话框)
    ├── SkipRestDialog (跳过休息对话框)
    ├── EditSetDialog (编辑参数对话框)
    └── WorkoutCompleteDialog (训练完成对话框)
```

### 2.2 屏幕尺寸适配
- **主要目标尺寸**: 393px × 852px (iPhone 14 Pro)
- **最小支持尺寸**: 375px × 667px (iPhone SE 2nd Gen)
- **最大支持尺寸**: 430px × 932px (iPhone 14 Plus)

## 3. 主界面 (MainScreen) 设计规范

### 3.1 布局结构
```
MainScreen
├── Header (头部区域)
│   ├── App Logo (动画图标)
│   ├── App Title (应用标题)
│   └── Subtitle (副标题)
├── Progress Indicator (步骤指示器)
├── Read Plan Section (读取计划区域)
│   ├── Section Header (区域标题)
│   ├── Description (描述文字)
│   ├── Action Button (操作按钮)
│   └── Status Display (状态显示)
├── Divider (分隔线)
└── Start Workout Section (开始训练区域)
    ├── Section Header (区域标题)
    ├── Description (描述文字)
    └── Action Button (操作按钮)
```

### 3.2 视觉设计规范

#### 3.2.1 背景设计
- **主背景**: 线性渐变
  - 浅色模式: `orange-50 → pink-50 → purple-100`
  - 深色模式: `gray-900 → gray-800`
- **动画背景**: 浮动光晕效果
  - 光晕 1: 橙色到粉色渐变圆形，模糊半径 3xl
  - 光晕 2: 紫色到蓝色渐变圆形，模糊半径 3xl
  - 动画时长: 18-20 秒循环

#### 3.2.2 配色方案
```swift
// 主题色
let primaryGradient = LinearGradient(
    colors: [Color.orange, Color.pink, Color.purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// 按钮配色
let blueButtonGradient = LinearGradient(
    colors: [Color.blue, Color.cyan],
    startPoint: .leading,
    endPoint: .trailing
)

let greenButtonGradient = LinearGradient(
    colors: [Color.green, Color.emerald],
    startPoint: .leading,
    endPoint: .trailing
)

// 状态色
let successColor = Color.green
let errorColor = Color.red
let warningColor = Color.orange
```

#### 3.2.3 字体规范
```swift
// 标题字体
.title1Font = Font.system(size: 28, weight: .bold)
.title2Font = Font.system(size: 20, weight: .semibold)
.title3Font = Font.system(size: 18, weight: .medium)

// 正文字体
.bodyFont = Font.system(size: 16, weight: .regular)
.captionFont = Font.system(size: 14, weight: .regular)
.smallFont = Font.system(size: 12, weight: .regular)
```

### 3.3 组件设计规范

#### 3.3.1 卡片组件 (Card)
```swift
struct GlassCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
```

#### 3.3.2 按钮组件 (Button)
```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isEnabled {
                            LinearGradient(
                                colors: [Color.orange, Color.pink, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: isEnabled ? Color.orange.opacity(0.3) : .clear, radius: 10)
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
```

### 3.4 动画规范

#### 3.4.1 入场动画
```swift
// 标题动画
.opacity(0)
.offset(y: -50)
.animation(.easeOut(duration: 0.6), value: isVisible)

// 卡片动画
.opacity(0)
.offset(y: 20)
.animation(.easeOut(duration: 0.5).delay(0.2), value: isVisible)

// 按钮动画
.scale(0)
.rotationEffect(.degrees(-180))
.animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
```

#### 3.4.2 循环动画
```swift
// Logo 脉动动画
.scaleEffect(isAnimating ? 1.1 : 1.0)
.opacity(isAnimating ? 0.5 : 1.0)
.animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)

// 光晕浮动动画
.offset(
    x: isAnimating ? 100 : 0,
    y: isAnimating ? 80 : 0
)
.scaleEffect(isAnimating ? 1.2 : 1.0)
.animation(.easeInOut(duration: 20.0).repeatForever(autoreverses: true), value: isAnimating)
```

## 4. 训练界面 (WorkoutScreen) 设计规范

### 4.1 布局结构
```
WorkoutScreen
├── Header (头部区域)
│   ├── Back Button (返回按钮)
│   ├── Workout Title (训练标题)
│   └── Progress Bar (进度条)
├── Rest Timer Overlay (休息时间覆盖层)
├── Exercise Content (训练内容区域)
│   ├── Exercise Image (动作图片)
│   ├── Exercise Info (动作信息)
│   │   ├── Exercise Name (动作名称)
│   │   ├── Exercise Timer (动作计时器)
│   │   ├── Set Counter (组数计数器)
│   │   ├── Rep Counter (次数计数器)
│   │   └── Weight Display (重量显示)
│   └── Edit Buttons (编辑按钮)
└── Bottom Action Area (底部操作区域)
    ├── Complete Button (完成按钮)
    └── Quit Button (放弃按钮)
```

### 4.2 视觉设计规范

#### 4.2.1 头部区域
```swift
struct WorkoutHeader: View {
    let progress: Double
    let workoutName: String
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Circle())

                Text(workoutName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()
            }

            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .clipShape(Capsule())

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .clipShape(Capsule())
                        .animation(.easeOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
```

#### 4.2.2 休息时间组件
```swift
struct RestTimerView: View {
    let timeLeft: Int
    let onSkip: () -> Void

    var body: some View {
        Button(action: onSkip) {
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 3.0).repeatForever(autoreverses: false), value: isAnimating)

                Text("休息时间: \(formatTime(timeLeft))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)

                Text("(点击跳过)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.orange.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .orange.opacity(0.2), radius: 10)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: timeLeft)
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

#### 4.2.3 动作信息卡片
```swift
struct ExerciseInfoCard: View {
    let exercise: WorkoutExercise
    let currentSet: Int
    let currentReps: Int
    let currentWeight: Int
    let elapsedTime: Int
    let onEditSet: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 动作名称
            Text(exercise.name)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // 动作计时器
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)

                Text("动作时间：")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)

                Text(formatTime(elapsedTime))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

            // 组数和次数
            HStack(spacing: 12) {
                // 组数
                VStack(spacing: 4) {
                    Image(systemName: "number")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)

                    Text("组数")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)

                    Text("\(currentSet) / \(exercise.sets)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

                // 次数 (可点击编辑)
                Button(action: onEditSet) {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "dumbbell")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)

                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.green.opacity(0.7))
                        }

                        Text("次数")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)

                        Text("\(currentReps)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.1), value: currentReps)
            }

            // 重量 (如果有)
            if currentWeight > 0 {
                Button(action: onEditSet) {
                    HStack(spacing: 8) {
                        Image(systemName: "scalemass")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.purple)

                        Image(systemName: "pencil")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.purple.opacity(0.7))

                        Text("重量：")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)

                        Text("\(currentWeight) kg")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.purple)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
    }
}
```

### 4.3 对话框设计规范

#### 4.3.1 通用对话框容器
```swift
struct GlassDialog<Content: View>: View {
    let title: String
    let content: Content

    var body: some View {
        VStack(spacing: 0) {
            // 头部
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)

            // 内容
            content
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 350)
    }
}
```

#### 4.3.2 完成记录对话框
```swift
struct CompletionDialog: View {
    @Binding var isPresented: Bool
    let defaultReps: Int
    let defaultWeight: Int
    let onConfirm: (Int, Double) -> Void

    @State private var reps: String = ""
    @State private var weight: String = ""

    var body: some View {
        GlassDialog(
            title: "记录完成情况",
            content: VStack(spacing: 16) {
                Text("请输入您实际完成的次数和重量")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // 次数输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("完成次数")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("0", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                }

                // 重量输入
                if defaultWeight > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("完成重量 (kg)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)

                        TextField("0.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                // 按钮
                HStack(spacing: 12) {
                    Button("取消") {
                        isPresented = false
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("确认") {
                        let repsValue = Int(reps) ?? 0
                        let weightValue = Double(weight) ?? 0.0
                        onConfirm(repsValue, weightValue)
                        isPresented = false
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        )
        .onAppear {
            reps = String(defaultReps)
            weight = String(defaultWeight)
        }
    }
}
```

## 5. 功能需求规范

### 5.1 状态管理

#### 5.1.1 主界面状态
```swift
class MainScreenViewModel: ObservableObject {
    @Published var hasWorkoutPlan: Bool = false
    @Published var planStatus: PlanStatus = .none
    @Published var errorCode: String = ""
    @Published var isReadingPlan: Bool = false

    enum PlanStatus {
        case none
        case success
        case error(String)
    }

    func readWorkoutPlan() async {
        isReadingPlan = true
        defer { isReadingPlan = false }

        do {
            // 从 iOS 备忘录读取计划
            let plan = try await MemoManager.shared.readWorkoutPlan()

            await MainActor.run {
                self.hasWorkoutPlan = true
                self.planStatus = .success
                self.errorCode = ""
            }
        } catch {
            await MainActor.run {
                self.hasWorkoutPlan = false
                self.planStatus = .error(error.localizedDescription)
                self.errorCode = extractErrorCode(from: error)
            }
        }
    }

    private func extractErrorCode(from error: Error) -> String {
        // 提取具体的错误代码
        if let memoError = error as? MemoError {
            return memoError.code
        }
        return "ERR_UNKNOWN"
    }
}
```

#### 5.1.2 训练界面状态
```swift
class WorkoutScreenViewModel: ObservableObject {
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var timeLeft: Int = 0
    @Published var isResting: Bool = false
    @Published var exerciseElapsedTime: Int = 0
    @Published var currentSetReps: Int = 0
    @Published var currentSetWeight: Double = 0.0
    @Published var showDialogs: Dialogs = Dialogs()

    struct Dialogs {
        var completion: Bool = false
        var quit: Bool = false
        var skipRest: Bool = false
        var editSet: Bool = false
        var workoutComplete: Bool = false
    }

    private let workoutPlan: WorkoutPlan
    private var exerciseStartTime: Date = Date()
    private var workoutStartTime: Date = Date()
    private var timer: Timer?

    init(workoutPlan: WorkoutPlan) {
        self.workoutPlan = workoutPlan
        setupInitialState()
    }

    func startExercise() {
        exerciseStartTime = Date()
        exerciseElapsedTime = 0
        startExerciseTimer()
    }

    func startRest() {
        isResting = true
        let currentExercise = workoutPlan.exercises[currentExerciseIndex]
        timeLeft = currentExercise.restTime
        startRestTimer()
    }

    func completeExercise(reps: Int, weight: Double) {
        // 处理训练完成逻辑
        if isLastSet && isLastExercise {
            finishWorkout()
        } else if isLastSet {
            nextExercise()
        } else {
            nextSet()
        }
    }

    private func startExerciseTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.exerciseElapsedTime += 1
        }
    }

    private func startRestTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                self.isResting = false
                self.startExercise()
            }
        }
    }
}
```

### 5.2 错误处理

#### 5.2.1 错误类型定义
```swift
enum FitnessAppError: LocalizedError {
    case memoNotFound
    case memoAccessDenied
    case memoFormatInvalid
    case networkError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .memoNotFound:
            return "未找到健身计划"
        case .memoAccessDenied:
            return "无法访问备忘录"
        case .memoFormatInvalid:
            return "健身计划格式错误"
        case .networkError:
            return "网络连接错误"
        case .unknownError:
            return "未知错误"
        }
    }

    var errorCode: String {
        switch self {
        case .memoNotFound:
            return "ERR_NOTE_NOT_FOUND_001"
        case .memoAccessDenied:
            return "ERR_NOTE_ACCESS_DENIED_002"
        case .memoFormatInvalid:
            return "ERR_NOTE_FORMAT_INVALID_003"
        case .networkError:
            return "ERR_NETWORK_ERROR_004"
        case .unknownError:
            return "ERR_UNKNOWN_ERROR_005"
        }
    }
}
```

#### 5.2.2 错误处理组件
```swift
struct ErrorView: View {
    let error: FitnessAppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)

                Text("读取失败：\(error.errorCode)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)

                Spacer()
            }

            if let description = error.errorDescription {
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Button("重试") {
                onRetry()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(12)
        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}
```

### 5.3 数据持久化

#### 5.3.1 健身计划数据模型
```swift
struct WorkoutPlan: Codable, Identifiable {
    let id = UUID()
    let name: String
    let exercises: [WorkoutExercise]
    let createdAt: Date
    let updatedAt: Date

    init(name: String, exercises: [WorkoutExercise]) {
        self.name = name
        self.exercises = exercises
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct WorkoutExercise: Codable, Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let sets: Int
    let reps: Int
    let weight: Double
    let restTime: Int // 秒

    // 可编辑的字段
    var completedReps: [Int] = []
    var completedWeights: [Double] = []
    var completedAt: [Date?] = []
}

struct WorkoutSession: Codable, Identifiable {
    let id = UUID()
    let workoutPlanId: UUID
    let startTime: Date
    var endTime: Date?
    var completedExercises: [CompletedExercise] = []

    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    var isCompleted: Bool {
        return endTime != nil
    }
}

struct CompletedExercise: Codable, Identifiable {
    let id = UUID()
    let exerciseId: UUID
    let completedSets: [CompletedSet]
    let startTime: Date
    let endTime: Date
}

struct CompletedSet: Codable, Identifiable {
    let id = UUID()
    let setNumber: Int
    let targetReps: Int
    let actualReps: Int
    let targetWeight: Double
    let actualWeight: Double
    let completedAt: Date
}
```

#### 5.3.2 本地存储管理
```swift
class WorkoutDataManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let workoutPlansKey = "workout_plans"
    private let workoutSessionsKey = "workout_sessions"

    @Published var workoutPlans: [WorkoutPlan] = []
    @Published var workoutSessions: [WorkoutSession] = []

    init() {
        loadData()
    }

    func saveWorkoutPlan(_ plan: WorkoutPlan) {
        if let index = workoutPlans.firstIndex(where: { $0.id == plan.id }) {
            workoutPlans[index] = plan
        } else {
            workoutPlans.append(plan)
        }
        saveData()
    }

    func saveWorkoutSession(_ session: WorkoutSession) {
        if let index = workoutSessions.firstIndex(where: { $0.id == session.id }) {
            workoutSessions[index] = session
        } else {
            workoutSessions.append(session)
        }
        saveData()
    }

    private func loadData() {
        if let plansData = userDefaults.data(forKey: workoutPlansKey),
           let plans = try? JSONDecoder().decode([WorkoutPlan].self, from: plansData) {
            workoutPlans = plans
        }

        if let sessionsData = userDefaults.data(forKey: workoutSessionsKey),
           let sessions = try? JSONDecoder().decode([WorkoutSession].self, from: sessionsData) {
            workoutSessions = sessions
        }
    }

    private func saveData() {
        if let plansData = try? JSONEncoder().encode(workoutPlans) {
            userDefaults.set(plansData, forKey: workoutPlansKey)
        }

        if let sessionsData = try? JSONEncoder().encode(workoutSessions) {
            userDefaults.set(sessionsData, forKey: workoutSessionsKey)
        }
    }
}
```

## 6. 技术实现说明

### 6.1 SwiftUI 迁移建议

#### 6.1.1 动画迁移
将 React 中的 Framer Motion 动画转换为 SwiftUI 动画：

```swift
// React 中的动画
<motion.div
  animate={{
    x: [0, 100, 0],
    y: [0, 80, 0],
    scale: [1, 1.2, 1],
  }}
  transition={{
    duration: 20,
    repeat: Infinity,
    ease: "easeInOut"
  }}
/>

// SwiftUI 对应实现
struct AnimatedBlob: View {
    @State private var animationOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blur(radius: 60)
            .scaleEffect(scale)
            .offset(animationOffset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 20.0)
                    .repeatForever(autoreverses: true)
                ) {
                    animationOffset = CGSize(width: 100, height: 80)
                    scale = 1.2
                }
            }
    }
}
```

#### 6.1.2 状态管理迁移
将 React 中的 useState 和 useEffect 迁移到 SwiftUI：

```swift
// React 中的状态管理
const [currentExerciseIndex, setCurrentExerciseIndex] = useState(0);
const [isResting, setIsResting] = useState(false);

useEffect(() => {
  let interval: NodeJS.Timeout;
  if (timeLeft > 0 && isResting) {
    interval = setInterval(() => {
      setTimeLeft((prev) => prev - 1);
    }, 1000);
  }
  return () => clearInterval(interval);
}, [timeLeft, isResting]);

// SwiftUI 对应实现
class WorkoutViewModel: ObservableObject {
    @Published var currentExerciseIndex: Int = 0
    @Published var isResting: Bool = false
    @Published var timeLeft: Int = 0

    private var timer: Timer?

    func startRestTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                self.isResting = false
            }
        }
    }
}
```

#### 6.1.3 样式迁移
将 Tailwind CSS 样式转换为 SwiftUI 修饰符：

```swift
// React 中的样式
className="bg-gradient-to-br from-orange-50 via-pink-50 to-purple-100 dark:from-gray-900 dark:to-gray-800"

// SwiftUI 对应实现
.background(
    LinearGradient(
        colors: colorScheme == .dark
            ? [Color.gray.opacity(0.9), Color.gray.opacity(0.8)]
            : [Color.orange.opacity(0.1), Color.pink.opacity(0.1), Color.purple.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
```

### 6.2 iOS 平台特性集成

#### 6.2.1 备忘录集成
```swift
import MemoKit

class MemoManager: ObservableObject {
    static let shared = MemoManager()

    func readWorkoutPlan() async throws -> WorkoutPlan {
        // 请求备忘录访问权限
        let hasPermission = await requestMemoAccess()
        guard hasPermission else {
            throw FitnessAppError.memoAccessDenied
        }

        // 读取备忘录内容
        let memoContent = try await fetchLatestWorkoutMemo()

        // 解析健身计划
        let workoutPlan = try parseWorkoutPlan(from: memoContent)

        return workoutPlan
    }

    private func requestMemoAccess() async -> Bool {
        // 实现备忘录权限请求
        return await withCheckedContinuation { continuation in
            // 请求权限的代码
        }
    }

    private func fetchLatestWorkoutMemo() async throws -> String {
        // 实现备忘录内容获取
        return ""
    }

    private func parseWorkoutPlan(from content: String) throws -> WorkoutPlan {
        // 实现健身计划解析逻辑
        throw FitnessAppError.memoFormatInvalid
    }
}
```

#### 6.2.2 触觉反馈集成
```swift
import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }

    func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }

    func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }

    func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}
```

#### 6.2.3 推送通知集成
```swift
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    func scheduleWorkoutReminder() {
        let content = UNMutableNotificationContent()
        content.title = "健身提醒"
        content.body = "该开始今天的训练了！"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "workout_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
```

### 6.3 性能优化建议

#### 6.3.1 图片加载优化
```swift
struct AsyncImageView: View {
    let url: URL?
    let placeholder: Image

    @State private var image: Image? = nil

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
        .clipped()
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = url else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.image = Image(uiImage: uiImage)
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}
```

#### 6.3.2 内存管理
```swift
class WorkoutSessionManager: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    func startWorkoutSession(plan: WorkoutPlan) {
        // 使用 weak 引用避免循环引用
        $currentExerciseIndex
            .sink { [weak self] index in
                self?.handleExerciseChange(index)
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
}
```

## 7. 测试要求

### 7.1 UI 测试
- 所有按钮的点击响应测试
- 动画流畅性测试
- 不同屏幕尺寸的适配测试
- 深色/浅色模式切换测试

### 7.2 功能测试
- 健身计划读取功能测试
- 训练流程完整性测试
- 数据持久化测试
- 错误处理测试

### 7.3 性能测试
- 内存使用情况测试
- 电池消耗测试
- 启动时间测试
- 滑动性能测试

## 8. 交付标准

### 8.1 代码质量
- 遵循 SwiftUI 最佳实践
- 代码注释完整
- 变量命名规范
- 模块化设计

### 8.2 用户体验
- 动画流畅自然
- 响应速度快
- 界面直观易用
- 错误提示友好

### 8.3 兼容性
- 支持 iOS 15.0+
- 适配 iPhone 所有尺寸
- 支持横竖屏切换
- 支持动态字体大小

---

## 附录

### A. 颜色定义
```swift
extension Color {
    static let appOrange = Color(red: 251/255, green: 146/255, blue: 60/255)
    static let appPink = Color(red: 236/255, green: 72/255, blue: 153/255)
    static let appPurple = Color(red: 139/255, green: 92/255, blue: 246/255)
    static let appBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    static let appCyan = Color(red: 6/255, green: 182/255, blue: 212/255)
    static let appGreen = Color(red: 34/255, green: 197/255, blue: 94/255)
    static let appEmerald = Color(red: 16/255, green: 185/255, blue: 129/255)
}
```

### B. 字体定义
```swift
extension Font {
    static let appTitle = Font.system(size: 28, weight: .bold)
    static let appHeadline = Font.system(size: 20, weight: .semibold)
    static let appSubheadline = Font.system(size: 18, weight: .medium)
    static let appBody = Font.system(size: 16, weight: .regular)
    static let appCaption = Font.system(size: 14, weight: .regular)
    static let appSmall = Font.system(size: 12, weight: .regular)
}
```

### C. 间距定义
```swift
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### D. 圆角定义
```swift
struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
    static let round: CGFloat = 9999
}
```

本需求文档基于 React 原型分析生成，为 iOS SwiftUI 开发提供详细的技术规范和实现指导。开发过程中应严格按照此文档执行，确保最终产品符合设计要求和质量标准。
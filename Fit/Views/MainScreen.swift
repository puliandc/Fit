//
//  MainScreen.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-01-10 - 基于Figma设计重新实现主界面
//

import SwiftUI

struct MainScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutSessionManager: WorkoutSessionManager
    @State private var hasWorkoutPlan: Bool = false
    @State private var isReadingPlan: Bool = false

    // 版本1.0: 外部训练计划服务集成
    @StateObject private var externalTrainingService = ExternalTrainingPlanService()

    // 版本1.1: 文件选择功能状态变量
    @State private var showFilePicker: Bool = false
    @State private var selectedFileURL: URL?
    @State private var fileSelectionError: String?

    
    var body: some View {
        ZStack {
            // 基于React设计的动画背景
            AnimatedBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // 顶部安全区域
                    Color.clear.frame(height: 20)

                    // 头部区域 - 基于React设计的LogoHeader
                    LogoHeader()

                    // 主要功能区域
                    VStack(spacing: 24) {
                        // 开始训练卡片 - 只在有计划时显示，放在最前面
                        if hasWorkoutPlan {
                            FeatureCard(
                                icon: "figure.run",
                                title: "开始训练",
                                subtitle: "开始训练吧！",
                                hasContent: false,
                                contentText: externalTrainingService.currentWorkoutPlan?.name ?? "准备就绪",
                                isLoading: false,
                                buttonText: "开始训练",
                                buttonAction: {
                                    // 版本1.2: 优先使用解析的训练计划，fallback到MockData
                                    let workoutPlan = externalTrainingService.currentWorkoutPlan ?? MockDataProvider.shared.sampleWorkoutPlans.first!

                                    // 使用新的WorkoutSessionManager启动训练
                                    workoutSessionManager.startWorkout(workoutPlan)
                                    navigationManager.navigateToWorkout(plan: workoutPlan)
                                },
                                cardColor: .appAccent,
                                delay: 0.2
                            )
                        }

                        // 训练计划摘要卡片 - 在有计划时显示
                        if hasWorkoutPlan, let workoutPlan = externalTrainingService.currentWorkoutPlan {
                            CompleteWorkoutPlanCard(workoutPlan: workoutPlan, delay: 0.3)
                        }

                        // 读取计划卡片 - 移到最底部
                        FeatureCard(
                            icon: "doc.text.fill",
                            title: "读取健身计划",
                            subtitle: "请选择健身计划",
                            hasContent: false,
                            contentText: hasWorkoutPlan ?
                                (externalTrainingService.currentWorkoutPlan?.name ?? "计划读取成功") :
                                "计划读取成功",
                            isLoading: isReadingPlan,
                            buttonText: hasWorkoutPlan ? "重新读取" : "读取计划",
                            buttonAction: {
                                if !isReadingPlan {
                                    readWorkoutPlan()
                                }
                            },
                            cardColor: .appPrimary,
                            delay: hasWorkoutPlan ? 0.4 : 0.2
                        )
                    }



                    // 底部空间
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            // .scrollIndicators(.hidden) // 暂时注释，需要iOS 16.0+支持
        }
        .onAppear {
            startAnimations()
        }
        // 版本1.1: 文件选择器集成
        .sheet(isPresented: $showFilePicker) {
            FilePickerView(
                isPresented: $showFilePicker,
                onFileSelected: { url in
                    handleFileSelection(url)
                },
                onError: { error in
                    handleFileSelectionError(error)
                }
            )
        }
        // 版本1.1: 文件选择错误提示
        .alert("文件选择错误", isPresented: .constant(fileSelectionError != nil)) {
            Button("确定") {
                fileSelectionError = nil
            }
        } message: {
            if let error = fileSelectionError {
                Text(error)
            }
        }
        // 版本1.2: JSON解析错误提示
        .alert("JSON解析错误", isPresented: .constant(externalTrainingService.errorMessage != nil)) {
            Button("确定") {
                externalTrainingService.clearError()
            }
        } message: {
            if let error = externalTrainingService.errorMessage {
                Text(error)
            }
        }
    }

    private func startAnimations() {
        // LogoHeader现在自己管理所有动画
        // MainScreen不再需要管理Header动画
    }

    private func readWorkoutPlan() {
        print("📱 用户点击文件选择按钮")
        print("📂 正在从下载文件夹打开文档选择器")

        // 版本1.1: 打开文件选择器而不是模拟处理
        showFilePicker = true
    }

    // 版本1.2: 处理文件选择成功
    private func handleFileSelection(_ url: URL) {
        print("👆 用户选择了文件: \(url.lastPathComponent)")
        print("📄 文件路径确认: \(url.path)")

        selectedFileURL = url
        isReadingPlan = true

        // 版本1.2: 使用外部服务处理选中的文件，进行实际JSON解析
        Task {
            await externalTrainingService.loadWorkoutPlan(from: url)

            // 版本1.2: 根据解析结果更新界面状态
            DispatchQueue.main.async {
                if externalTrainingService.currentWorkoutPlan != nil {
                    hasWorkoutPlan = true
                    print("✅ 版本1.2: JSON解析成功，训练计划已加载")
                } else if let error = externalTrainingService.errorMessage {
                    print("❌ 版本1.2: JSON解析失败: \(error)")
                    // 错误已经在服务中处理，这里不需要额外处理
                }

                isReadingPlan = false
            }
        }
    }

    // 版本1.1: 处理文件选择错误
    private func handleFileSelectionError(_ error: String) {
        print("❌ 文件选择出现错误: \(error)")
        fileSelectionError = error
        isReadingPlan = false
    }
}

// MARK: - Modern Background
struct ModernBackground: View {
    @State private var blob1Offset: CGSize = .zero
    @State private var blob1Scale: CGFloat = 1.0
    @State private var blob2Offset: CGSize = .zero
    @State private var blob2Scale: CGFloat = 1.0
    @State private var gradientRotation: Double = 0

    var body: some View {
        ZStack {
            // 主背景渐变
            LinearGradient.backgroundGradient
                .ignoresSafeArea()

            // 动态渐变叠加
            LinearGradient(
                colors: [
                    .primaryGradientStart.opacity(0.15),
                    .accentGradientStart.opacity(0.1),
                    .primaryGradientEnd.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(gradientRotation))
            .ignoresSafeArea()
            .animation(
                .linear(duration: 30.0).repeatForever(autoreverses: false),
                value: gradientRotation
            )

            // 动态光斑 1
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.primaryGradientStart.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 250
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(blob1Scale)
                .offset(blob1Offset)
                .blur(radius: 80)
                .animation(
                    .easeInOut(duration: 25.0)
                    .repeatForever(autoreverses: true),
                    value: blob1Offset
                )
                .animation(
                    .easeInOut(duration: 20.0)
                    .repeatForever(autoreverses: true),
                    value: blob1Scale
                )

            // 动态光斑 2
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.accentGradientStart.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 40,
                        endRadius: 200
                    )
                )
                .frame(width: 320, height: 320)
                .scaleEffect(blob2Scale)
                .offset(CGSize(width: -blob2Offset.width, height: -blob2Offset.height))
                .blur(radius: 70)
                .animation(
                    .easeInOut(duration: 22.0)
                    .repeatForever(autoreverses: true),
                    value: blob2Offset
                )
                .animation(
                    .easeInOut(duration: 18.0)
                    .repeatForever(autoreverses: true),
                    value: blob2Scale
                )

            // 细微纹理
            MeshGradientBackground()
                .opacity(0.03)
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation {
                blob1Offset = CGSize(width: 120, height: 100)
                blob1Scale = 1.3
                blob2Offset = CGSize(width: -100, height: 140)
                blob2Scale = 1.4
                gradientRotation = 360
            }
        }
    }
}

// MARK: - Mesh Gradient Background
struct MeshGradientBackground: View {
    var body: some View {
        // 创建细微的网格纹理
        Canvas { context, size in
            let gridSize: CGFloat = 40
            let columns = Int(size.width / gridSize)
            let rows = Int(size.height / gridSize)

            for i in 0..<columns {
                for j in 0..<rows {
                    let x = CGFloat(i) * gridSize
                    let y = CGFloat(j) * gridSize

                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x,
                            y: y,
                            width: 2,
                            height: 2
                        )),
                        with: .color(.appSurfaceLight)
                    )
                }
            }
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    @Binding var animationOffset: CGSize
    @Binding var scale: CGFloat
    @Binding var isAnimating: Bool
    @Binding var showContent: Bool

    var body: some View {
        VStack(spacing: 24) {
            // 应用Logo动画
            ZStack {
                // 背景光环
                Circle()
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.6 : 0.8)
                    .blur(radius: 20)
                    .animation(
                        .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                // 主Logo背景
                Circle()
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 88, height: 88)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .opacity(showContent ? 1.0 : 0)
                    .shadow(color: .primaryGradientStart.opacity(0.4), radius: 20, x: 0, y: 10)
                    .animation(
                        .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: showContent)

                // Logo图标
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.appText)
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1.0 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
            }

            // 应用标题
            VStack(spacing: 8) {
                Text("Fit")
                    .displayTitleStyle()
                    .scaleEffect(showContent ? 1.0 : 0.9)
                    .opacity(showContent ? 1.0 : 0)

                Text("你的智能健身助手")
                    .featureBodyStyle()
                    .scaleEffect(showContent ? 1.0 : 0.95)
                    .opacity(showContent ? 1.0 : 0)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: showContent)
        }
        .scaleEffect(scale)
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: scale)
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let hasContent: Bool
    let contentText: String
    let isLoading: Bool
    let buttonText: String
    let buttonAction: () -> Void
    let cardColor: Color
    let delay: Double

    @State private var isVisible: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200
    @State private var isHovered: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // 卡片头部
            HStack(alignment: .top, spacing: 16) {
                // 图标容器
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [cardColor, cardColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: pulseScale
                        )

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.appText)
                }

                // 标题和副标题
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(
                            title == "读取健身计划" ?
                            LinearGradient(
                                colors: [
                                    Color(red: 0.22, green: 0.51, blue: 0.96), // blue-600
                                    Color(red: 0.06, green: 0.75, blue: 0.82)  // cyan-600
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [
                                    Color(red: 0.95, green: 0.29, blue: 0.26), // orange-600 (开始训练)
                                    Color(red: 0.91, green: 0.15, blue: 0.46)  // pink-600
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text(subtitle)
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(
                            title == "读取健身计划" ?
                            Color(red: 0.439, green: 0.447, blue: 0.498) : // gray-600
                            .appTextSecondary
                        )
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            // 状态显示
            if hasContent {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.success)
                        .font(.system(size: 16, weight: .semibold))

                    Text(contentText)
                        .foregroundColor(.success)
                        .font(.system(size: 14, weight: .medium))

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.success.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .transition(.scale.combined(with: .opacity))
            }

            // 加载状态
            if isLoading {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .appTextSecondary))
                        .scaleEffect(0.8)

                    Text("正在读取...")
                        .foregroundColor(.appTextSecondary)
                        .font(.system(size: 14, weight: .medium))

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .transition(.opacity)
            }

            // 操作按钮
            ModernButton(
                text: buttonText,
                action: buttonAction,
                style: (title == "读取健身计划") ? .readPlan : .primary,
                isDisabled: isLoading,
                fullWidth: true
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.98, blue: 1.0),
                            Color(red: 0.95, green: 0.96, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    // 光泽动画覆盖层
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black,
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .animation(
                            .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                )
                .shadow(color: .appBackground.opacity(0.12), radius: 25, x: 0, y: 10)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .scaleEffect(isHovered ? 1.02 : 1.0) // 悬停时的缩放效果
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 20)
        .offset(y: isHovered ? -2 : 0) // 悬停时的轻微上移
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay), value: isVisible)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onAppear {
            withAnimation {
                isVisible = true
                pulseScale = 1.1
                // 启动光泽动画
                shimmerOffset = 200
            }
        }
        .onTapGesture {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Modern Button
struct ModernButton: View {
    let text: String
    let action: () -> Void
    let style: ModernButtonStyle
    let isDisabled: Bool
    let fullWidth: Bool

    @State private var isPressed: Bool = false

    enum ModernButtonStyle {
        case primary
        case secondary
        case disabled
        case readPlan // 新增读取计划专用样式
    }

    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if style == .primary {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                } else if style == .secondary {
                    Image(systemName: isDisabled ? "lock.circle.fill" : "play.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                } else {
                    Image(systemName: "hourglass.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                }

                Text(text)
                    .buttonPrimaryStyle()
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                buttonBackground
                    .scaleEffect(isPressed ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            )
            .foregroundColor(buttonTextColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: buttonShadowColor, radius: isPressed ? 5 : 15, x: 0, y: isPressed ? 3 : 8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    private var buttonBackground: some View {
        Group {
            switch style {
            case .primary:
                LinearGradient.accentGradient
            case .secondary:
                LinearGradient(
                    colors: [.appSurfaceElevated, .appSurfaceLight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .disabled:
                LinearGradient(
                    colors: [.appTextDisabled.opacity(0.3), .appTextDisabled.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .readPlan:
                // 参考React原型：蓝色到青色渐变
                LinearGradient(
                    colors: [
                        Color(red: 0.13, green: 0.59, blue: 0.95), // blue-500
                        Color(red: 0.06, green: 0.75, blue: 0.82)  // cyan-600
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var buttonTextColor: Color {
        switch style {
        case .primary:
            return .appText
        case .secondary:
            return isDisabled ? .appTextDisabled : .appText
        case .disabled:
            return .appTextDisabled
        case .readPlan:
            return .white // 读取计划按钮使用白色文字
        }
    }

    private var buttonShadowColor: Color {
        switch style {
        case .primary:
            return .accentGradientStart.opacity(0.4)
        case .secondary:
            return .appSurfaceElevated.opacity(0.3)
        case .disabled:
            return .clear
        case .readPlan:
            return Color(red: 0.13, green: 0.59, blue: 0.95).opacity(0.4) // blue-500 opacity
        }
    }
}


// MARK: - Complete Workout Plan Card (版本1.3)
struct CompleteWorkoutPlanCard: View {
    let workoutPlan: WorkoutPlan
    let delay: Double

    @State private var isVisible: Bool = false
    @State private var showAllExercises: Bool = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var isHovered: Bool = false

    // 计算动作数量（按不同的练习名称统计）
    private var exerciseCount: Int {
        let uniqueExerciseNames = Set(workoutPlan.exercises.map { $0.exercise.name })
        return uniqueExerciseNames.count
    }

    // 计算总组数（所有ExerciseSet的数量）
    private var totalSets: Int {
        workoutPlan.exercises.count
    }

    // 按动作名称分组汇总（保持原始顺序）
    private var groupedExercises: [(name: String, sets: Int, reps: Int)] {
        // 按练习名称分组，但保持原始顺序
        var seenNames: Set<String> = []
        var result: [(name: String, sets: Int, reps: Int)] = []

        for exercise in workoutPlan.exercises {
            let name = exercise.exercise.name
            if !seenNames.contains(name) {
                // 第一次遇到这个练习名称，添加到结果中
                seenNames.insert(name)
                let allSetsForExercise = workoutPlan.exercises.filter { $0.exercise.name == name }
                let sets = allSetsForExercise.count
                let reps = allSetsForExercise.first?.targetReps ?? 0
                result.append((name: name, sets: sets, reps: reps))
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 20) {
            // 卡片头部
            HStack(alignment: .top, spacing: 16) {
                // 图标容器
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.success, .success.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.appText)
                }

                // 标题和信息
                VStack(alignment: .leading, spacing: 4) {
                    Text("训练计划")
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.62, blue: 0.34), // green-600
                                    Color(red: 0.05, green: 0.75, blue: 0.41)  // emerald-600
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text(workoutPlan.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.success)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            // 训练统计信息
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // 动作数量
                    StatItem(
                        icon: "dumbbell.fill",
                        value: "\(exerciseCount)",
                        label: "动作数量",
                        color: .appPrimary
                    )

                    // 总组数
                    StatItem(
                        icon: "number.circle.fill",
                        value: "\(totalSets)",
                        label: "总组数",
                        color: .success
                    )

                    // 预估时长
                    StatItem(
                        icon: "clock.fill",
                        value: "\(workoutPlan.duration)分钟",
                        label: "预估时长",
                        color: .warning
                    )
                }
                .padding(.horizontal, 4)
            }

            // 练习项目列表
            VStack(spacing: 12) {
                HStack {
                    Text("练习项目")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appText)

                    Spacer()

                    // 展开/收起按钮
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAllExercises.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(showAllExercises ? "收起" : "展开")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appPrimary)

                            Image(systemName: showAllExercises ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appPrimary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if showAllExercises {
                    // 显示按动作分组的汇总列表
                    VStack(spacing: 6) {
                        ForEach(Array(groupedExercises.enumerated()), id: \.offset) { index, exercise in
                            HStack(spacing: 8) {
                                // 序号圆圈 - 使用指定的绿色
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(red: 0, green: 0.79, blue: 0.32))
                                        .frame(width: 24, height: 24)

                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 1, green: 1, blue: 1))
                                }

                                Text(exercise.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.22))
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("\(exercise.sets)组")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.51))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 1, green: 1, blue: 1).opacity(0.5))
                            )
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.98, blue: 1.0),
                            Color(red: 0.95, green: 0.96, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    // 光泽动画覆盖层
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black,
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .animation(
                            .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                )
                .shadow(color: .appBackground.opacity(0.12), radius: 25, x: 0, y: 10)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .scaleEffect(isHovered ? 1.02 : 1.0) // 悬停时的缩放效果
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 20)
        .offset(y: isHovered ? -2 : 0) // 悬停时的轻微上移
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay), value: isVisible)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onAppear {
            withAnimation {
                isVisible = true
                // 启动光泽动画
                shimmerOffset = 200
            }
        }
        .onTapGesture {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    @State private var isVisible: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Exercise Row (单个练习项目，匹配React原型)
struct ExerciseRow: View {
    let exerciseSet: ExerciseSet
    let index: Int

    var body: some View {
        HStack(spacing: 8) {
            // 序号圆圈 - 使用指定的绿色
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0, green: 0.79, blue: 0.32))
                    .frame(width: 24, height: 24)

                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 1, green: 1, blue: 1))
            }

            // 练习名称
            Text(exerciseSet.exercise.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.22))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 组数和次数信息 - 匹配React原型格式
            Text("\(exerciseSet.targetReps)次 × \(Int(exerciseSet.targetWeight))kg")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.51))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 1, green: 1, blue: 1).opacity(0.5))
        )
    }
}

// MARK: - Preview
#Preview {
    MainScreen()
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
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

    // 调试模式状态变量 - 仅在开发构建中可用
    #if DEBUG
    @State private var isDebugModeEnabled: Bool = false
    @State private var showDebugOptions: Bool = false
    #endif

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
                                hasContent: true,
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

                        // 版本1.3: 隐藏训练计划摘要卡片，保持界面简洁
                        // if hasWorkoutPlan, let workoutPlan = externalTrainingService.currentWorkoutPlan {
                        //     CompleteWorkoutPlanCard(workoutPlan: workoutPlan, delay: 0.3)
                        // }

                        // 读取计划卡片 - 移到最底部
                        FeatureCard(
                            icon: "doc.text.fill",
                            title: "读取健身计划",
                            subtitle: "请选择健身计划",
                            hasContent: hasWorkoutPlan,
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

                    #if DEBUG
                    // 调试模式区域 - 仅在开发构建中显示
                    if isDebugModeEnabled {
                        DebugModeSection(
                            showOptions: $showDebugOptions,
                            externalTrainingService: externalTrainingService,
                            onSimulateSuccess: {
                                print("🐛 DEBUG: Simulate success button clicked")
                                hasWorkoutPlan = true
                                print("🐛 DEBUG: hasWorkoutPlan set to true")
                            },
                            onDirectWorkout: {
                                print("🐛 DEBUG: Direct workout button clicked")

                                // 安全检查训练计划
                                guard let workoutPlan = MockDataProvider.shared.sampleWorkoutPlans.first else {
                                    print("🚨 ERROR: No workout plans available in MockDataProvider")
                                    return
                                }

                                print("🐛 DEBUG: Selected workout plan: \(workoutPlan.name)")
                                print("🐛 DEBUG: Workout plan has \(workoutPlan.exercises.count) exercises")

                                // 验证训练计划完整性
                                guard !workoutPlan.exercises.isEmpty else {
                                    print("🚨 ERROR: Workout plan has no exercises")
                                    return
                                }

                                print("🐛 DEBUG: Starting workout with safe validation...")
                                workoutSessionManager.startWorkout(workoutPlan)
                                navigationManager.navigateToWorkout(plan: workoutPlan)
                                print("🐛 DEBUG: Workout start command sent")
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    #endif

                    #if DEBUG
                    // 调试模式开关 - 仅在开发构建中显示
                    DebugModeToggle(
                        isEnabled: $isDebugModeEnabled,
                        onToggle: { enabled in
                            if !enabled {
                                showDebugOptions = false
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    #endif

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
                style: (title == "读取健身计划") ? .readPlan : (hasContent ? .primary : (isLoading ? .disabled : .secondary)),
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

// MARK: - Debug Mode Toggle
struct DebugModeToggle: View {
    @Binding var isEnabled: Bool
    let onToggle: (Bool) -> Void

    @State private var isVisible: Bool = false

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isEnabled.toggle()
                    onToggle(isEnabled)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isEnabled ? "ladybug.fill" : "ladybug")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isEnabled ? .warning : .appTextMuted)

                    Text("调试模式")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isEnabled ? .warning : .appTextMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isEnabled ? Color.warning.opacity(0.15) : Color.appSurfaceLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isEnabled ? Color.warning.opacity(0.3) : Color.glassBorder, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.5)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Debug Mode Section
struct DebugModeSection: View {
    @Binding var showOptions: Bool
    let externalTrainingService: ExternalTrainingPlanService
    let onSimulateSuccess: () -> Void
    let onDirectWorkout: () -> Void

    @State private var isVisible: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // 调试模式标题
            HStack {
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.warning)

                Text("调试功能")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appText)

                Spacer()

                // 展开/收起按钮
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showOptions.toggle()
                    }
                }) {
                    Image(systemName: showOptions ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // 调试选项
            if showOptions {
                VStack(spacing: 12) {
                    // 模拟读取成功按钮
                    DebugActionButton(
                        icon: "checkmark.circle.fill",
                        title: "模拟读取成功",
                        subtitle: "设置训练计划读取成功状态",
                        color: .success,
                        action: onSimulateSuccess
                    )

                    // 版本1.3完整训练计划解析测试按钮
                    DebugActionButton(
                        icon: "gear.circle.fill",
                        title: "版本1.3完整训练计划解析测试",
                        subtitle: "测试ExternalTrainingPlanService完整训练计划解析功能",
                        color: .warning,
                        action: {
                            print("🐛 DEBUG: 版本1.3 完整训练计划解析测试开始")
                            Task {
                                // 尝试读取test.json文件
                                let testPath = "/Users/lujiaxian/APP/Fit/test.json"
                                let testURL = URL(fileURLWithPath: testPath)
                                await externalTrainingService.loadWorkoutPlan(from: testURL)
                            }
                        }
                    )

                    // 显示当前训练计划完整信息按钮
                    DebugActionButton(
                        icon: "info.circle.fill",
                        title: "显示当前训练计划完整信息",
                        subtitle: "查看解析出的训练计划详细信息，包括所有练习项目和组数配置",
                        color: .appPrimary,
                        action: {
                            print("🐛 DEBUG: 显示当前训练计划完整信息")
                            if let workoutPlan = externalTrainingService.currentWorkoutPlan {
                                print("📋 === 训练计划基本信息 ===")
                                print("📋 训练计划名称: \(workoutPlan.name)")
                                print("📋 训练计划描述: \(workoutPlan.description)")
                                print("📋 训练类别: \(workoutPlan.category)")
                                print("📋 训练难度: \(workoutPlan.difficulty)")
                                print("📋 预估时长: \(workoutPlan.duration) 分钟")
                                print("📋 预估热量: \(workoutPlan.estimatedCalories) 卡路里")
                                print("📋 总训练组数: \(workoutPlan.exercises.count)")

                                // 按练习名称分组显示
                                let grouped = Dictionary(grouping: workoutPlan.exercises) { $0.exercise.name }
                                print("\n📋 === 练习项目详情 ===")

                                for (exerciseName, sets) in grouped.sorted(by: { $0.key < $1.key }) {
                                    print("🏋️ 练习项目: \(exerciseName)")
                                    print("  📊 组数: \(sets.count)")

                                    for (index, exerciseSet) in sets.enumerated() {
                                        print("    📝 第\(index + 1)组:")
                                        print("      目标次数: \(exerciseSet.targetReps)")
                                        print("      目标重量: \(exerciseSet.targetWeight) kg")
                                        print("      休息时间: \(exerciseSet.restTime) 秒")
                                        print("      练习类别: \(exerciseSet.exercise.category)")
                                        print("      主要肌群: \(exerciseSet.exercise.muscleGroups)")
                                        print("      使用器械: \(exerciseSet.exercise.equipment)")
                                    }
                                    print("")
                                }

                                print("📋 === 训练计划完整信息显示完成 ===")
                            } else {
                                print("📋 当前没有加载的训练计划")
                            }
                        }
                    )

                    // 直接进入训练按钮
                    DebugActionButton(
                        icon: "play.circle.fill",
                        title: "直接进入训练",
                        subtitle: "跳过读取步骤，直接开始训练",
                        color: .workoutColor,
                        action: onDirectWorkout
                    )

                    // 测试训练日志功能按钮
                    DebugActionButton(
                        icon: "doc.text.fill",
                        title: "测试训练日志功能",
                        subtitle: "创建示例训练日志并验证文件系统访问性",
                        color: .appPrimary,
                        action: {
                            print("🧪 开始测试训练日志功能...")
                            WorkoutLogTestHelper.testFileSystemAccess()

                            // 同时验证文件App访问性
                            let success = WorkoutLogTestHelper.verifyFileAppAccess()
                            if success {
                                print("✅ 示例日志已创建，请在文件App中查看")
                            }
                        }
                    )
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.warning.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.warning.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.warning.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Debug Action Button
struct DebugActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    @State private var isPressed: Bool = false
    @State private var isVisible: Bool = false

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }

                // 文本内容
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appText)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextMuted)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // 箭头图标
                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appSurfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
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
                    Text("训练计划已加载")
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
                    // 练习数量
                    StatItem(
                        icon: "dumbbell.fill",
                        value: "\(workoutPlan.exercises.count)",
                        label: "练习项目",
                        color: .appPrimary
                    )

                    // 总组数
                    StatItem(
                        icon: "number.circle.fill",
                        value: "\(workoutPlan.exercises.count)",
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
                    // 显示所有练习项目 - 匹配React原型的单个项目显示
                    VStack(spacing: 8) {
                        ForEach(0..<workoutPlan.exercises.count, id: \.self) { index in
                            ExerciseRow(
                                exerciseSet: workoutPlan.exercises[index],
                                index: index
                            )
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    // 默认不显示任何训练项目，只有点击展开后才显示
                    VStack(spacing: 8) {
                        // 空状态，不显示任何训练动作
                        HStack {
                            Text("点击展开查看训练动作")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
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
            // 序号圆圈 - 匹配React原型样式
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.05, green: 0.62, blue: 0.34), // green-500
                                Color(red: 0.05, green: 0.75, blue: 0.41)  // emerald-500
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)

                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }

            // 练习名称
            Text(exerciseSet.exercise.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 组数和次数信息 - 匹配React原型格式
            Text("\(exerciseSet.targetReps)次 × \(Int(exerciseSet.targetWeight))kg")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appSurfaceLight.opacity(0.5))
        )
    }
}

// MARK: - Preview
#Preview {
    MainScreen()
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
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
    @State private var hasWorkoutPlan: Bool = false
    @State private var isReadingPlan: Bool = false
    @State private var animationOffset: CGSize = .zero
    @State private var scale: CGFloat = 0.9
    @State private var isAnimating: Bool = false
    @State private var showContent: Bool = false

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
            // 现代化背景
            ModernBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // 顶部安全区域
                    Color.clear.frame(height: 20)

                    // 头部区域
                    HeaderSection(
                        animationOffset: $animationOffset,
                        scale: $scale,
                        isAnimating: $isAnimating,
                        showContent: $showContent
                    )

                    // 主要功能区域
                    VStack(spacing: 24) {
                        // 读取计划卡片
                        FeatureCard(
                            icon: "doc.text.fill",
                            title: "读取健身计划",
                            subtitle: "从 iOS 备忘录读取您的健身训练计划",
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
                            delay: 0.2
                        )

                        // 开始训练卡片
                        FeatureCard(
                            icon: "figure.run",
                            title: "开始训练",
                            subtitle: hasWorkoutPlan ? "您的健身计划已准备就绪，开始今天的训练吧！" : "请先读取健身计划以开始训练",
                            hasContent: hasWorkoutPlan,
                            contentText: hasWorkoutPlan ?
                                (externalTrainingService.currentWorkoutPlan?.name ?? "准备就绪") :
                                "准备就绪",
                            isLoading: false,
                            buttonText: "开始训练",
                            buttonAction: {
                                if hasWorkoutPlan {
                                    // 版本1.2: 优先使用解析的训练计划，fallback到MockData
                                    let workoutPlan = externalTrainingService.currentWorkoutPlan ?? MockDataProvider.shared.sampleWorkoutPlans.first!
                                    navigationManager.startWorkout(workoutPlan)
                                }
                            },
                            cardColor: .appAccent,
                            delay: 0.4
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
                                navigationManager.startWorkout(workoutPlan)
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
        // 延迟显示内容
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                showContent = true
                scale = 1.0
            }
        }

        // 背景动画
        withAnimation(.easeInOut(duration: 15.0).repeatForever(autoreverses: true)) {
            animationOffset = CGSize(width: 80, height: 60)
        }

        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
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
                        with: .color(.white)
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
                    .foregroundColor(.white)
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

    var body: some View {
        VStack(spacing: 20) {
            // 卡片头部
            HStack(spacing: 16) {
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
                        .foregroundColor(.white)
                }

                // 标题和副标题
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .featureTitleStyle()
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .featureBodyStyle()
                        .multilineTextAlignment(.leading)
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
                style: hasContent ? .primary : (isLoading ? .disabled : .secondary),
                isDisabled: isLoading,
                fullWidth: true
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient.surfaceGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
                .shadow(color: Color.glassShadowEffect, radius: 20, x: 0, y: 10)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
                pulseScale = 1.1
            }
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
            }
        }
    }

    private var buttonTextColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return isDisabled ? .appTextDisabled : .appText
        case .disabled:
            return .appTextDisabled
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

                    // 版本1.2架构测试按钮
                    DebugActionButton(
                        icon: "gear.circle.fill",
                        title: "版本1.2JSON解析测试",
                        subtitle: "测试ExternalTrainingPlanService JSON解析功能",
                        color: .warning,
                        action: {
                            print("🐛 DEBUG: 版本1.2 JSON解析测试开始")
                            Task {
                                // 尝试读取test.json文件
                                let testPath = "/Users/lujiaxian/APP/Fit/test.json"
                                let testURL = URL(fileURLWithPath: testPath)
                                await externalTrainingService.loadWorkoutPlan(from: testURL)
                            }
                        }
                    )

                    // 显示当前训练计划信息按钮
                    DebugActionButton(
                        icon: "info.circle.fill",
                        title: "显示当前训练计划信息",
                        subtitle: "查看解析出的训练计划详细信息",
                        color: .appPrimary,
                        action: {
                            print("🐛 DEBUG: 显示当前训练计划信息")
                            if let workoutPlan = externalTrainingService.currentWorkoutPlan {
                                print("📋 训练计划名称: \(workoutPlan.name)")
                                print("📋 训练计划描述: \(workoutPlan.description)")
                                print("📋 练习数量: \(workoutPlan.exercises.count)")
                                print("📋 预估时长: \(workoutPlan.duration) 分钟")
                                print("📋 预估热量: \(workoutPlan.estimatedCalories) 卡路里")

                                for (index, exerciseSet) in workoutPlan.exercises.enumerated() {
                                    print("  📝 练习 \(index + 1): \(exerciseSet.exercise.name)")
                                    print("    目标次数: \(exerciseSet.targetReps)")
                                    print("    目标重量: \(exerciseSet.targetWeight) kg")
                                    print("    休息时间: \(exerciseSet.restTime) 秒")
                                }
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

// MARK: - Preview
#Preview {
    MainScreen()
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
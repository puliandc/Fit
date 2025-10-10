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
                            contentText: "计划读取成功",
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
                            contentText: "准备就绪",
                            isLoading: false,
                            buttonText: "开始训练",
                            buttonAction: {
                                if hasWorkoutPlan {
                                    if let workoutPlan = MockDataProvider.shared.sampleWorkoutPlans.first {
                                        navigationManager.startWorkout(workoutPlan)
                                    }
                                }
                            },
                            cardColor: .appAccent,
                            delay: 0.4
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
        isReadingPlan = true

        // 模拟读取过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            hasWorkoutPlan = true
            isReadingPlan = false
        }
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

// MARK: - Preview
#Preview {
    MainScreen()
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
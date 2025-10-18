//
//  LogoHeader.swift
//  Fit
//
//  Created by Jason Lu on 10/16/2025.
//  Updated: 2025-10-18 16:19 - 调整动画效果组合
//  Based on React design specifications for MainScreen Logo Header
//

import SwiftUI

// MARK: - Logo Header Component
struct LogoHeader: View {
    // MARK: - Animation State Properties
    @State private var headerOpacity: Double = 0.0
    @State private var headerOffset: CGFloat = -50.0
    @State private var logoScale: CGFloat = 1.0
    @State private var logoRotation: Double = 0.0
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.8
    @State private var figureGlowScale: CGFloat = 1.0
    @State private var figureGlowOpacity: Double = 0.8
    @State private var titleOpacity: Double = 0.0
    @State private var subtitleOpacity: Double = 0.0

    // MARK: - Body
    var body: some View {
        // Header - 整体容器
        VStack(spacing: 0) {
            // Logo图标容器
            logoIconContainer

            // 主标题 "FIT"
            mainTitle

            // 副标题
            subtitle
        }
        .padding(.top, 40)    // 减少顶部padding
        .padding(.bottom, 16) // 减少底部padding
        .padding(.horizontal, 24) // px-6 (1.5rem)
        // .opacity(headerOpacity) - 已禁用容器入场动画，直接显示
        // .offset(y: headerOffset) - 已禁用容器入场动画，直接显示
        .zIndex(10)
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Logo Icon Container
    private var logoIconContainer: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo圆形背景 + 图标
            ZStack {
                // Logo圆形背景
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F97316"), // orange-500
                                Color(hex: "#EC4899")  // pink-500
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96) // w-24 h-24
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .scaleEffect(logoScale)
                    .rotationEffect(.degrees(logoRotation)) // 摇摆动画作用于整个Logo

                // 脉冲光晕效果 - 激进增强版
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#FFD700"), // 金色，更明显
                                Color(hex: "#FFA500"), // 橙色
                                Color(hex: "#FF6B6B"), // 红色
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 48
                        )
                    )
                    .frame(width: 110, height: 110) // 比背景更大
                    .scaleEffect(glowScale)
                    .opacity(glowOpacity)
                    .blur(radius: 3) // 减少模糊，更清晰

                // 小人图标光晕效果
                Image(systemName: "figure.run")
                    .font(.system(size: 48, weight: .semibold)) // 与原小人图标相同大小
                    .foregroundColor(.white) // 白色光晕
                    .scaleEffect(figureGlowScale)
                    .opacity(figureGlowOpacity)
                    // 取消模糊效果

                // Activity 图标
                Image(systemName: "figure.run")
                    .font(.system(size: 48, weight: .semibold)) // w-12 h-12 equivalent
                    .foregroundColor(.white)
                    .zIndex(10)
                    // 取消旋转动画，保持静止
            }
            .padding(.bottom, 12) // 减少Logo底部spacing

            Spacer()
        }
    }

    
    // MARK: - Main Title
    private var mainTitle: some View {
        Text("FIT")
            .font(.custom("Rounded Mplus 1c", size: 60))
            .fontWeight(.black) // 800 weight
            .tracking(-1.5) // tracking-tight
            .multilineTextAlignment(.center)
            .padding(.bottom, 8) // 减少标题底部spacing
            // .opacity(titleOpacity) - 主标题无动画，直接显示
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(hex: "#EA580C"), // orange-600
                        Color(hex: "#DB2777"), // pink-600
                        Color(hex: "#9333EA")  // purple-600
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .environment(\.colorScheme, .light) // 强制使用亮色主题
    }

    // MARK: - Subtitle
    private var subtitle: some View {
        Text("今天的燃动开始了")
            .font(.custom("PingFang SC", size: 16))
            .fontWeight(.semibold) // 600 weight
            .multilineTextAlignment(.center)
            .opacity(subtitleOpacity)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(hex: "#F97316"), // orange-500
                        Color(hex: "#EC4899"), // pink-500
                        Color(hex: "#A855F7")  // purple-500
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .environment(\.colorScheme, .light) // 强制使用亮色主题
    }

    // MARK: - Animation Control
    private func startAnimations() {
        // 整体容器入场动画 (0.6秒) - 已禁用
        /*
        withAnimation(.easeOut(duration: 0.6)) {
            headerOpacity = 1.0
            headerOffset = 0.0
        }
        */

        // Logo弹簧缩放动画 (延迟0.2秒) - 已禁用
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.15, blendDuration: 0)) {
                logoScale = 1.0
            }
        }
        */

        // Logo摇摆动画序列 - 4步循环
        animateLogoSwing()

        // Logo圆形光晕动画 (立即开始)
        withAnimation(
            .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            glowScale = 1.5
            glowOpacity = 0.0
        }


        // 主标题不使用淡入动画 - 直接显示
        // titleOpacity = 1.0 - 已禁用，主标题无动画

        // 小人图标光晕动画 (立即开始)
        withAnimation(
            .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            figureGlowScale = 1.5
            figureGlowOpacity = 0.0
        }

        // 副标题使用淡入动画 (延迟1.0秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 2.0)) {
                subtitleOpacity = 1.0
            }
        }
    }

    // MARK: - Logo Swing Animation
    private func animateLogoSwing() {
        // 第1步：顺时针旋转20度 (1秒)
        withAnimation(.easeInOut(duration: 1.0)) {
            logoRotation = 20.0
        }

        // 第2步：逆时针旋转20度 (1秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                logoRotation = -20.0
            }
        }

        // 第3步：回到初始位置 (1秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                logoRotation = 0.0
            }
        }

        // 第4步：逆时针旋转20度 (1秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                logoRotation = -20.0
            }
        }

        // 第5步：顺时针旋转20度 (1秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                logoRotation = 20.0
            }
        }

        // 第6步：回到初始位置 (1秒)，然后重新开始循环
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                logoRotation = 0.0
            }
        }

        // 循环播放整个动画序列
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            animateLogoSwing() // 递归调用，形成无限循环
        }
      }

    }

// MARK: - Font Extensions for Custom Fonts
extension Font {
    static func custom(_ name: String, size: CGFloat) -> Font {
        // 字体优先级：Rounded Mplus 1c → Nunito → SF Pro Rounded → system
        switch name {
        case "Rounded Mplus 1c":
            return .system(size: size, weight: .black, design: .rounded)
        case "PingFang SC":
            return .system(size: size, weight: .semibold, design: .default)
        default:
            return .system(size: size, weight: .regular)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        LogoHeader()
        Spacer()
    }
    .background(Color.gray.opacity(0.1))
}
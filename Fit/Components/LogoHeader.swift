//
//  LogoHeader.swift
//  Fit
//
//  Created by Jason Lu on 10/16/2025.
//  Based on React design specifications for MainScreen Logo Header
//

import SwiftUI

// MARK: - Logo Header Component
struct LogoHeader: View {
    // MARK: - Animation State Properties
    @State private var headerOpacity: Double = 0.0
    @State private var headerOffset: CGFloat = -50.0
    @State private var logoScale: CGFloat = 0.0
    @State private var logoRotation: Double = 0.0
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
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
        .opacity(headerOpacity)
        .offset(y: headerOffset)
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
                    .rotationEffect(.degrees(logoRotation))

                // 脉冲光晕效果
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FB923C"), // orange-400
                                Color(hex: "#F472B6")  // pink-400
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .scaleEffect(glowScale)
                    .opacity(glowOpacity)
                    .blur(radius: 15)

                // Activity 图标
                Image(systemName: "figure.run")
                    .font(.system(size: 48, weight: .semibold)) // w-12 h-12 equivalent
                    .foregroundColor(.white)
                    .zIndex(10)
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
            .opacity(titleOpacity)
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
        // 整体容器入场动画 (0.6秒)
        withAnimation(.easeOut(duration: 0.6)) {
            headerOpacity = 1.0
            headerOffset = 0.0
        }

        // Logo弹簧缩放动画 (延迟0.2秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.15, blendDuration: 0)) {
                logoScale = 1.0
            }
        }

        // Logo摇摆动画 (3秒循环) - 参考React原型：[0, 10, -10, 0]
        withAnimation(
            .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: false)
        ) {
            logoRotation = 10.0
        }

        // 脉冲光晕动画已注释 - 仅保留Logo摇摆动画
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(
                .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                glowScale = 1.2
                glowOpacity = 0.0
            }
        }
        */

        // 主标题和副标题不使用淡入动画 - 直接显示
        titleOpacity = 1.0
        subtitleOpacity = 1.0
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
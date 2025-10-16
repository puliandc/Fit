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
        .padding(.top, 56)    // pt-14 (3.5rem)
        .padding(.bottom, 24) // pb-6 (1.5rem)
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
            .padding(.bottom, 20) // mb-5

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
            .padding(.bottom, 12) // mb-3
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

        // Logo摇摆动画 (3秒循环)
        withAnimation(
            .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: false)
        ) {
            logoRotation = 10.0
        }

        // 持续摇摆动画
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.5)) {
                logoRotation = logoRotation == 0 ? 10 : -10
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    logoRotation = 0
                }
            }
        }

        // 脉冲光晕动画 (2秒循环)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2.0)) {
                glowScale = 1.2
                glowOpacity = 0.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    glowScale = 1.0
                    glowOpacity = 0.5
                }
            }
        }

        // 主标题淡入动画 (延迟0.4秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.8)) {
                titleOpacity = 1.0
            }
        }

        // 副标题淡入动画 (延迟0.5秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.8)) {
                subtitleOpacity = 1.0
            }
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
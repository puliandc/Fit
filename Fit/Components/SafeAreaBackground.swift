//
//  SafeAreaBackground.swift
//  Fit
//
//  Created by Jason Lu on 10/19/2025.
//  Architecture: 统一的安全区域背景处理组件，确保跨屏幕的一致性
//

import SwiftUI

// MARK: - Safe Area Background Component
struct SafeAreaBackground: View {
    var body: some View {
        // 使用与AnimatedBackground协调的基础渐变色
        LinearGradient(
            colors: [
                Color(hex: "#FFF7ED"), // orange-50 - 与AnimatedBackground的主色调协调
                Color(hex: "#FCE7F3"), // pink-50 - 提供温暖感
                Color(hex: "#F3E8FF")  // purple-100 - 增加层次感
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Enhanced Safe Area Background with System Fallback
struct EnhancedSafeAreaBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if colorScheme == .light {
                // 浅色模式：使用温暖的浅色调
                LinearGradient(
                    colors: [
                        Color(hex: "#FFF7ED"), // orange-50
                        Color(hex: "#FCE7F3"), // pink-50
                        Color(hex: "#F3E8FF")  // purple-100
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // 深色模式：使用协调的深色调
                LinearGradient(
                    colors: [
                        Color(hex: "#1C1917"), // stone-800
                        Color(hex: "#1E1B4B"), // indigo-950
                        Color(hex: "#18181B")  // zinc-900
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}

// MARK: - Header/Footer Safe Area Background
struct ComponentSafeAreaBackground: View {
    let opacity: Double
    let useMaterial: Bool

    init(opacity: Double = 0.9, useMaterial: Bool = true) {
        self.opacity = opacity
        self.useMaterial = useMaterial
    }

    var body: some View {
        // 统一的白色半透明背景，用于Header和Footer组件
        ZStack {
            if useMaterial {
                // 毛玻璃背景层
                Color.white.opacity(opacity)
                    .background(.ultraThinMaterial)
            } else {
                // 纯色背景层
                Color.white.opacity(opacity)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // 基础安全区域背景
        SafeAreaBackground()
            .frame(height: 100)
            .cornerRadius(12)

        // 增强安全区域背景
        EnhancedSafeAreaBackground()
            .frame(height: 100)
            .cornerRadius(12)

        // 组件安全区域背景
        ComponentSafeAreaBackground()
            .frame(height: 100)
            .cornerRadius(12)
    }
    .padding()
    .preferredColorScheme(.light)
}
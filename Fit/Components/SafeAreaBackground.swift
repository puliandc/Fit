//
//  SafeAreaBackground.swift
//  Fit
//
//  Created by Jason Lu on 10/19/2025.
//  Updated: 09:00:00 10/20/2025 by Jason Lu - 修复Header和Footer背景延伸问题
//  Architecture: 统一的安全区域背景处理组件，确保跨屏幕的一致性和安全区域延伸
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
    let extendToSafeArea: Bool
    let edge: Edge.Set

    init(opacity: Double = 0.9, useMaterial: Bool = true, extendToSafeArea: Bool = false, edge: Edge.Set = []) {
        self.opacity = opacity
        self.useMaterial = useMaterial
        self.extendToSafeArea = extendToSafeArea
        self.edge = edge
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
        .ignoresSafeArea(extendToSafeArea ? .all : [])
    }
}

// MARK: - Extended Header Background (向上延伸到安全区域)
struct ExtendedHeaderBackground: View {
    let opacity: Double
    let useMaterial: Bool
    let showBottomBorder: Bool

    init(opacity: Double = 0.9, useMaterial: Bool = true, showBottomBorder: Bool = true) {
        self.opacity = opacity
        self.useMaterial = useMaterial
        self.showBottomBorder = showBottomBorder
    }

    var body: some View {
        ZStack {
            // 白色半透明背景层
            Color.white.opacity(opacity)
                .background(.ultraThinMaterial)

            if showBottomBorder {
                // 延伸边框到整个宽度，避免视觉中断
                Rectangle()
                    .fill(Color.glassBorder)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .position(y: 0) // 相对于容器底部
            }
        }
        .ignoresSafeArea(edges: .top) // 向上延伸到顶部安全区域
    }
}

// MARK: - Extended Footer Background (向下延伸到安全区域)
struct ExtendedFooterBackground: View {
    let opacity: Double
    let useMaterial: Bool
    let showTopBorder: Bool

    init(opacity: Double = 0.9, useMaterial: Bool = true, showTopBorder: Bool = true) {
        self.opacity = opacity
        self.useMaterial = useMaterial
        self.showTopBorder = showTopBorder
    }

    var body: some View {
        ZStack {
            // 白色半透明背景层
            Color.white.opacity(opacity)
                .background(.ultraThinMaterial)

            if showTopBorder {
                // 延伸边框到整个宽度，避免视觉中断
                Rectangle()
                    .fill(Color.glassBorder)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .position(y: 0) // 相对于容器顶部
            }
        }
        .ignoresSafeArea(edges: .bottom) // 向下延伸到底部安全区域
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

        // 扩展Header背景 - 显示安全区域延伸效果
        VStack {
            Text("Header Background")
                .font(.headline)
                .foregroundColor(.primary)
                .padding()

            ZStack {
                // 模拟内容区域
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 60)
                    .padding(.horizontal)
            }
            .background(ExtendedHeaderBackground(showBottomBorder: true))
        }
        .frame(height: 120)
        .cornerRadius(12)

        // 扩展Footer背景 - 显示安全区域延伸效果
        VStack {
            ZStack {
                // 模拟内容区域
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.2))
                    .frame(height: 60)
                    .padding(.horizontal)
            }
            .background(ExtendedFooterBackground(showTopBorder: true))

            Text("Footer Background")
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
        }
        .frame(height: 120)
        .cornerRadius(12)
    }
    .padding()
    .preferredColorScheme(.light)
}
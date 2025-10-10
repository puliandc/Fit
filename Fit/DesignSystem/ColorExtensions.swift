//
//  ColorExtensions.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-01-10 - 基于Figma设计重新定义颜色系统
//

import SwiftUI

// MARK: - App Colors (基于Figma设计规范)
extension Color {
    // MARK: - Primary Colors - 深色主题渐变系统
    static let appPrimary = Color(hex: "#6366F1") // Indigo-500
    static let appPrimaryLight = Color(hex: "#818CF8") // Indigo-400
    static let appPrimaryDark = Color(hex: "#4F46E5") // Indigo-600

    // MARK: - Accent Colors - 功能性色彩
    static let appAccent = Color(hex: "#F97316") // Orange-500
    static let appAccentLight = Color(hex: "#FB923C") // Orange-400
    static let appAccentDark = Color(hex: "#EA580C") // Orange-600

    // MARK: - Background Colors - 深色背景系统
    static let appBackground = Color(hex: "#09090B") // Zinc-950
    static let appSurface = Color(hex: "#18181B") // Zinc-900
    static let appSurfaceLight = Color(hex: "#27272A") // Zinc-800
    static let appSurfaceElevated = Color(hex: "#3F3F46") // Zinc-700

    // MARK: - Text Colors - 文本层级
    static let appText = Color(hex: "#FAFAFA") // Zinc-50
    static let appTextSecondary = Color(hex: "#A1A1AA") // Zinc-400
    static let appTextMuted = Color(hex: "#71717A") // Zinc-500
    static let appTextDisabled = Color(hex: "#52525B") // Zinc-600

    // MARK: - Glass Effect Colors - 毛玻璃效果
    static let glassBackground = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    static let glassShadowEffect = Color.black.opacity(0.4)
    static let glassHighlight = Color.white.opacity(0.15)

    // MARK: - Status Colors - 状态色彩
    static let success = Color(hex: "#22C55E") // Green-500
    static let successLight = Color(hex: "#4ADE80") // Green-400
    static let warning = Color(hex: "#F59E0B") // Amber-500
    static let error = Color(hex: "#EF4444") // Red-500
    static let info = Color(hex: "#3B82F6") // Blue-500

    // MARK: - Gradient Colors - 渐变系统
    static let primaryGradientStart = Color(hex: "#6366F1") // Indigo
    static let primaryGradientEnd = Color(hex: "#A855F7") // Purple

    static let accentGradientStart = Color(hex: "#F97316") // Orange
    static let accentGradientEnd = Color(hex: "#EC4899") // Pink

    static let successGradientStart = Color(hex: "#22C55E") // Green
    static let successGradientEnd = Color(hex: "#14B8A6") // Teal

    // MARK: - Feature Colors - 功能特色色彩
    static let workoutColor = Color(hex: "#F97316") // Orange
    static let restColor = Color(hex: "#3B82F6") // Blue
    static let progressColor = Color(hex: "#A855F7") // Purple

    // MARK: - Animation Colors - 动画色彩
    static let pulseColor = Color(hex: "#A855F7") // Purple
    static let highlightColor = Color(hex: "#FCD34D") // Yellow
    static let shimmerColor = Color.white.opacity(0.3)
}

// MARK: - Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Extensions (基于Figma设计)
extension LinearGradient {
    // 主要渐变 - 用于重要元素
    static let primaryGradient = LinearGradient(
        colors: [.primaryGradientStart, .primaryGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 强调渐变 - 用于行动按钮
    static let accentGradient = LinearGradient(
        colors: [.accentGradientStart, .accentGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 成功渐变 - 用于完成状态
    static let successGradient = LinearGradient(
        colors: [.successGradientStart, .successGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 训练渐变 - 运动相关
    static let workoutGradient = LinearGradient(
        colors: [.workoutColor, .accentGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 休息渐变 - 休息相关
    static let restGradient = LinearGradient(
        colors: [.restColor, .info],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 毛玻璃渐变 - 背景装饰
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.04),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 背景渐变 - 主背景
    static let backgroundGradient = LinearGradient(
        colors: [.appBackground, .appSurface],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 表面渐变 - 卡片背景
    static let surfaceGradient = LinearGradient(
        colors: [.appSurface, .appSurfaceLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Shadow Extensions
extension Color {
    static let softShadow = Color.black.opacity(0.1)
    static let mediumShadow = Color.black.opacity(0.2)
    static let hardShadow = Color.black.opacity(0.3)

    static let glassShadow = Color.black.opacity(0.1)
    static let glowShadow = Color(hex: "#8B5CF6").opacity(0.3)
}

// MARK: - Color Schemes
extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Accessibility Colors
extension Color {
    static let accessibilityHighContrast = Color.black
    static let accessibilityReducedMotion = Color.gray
}
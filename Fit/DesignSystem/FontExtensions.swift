//
//  FontExtensions.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-01-14 - 精简字体系统，只保留实际使用的样式
//

import SwiftUI

// MARK: - App Fonts (基于Figma设计规范)
extension Font {
    // MARK: - Display Fonts - 标题字体层级
    static let displayLarge = Font.system(size: 56, weight: .bold, design: .rounded) // 主标题

    // MARK: - UI Fonts - 界面字体层级
    static let uiLarge = Font.system(size: 20, weight: .medium) // 大按钮

    // MARK: - Feature Fonts - 功能性字体
    static let featureTitle = Font.system(size: 20, weight: .bold) // 功能标题
    static let featureBody = Font.system(size: 16, weight: .medium) // 功能正文
}

// MARK: - Font Styles (基于Figma设计规范)
struct AppFontStyle {
    let font: Font
    let color: Color
    let lineHeight: CGFloat
    let letterSpacing: CGFloat

    // MARK: - Display Styles - 展示样式
    static let displayTitle = AppFontStyle(
        font: .displayLarge,
        color: .appText,
        lineHeight: 64,
        letterSpacing: -0.8
    )

    // MARK: - Feature Styles - 功能样式
    static let featureTitle = AppFontStyle(
        font: .featureTitle,
        color: .appText,
        lineHeight: 28,
        letterSpacing: -0.1
    )

    static let featureBody = AppFontStyle(
        font: .featureBody,
        color: .appTextSecondary,
        lineHeight: 24,
        letterSpacing: 0.1
    )

    // MARK: - UI Styles - 界面元素样式
    static let buttonPrimary = AppFontStyle(
        font: .uiLarge,
        color: .white,
        lineHeight: 24,
        letterSpacing: 0.5
    )
}

// MARK: - Text Style Extensions (基于Figma设计)
extension Text {
    // Display Styles
    func displayTitleStyle() -> some View {
        self
            .font(AppFontStyle.displayTitle.font)
            .foregroundColor(AppFontStyle.displayTitle.color)
            .lineSpacing(AppFontStyle.displayTitle.lineHeight - 56)
    }

    // Feature Styles
    func featureTitleStyle() -> some View {
        self
            .font(AppFontStyle.featureTitle.font)
            .foregroundColor(AppFontStyle.featureTitle.color)
            .lineSpacing(AppFontStyle.featureTitle.lineHeight - 20)
    }

    func featureBodyStyle() -> some View {
        self
            .font(AppFontStyle.featureBody.font)
            .foregroundColor(AppFontStyle.featureBody.color)
            .lineSpacing(AppFontStyle.featureBody.lineHeight - 16)
    }

    // UI Styles
    func buttonPrimaryStyle() -> some View {
        self
            .font(AppFontStyle.buttonPrimary.font)
            .foregroundColor(AppFontStyle.buttonPrimary.color)
            .lineSpacing(AppFontStyle.buttonPrimary.lineHeight - 20)
    }
}
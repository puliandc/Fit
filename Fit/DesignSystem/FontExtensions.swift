//
//  FontExtensions.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//  Updated: 2025-01-10 - 基于Figma设计重新定义字体系统
//

import SwiftUI

// MARK: - App Fonts (基于Figma设计规范)
extension Font {
    // MARK: - Display Fonts - 标题字体层级
    static let displayLarge = Font.system(size: 56, weight: .bold, design: .rounded) // 主标题
    static let displayMedium = Font.system(size: 40, weight: .bold, design: .rounded) // 大标题
    static let displaySmall = Font.system(size: 32, weight: .semibold, design: .rounded) // 中标题

    // MARK: - Headline Fonts - 头部字体层级
    static let headlineLarge = Font.system(size: 28, weight: .semibold) // 大标题
    static let headlineMedium = Font.system(size: 22, weight: .semibold) // 中标题
    static let headlineSmall = Font.system(size: 18, weight: .semibold) // 小标题

    // MARK: - Body Fonts - 正文字体层级
    static let bodyLarge = Font.system(size: 18, weight: .regular) // 大正文
    static let bodyMedium = Font.system(size: 16, weight: .regular) // 中正文
    static let bodySmall = Font.system(size: 14, weight: .regular) // 小正文

    // MARK: - UI Fonts - 界面字体层级
    static let uiLarge = Font.system(size: 20, weight: .medium) // 大按钮
    static let uiMedium = Font.system(size: 18, weight: .medium) // 中按钮
    static let uiSmall = Font.system(size: 16, weight: .medium) // 小按钮

    // MARK: - Caption Fonts - 说明文字层级
    static let captionLarge = Font.system(size: 14, weight: .medium) // 大说明
    static let captionMedium = Font.system(size: 12, weight: .medium) // 中说明
    static let captionSmall = Font.system(size: 10, weight: .medium) // 小说明

    // MARK: - Monospace Fonts - 等宽字体层级
    static let monoLarge = Font.system(size: 32, weight: .bold, design: .monospaced) // 大计时器
    static let monoMedium = Font.system(size: 24, weight: .semibold, design: .monospaced) // 中计时器
    static let monoSmall = Font.system(size: 18, weight: .medium, design: .monospaced) // 小计时器

    // MARK: - Feature Fonts - 功能性字体
    static let featureTitle = Font.system(size: 20, weight: .bold) // 功能标题
    static let featureBody = Font.system(size: 16, weight: .medium) // 功能正文
}

// MARK: - Font Weight Extensions (iOS 15.0+ Compatible)
extension Font.Weight {
    static let extraLight = Font.Weight.thin
    static let light = Font.Weight.light
    static let regular = Font.Weight.regular
    static let medium = Font.Weight.medium
    static let semibold = Font.Weight.semibold
    static let bold = Font.Weight.bold
    static let extraBold = Font.Weight.heavy
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

    static let displaySubtitle = AppFontStyle(
        font: .displayMedium,
        color: .appText,
        lineHeight: 48,
        letterSpacing: -0.5
    )

    // MARK: - Screen Styles - 界面标题样式
    static let screenTitle = AppFontStyle(
        font: .headlineLarge,
        color: .appText,
        lineHeight: 36,
        letterSpacing: -0.3
    )

    static let sectionTitle = AppFontStyle(
        font: .headlineMedium,
        color: .appText,
        lineHeight: 30,
        letterSpacing: -0.2
    )

    static let cardTitle = AppFontStyle(
        font: .headlineSmall,
        color: .appText,
        lineHeight: 26,
        letterSpacing: -0.1
    )

    // MARK: - Body Styles - 正文样式
    static let bodyText = AppFontStyle(
        font: .bodyLarge,
        color: .appText,
        lineHeight: 28,
        letterSpacing: 0
    )

    static let bodySecondary = AppFontStyle(
        font: .bodyMedium,
        color: .appTextSecondary,
        lineHeight: 24,
        letterSpacing: 0.1
    )

    static let bodySmall = AppFontStyle(
        font: .bodySmall,
        color: .appTextMuted,
        lineHeight: 20,
        letterSpacing: 0.2
    )

    // MARK: - UI Styles - 界面元素样式
    static let buttonPrimary = AppFontStyle(
        font: .uiLarge,
        color: .white,
        lineHeight: 24,
        letterSpacing: 0.5
    )

    static let buttonSecondary = AppFontStyle(
        font: .uiMedium,
        color: .appText,
        lineHeight: 22,
        letterSpacing: 0.3
    )

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

    // MARK: - Caption Styles - 说明文字样式
    static let captionText = AppFontStyle(
        font: .captionLarge,
        color: .appTextMuted,
        lineHeight: 18,
        letterSpacing: 0.3
    )

    static let captionSmall = AppFontStyle(
        font: .captionMedium,
        color: .appTextDisabled,
        lineHeight: 16,
        letterSpacing: 0.4
    )

    // MARK: - Timer Styles - 计时器样式
    static let timerLarge = AppFontStyle(
        font: .monoLarge,
        color: .appText,
        lineHeight: 40,
        letterSpacing: 0
    )

    static let timerMedium = AppFontStyle(
        font: .monoMedium,
        color: .appText,
        lineHeight: 32,
        letterSpacing: 0
    )

    static let timerSmall = AppFontStyle(
        font: .monoSmall,
        color: .appTextSecondary,
        lineHeight: 24,
        letterSpacing: 0.1
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

    func displaySubtitleStyle() -> some View {
        self
            .font(AppFontStyle.displaySubtitle.font)
            .foregroundColor(AppFontStyle.displaySubtitle.color)
            .lineSpacing(AppFontStyle.displaySubtitle.lineHeight - 40)
    }

    // Screen Title Styles
    func screenTitleStyle() -> some View {
        self
            .font(AppFontStyle.screenTitle.font)
            .foregroundColor(AppFontStyle.screenTitle.color)
            .lineSpacing(AppFontStyle.screenTitle.lineHeight - 28)
    }

    func sectionTitleStyle() -> some View {
        self
            .font(AppFontStyle.sectionTitle.font)
            .foregroundColor(AppFontStyle.sectionTitle.color)
            .lineSpacing(AppFontStyle.sectionTitle.lineHeight - 22)
    }

    func cardTitleStyle() -> some View {
        self
            .font(AppFontStyle.cardTitle.font)
            .foregroundColor(AppFontStyle.cardTitle.color)
            .lineSpacing(AppFontStyle.cardTitle.lineHeight - 18)
    }

    // Body Styles
    func bodyStyle() -> some View {
        self
            .font(AppFontStyle.bodyText.font)
            .foregroundColor(AppFontStyle.bodyText.color)
            .lineSpacing(AppFontStyle.bodyText.lineHeight - 18)
    }

    func bodySecondaryStyle() -> some View {
        self
            .font(AppFontStyle.bodySecondary.font)
            .foregroundColor(AppFontStyle.bodySecondary.color)
            .lineSpacing(AppFontStyle.bodySecondary.lineHeight - 16)
    }

    func bodySmallStyle() -> some View {
        self
            .font(AppFontStyle.bodySmall.font)
            .foregroundColor(AppFontStyle.bodySmall.color)
            .lineSpacing(AppFontStyle.bodySmall.lineHeight - 14)
    }

    // UI Styles
    func buttonPrimaryStyle() -> some View {
        self
            .font(AppFontStyle.buttonPrimary.font)
            .foregroundColor(AppFontStyle.buttonPrimary.color)
            .lineSpacing(AppFontStyle.buttonPrimary.lineHeight - 20)
    }

    func buttonSecondaryStyle() -> some View {
        self
            .font(AppFontStyle.buttonSecondary.font)
            .foregroundColor(AppFontStyle.buttonSecondary.color)
            .lineSpacing(AppFontStyle.buttonSecondary.lineHeight - 18)
    }

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

    // Caption Styles
    func captionStyle() -> some View {
        self
            .font(AppFontStyle.captionText.font)
            .foregroundColor(AppFontStyle.captionText.color)
            .lineSpacing(AppFontStyle.captionText.lineHeight - 14)
    }

    func captionSmallStyle() -> some View {
        self
            .font(AppFontStyle.captionSmall.font)
            .foregroundColor(AppFontStyle.captionSmall.color)
            .lineSpacing(AppFontStyle.captionSmall.lineHeight - 12)
    }

    // Timer Styles
    func timerLargeStyle() -> some View {
        self
            .font(AppFontStyle.timerLarge.font)
            .foregroundColor(AppFontStyle.timerLarge.color)
            .lineSpacing(AppFontStyle.timerLarge.lineHeight - 32)
    }

    func timerMediumStyle() -> some View {
        self
            .font(AppFontStyle.timerMedium.font)
            .foregroundColor(AppFontStyle.timerMedium.color)
            .lineSpacing(AppFontStyle.timerMedium.lineHeight - 24)
    }

    func timerSmallStyle() -> some View {
        self
            .font(AppFontStyle.timerSmall.font)
            .foregroundColor(AppFontStyle.timerSmall.color)
            .lineSpacing(AppFontStyle.timerSmall.lineHeight - 18)
    }
}
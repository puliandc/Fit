//
//  FontExtensions_Fixed.swift
//  Fit
//
//  Fixed version with fallback fonts and deployment target compatibility
//

import SwiftUI

// MARK: - App Fonts with Fallbacks (iOS 15.0+ Compatible)
extension Font {
    // MARK: - Display Fonts (Large Headings)
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 30, weight: .semibold, design: .rounded)

    // MARK: - Headline Fonts
    static let headlineLarge = Font.system(size: 24, weight: .semibold)
    static let headlineMedium = Font.system(size: 20, weight: .semibold)
    static let headlineSmall = Font.system(size: 18, weight: .semibold)

    // MARK: - Body Fonts
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)

    // MARK: - UI Fonts (Buttons, Labels)
    static let uiLarge = Font.system(size: 18, weight: .medium)
    static let uiMedium = Font.system(size: 16, weight: .medium)
    static let uiSmall = Font.system(size: 14, weight: .medium)

    // MARK: - Caption Fonts
    static let captionLarge = Font.system(size: 12, weight: .medium)
    static let captionMedium = Font.system(size: 10, weight: .medium)
    static let captionSmall = Font.system(size: 8, weight: .medium)

    // MARK: - Monospace Fonts (Numbers, Code)
    static let monoLarge = Font.system(size: 24, weight: .medium, design: .monospaced)
    static let monoMedium = Font.system(size: 18, weight: .medium, design: .monospaced)
    static let monoSmall = Font.system(size: 14, weight: .medium, design: .monospaced)
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

// MARK: - Font Styles (iOS 15.0+ Compatible)
struct AppFontStyle {
    let font: Font
    let color: Color
    let lineHeight: CGFloat
    let letterSpacing: CGFloat

    // MARK: - Predefined Styles
    static let displayTitle = AppFontStyle(
        font: .displayLarge,
        color: .appText,
        lineHeight: 56,
        letterSpacing: -0.5
    )

    static let screenTitle = AppFontStyle(
        font: .headlineLarge,
        color: .appText,
        lineHeight: 32,
        letterSpacing: -0.2
    )

    static let cardTitle = AppFontStyle(
        font: .headlineMedium,
        color: .appText,
        lineHeight: 28,
        letterSpacing: -0.1
    )

    static let bodyText = AppFontStyle(
        font: .bodyLarge,
        color: .appText,
        lineHeight: 24,
        letterSpacing: 0
    )

    static let secondaryText = AppFontStyle(
        font: .bodyMedium,
        color: .appTextSecondary,
        lineHeight: 20,
        letterSpacing: 0.1
    )

    static let captionText = AppFontStyle(
        font: .captionMedium,
        color: .appTextMuted,
        lineHeight: 16,
        letterSpacing: 0.2
    )

    static let buttonText = AppFontStyle(
        font: .uiMedium,
        color: .white,
        lineHeight: 20,
        letterSpacing: 0.5
    )

    static let timerText = AppFontStyle(
        font: .monoLarge,
        color: .appText,
        lineHeight: 32,
        letterSpacing: 0
    )
}

// MARK: - Text Style Extensions (iOS 15.0+ Compatible)
extension Text {
    func displayStyle() -> some View {
        self
            .font(AppFontStyle.displayTitle.font)
            .foregroundColor(AppFontStyle.displayTitle.color)
            .lineSpacing(AppFontStyle.displayTitle.lineHeight - 24)
    }

    func screenTitleStyle() -> some View {
        self
            .font(AppFontStyle.screenTitle.font)
            .foregroundColor(AppFontStyle.screenTitle.color)
            .lineSpacing(AppFontStyle.screenTitle.lineHeight - 24)
    }

    func cardTitleStyle() -> some View {
        self
            .font(AppFontStyle.cardTitle.font)
            .foregroundColor(AppFontStyle.cardTitle.color)
            .lineSpacing(AppFontStyle.cardTitle.lineHeight - 20)
    }

    func bodyStyle() -> some View {
        self
            .font(AppFontStyle.bodyText.font)
            .foregroundColor(AppFontStyle.bodyText.color)
            .lineSpacing(AppFontStyle.bodyText.lineHeight - 16)
    }

    func secondaryStyle() -> some View {
        self
            .font(AppFontStyle.secondaryText.font)
            .foregroundColor(AppFontStyle.secondaryText.color)
            .lineSpacing(AppFontStyle.secondaryText.lineHeight - 14)
    }

    func captionStyle() -> some View {
        self
            .font(AppFontStyle.captionText.font)
            .foregroundColor(AppFontStyle.captionText.color)
            .lineSpacing(AppFontStyle.captionText.lineHeight - 10)
    }

    func buttonStyle() -> some View {
        self
            .font(AppFontStyle.buttonText.font)
            .foregroundColor(AppFontStyle.buttonText.color)
            .lineSpacing(AppFontStyle.buttonText.lineHeight - 16)
    }

    func timerStyle() -> some View {
        self
            .font(AppFontStyle.timerText.font)
            .foregroundColor(AppFontStyle.timerText.color)
            .lineSpacing(AppFontStyle.timerText.lineHeight - 24)
    }
}
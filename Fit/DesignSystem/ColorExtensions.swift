//
//  ColorExtensions.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

// MARK: - App Colors
extension Color {
    // MARK: - Primary Colors
    static let appPrimary = Color(hex: "#4F46E5")
    static let appPrimaryLight = Color(hex: "#818CF8")
    static let appPrimaryDark = Color(hex: "#3730A3")

    // MARK: - Secondary Colors
    static let appSecondary = Color(hex: "#10B981")
    static let appSecondaryLight = Color(hex: "#34D399")
    static let appSecondaryDark = Color(hex: "#047857")

    // MARK: - Neutral Colors
    static let appBackground = Color(hex: "#0F172A")
    static let appSurface = Color(hex: "#1E293B")
    static let appSurfaceLight = Color(hex: "#334155")
    static let appText = Color(hex: "#F8FAFC")
    static let appTextSecondary = Color(hex: "#CBD5E1")
    static let appTextMuted = Color(hex: "#64748B")

    // MARK: - Glass Effect Colors
    static let glassBackground = Color.white.opacity(0.1)
    static let glassBorder = Color.white.opacity(0.2)
    static let glassShadowEffect = Color.black.opacity(0.3)

    // MARK: - Status Colors
    static let success = Color(hex: "#10B981")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")
    static let info = Color(hex: "#3B82F6")

    // MARK: - Gradient Colors
    static let gradientStart = Color(hex: "#667EEA")
    static let gradientEnd = Color(hex: "#764BA2")

    static let workoutGradientStart = Color(hex: "#F093FB")
    static let workoutGradientEnd = Color(hex: "#F5576C")

    static let restGradientStart = Color(hex: "#4FACFE")
    static let restGradientEnd = Color(hex: "#00F2FE")

    // MARK: - Animation Colors
    static let pulseColor = Color(hex: "#8B5CF6")
    static let highlightColor = Color(hex: "#FCD34D")
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

// MARK: - Gradient Extensions
extension LinearGradient {
    static let appGradient = LinearGradient(
        colors: [.gradientStart, .gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let workoutGradient = LinearGradient(
        colors: [.workoutGradientStart, .workoutGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let restGradient = LinearGradient(
        colors: [.restGradientStart, .restGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.1),
            Color.white.opacity(0.05),
            Color.clear
        ],
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
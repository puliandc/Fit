//
//  ActionButton.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void

    @State private var isPressed = false
    @State private var isHovered = false

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(iconFont)
                }

                Text(title)
                    .font(textFont)
                    .fontWeight(textWeight)
            }
            .foregroundColor(style.textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                ZStack {
                    // Background gradient or solid color
                    if style.hasGradient {
                        LinearGradient(
                            colors: style.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        style.backgroundColor
                    }

                    // Hover effect overlay
                    if isHovered {
                        style.hoverOverlay
                    }

                    // Pressed effect overlay
                    if isPressed {
                        style.pressedOverlay
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .shadow(
                color: style.shadowColor.opacity(isPressed ? 0.2 : (isHovered ? 0.4 : 0.3)),
                radius: isPressed ? 8 : (isHovered ? 16 : 12),
                x: 0,
                y: isPressed ? 2 : (isHovered ? 6 : 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }

            action()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }

    // MARK: - Computed Properties
    private var textFont: Font {
        switch size {
        case .small:
            return .captionLarge
        case .medium:
            return .uiMedium
        case .large:
            return .uiLarge
        }
    }

    private var iconFont: Font {
        switch size {
        case .small:
            return .captionLarge
        case .medium:
            return .bodyMedium
        case .large:
            return .headlineSmall
        }
    }

    private var textWeight: Font.Weight {
        switch size {
        case .small:
            return Font.Weight.medium
        case .medium:
            return Font.Weight.medium
        case .large:
            return Font.Weight.semibold
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small:
            return 8
        case .medium:
            return 12
        case .large:
            return 16
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return 12
        case .medium:
            return 20
        case .large:
            return 28
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small:
            return 6
        case .medium:
            return 10
        case .large:
            return 14
        }
    }
}

// MARK: - Button Style
extension ActionButton {
    enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case success
        case warning
        case error
        case glass
        case outline

        var backgroundColor: Color {
            switch self {
            case .primary:
                return .appPrimary
            case .secondary:
                return .appSecondary
            case .tertiary:
                return .appSurface
            case .success:
                return .success
            case .warning:
                return .warning
            case .error:
                return .error
            case .glass:
                return .glassBackground
            case .outline:
                return .clear
            }
        }

        var gradientColors: [Color] {
            switch self {
            case .primary:
                return [.appPrimary, .appPrimaryDark]
            case .secondary:
                return [.appSecondary, .appSecondaryDark]
            case .success:
                return [.success, .green]
            case .warning:
                return [.warning, .orange]
            case .error:
                return [.error, .red]
            case .glass:
                return [.glassBackground, .glassBackground.opacity(0.05)]
            default:
                return [backgroundColor]
            }
        }

        var hasGradient: Bool {
            switch self {
            case .primary, .secondary, .success, .warning, .error, .glass:
                return true
            default:
                return false
            }
        }

        var textColor: Color {
            switch self {
            case .primary, .secondary, .success, .warning, .error:
                return .white
            case .tertiary, .glass:
                return .appText
            case .outline:
                return .appPrimary
            }
        }

        var borderColor: Color {
            switch self {
            case .primary, .secondary, .success, .warning, .error:
                return .clear
            case .tertiary:
                return .appSurfaceLight
            case .glass:
                return .glassBorder
            case .outline:
                return .appPrimary
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .outline, .glass:
                return 1
            default:
                return 0
            }
        }

        var shadowColor: Color {
            switch self {
            case .primary:
                return .appPrimary.opacity(0.3)
            case .secondary:
                return .appSecondary.opacity(0.3)
            case .success:
                return .success.opacity(0.3)
            case .warning:
                return .warning.opacity(0.3)
            case .error:
                return .error.opacity(0.3)
            default:
                return .glassShadow
            }
        }

        var hoverOverlay: Color {
            switch self {
            case .primary:
                return .white.opacity(0.1)
            case .secondary:
                return .white.opacity(0.1)
            case .tertiary:
                return .appSurfaceLight.opacity(0.2)
            case .glass:
                return .white.opacity(0.05)
            default:
                return .clear
            }
        }

        var pressedOverlay: Color {
            switch self {
            case .primary:
                return .black.opacity(0.2)
            case .secondary:
                return .black.opacity(0.2)
            case .tertiary:
                return .appSurfaceLight.opacity(0.4)
            case .glass:
                return .white.opacity(0.1)
            default:
                return .clear
            }
        }
    }

    enum ButtonSize {
        case small
        case medium
        case large
    }
}

// MARK: - Convenience Initializers
extension ActionButton {
    static func primary(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(title, icon: icon, style: .primary, size: size, action: action)
    }

    static func secondary(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(title, icon: icon, style: .secondary, size: size, action: action)
    }

    static func glass(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(title, icon: icon, style: .glass, size: size, action: action)
    }

    static func outline(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(title, icon: icon, style: .outline, size: size, action: action)
    }

    static func success(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(title, icon: icon, style: .success, size: size, action: action)
    }

    static func warning(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(title, icon: icon, style: .warning, size: size, action: action)
    }

    static func error(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(title, icon: icon, style: .error, size: size, action: action)
    }
}

// MARK: - Specialized Action Buttons
struct WorkoutActionButton: View {
    let title: String
    let systemImage: String
    let isRunning: Bool
    let action: () -> Void

    @State private var pulseAnimation = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)

                Text(title)
                    .font(.headlineSmall)
                    .fontWeight(Font.Weight.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    LinearGradient.workoutGradient

                    if isRunning {
                        Circle()
                            .fill(.white.opacity(0.3))
                            .scaleEffect(pulseAnimation ? 1.5 : 0.8)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: .workoutGradientStart.opacity(0.4),
                radius: 20,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isRunning ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isRunning)
        .onAppear {
            if isRunning {
                pulseAnimation = true
            }
        }
        .onChange(of: isRunning) { newValue in
            pulseAnimation = newValue
        }
    }
}

struct IconActionButton: View {
    let systemImage: String
    let style: ActionButton.ButtonStyle
    let size: CGFloat
    let action: () -> Void

    @State private var isPressed = false
    @State private var isHovered = false

    init(
        systemImage: String,
        style: ActionButton.ButtonStyle = .glass,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: Font.Weight.medium))
                .foregroundColor(style.textColor)
                .frame(width: size, height: size)
                .background(
                    ZStack {
                        if style.hasGradient {
                            LinearGradient(
                                colors: style.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            style.backgroundColor
                        }

                        if isHovered {
                            style.hoverOverlay
                        }

                        if isPressed {
                            style.pressedOverlay
                        }
                    }
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(style.borderColor, lineWidth: style.borderWidth)
                )
                .shadow(
                    color: style.shadowColor.opacity(isPressed ? 0.2 : (isHovered ? 0.4 : 0.3)),
                    radius: isPressed ? 4 : (isHovered ? 8 : 6),
                    x: 0,
                    y: isPressed ? 1 : (isHovered ? 3 : 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }

            action()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Primary buttons
        ActionButton.primary("Primary Button", icon: "play.fill") { }
        ActionButton.primary("Large Primary", icon: "heart.fill", size: .large) { }
        ActionButton.primary("Small Primary", icon: "star.fill", size: .small) { }

        // Style variations
        ActionButton.secondary("Secondary Button", icon: "pause.fill") { }
        ActionButton.glass("Glass Button", icon: "glass") { }
        ActionButton.outline("Outline Button", icon: "square") { }
        ActionButton.success("Success", icon: "checkmark") { }
        ActionButton.warning("Warning", icon: "exclamationmark") { }
        ActionButton.error("Error", icon: "xmark") { }

        // Specialized buttons
        WorkoutActionButton(title: "Start Workout", systemImage: "play.fill", isRunning: false) { }
        WorkoutActionButton(title: "Running...", systemImage: "stop.fill", isRunning: true) { }

        HStack(spacing: 16) {
            IconActionButton(systemImage: "heart.fill", style: .glass) { }
            IconActionButton(systemImage: "plus", style: .primary) { }
            IconActionButton(systemImage: "pause", style: .secondary) { }
        }
    }
    .padding()
    .background(Color.appBackground)
}
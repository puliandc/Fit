//
//  GlassCard.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    let borderWidth: CGFloat
    let borderColor: Color
    let backgroundColor: Color

    init(
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        shadowRadius: CGFloat = 20,
        shadowOpacity: Double = 0.3,
        borderWidth: CGFloat = 1,
        borderColor: Color = .glassBorder,
        backgroundColor: Color = .glassBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Glass effect background
                    backgroundColor

                    // Gradient overlay for depth
                    LinearGradient.glassGradient

                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: .glassShadowEffect.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Glass Card Variants
extension GlassCard {
    // Small card for compact content
    init(
        style: CardStyle = .standard,
        @ViewBuilder content: () -> Content
    ) {
        switch style {
        case .small:
            self.init(
                cornerRadius: 12,
                padding: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
                shadowRadius: 12,
                shadowOpacity: 0.2,
                borderWidth: 1,
                content: content
            )
        case .large:
            self.init(
                cornerRadius: 20,
                padding: EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24),
                shadowRadius: 30,
                shadowOpacity: 0.4,
                borderWidth: 1,
                content: content
            )
        case .minimal:
            self.init(
                cornerRadius: 8,
                padding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
                shadowRadius: 8,
                shadowOpacity: 0.1,
                borderWidth: 0.5,
                borderColor: .glassBorder.opacity(0.3),
                backgroundColor: .glassBackground.opacity(0.05),
                content: content
            )
        case .interactive:
            self.init(
                cornerRadius: 16,
                padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
                shadowRadius: 25,
                shadowOpacity: 0.4,
                borderWidth: 1,
                borderColor: .glassBorder,
                backgroundColor: .glassBackground,
                content: content
            )
        default:
            self.init(content: content)
        }
    }
}

enum CardStyle {
    case standard
    case small
    case large
    case minimal
    case interactive
}

// MARK: - Glass Card Modifier
extension View {
    func glassCardStyle(
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        shadowRadius: CGFloat = 20,
        shadowOpacity: Double = 0.3,
        borderWidth: CGFloat = 1,
        borderColor: Color = .glassBorder,
        backgroundColor: Color = .glassBackground
    ) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            padding: padding,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity,
            borderWidth: borderWidth,
            borderColor: borderColor,
            backgroundColor: backgroundColor
        ))
    }
}

struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    let borderWidth: CGFloat
    let borderColor: Color
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    backgroundColor
                    LinearGradient.glassGradient
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: .glassShadowEffect.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Animated Glass Card
struct AnimatedGlassCard<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    @State private var isHovered = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GlassCard(
            cornerRadius: isPressed ? 14 : 16,
            shadowRadius: isPressed ? 15 : (isHovered ? 30 : 20),
            shadowOpacity: isPressed ? 0.2 : (isHovered ? 0.5 : 0.3),
            borderWidth: 1,
            borderColor: isHovered ? .glassBorder.opacity(0.5) : .glassBorder,
            backgroundColor: isPressed ? .glassBackground.opacity(0.15) : .glassBackground
        ) {
            content
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
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
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Glass Card with Blur Effect
struct BlurredGlassCard<Content: View>: View {
    let content: Content
    let blurRadius: CGFloat
    let vibrancy: Bool

    init(
        blurRadius: CGFloat = 20,
        vibrancy: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.blurRadius = blurRadius
        self.vibrancy = vibrancy
    }

    var body: some View {
        content
            .padding(16)
            .background(
                ZStack {
                    if vibrancy {
                        // Vibrancy effect for iOS
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .blur(radius: blurRadius)
                    } else {
                        // Regular blur effect
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .blur(radius: blurRadius)
                    }

                    LinearGradient.glassGradient
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: .glassShadowEffect,
                radius: 20,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Standard Glass Card")
                    .cardTitleStyle()
                Text("This is a standard glass card with blur effect and shadow")
                    .bodyStyle()
            }
        }

        GlassCard(style: .small) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Small Card")
                    .bodyStyle()
            }
        }

        GlassCard(style: .large) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Large Glass Card")
                    .cardTitleStyle()
                Text("This is a large glass card with more padding and space for detailed content.")
                    .bodyStyle()
                HStack {
                    Button("Action") { }
                        .buttonStyle(.borderedProminent)
                    Button("Secondary") { }
                        .buttonStyle(.bordered)
                }
            }
        }

        AnimatedGlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Interactive Card")
                    .cardTitleStyle()
                Text("Tap or hover to see the animation effects")
                    .bodySecondaryStyle()
            }
        }

        BlurredGlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Blurred Card")
                    .cardTitleStyle()
                Text("This card uses system blur effect for a more native feel")
                    .bodyStyle()
            }
        }
    }
    .padding()
    .background(Color.appBackground)
}
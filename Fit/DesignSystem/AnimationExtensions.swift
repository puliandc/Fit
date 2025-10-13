//
//  AnimationExtensions.swift
//  Fit
//
//  Created by 陆家贤 on 10/1/2025.
//  微动画和交互效果扩展
//

import SwiftUI

// MARK: - 动画扩展
extension View {
    // 弹性进入动画
    func elasticAppear(delay: Double = 0) -> some View {
        self
            .scaleEffect(0.8)
            .opacity(0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay), value: true)
    }

    // 滑动进入动画
    func slideIn(from edge: Edge = .bottom, delay: Double = 0) -> some View {
        self
            .offset(
                x: edge == .leading ? 50 : edge == .trailing ? -50 : 0,
                y: edge == .top ? 50 : edge == .bottom ? -50 : 0
            )
            .opacity(0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: true)
    }

    // 渐变显示动画
    func fadeIn(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .animation(.easeInOut(duration: 0.6).delay(delay), value: true)
    }

    // 脉冲动画
    func pulseAnimation(duration: Double = 2.0) -> some View {
        self
            .scaleEffect(1.0)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: true
            )
    }

    // 悬停效果
    func hoverEffect() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.2), value: true)
            .onHover { isHovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    // 在支持的平台实现悬停效果
                }
            }
    }

    // 按压反馈
    func pressFeedback() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: true)
    }

    // 闪烁效果
    func shimmerEffect() -> some View {
        self
            .overlay(
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(45))
                .offset(x: -200)
                .animation(
                    .linear(duration: 2.0).repeatForever(autoreverses: false),
                    value: true
                )
            )
            .clipped()
    }

    // 呼吸动画
    func breathingAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(
                .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                value: true
            )
    }

    // 摇摆动画
    func shakeAnimation() -> some View {
        self
            .rotationEffect(.degrees(0))
            .animation(
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                value: true
            )
    }
}

// MARK: - 按钮动画样式
struct AnimatedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - 触觉反馈管理器
class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()

    private init() {}

    // 轻微触觉反馈
    func lightImpact() {
        #if !os(macOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }

    // 中等触觉反馈
    func mediumImpact() {
        #if !os(macOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }

    // 强烈触觉反馈
    func heavyImpact() {
        #if !os(macOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        #endif
    }

    // 成功反馈
    func success() {
        #if !os(macOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        #endif
    }

    // 警告反馈
    func warning() {
        #if !os(macOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
        #endif
    }

    // 错误反馈
    func error() {
        #if !os(macOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
        #endif
    }

    // 选择反馈
    func selectionChanged() {
        #if !os(macOS)
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        #endif
    }
}

// MARK: - 自定义动画修饰符
struct SpringInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay), value: isVisible)
            .onAppear {
                withAnimation {
                    isVisible = true
                }
            }
    }
}

struct SlideInFromBottomModifier: ViewModifier {
    let delay: Double
    @State private var offset: CGFloat = 50
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: true)
            .onAppear {
                withAnimation {
                    offset = 0
                    opacity = 1
                }
            }
    }
}

// MARK: - 动画修饰符扩展
extension View {
    func springIn(delay: Double = 0) -> some View {
        modifier(SpringInModifier(delay: delay))
    }

    func slideInFromBottom(delay: Double = 0) -> some View {
        modifier(SlideInFromBottomModifier(delay: delay))
    }

    // 添加触觉反馈
    func withHaptic(_ feedbackType: HapticType) -> some View {
        self.onTapGesture {
            HapticFeedbackManager.shared.performFeedback(feedbackType)
        }
    }
}

// MARK: - 触觉反馈类型
enum HapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
}

extension HapticFeedbackManager {
    func performFeedback(_ type: HapticType) {
        switch type {
        case .light:
            lightImpact()
        case .medium:
            mediumImpact()
        case .heavy:
            heavyImpact()
        case .success:
            success()
        case .warning:
            warning()
        case .error:
            error()
        case .selection:
            selectionChanged()
        }
    }
}

// MARK: - 自定义转场动画
struct CustomTransitions {
    static let scaleAndFade = AnyTransition.asymmetric(
        insertion: .scale.combined(with: .opacity),
        removal: .opacity
    )

    static let slideAndFade = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .opacity
    )

    static let customSpring = AnyTransition.asymmetric(
        insertion: .scale.combined(with: .opacity),
        removal: .scale.combined(with: .opacity)
    )
}

// MARK: - 动画预设
struct AnimationPresets {
    static let quickSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let smoothSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let slowSpring = Animation.spring(response: 0.8, dampingFraction: 0.8)

    static let quickEase = Animation.easeInOut(duration: 0.2)
    static let smoothEase = Animation.easeInOut(duration: 0.4)
    static let slowEase = Animation.easeInOut(duration: 0.6)

    static let quickLinear = Animation.linear(duration: 0.2)
    static let smoothLinear = Animation.linear(duration: 0.4)
}
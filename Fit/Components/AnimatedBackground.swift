//
//  AnimatedBackground.swift
//  Fit
//
//  Created by Jason Lu on 10/16/2025.
//  Based on React design specifications for MainScreen background
//

import SwiftUI

// MARK: - Animated Background Component

struct AnimatedBackground: View
{
    // MARK: - Animation State Properties

    @State private var blob1Offset: CGSize = .zero
    @State private var blob1Scale: CGFloat = 1.0
    @State private var isLowPowerMode: Bool = false
    // 默认关闭背景动画以降低 GPU 占用；如需可在未来按需开启
    @State private var isAnimationEnabled: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View
    {
        ZStack
        {
            // 基础渐变背景容器 - 完全覆盖整个屏幕包括安全区域
            baseGradientBackground
            // 移除clipped()，让背景延伸到安全区域

            // 条件性显示动画模糊球层
            if isAnimationEnabled && !isLowPowerMode && !reduceMotion
            {
                animatedBlobLayer
                // 移除clipped()，让动画效果延伸到安全区域
            }
        }
        .onAppear
        {
            checkBatteryLevel()
            if reduceMotion
            {
                isAnimationEnabled = false
            }
            else
            {
                startAnimations()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification))
        { _ in
            checkBatteryLevel()
        }
        .onChange(of: reduceMotion)
        { _, newValue in
            if newValue
            {
                isAnimationEnabled = false
            }
            else
            {
                startAnimations()
            }
        }
    }

    // MARK: - Base Gradient Background

    private var baseGradientBackground: some View
    {
        LinearGradient(
            colors: [
                Color(hex: "#FFF7ED"), // orange-50
                Color(hex: "#FCE7F3"), // pink-50
                Color(hex: "#F3E8FF") // purple-100
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Animated Blob Layer

    private var animatedBlobLayer: some View
    {
        GeometryReader
        { geometry in
            // 简化为单个模糊球 - 左上角 橙粉色
            AnimatedBlob(
                colors: [
                    Color(hex: "#FDBA74").opacity(0.2), // 降低透明度 orange-300/20
                    Color(hex: "#F9A8D4").opacity(0.2) // 降低透明度 pink-300/20
                ],
                size: CGSize(width: 300, height: 300), // 减小尺寸
                position: CGPoint(
                    x: -geometry.size.width * 0.05, // left: -5% (减少偏移)
                    y: -geometry.size.height * 0.05 // top: -5% (减少偏移)
                ),
                offset: blob1Offset,
                scale: blob1Scale,
                blurRadius: 48 // 减小模糊半径
            )
        }
        .allowsHitTesting(false) // pointer-events-none equivalent
    }

    // MARK: - Animation Control

    private func startAnimations()
    {
        // 智能动画控制：根据电池状态和设置决定是否启动动画
        guard isAnimationEnabled, !isLowPowerMode, !reduceMotion else { return }

        // 简化的单球动画 (30秒周期，更慢的动画减少GPU负担)
        withAnimation(
            .easeInOut(duration: 30.0)
                .repeatForever(autoreverses: true)
        )
        {
            blob1Offset = CGSize(width: 60, height: 40) // 减小移动幅度
            blob1Scale = 1.1 // 减小缩放幅度
        }
    }

    // MARK: - Battery Level Detection

    private func checkBatteryLevel()
    {
        UIDevice.current.isBatteryMonitoringEnabled = true

        let batteryLevel = UIDevice.current.batteryLevel
        _ = UIDevice.current.batteryState

        // 低电量模式判断：电量低于20%或处于低功耗模式
        let isLowBattery = batteryLevel < 0.2 && batteryLevel != -1.0
        let isPowerSaver = ProcessInfo.processInfo.isLowPowerModeEnabled

        isLowPowerMode = isLowBattery || isPowerSaver

        // 如果进入低电量模式，停止动画
        if isLowPowerMode
        {
            isAnimationEnabled = false
        }
    }

    // MARK: - Public Animation Control

    func toggleAnimation()
    {
        isAnimationEnabled.toggle()
        if isAnimationEnabled, !reduceMotion
        {
            checkBatteryLevel() // 重新检查电池状态
            startAnimations()
        }
    }
}

// MARK: - Animated Blob Component

struct AnimatedBlob: View
{
    let colors: [Color]
    let size: CGSize
    let position: CGPoint
    let offset: CGSize
    let scale: CGFloat
    let blurRadius: CGFloat

    var body: some View
    {
        Circle()
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size.width, height: size.height)
            .position(position)
            .offset(offset)
            .scaleEffect(scale)
            .blur(radius: blurRadius)
    }
}

// MARK: - Preview

#Preview
{
    AnimatedBackground()
        .preferredColorScheme(.light)
}

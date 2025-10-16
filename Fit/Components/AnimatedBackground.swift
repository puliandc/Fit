//
//  AnimatedBackground.swift
//  Fit
//
//  Created by Jason Lu on 10/16/2025.
//  Based on React design specifications for MainScreen background
//

import SwiftUI

// MARK: - Animated Background Component
struct AnimatedBackground: View {
    // MARK: - Animation State Properties
    @State private var blob1Offset: CGSize = .zero
    @State private var blob1Scale: CGFloat = 1.0
    @State private var blob2Offset: CGSize = .zero
    @State private var blob2Scale: CGFloat = 1.0

    // MARK: - Body
    var body: some View {
        ZStack {
            // 基础渐变背景容器
            baseGradientBackground
                .ignoresSafeArea()

            // 动画模糊球层
            animatedBlobLayer
                .ignoresSafeArea()
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Base Gradient Background
    private var baseGradientBackground: some View {
        LinearGradient(
            colors: [
                Color(hex: "#FFF7ED"), // orange-50
                Color(hex: "#FCE7F3"), // pink-50
                Color(hex: "#F3E8FF")  // purple-100
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Animated Blob Layer
    private var animatedBlobLayer: some View {
        GeometryReader { geometry in
            ZStack {
                // 模糊球 1 - 左上角 橙粉色
                AnimatedBlob(
                    colors: [
                        Color(hex: "#FDBA74").opacity(0.3), // orange-300/30
                        Color(hex: "#F9A8D4").opacity(0.3)  // pink-300/30
                    ],
                    size: CGSize(width: 384, height: 384),
                    position: CGPoint(
                        x: -geometry.size.width * 0.1, // left: -10%
                        y: -geometry.size.height * 0.1  // top: -10%
                    ),
                    offset: blob1Offset,
                    scale: blob1Scale,
                    blurRadius: 64
                )

                // 模糊球 2 - 右下角 紫蓝色
                AnimatedBlob(
                    colors: [
                        Color(hex: "#D8B4FE").opacity(0.3), // purple-300/30
                        Color(hex: "#93C5FD").opacity(0.3)  // blue-300/30
                    ],
                    size: CGSize(width: 320, height: 320),
                    position: CGPoint(
                        x: geometry.size.width * 1.1,  // right: -10% (110% from left)
                        y: geometry.size.height * 1.1  // bottom: -10% (110% from top)
                    ),
                    offset: blob2Offset,
                    scale: blob2Scale,
                    blurRadius: 64
                )
            }
        }
        .allowsHitTesting(false) // pointer-events-none equivalent
    }

    // MARK: - Animation Control
    private func startAnimations() {
        // 模糊球 1 动画 (20秒周期)
        withAnimation(
            .easeInOut(duration: 20.0)
                .repeatForever(autoreverses: true)
        ) {
            blob1Offset = CGSize(width: 100, height: 80)
            blob1Scale = 1.2
        }

        // 模糊球 2 动画 (18秒周期，延迟2秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(
                .easeInOut(duration: 18.0)
                    .repeatForever(autoreverses: true)
            ) {
                blob2Offset = CGSize(width: -80, height: 100)
                blob2Scale = 1.3
            }
        }
    }
}

// MARK: - Animated Blob Component
struct AnimatedBlob: View {
    let colors: [Color]
    let size: CGSize
    let position: CGPoint
    let offset: CGSize
    let scale: CGFloat
    let blurRadius: CGFloat

    var body: some View {
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
#Preview {
    AnimatedBackground()
        .preferredColorScheme(.light)
}
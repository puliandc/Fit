//
//  ContentView.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack {
            // Background - use system color instead of custom extension to test
            Color.black.ignoresSafeArea()

            // Simple test content
            VStack(spacing: 20) {
                Text("Fit App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Text("UI Test - Version 0.2")
                    .font(.title2)
                    .foregroundColor(.gray)

                Text("If you can see this, the app is working!")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                Button(action: {
                    print("Button tapped!")
                }) {
                    Text("Test Button")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .padding()
        }
        .onAppear {
            print("🚀 Simple ContentView appeared successfully!")
            print("📱 NavigationManager state: \(navigationManager.currentScreen)")
        }
    }
}

// MARK: - Extensions for WorkoutCategory (keeping existing code)
extension WorkoutCategory {
    var systemImage: String {
        switch self {
        case .fullBody:
            return "figure.walk"
        case .upperBody:
            return "figure.arms.open"
        case .lowerBody:
            return "figure.run"
        case .core:
            return "circle.circle" // iOS 15.0+ compatible alternative
        case .cardio:
            return "heart.fill"
        case .hiit:
            return "flame.fill"
        case .yoga:
            return "figure.yoga"
        case .strength:
            return "dumbbell.fill"
        case .endurance:
            return "timer"
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(NavigationManager.preview)
        .preferredColorScheme(.dark)
}
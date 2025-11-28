//
//  FitApp.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import AVFoundation
import SwiftUI

@main
struct FitApp: App
{
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var dialogManager = DialogManager()
    @StateObject private var workoutSessionManager = WorkoutSessionManager()
    private let voiceManager = VoiceManager.shared

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(navigationManager)
                .environmentObject(dialogManager)
                .environmentObject(workoutSessionManager)
                .onAppear
                {
                    voiceManager.speak("今天的燃动开始了")
                }
        }
    }
}

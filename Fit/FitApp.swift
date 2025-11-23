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
                    setupAudioSession()
                    voiceManager.speak("今天的燃动开始了")
                }
        }
    }

    private func setupAudioSession()
    {
        do
        {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch
        {
            print("音频会话设置失败: \(error)")
        }
    }
}

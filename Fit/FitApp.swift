//
//  FitApp.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

@main
struct FitApp: App {
    @StateObject private var navigationManager = NavigationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationManager)
        }
    }
}

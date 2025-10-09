//
//  CompatibleNavigationView.swift
//  Fit
//
//  iOS 15.0 compatible navigation wrapper
//

import SwiftUI
import Combine

// MARK: - iOS 15.0 Compatible Navigation Container
struct CompatibleNavigationView<Content: View>: View {
    let content: Content
    @StateObject private var navigationManager = NavigationManager()

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            content
                .environmentObject(navigationManager)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // iOS 15.0 compatible
    }
}

// MARK: - iOS 15.0 Compatible Navigation Link
struct CompatibleNavigationLink<Destination: View, Label: View>: View {
    let destination: Destination
    let label: Label
    let screen: AppScreen

    init(screen: AppScreen, @ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
        self.screen = screen
        self.destination = destination()
        self.label = label()
    }

    var body: some View {
        NavigationLink(destination: destination) {
            label
        }
    }
}

// MARK: - Navigation State Manager for iOS 15.0
class CompatibleNavigationStateManager: ObservableObject {
    @Published var currentScreen: AppScreen = .main
    @Published var navigationHistory: [AppScreen] = []

    func navigate(to screen: AppScreen) {
        navigationHistory.append(currentScreen)
        currentScreen = screen
    }

    func goBack() {
        if let previousScreen = navigationHistory.popLast() {
            currentScreen = previousScreen
        }
    }

    func canGoBack() -> Bool {
        return !navigationHistory.isEmpty
    }

    func clearHistory() {
        navigationHistory.removeAll()
    }
}

// MARK: - Preview
struct CompatibleNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CompatibleNavigationView {
            Text("Hello, iOS 15.0!")
                .navigationTitle("Compatible Navigation")
        }
    }
}
# iOS Fit App V0.2 - Implementation Guide

//created by Jason Lu on 09:17:00 10/12/2025

## Overview

This guide provides step-by-step instructions for implementing the iOS Fit app V0.2 with focus on React-level animations, offline functionality, and local data persistence.

## 1. Project Setup

### 1.1 Xcode Configuration

#### Project Settings
```
Project: Fit
Target: Fit
iOS Deployment Target: 26.0
Supported Devices: iPhone
Architecture: arm64
Build Configuration: Debug/Release
```

#### Info.plist Updates
```xml
<!-- Add to Info.plist -->
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>armv7</string>
</array>

<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>

<key>UIStatusBarStyle</key>
<string>UIStatusBarStyleLightContent</string>

<key>UIViewControllerBasedStatusBarAppearance</key>
<false/>

<key>NSHumanReadableCopyright</key>
<string>Copyright © 2025 Fit App. All rights reserved.</string>
```

#### Build Settings
```
Swift Compiler - Language:
  - Swift Language Version: Swift 5

Deployment:
  - iOS Deployment Target: 26.0
  - Supported Platforms: iOS

Linking:
  - Runpath Search Paths: $(inherited) @executable_path/Frameworks

Build Options:
  - Enable Bitcode: No
  - Swift Compiler Mode: Incremental
```

### 1.2 Required Frameworks
```swift
// Add to your project
import SwiftUI
import CoreData
import Combine
import Foundation
import UIKit
import UserNotifications
```

## 2. Core Data Implementation

### 2.1 Data Model File Creation

1. Create `Fit.xcdatamodeld` file
2. Add entities as defined in the architecture document
3. Set entity attributes and relationships

### 2.2 Core Data Stack Setup

```swift
// Persistence.swift
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Add sample data for previews
        let sampleWorkoutPlan = WorkoutPlanEntity(context: viewContext)
        sampleWorkoutPlan.id = UUID()
        sampleWorkoutPlan.name = "Sample Workout"
        sampleWorkoutPlan.createdDate = Date()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Fit")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
```

## 3. File Structure Implementation

### 3.1 Create Directory Structure

```
Fit/
├── App/
│   ├── FitApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Persistence.swift
│   └── Extensions/
│       ├── View+Extensions.swift
│       ├── Color+Extensions.swift
│       └── Font+Extensions.swift
├── Models/
│   ├── WorkoutPlan.swift
│   ├── Exercise.swift
│   ├── ExerciseSet.swift
│   ├── WorkoutSession.swift
│   └── Core Data Models/
│       ├── WorkoutPlanEntity.swift
│       ├── ExerciseEntity.swift
│       ├── ExerciseSetEntity.swift
│       └── WorkoutSessionEntity.swift
├── Views/
│   ├── Workout Plans/
│   │   ├── WorkoutPlansView.swift
│   │   ├── WorkoutPlanCardView.swift
│   │   ├── WorkoutPlanDetailView.swift
│   │   └── ExerciseCardView.swift
│   ├── Active Workout/
│   │   ├── ActiveWorkoutView.swift
│   │   ├── CurrentSetView.swift
│   │   ├── RestTimerView.swift
│   │   └── WorkoutProgressView.swift
│   ├── History/
│   │   ├── WorkoutHistoryView.swift
│   │   └── WorkoutSessionDetailView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── SetTypeBanner.swift
│       ├── ActionButton.swift
│       ├── ExercisePreviewChip.swift
│       └── TimerRing.swift
├── ViewModels/
│   ├── WorkoutPlansViewModel.swift
│   ├── ActiveWorkoutViewModel.swift
│   ├── WorkoutHistoryViewModel.swift
│   └── TimerViewModel.swift
├── Services/
│   ├── WorkoutRepository.swift
│   ├── TimerManager.swift
│   ├── AnimationManager.swift
│   └── StorageManager.swift
└── Resources/
    ├── Localizable.strings
    ├── Assets.xcassets
    └── Info.plist
```

### 3.2 Key Files Implementation

#### FitApp.swift
```swift
import SwiftUI

@main
struct FitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(WorkoutPlansViewModel())
                .environmentObject(ActiveWorkoutViewModel())
                .environmentObject(TimerViewModel())
        }
    }
}
```

#### ContentView.swift
```swift
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var workoutPlansViewModel: WorkoutPlansViewModel
    @EnvironmentObject var activeWorkoutViewModel: ActiveWorkoutViewModel

    var body: some View {
        TabView {
            WorkoutPlansView()
                .tabItem {
                    Label("训练计划", systemImage: "list.bullet")
                }

            ActiveWorkoutView()
                .tabItem {
                    Label("开始训练", systemImage: "play.circle")
                }

            WorkoutHistoryView()
                .tabItem {
                    Label("训练记录", systemImage: "clock")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .accentColor(.blue)
        .onAppear {
            setupAppearance()
        }
    }

    private func setupAppearance() {
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
```

## 4. Implementation Phases

### Phase 1: Core Architecture (Days 1-5)

#### Day 1: Project Setup
- [ ] Create Xcode project with iOS 26.0 target
- [ ] Set up directory structure
- [ ] Add Core Data model file
- [ ] Configure build settings

#### Day 2: Data Models
- [ ] Implement Core Data entities
- [ ] Create Swift model structs
- [ ] Set up persistence controller
- [ ] Add model validation

#### Day 3: Repository Pattern
- [ ] Create WorkoutRepository protocol
- [ ] Implement Core Data repository
- [ ] Add storage manager
- [ ] Test data persistence

#### Day 4: View Models
- [ ] Create WorkoutPlansViewModel
- [ ] Create ActiveWorkoutViewModel
- [ ] Create TimerViewModel
- [ ] Set up Combine publishers

#### Day 5: Navigation Structure
- [ ] Implement TabView structure
- [ ] Create basic views
- [ ] Set up navigation flow
- [ ] Test navigation

### Phase 2: Workout Management (Days 6-15)

#### Day 6-7: Workout Plans List
- [ ] Implement WorkoutPlansView
- [ ] Create WorkoutPlanCardView
- [ ] Add workout plan CRUD operations
- [ ] Implement empty state view

#### Day 8-10: Workout Plan Detail
- [ ] Create WorkoutPlanDetailView
- [ ] Implement ExerciseCardView
- [ ] Add drag-and-drop reordering
- [ ] Create exercise editor

#### Day 11-12: Set Management
- [ ] Implement set creation and editing
- [ ] Add three set types support
- [ ] Create rest time configuration
- [ ] Implement set validation

#### Day 13-15: Data Persistence
- [ ] Complete Core Data integration
- [ ] Add data migration support
- [ ] Implement error handling
- [ ] Add data export/import

### Phase 3: Active Workout Session (Days 16-25)

#### Day 16-17: Active Workout UI
- [ ] Create ActiveWorkoutView
- [ ] Implement workout session tracking
- [ ] Add exercise progression
- [ ] Create current set display

#### Day 18-19: Timer System
- [ ] Implement TimerViewModel
- [ ] Create RestTimerView
- [ ] Add timer controls
- [ ] Implement background timer

#### Day 20-21: Set Completion
- [ ] Create set completion flow
- [ ] Add input validation
- [ ] Implement skip rest functionality
- [ ] Create progress tracking

#### Day 22-23: Workout State Management
- [ ] Implement workout state persistence
- [ ] Add pause/resume functionality
- [ ] Create workout summary
- [ ] Add error recovery

#### Day 24-25: Polish & Animations
- [ ] Add transition animations
- [ ] Implement micro-interactions
- [ ] Optimize performance
- [ ] Add haptic feedback

### Phase 4: History & Analytics (Days 26-30)

#### Day 26-27: Workout History
- [ ] Create WorkoutHistoryView
- [ ] Implement session list
- [ ] Add session detail view
- [ ] Create filtering options

#### Day 28-29: Progress Tracking
- [ ] Add progress charts
- [ ] Implement statistics
- [ ] Create personal records
- [ ] Add trend analysis

#### Day 30: Final Polish
- [ ] Performance optimization
- [ ] UI/UX refinements
- [ ] Bug fixes
- [ ] Documentation

## 5. Performance Optimization

### 5.1 Animation Performance

```swift
// Use withAnimation for smooth transitions
withAnimation(.easeInOut(duration: 0.3)) {
    // Update state
}

// Use @State for local animations
@State private var isAnimating = false

// Use @Published for reactive updates
@Published var currentSet: ExerciseSet?

// Optimize heavy animations
func optimizeAnimation() {
    // Reduce animation complexity
    // Use hardware acceleration
    // Test on actual devices
}
```

### 5.2 Memory Management

```swift
// Use weak references to prevent retain cycles
class TimerManager: ObservableObject {
    private var timer: Timer?

    deinit {
        timer?.invalidate()
    }
}

// Clear cache when memory warning occurs
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    ImageCache.shared.clearCache()
}

// Use lazy loading for heavy resources
lazy var expensiveView: SomeView = {
    return SomeView()
}()
```

## 6. Testing Strategy

### 6.1 Unit Tests

```swift
import XCTest
@testable import Fit

class WorkoutPlanTests: XCTestCase {
    func testWorkoutPlanValidation() {
        let workoutPlan = WorkoutPlan.example
        let errors = workoutPlan.validate()
        XCTAssertTrue(errors.isEmpty)
    }

    func testSetTypeColors() {
        XCTAssertEqual(SetType.warmup.color, "blue")
        XCTAssertEqual(SetType.formal.color, "green")
        XCTAssertEqual(SetType.superSet.color, "orange")
    }
}
```

### 6.2 UI Tests

```swift
import XCTest

class FitUITests: XCTestCase {
    func testWorkoutPlanCreation() {
        let app = XCUIApplication()
        app.launch()

        // Test workout plan creation flow
        app.buttons["+"].tap()
        app.textFields["计划名称"].tap()
        app.textFields["计划名称"].typeText("测试计划")
        app.buttons["保存"].tap()

        XCTAssertTrue(app.staticTexts["测试计划"].exists)
    }
}
```

## 7. Build and Deployment

### 7.1 Debug Build Configuration

```bash
# Build for testing
xcodebuild -scheme Fit -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild test -scheme Fit -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 7.2 Release Build Configuration

```bash
# Archive for distribution
xcodebuild archive -scheme Fit -destination 'generic/platform=iOS' -archivePath Fit.xcarchive

# Export IPA
xcodebuild -exportArchive -archivePath Fit.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

### 7.3 App Store Preparation

```swift
// Add app metadata
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

// Configure app metadata in App Store Connect
// - App description
// - Screenshots
// - Privacy policy
// - App categories
```

## 8. Troubleshooting

### 8.1 Common Issues

#### Core Data Issues
```swift
// Handle Core Data errors
do {
    try viewContext.save()
} catch {
    let nsError = error as NSError
    print("Core Data error: \(nsError), \(nsError.userInfo)")
    // Handle error appropriately
}
```

#### Animation Issues
```swift
// Ensure animations run on main thread
DispatchQueue.main.async {
    withAnimation {
        // Update UI
    }
}
```

#### Memory Issues
```swift
// Monitor memory usage
override func viewDidDisappear() {
    super.viewDidDisappear()
    // Clean up resources
}
```

This comprehensive implementation guide provides a roadmap for building the iOS Fit app V0.2 with focus on performance, user experience, and maintainable code architecture.
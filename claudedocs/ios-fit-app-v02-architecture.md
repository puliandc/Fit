# iOS Fit App V0.2 - System Architecture Design

## Executive Summary

The iOS Fit app V0.2 is designed as a native iOS application targeting iOS 26.0 with iPhone-only support. The architecture prioritizes UI fluency matching React-level animations, offline functionality, and local data persistence for workout management.

## 1. Architecture Overview

### 1.1 System Architecture Pattern
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Views │ ViewModels │ Animations │ Navigation │ State Mgmt  │
├─────────────────────────────────────────────────────────────┤
│                    Business Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Services │ Use Cases │ Workout Engine │ Timer Engine      │
├─────────────────────────────────────────────────────────────┤
│                     Data Layer                              │
├─────────────────────────────────────────────────────────────┤
│  Repositories │ Local Storage │ Models │ Cache Manager      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Component Structure
```
FitApp
├── Core
│   ├── App Entry Point
│   └── Environment Configuration
├── Features
│   ├── Workout Plans
│   ├── Active Workout
│   ├── Workout History
│   └── Settings
├── Shared
│   ├── Components
│   ├── Animations
│   ├── Extensions
│   └── Utilities
└── Infrastructure
    ├── Storage
    ├── Networking (for future use)
    └── Analytics
```

### 1.3 Data Flow Architecture
- **Unidirectional Data Flow**: SwiftUI → ViewModel → Service → Repository
- **State Management**: ObservableObject + @Published for reactive UI
- **Animation System**: SwiftUI native animations with custom timing curves
- **Local Storage**: Core Data with SQLite backend

## 2. Data Models

### 2.1 Core Data Entities

#### WorkoutPlan Entity
```swift
@objc(WorkoutPlan)
public class WorkoutPlan: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdDate: Date
    @NSManaged public var exercises: NSOrderedSet
}

extension WorkoutPlan {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutPlan> {
        return NSFetchRequest<WorkoutPlan>(entityName: "WorkoutPlan")
    }
}
```

#### Exercise Entity
```swift
@objc(Exercise)
public class Exercise: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var sets: NSOrderedSet
    @NSManaged public var workoutPlan: WorkoutPlan
    @NSManaged public var exerciseRestTime: Int16 // seconds
}

extension Exercise {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }
}
```

#### ExerciseSet Entity
```swift
@objc(ExerciseSet)
public class ExerciseSet: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var setType: String // "热身组", "正式组", "超级组"
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Float
    @NSManaged public var exercise: Exercise
    @NSManaged public var setRestTime: Int16 // seconds
    @NSManaged public var displayOrder: Int16
}

extension ExerciseSet {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseSet> {
        return NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
    }
}
```

#### WorkoutSession Entity (History)
```swift
@objc(WorkoutSession)
public class WorkoutSession: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var workoutPlan: WorkoutPlan
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var completedSets: NSOrderedSet
}

extension WorkoutSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSession> {
        return NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
    }
}
```

#### CompletedSet Entity
```swift
@objc(CompletedSet)
public class CompletedSet: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var exerciseSet: ExerciseSet
    @NSManaged public var completedReps: Int16
    @NSManaged public var completedWeight: Float
    @NSManaged public var actualRestTime: Int16
    @NSManaged public var workoutSession: WorkoutSession
    @NSManaged public var completionDate: Date
}

extension CompletedSet {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompletedSet> {
        return NSFetchRequest<CompletedSet>(entityName: "CompletedSet")
    }
}
```

### 2.2 Swift Data Models

#### SetType Enum
```swift
enum SetType: String, CaseIterable, Codable {
    case warmup = "热身组"
    case formal = "正式组"
    case superSet = "超级组"

    var displayName: String {
        return self.rawValue
    }

    var color: Color {
        switch self {
        case .warmup: return .blue
        case .formal: return .green
        case .superSet: return .orange
        }
    }
}
```

#### Workout Data Models
```swift
struct ExerciseSetData: Identifiable, Codable {
    let id: UUID
    var setType: SetType
    var reps: Int
    var weight: Float
    var setRestTime: Int
    var displayOrder: Int
}

struct ExerciseData: Identifiable, Codable {
    let id: UUID
    var name: String
    var sets: [ExerciseSetData]
    var exerciseRestTime: Int
}

struct WorkoutPlanData: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdDate: Date
    var exercises: [ExerciseData]
}
```

## 3. Component Design

### 3.1 View Hierarchy
```
MainTabView
├── WorkoutPlansView
│   ├── WorkoutPlanListView
│   ├── WorkoutPlanDetailView
│   ├── ExerciseListView
│   └── ExerciseSetListView
├── ActiveWorkoutView
│   ├── CurrentExerciseView
│   ├── ActiveSetView
│   ├── TimerView
│   └── RestTimerView
├── WorkoutHistoryView
│   ├── WorkoutSessionListView
│   ├── WorkoutSessionDetailView
│   └── ProgressChartView
└── SettingsView
    ├── GeneralSettingsView
    └── DataManagementView
```

### 3.2 Animation System Components

#### Animation Manager
```swift
class AnimationManager: ObservableObject {
    @Published var currentAnimation: AnimationType?

    // Smooth transitions matching React-level performance
    static let smoothTransition = Animation.easeInOut(duration: 0.3)
    static let quickTransition = Animation.easeInOut(duration: 0.15)
    static let bouncyTransition = Animation.spring(response: 0.5, dampingFraction: 0.8)

    // Custom timing curves for workout-specific animations
    static let setCompletion = Animation.timingCurve(0.2, 0.8, 0.2, 1)
    static let restTimer = Animation.easeInOut(duration: 0.4)
    static let exerciseTransition = Animation.easeInOut(duration: 0.5)
}
```

#### Transition Components
```swift
struct FadeInView: View {
    @State private var opacity = 0.0
    let content: AnyView

    var body: some View {
        content.opacity(opacity)
            .onAppear {
                withAnimation(AnimationManager.smoothTransition) {
                    opacity = 1.0
                }
            }
    }
}

struct SlideInFromBottom: View {
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    let content: AnyView

    var body: some View {
        content.offset(y: offset)
            .onAppear {
                withAnimation(AnimationManager.bouncyTransition) {
                    offset = 0
                }
            }
    }
}
```

### 3.3 State Management Components

#### Workout State Manager
```swift
class WorkoutStateManager: ObservableObject {
    @Published var currentWorkoutPlan: WorkoutPlanData?
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0
    @Published var workoutState: WorkoutState = .notStarted
    @Published var remainingRestTime: Int = 0
    @Published var isResting: Bool = false

    enum WorkoutState {
        case notStarted
        case inProgress
        case rest
        case completed
    }
}
```

#### Timer Manager
```swift
class TimerManager: ObservableObject {
    @Published var currentTime: Int = 0
    @Published var isRunning: Bool = false

    private var timer: Timer?
    private var totalTime: Int = 0

    func startTimer(duration: Int) {
        totalTime = duration
        currentTime = duration
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentTime > 0 {
                self.currentTime -= 1
            } else {
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}
```

## 4. API Design

### 4.1 Data Service Interfaces

#### Workout Repository Protocol
```swift
protocol WorkoutRepositoryProtocol {
    func fetchWorkoutPlans() async throws -> [WorkoutPlanData]
    func saveWorkoutPlan(_ plan: WorkoutPlanData) async throws
    func deleteWorkoutPlan(id: UUID) async throws
    func fetchWorkoutSessions() async throws -> [WorkoutSessionData]
    func saveWorkoutSession(_ session: WorkoutSessionData) async throws
}
```

#### Core Data Implementation
```swift
class CoreDataWorkoutRepository: WorkoutRepositoryProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func fetchWorkoutPlans() async throws -> [WorkoutPlanData] {
        let request: NSFetchRequest<WorkoutPlan> = WorkoutPlan.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \WorkoutPlan.createdDate, ascending: false)
        request.sortDescriptors = [sortDescriptor]

        let workoutPlans = try container.viewContext.fetch(request)
        return workoutPlans.map { $0.toWorkoutPlanData() }
    }

    // ... other implementations
}
```

### 4.2 Animation Control APIs

#### Animation Controller
```swift
class AnimationController: ObservableObject {
    @Published var activeAnimations: [AnimationType] = []

    func animateSetCompletion(completion: @escaping () -> Void) {
        withAnimation(AnimationManager.setCompletion) {
            // Trigger set completion animation
            activeAnimations.append(.setCompletion)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion()
            self.activeAnimations.removeAll { $0 == .setCompletion }
        }
    }

    func animateExerciseTransition(from: Int, to: Int) {
        withAnimation(AnimationManager.exerciseTransition) {
            activeAnimations.append(.exerciseTransition(from: from, to: to))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activeAnimations.removeAll {
                if case .exerciseTransition(let f, let t) = $0 {
                    return f == from && t == to
                }
                return false
            }
        }
    }
}

enum AnimationType: Equatable {
    case setCompletion
    case exerciseTransition(from: Int, to: Int)
    case restTimerStart
    case restTimerComplete
}
```

### 4.3 Local Storage APIs

#### Storage Manager
```swift
class StorageManager: ObservableObject {
    private let repository: WorkoutRepositoryProtocol

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
    }

    @MainActor
    func loadWorkoutPlans() async -> [WorkoutPlanData] {
        do {
            return try await repository.fetchWorkoutPlans()
        } catch {
            print("Error loading workout plans: \(error)")
            return []
        }
    }

    @MainActor
    func saveWorkoutPlan(_ plan: WorkoutPlanData) async -> Bool {
        do {
            try await repository.saveWorkoutPlan(plan)
            return true
        } catch {
            print("Error saving workout plan: \(error)")
            return false
        }
    }

    // ... other storage methods
}
```

## 5. Technical Specifications

### 5.1 Performance Requirements

#### Animation Performance Targets
- **Frame Rate**: 60 FPS for all animations
- **Animation Latency**: < 16ms (1 frame)
- **Transition Duration**: 200-500ms depending on context
- **Memory Usage**: < 100MB for in-memory workout data

#### UI Performance Metrics
```swift
struct PerformanceMetrics {
    static let targetFrameRate = 60.0
    static let maxAnimationLatency = 0.016 // 16ms
    static let maxMemoryUsage = 100 * 1024 * 1024 // 100MB
    static let maxAppStartupTime = 2.0 // 2 seconds
}
```

### 5.2 Memory Management

#### Memory Optimization Strategies
```swift
class MemoryManager {
    static func optimizeMemoryUsage() {
        // Clear cached images when memory warning occurs
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            ImageCache.shared.clearCache()
        }
    }

    static func preloadCriticalResources() {
        // Preload workout plans and current session
        Task {
            await WorkoutManager.shared.loadCurrentWorkout()
        }
    }
}
```

#### Image Caching System
```swift
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let maxCacheSize = 50 * 1024 * 1024 // 50MB

    init() {
        cache.totalCostLimit = maxCacheSize
        cache.countLimit = 100
    }

    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func getImage(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
```

### 5.3 Build Configuration

#### Project Settings
```
iOS Deployment Target: 26.0
Supported Devices: iPhone
Architecture: arm64
Build Configuration: Release
Optimization Level: -Os
Code Signing: Development (Debug), Distribution (Release)
```

#### Info.plist Configuration
```xml
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
```

## 6. Implementation Roadmap

### Phase 1: Core Architecture (Week 1-2)
- [ ] Set up Core Data stack with all entities
- [ ] Implement repository pattern with Core Data
- [ ] Create base view models and state managers
- [ ] Set up navigation structure

### Phase 2: Workout Management (Week 3-4)
- [ ] Implement workout plan CRUD operations
- [ ] Create exercise and set management UI
- [ ] Implement three set types (热身组, 正式组, 超级组)
- [ ] Add local data persistence

### Phase 3: Active Workout Session (Week 5-6)
- [ ] Build active workout flow
- [ ] Implement timer system
- [ ] Create rest management functionality
- [ ] Add workout session tracking

### Phase 4: Animation & Polish (Week 7-8)
- [ ] Implement React-level animations
- [ ] Add smooth transitions
- [ ] Create micro-interactions
- [ ] Performance optimization

### Phase 5: History & Analytics (Week 9-10)
- [ ] Implement workout history tracking
- [ ] Create progress visualization
- [ ] Add data export functionality
- [ ] Performance tuning

## 7. Quality Assurance

### 7.1 Testing Strategy
- **Unit Tests**: 80% coverage for business logic
- **Integration Tests**: Core Data operations
- **UI Tests**: Critical user flows
- **Performance Tests**: Animation smoothness

### 7.2 Code Quality Standards
- **SwiftLint**: Enforce coding standards
- **SwiftFormat**: Automatic code formatting
- **Code Review**: Peer review for all changes
- **Documentation**: Comprehensive code documentation

This architecture provides a solid foundation for the iOS Fit app V0.2, prioritizing animation performance and offline functionality while maintaining clean, scalable architecture for future enhancements.
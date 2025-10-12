# Workout Plan Data Structure Specification

//created by Jason Lu on 09:17:00 10/12/2025

## Overview

This document defines the complete data structure for workout plans in the iOS Fit app V0.2, supporting three set types (热身组, 正式组, 超级组) with comprehensive rest time management.

## 1. Workout Plan Template Structure

### 1.1 Complete Workout Plan Example

Based on the user's requirements, here's the complete data structure for a typical workout plan:

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "胸部训练计划",
  "createdDate": "2025-01-15T10:00:00Z",
  "exercises": [
    {
      "id": "456e7890-e89b-12d3-a456-426614174001",
      "name": "卧推",
      "exerciseRestTime": 60,
      "sets": [
        {
          "id": "789e0123-e89b-12d3-a456-426614174002",
          "setType": "热身组",
          "reps": 15,
          "weight": 20.0,
          "setRestTime": 60,
          "displayOrder": 1
        },
        {
          "id": "890e1234-e89b-12d3-a456-426614174003",
          "setType": "正式组",
          "reps": 12,
          "weight": 40.0,
          "setRestTime": 90,
          "displayOrder": 2
        },
        {
          "id": "901e2345-e89b-12d3-a456-426614174004",
          "setType": "正式组",
          "reps": 10,
          "weight": 50.0,
          "setRestTime": 90,
          "displayOrder": 3
        },
        {
          "id": "012e3456-e89b-12d3-a456-426614174005",
          "setType": "正式组",
          "reps": 8,
          "weight": 60.0,
          "setRestTime": 120,
          "displayOrder": 4
        }
      ]
    },
    {
      "id": "234e4567-e89b-12d3-a456-426614174006",
      "name": "哑铃飞鸟",
      "exerciseRestTime": 60,
      "sets": [
        {
          "id": "345e5678-e89b-12d3-a456-426614174007",
          "setType": "正式组",
          "reps": 12,
          "weight": 15.0,
          "setRestTime": 60,
          "displayOrder": 1
        },
        {
          "id": "456e6789-e89b-12d3-a456-426614174008",
          "setType": "正式组",
          "reps": 12,
          "weight": 15.0,
          "setRestTime": 60,
          "displayOrder": 2
        },
        {
          "id": "567e7890-e89b-12d3-a456-426614174009",
          "setType": "超级组",
          "reps": 10,
          "weight": 20.0,
          "setRestTime": 45,
          "displayOrder": 3
        }
      ]
    },
    {
      "id": "678e8901-e89b-12d3-a456-426614174010",
      "name": "俯卧撑",
      "exerciseRestTime": 30,
      "sets": [
        {
          "id": "789e9012-e89b-12d3-a456-426614174011",
          "setType": "正式组",
          "reps": 20,
          "weight": 0.0,
          "setRestTime": 45,
          "displayOrder": 1
        },
        {
          "id": "890e0123-e89b-12d3-a456-426614174012",
          "setType": "正式组",
          "reps": 15,
          "weight": 0.0,
          "setRestTime": 45,
          "displayOrder": 2
        }
      ]
    }
  ]
}
```

## 2. Data Model Implementation

### 2.1 Swift Models

```swift
import Foundation

// MARK: - Main Models
struct WorkoutPlan: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdDate: Date
    var exercises: [Exercise]

    static let example = WorkoutPlan(
        id: UUID(),
        name: "胸部训练计划",
        createdDate: Date(),
        exercises: [
            Exercise.benchPressExample,
            Exercise.dumbbellFlyExample,
            Exercise.pushUpExample
        ]
    )
}

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var exerciseRestTime: Int // seconds
    var sets: [ExerciseSet]

    static let benchPressExample = Exercise(
        id: UUID(),
        name: "卧推",
        exerciseRestTime: 60,
        sets: [
            ExerciseSet(id: UUID(), setType: .warmup, reps: 15, weight: 20.0, setRestTime: 60, displayOrder: 1),
            ExerciseSet(id: UUID(), setType: .formal, reps: 12, weight: 40.0, setRestTime: 90, displayOrder: 2),
            ExerciseSet(id: UUID(), setType: .formal, reps: 10, weight: 50.0, setRestTime: 90, displayOrder: 3),
            ExerciseSet(id: UUID(), setType: .formal, reps: 8, weight: 60.0, setRestTime: 120, displayOrder: 4)
        ]
    )

    static let dumbbellFlyExample = Exercise(
        id: UUID(),
        name: "哑铃飞鸟",
        exerciseRestTime: 60,
        sets: [
            ExerciseSet(id: UUID(), setType: .formal, reps: 12, weight: 15.0, setRestTime: 60, displayOrder: 1),
            ExerciseSet(id: UUID(), setType: .formal, reps: 12, weight: 15.0, setRestTime: 60, displayOrder: 2),
            ExerciseSet(id: UUID(), setType: .superSet, reps: 10, weight: 20.0, setRestTime: 45, displayOrder: 3)
        ]
    )

    static let pushUpExample = Exercise(
        id: UUID(),
        name: "俯卧撑",
        exerciseRestTime: 30,
        sets: [
            ExerciseSet(id: UUID(), setType: .formal, reps: 20, weight: 0.0, setRestTime: 45, displayOrder: 1),
            ExerciseSet(id: UUID(), setType: .formal, reps: 15, weight: 0.0, setRestTime: 45, displayOrder: 2)
        ]
    )
}

struct ExerciseSet: Identifiable, Codable, Equatable {
    let id: UUID
    var setType: SetType
    var reps: Int
    var weight: Float
    var setRestTime: Int // seconds
    var displayOrder: Int
}

// MARK: - Set Type Enum
enum SetType: String, CaseIterable, Codable {
    case warmup = "热身组"
    case formal = "正式组"
    case superSet = "超级组"

    var displayName: String {
        return self.rawValue
    }

    var color: String {
        switch self {
        case .warmup: return "blue"
        case .formal: return "green"
        case .superSet: return "orange"
        }
    }

    var description: String {
        switch self {
        case .warmup: return "激活肌肉，准备训练"
        case .formal: return "主要训练组，注重质量"
        case .superSet: return "高强度训练，挑战极限"
        }
    }

    var icon: String {
        switch self {
        case .warmup: return "flame.fill"
        case .formal: return "star.fill"
        case .superSet: return "bolt.fill"
        }
    }
}

// MARK: - Workout Session (For History)
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let workoutPlan: WorkoutPlan
    let startDate: Date
    var endDate: Date?
    var completedSets: [CompletedSet]
    var notes: String?

    var duration: TimeInterval? {
        guard let endDate = endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    var isCompleted: Bool {
        return endDate != nil
    }
}

struct CompletedSet: Identifiable, Codable {
    let id: UUID
    let exerciseSetId: UUID
    let exerciseName: String
    let setType: SetType
    let plannedReps: Int
    let plannedWeight: Float
    let completedReps: Int
    let completedWeight: Float
    let actualRestTime: Int
    let completionDate: Date

    var isCompleted: Bool {
        return completedReps > 0
    }
}
```

### 2.2 Core Data Models

```swift
import Foundation
import CoreData

// MARK: - WorkoutPlan Core Data Entity
@objc(WorkoutPlanEntity)
public class WorkoutPlanEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdDate: Date
    @NSManaged public var exercises: NSOrderedSet?

    func toWorkoutPlan() -> WorkoutPlan {
        let exercises = (exercises?.array as? [ExerciseEntity])?.map { $0.toExercise() } ?? []
        return WorkoutPlan(
            id: id,
            name: name,
            createdDate: createdDate,
            exercises: exercises
        )
    }

    func fromWorkoutPlan(_ workoutPlan: WorkoutPlan) {
        id = workoutPlan.id
        name = workoutPlan.name
        createdDate = workoutPlan.createdDate

        let exerciseEntities = workoutPlan.exercises.map { exercise in
            let entity = ExerciseEntity(context: self.managedObjectContext!)
            entity.fromExercise(exercise)
            entity.workoutPlan = self
            return entity
        }
        exercises = NSOrderedSet(array: exerciseEntities)
    }
}

// MARK: - Exercise Core Data Entity
@objc(ExerciseEntity)
public class ExerciseEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var exerciseRestTime: Int16
    @NSManaged public var workoutPlan: WorkoutPlanEntity?
    @NSManaged public var sets: NSOrderedSet?

    func toExercise() -> Exercise {
        let sets = (sets?.array as? [ExerciseSetEntity])?.map { $0.toExerciseSet() } ?? []
        return Exercise(
            id: id,
            name: name,
            exerciseRestTime: Int(exerciseRestTime),
            sets: sets
        )
    }

    func fromExercise(_ exercise: Exercise) {
        id = exercise.id
        name = exercise.name
        exerciseRestTime = Int16(exercise.exerciseRestTime)

        let setEntities = exercise.sets.map { set in
            let entity = ExerciseSetEntity(context: self.managedObjectContext!)
            entity.fromExerciseSet(set)
            entity.exercise = self
            return entity
        }
        sets = NSOrderedSet(array: setEntities)
    }
}

// MARK: - ExerciseSet Core Data Entity
@objc(ExerciseSetEntity)
public class ExerciseSetEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var setType: String
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Float
    @NSManaged public var setRestTime: Int16
    @NSManaged public var displayOrder: Int16
    @NSManaged public var exercise: ExerciseEntity?

    func toExerciseSet() -> ExerciseSet {
        return ExerciseSet(
            id: id,
            setType: SetType(rawValue: setType) ?? .formal,
            reps: Int(reps),
            weight: weight,
            setRestTime: Int(setRestTime),
            displayOrder: Int(displayOrder)
        )
    }

    func fromExerciseSet(_ set: ExerciseSet) {
        id = set.id
        setType = set.setType.rawValue
        reps = Int16(set.reps)
        weight = set.weight
        setRestTime = Int16(set.setRestTime)
        displayOrder = Int16(set.displayOrder)
    }
}
```

## 3. Validation Rules

### 3.1 Workout Plan Validation
```swift
extension WorkoutPlan {
    func validate() -> [ValidationError] {
        var errors: [ValidationError] = []

        if name.isEmpty {
            errors.append(ValidationError(field: "name", message: "训练计划名称不能为空"))
        }

        if exercises.isEmpty {
            errors.append(ValidationError(field: "exercises", message: "至少需要添加一个训练动作"))
        }

        for (index, exercise) in exercises.enumerated() {
            let exerciseErrors = exercise.validate()
            for error in exerciseErrors {
                errors.append(ValidationError(
                    field: "exercises[\(index)].\(error.field)",
                    message: error.message
                ))
            }
        }

        return errors
    }
}

extension Exercise {
    func validate() -> [ValidationError] {
        var errors: [ValidationError] = []

        if name.isEmpty {
            errors.append(ValidationError(field: "name", message: "动作名称不能为空"))
        }

        if exerciseRestTime < 0 {
            errors.append(ValidationError(field: "exerciseRestTime", message: "动作间休息时间不能为负数"))
        }

        if sets.isEmpty {
            errors.append(ValidationError(field: "sets", message: "至少需要添加一个训练组"))
        }

        for (index, set) in sets.enumerated() {
            let setErrors = set.validate()
            for error in setErrors {
                errors.append(ValidationError(
                    field: "sets[\(index)].\(error.field)",
                    message: error.message
                ))
            }
        }

        return errors
    }
}

extension ExerciseSet {
    func validate() -> [ValidationError] {
        var errors: [ValidationError] = []

        if reps <= 0 {
            errors.append(ValidationError(field: "reps", message: "重复次数必须大于0"))
        }

        if weight < 0 {
            errors.append(ValidationError(field: "weight", message: "重量不能为负数"))
        }

        if setRestTime < 0 {
            errors.append(ValidationError(field: "setRestTime", message: "组间休息时间不能为负数"))
        }

        if displayOrder <= 0 {
            errors.append(ValidationError(field: "displayOrder", message: "显示顺序必须大于0"))
        }

        return errors
    }
}

struct ValidationError {
    let field: String
    let message: String
}
```

## 4. Default Values and Templates

### 4.1 Default Rest Times by Set Type
```swift
struct DefaultRestTimes {
    static let warmup: Int = 60      // 热身组默认休息60秒
    static let formal: Int = 90      // 正式组默认休息90秒
    static let superSet: Int = 45    // 超级组默认休息45秒

    static func getDefaultRestTime(for setType: SetType) -> Int {
        switch setType {
        case .warmup: return warmup
        case .formal: return formal
        case .superSet: return superSet
        }
    }
}
```

### 4.2 Workout Plan Templates
```swift
struct WorkoutPlanTemplates {
    static let beginnerChest = WorkoutPlan(
        id: UUID(),
        name: "新手胸部训练",
        createdDate: Date(),
        exercises: [
            Exercise(
                id: UUID(),
                name: "俯卧撑",
                exerciseRestTime: 60,
                sets: [
                    ExerciseSet(id: UUID(), setType: .warmup, reps: 10, weight: 0, setRestTime: 30, displayOrder: 1),
                    ExerciseSet(id: UUID(), setType: .formal, reps: 8, weight: 0, setRestTime: 45, displayOrder: 2),
                    ExerciseSet(id: UUID(), setType: .formal, reps: 6, weight: 0, setRestTime: 45, displayOrder: 3)
                ]
            )
        ]
    )

    static let intermediateChest = WorkoutPlan(
        id: UUID(),
        name: "中级胸部训练",
        createdDate: Date(),
        exercises: [
            Exercise.benchPressExample,
            Exercise.dumbbellFlyExample
        ]
    )

    static let advancedChest = WorkoutPlan(
        id: UUID(),
        name: "高级胸部训练",
        createdDate: Date(),
        exercises: [
            Exercise.benchPressExample,
            Exercise.dumbbellFlyExample,
            Exercise.pushUpExample
        ]
    )
}
```

## 5. Data Migration

### 5.1 Schema Versioning
```swift
struct WorkoutPlanSchema {
    static let currentVersion: Int = 1

    static func migrate(from oldVersion: Int, to newVersion: Int) {
        // Handle future schema migrations
        switch (oldVersion, newVersion) {
        case (1, 2):
            // Future migration logic
            break
        default:
            break
        }
    }
}
```

This comprehensive data structure provides a solid foundation for the workout management system, supporting all three set types with proper validation and default values.
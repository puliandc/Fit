//
//  MockData.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI
import Foundation

// MARK: - Exercise Model
struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let muscleGroups: [MuscleGroup]
    let equipment: Equipment
    let difficulty: Difficulty
    let instructions: [String]
    let tips: [String]
    let imageName: String
    let videoURL: String?

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory,
        muscleGroups: [MuscleGroup],
        equipment: Equipment,
        difficulty: Difficulty,
        instructions: [String],
        tips: [String] = [],
        imageName: String,
        videoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.muscleGroups = muscleGroups
        self.equipment = equipment
        self.difficulty = difficulty
        self.instructions = instructions
        self.tips = tips
        self.imageName = imageName
        self.videoURL = videoURL
    }
}

// MARK: - Exercise Set Model
struct ExerciseSet: Identifiable, Codable, Hashable {
    let id: UUID
    let exercise: Exercise
    let targetReps: Int  // Number of sets for this exercise
    let targetWeight: Double
    let restTime: Int // in seconds
    var notes: String?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        targetReps: Int,
        targetWeight: Double,
        restTime: Int = 60,
        notes: String? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.restTime = restTime
        self.notes = notes
    }
}

// MARK: - Workout Plan Model
struct WorkoutPlan: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let category: WorkoutCategory
    let difficulty: Difficulty
    let duration: Int // in minutes
    let exercises: [ExerciseSet]
    let estimatedCalories: Int
    let createdBy: String
    let createdAt: Date
    let isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: WorkoutCategory,
        difficulty: Difficulty,
        duration: Int,
        exercises: [ExerciseSet],
        estimatedCalories: Int,
        createdBy: String = "Fit App",
        createdAt: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.exercises = exercises
        self.estimatedCalories = estimatedCalories
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}

// MARK: - Equatable Conformance
extension WorkoutPlan {
    static func == (lhs: WorkoutPlan, rhs: WorkoutPlan) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Workout Session Model
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let workoutPlan: WorkoutPlan
    let startTime: Date
    var endTime: Date?
    var completedSets: [CompletedSet]
    var status: WorkoutStatus
    var notes: String?
    var caloriesBurned: Int?

    init(
        id: UUID = UUID(),
        workoutPlan: WorkoutPlan,
        startTime: Date = Date(),
        completedSets: [CompletedSet] = [],
        status: WorkoutStatus = .inProgress,
        notes: String? = nil,
        caloriesBurned: Int? = nil
    ) {
        self.id = id
        self.workoutPlan = workoutPlan
        self.startTime = startTime
        self.endTime = nil
        self.completedSets = completedSets
        self.status = status
        self.notes = notes
        self.caloriesBurned = caloriesBurned
    }
}

struct CompletedSet: Identifiable, Codable {
    let id: UUID
    let exerciseSetId: UUID
    let actualReps: Int
    let actualWeight: Double
    let completedAt: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        exerciseSetId: UUID,
        actualReps: Int,
        actualWeight: Double,
        completedAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseSetId = exerciseSetId
        self.actualReps = actualReps
        self.actualWeight = actualWeight
        self.completedAt = completedAt
        self.notes = notes
    }
}

// MARK: - Enums
enum ExerciseCategory: String, Codable, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case balance = "Balance"
    case hiit = "HIIT"
    case yoga = "Yoga"
    case plyometrics = "Plyometrics"
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case glutes = "Glutes"
    case core = "Core"
    case calves = "Calves"
    case forearms = "Forearms"
    case traps = "Trapezius"
    case abs = "Abdominals"
}

enum Equipment: String, Codable, CaseIterable {
    case none = "Bodyweight"
    case dumbbells = "Dumbbells"
    case barbell = "Barbell"
    case kettlebell = "Kettlebell"
    case resistanceBands = "Resistance Bands"
    case pullUpBar = "Pull-up Bar"
    case bench = "Bench"
    case machine = "Machine"
    case cable = "Cable"
    case medicineBall = "Medicine Ball"
    case foamRoller = "Foam Roller"
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"

    var color: Color {
        switch self {
        case .beginner:
            return .green
        case .intermediate:
            return .yellow
        case .advanced:
            return .orange
        case .expert:
            return .red
        }
    }
}

enum WorkoutCategory: String, Codable, CaseIterable {
    case fullBody = "Full Body"
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case core = "Core"
    case cardio = "Cardio"
    case hiit = "HIIT"
    case yoga = "Yoga"
    case strength = "Strength"
    case endurance = "Endurance"
}

enum WorkoutStatus: String, Codable, CaseIterable {
    case planned = "Planned"
    case inProgress = "In Progress"
    case paused = "Paused"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Mock Data Provider
class MockDataProvider {
    static let shared = MockDataProvider()

    // 修复循环依赖问题 - 延迟初始化
    private var _sampleExercises: [Exercise]?
    private var _sampleWorkoutPlans: [WorkoutPlan]?

    private init() {
        initializeData()
    }

    // 延迟初始化的示例练习数据
    var sampleExercises: [Exercise] {
        if let exercises = _sampleExercises {
            return exercises
        }

        let exercises = [
            Exercise(
                name: "Push-ups",
                category: .strength,
                muscleGroups: [.chest, .triceps, .shoulders],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Start in a plank position with hands shoulder-width apart",
                    "Lower your body until your chest nearly touches the floor",
                    "Push back up to the starting position"
                ],
                tips: [
                    "Keep your body in a straight line from head to heels",
                    "Engage your core throughout the movement"
                ],
                imageName: "pushup"
            ),
            Exercise(
                name: "Squats",
                category: .strength,
                muscleGroups: [.legs, .glutes, .abs],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Stand with feet shoulder-width apart",
                    "Lower your body as if sitting in a chair",
                    "Return to the starting position"
                ],
                tips: [
                    "Keep your chest up and back straight",
                    "Don't let your knees go past your toes"
                ],
                imageName: "squat"
            ),
            Exercise(
                name: "Dumbbell Bench Press",
                category: .strength,
                muscleGroups: [.chest, .triceps, .shoulders],
                equipment: .dumbbells,
                difficulty: .intermediate,
                instructions: [
                    "Lie on a bench with dumbbells in your hands",
                    "Lower the dumbbells to your chest level",
                    "Press the dumbbells back up to the starting position"
                ],
                tips: [
                    "Control the movement on the way down",
                    "Keep your elbows at a 45-degree angle"
                ],
                imageName: "dumbbell_press"
            ),
            Exercise(
                name: "Plank",
                category: .strength,
                muscleGroups: [.abs, .shoulders],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Start in a push-up position",
                    "Hold your body in a straight line",
                    "Engage your core and hold the position"
                ],
                tips: [
                    "Don't let your hips sag",
                    "Keep breathing throughout the exercise"
                ],
                imageName: "plank"
            ),
            Exercise(
                name: "Jumping Jacks",
                category: .cardio,
                muscleGroups: [.legs, .abs],
                equipment: .none,
                difficulty: .beginner,
                instructions: [
                    "Start with feet together and arms at your sides",
                    "Jump while spreading your legs and raising your arms",
                    "Jump back to the starting position"
                ],
                tips: [
                    "Land softly to protect your joints",
                    "Maintain a steady rhythm"
                ],
                imageName: "jumping_jacks"
            )
        ]

        _sampleExercises = exercises
        return exercises
    }

    // 延迟初始化的示例训练计划数据
    var sampleWorkoutPlans: [WorkoutPlan] {
        if let plans = _sampleWorkoutPlans {
            return plans
        }

        let exercises = sampleExercises // 使用已经初始化的练习数据
        let plans = [
            WorkoutPlan(
                name: "Full Body Beginner",
                description: "A comprehensive full-body workout perfect for beginners",
                category: .fullBody,
                difficulty: .beginner,
                duration: 30,
                exercises: [
                    ExerciseSet(exercise: exercises[0], targetReps: 10, targetWeight: 0),
                    ExerciseSet(exercise: exercises[1], targetReps: 15, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 8, targetWeight: 0),
                    ExerciseSet(exercise: exercises[1], targetReps: 12, targetWeight: 0),
                    ExerciseSet(exercise: exercises[3], targetReps: 30, targetWeight: 0, restTime: 0)
                ],
                estimatedCalories: 200
            ),
            WorkoutPlan(
                name: "Upper Body Strength",
                description: "Build upper body strength with targeted exercises",
                category: .upperBody,
                difficulty: .intermediate,
                duration: 45,
                exercises: [
                    ExerciseSet(exercise: exercises[2], targetReps: 12, targetWeight: 20),
                    ExerciseSet(exercise: exercises[2], targetReps: 10, targetWeight: 22.5),
                    ExerciseSet(exercise: exercises[2], targetReps: 8, targetWeight: 25),
                    ExerciseSet(exercise: exercises[0], targetReps: 15, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 12, targetWeight: 0),
                    ExerciseSet(exercise: exercises[0], targetReps: 10, targetWeight: 0)
                ],
                estimatedCalories: 300
            ),
            WorkoutPlan(
                name: "HIIT Cardio Blast",
                description: "High-intensity interval training for maximum calorie burn",
                category: .hiit,
                difficulty: .advanced,
                duration: 20,
                exercises: [
                    ExerciseSet(exercise: exercises[4], targetReps: 30, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[0], targetReps: 20, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[1], targetReps: 25, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[4], targetReps: 30, targetWeight: 0, restTime: 10),
                    ExerciseSet(exercise: exercises[0], targetReps: 15, targetWeight: 0, restTime: 10)
                ],
                estimatedCalories: 250
            )
        ]

        _sampleWorkoutPlans = plans
        return plans
    }

    // 安全初始化方法
    private func initializeData() {
        // 预先初始化数据以避免循环依赖
        _ = sampleExercises
        _ = sampleWorkoutPlans
    }

    // MARK: - Helper Methods
    func getExercise(byName name: String) -> Exercise? {
        return sampleExercises.first { $0.name == name }
    }

    func getWorkoutPlan(byName name: String) -> WorkoutPlan? {
        return sampleWorkoutPlans.first { $0.name == name }
    }

    func getExercisesByCategory(_ category: ExerciseCategory) -> [Exercise] {
        return sampleExercises.filter { $0.category == category }
    }

    func getExercisesByMuscleGroup(_ muscleGroup: MuscleGroup) -> [Exercise] {
        return sampleExercises.filter { $0.muscleGroups.contains(muscleGroup) }
    }

    func getWorkoutPlansByDifficulty(_ difficulty: Difficulty) -> [WorkoutPlan] {
        return sampleWorkoutPlans.filter { $0.difficulty == difficulty }
    }
}

// MARK: - Preview Helpers
extension MockDataProvider {
    static var previewWorkout: WorkoutPlan {
        return shared.sampleWorkoutPlans[0]
    }

    static var previewExercises: [Exercise] {
        return Array(shared.sampleExercises.prefix(3))
    }

    static var previewExercise: Exercise {
        return shared.sampleExercises[0]
    }
}
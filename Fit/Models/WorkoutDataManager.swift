//
//  WorkoutDataManager.swift
//  Fit
//
//  Created by Jason Lu on 09:30:00 10/12/2025.
//

import Foundation
import Combine

// MARK: - Simplified Workout Data Manager
class WorkoutDataManager: ObservableObject {

    // MARK: - Published Properties
    @Published var trainingPlans: [TrainingPlan] = []
    @Published var trainingSessions: [TrainingSession] = []

    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization
    init() {
        // 设置日期格式化策略
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        // 加载数据
        loadData()
    }

    // MARK: - Data Loading
    func loadData() {
        DispatchQueue.global(qos: .background).async {
            self.loadTrainingPlans()
            self.loadTrainingSessions()

            DispatchQueue.main.async {
                print("✅ 简化数据加载完成")
            }
        }
    }

    private func loadTrainingPlans() {
        if let data = userDefaults.data(forKey: "training_plans") {
            do {
                trainingPlans = try decoder.decode([TrainingPlan].self, from: data)
            } catch {
                print("❌ 加载训练计划失败: \(error)")
                loadDefaultTrainingPlans()
            }
        } else {
            loadDefaultTrainingPlans()
        }
    }

    private func loadTrainingSessions() {
        if let data = userDefaults.data(forKey: "training_sessions") {
            do {
                trainingSessions = try decoder.decode([TrainingSession].self, from: data)
            } catch {
                print("❌ 加载训练会话失败: \(error)")
                trainingSessions = []
            }
        }
    }

    // MARK: - Data Saving
    func saveData() {
        DispatchQueue.global(qos: .background).async {
            self.saveTrainingPlans()
            self.saveTrainingSessions()

            DispatchQueue.main.async {
                print("✅ 数据保存完成")
            }
        }
    }

    private func saveTrainingPlans() {
        do {
            let data = try encoder.encode(trainingPlans)
            userDefaults.set(data, forKey: "training_plans")
        } catch {
            print("❌ 保存训练计划失败: \(error)")
        }
    }

    private func saveTrainingSessions() {
        do {
            let data = try encoder.encode(trainingSessions)
            userDefaults.set(data, forKey: "training_sessions")
        } catch {
            print("❌ 保存训练会话失败: \(error)")
        }
    }

    // MARK: - Training Plan Management
    func addTrainingPlan(_ plan: TrainingPlan) {
        trainingPlans.append(plan)
        saveTrainingPlans()
    }

    func updateTrainingPlan(_ plan: TrainingPlan) {
        if let index = trainingPlans.firstIndex(where: { $0.id == plan.id }) {
            trainingPlans[index] = plan
            saveTrainingPlans()
        }
    }

    func deleteTrainingPlan(_ planId: UUID) {
        trainingPlans.removeAll { $0.id == planId }
        saveTrainingPlans()
    }

    // MARK: - Training Session Management
    func addTrainingSession(_ session: TrainingSession) {
        trainingSessions.append(session)
        saveTrainingSessions()
    }

    func updateTrainingSession(_ session: TrainingSession) {
        if let index = trainingSessions.firstIndex(where: { $0.id == session.id }) {
            trainingSessions[index] = session
            saveTrainingSessions()
        }
    }

    // MARK: - Data Query Methods
    func getTrainingPlan(by id: UUID) -> TrainingPlan? {
        return trainingPlans.first { $0.id == id }
    }

    func getTrainingSession(by id: UUID) -> TrainingSession? {
        return trainingSessions.first { $0.id == id }
    }

    func getTrainingSessions(for date: String) -> [TrainingSession] {
        return trainingSessions.filter { $0.date == date }
    }

    func getAllTrainingPlans() -> [TrainingPlan] {
        return trainingPlans
    }

    func getAllTrainingSessions() -> [TrainingSession] {
        return trainingSessions
    }

    // MARK: - Search Methods
    func searchTrainingPlans(query: String) -> [TrainingPlan] {
        return trainingPlans.filter { plan in
            plan.name.localizedCaseInsensitiveContains(query) ||
            plan.description.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - Data Export/Import
    func exportTrainingPlans() -> String {
        var exportText = "训练计划导出\n\n"

        for plan in trainingPlans {
            exportText += "计划: \(plan.name)\n"
            exportText += "描述: \(plan.description)\n"
            exportText += "练习数量: \(plan.exercises.count)\n\n"

            for exercise in plan.exercises {
                exportText += "  - \(exercise.name)\n"
                for set in exercise.sets {
                    exportText += "    组: \(set.setType.displayName) - \(set.targetReps)次 x \(set.targetWeight)kg\n"
                }
            }
            exportText += "\n"
        }

        return exportText
    }

    // MARK: - Statistics
    func getTotalWorkoutCount() -> Int {
        return trainingSessions.filter { $0.endTime != nil }.count
    }

    func getTotalWorkoutDuration() -> TimeInterval {
        return trainingSessions
            .filter { $0.endTime != nil }
            .compactMap { session -> TimeInterval? in
                guard let endTime = session.endTime else { return nil }
                return endTime.timeIntervalSince(session.startTime)
            }
            .reduce(0, +)
    }

    // MARK: - Cleanup
    func clearAllData() {
        trainingPlans.removeAll()
        trainingSessions.removeAll()
        saveData()
        print("🗑️ 已清除所有训练数据")
    }

    // MARK: - Default Data Loading
    private func loadDefaultTrainingPlans() {
        // 创建一些默认的训练计划
        let defaultPlans = createDefaultTrainingPlans()
        trainingPlans = defaultPlans
        saveTrainingPlans()
    }

    private func createDefaultTrainingPlans() -> [TrainingPlan] {
        // 创建简化版的默认训练计划
        let plan1 = TrainingPlan(
            name: "初级全身训练",
            description: "适合初学者的全身训练计划",
            exercises: [
                TrainingExercise(
                    name: "俯卧撑",
                    sets: [
                        TrainingSet(setType: .warmup, targetReps: 5, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 10, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 8, targetWeight: 0)
                    ]
                ),
                TrainingExercise(
                    name: "深蹲",
                    sets: [
                        TrainingSet(setType: .warmup, targetReps: 10, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 15, targetWeight: 0),
                        TrainingSet(setType: .working, targetReps: 12, targetWeight: 0)
                    ]
                )
            ]
        )

        let plan2 = TrainingPlan(
            name: "上肢力量训练",
            description: "专注上肢力量训练计划",
            exercises: [
                TrainingExercise(
                    name: "哑铃卧推",
                    sets: [
                        TrainingSet(setType: .warmup, targetReps: 8, targetWeight: 10),
                        TrainingSet(setType: .working, targetReps: 12, targetWeight: 12),
                        TrainingSet(setType: .working, targetReps: 10, targetWeight: 15)
                    ]
                ),
                TrainingExercise(
                    name: "哑铃飞鸟",
                    sets: [
                        TrainingSet(setType: .working, targetReps: 12, targetWeight: 5),
                        TrainingSet(setType: .working, targetReps: 10, targetWeight: 6)
                    ]
                )
            ]
        )

        return [plan1, plan2]
    }
}
//
//  WorkoutLogModels.swift
//  Fit
//
//  Created by Jason Lu on 14/10/2025.
//

import Foundation

// MARK: - Workout Log Entry
struct WorkoutLogEntry: Codable {
    let exercise: String          // 动作名称
    let setOrder: Int             // 组序
    let targetWeight: Double      // 目标重量
    let actualWeight: WorkoutValue  // 实际重量
    let targetReps: Int           // 目标次数
    let actualReps: WorkoutValue   // 实际次数
    let trainingDuration: WorkoutValue // 训练时长
    let restTime: Double          // 组间休息
    let notes: String             // 备注
}

// MARK: - WorkoutValue (处理实际值或N/A)
enum WorkoutValue: Codable {
    case value(Double)
    case na(String)

    var stringValue: String {
        switch self {
        case .value(let double):
            return String(format: "%.1f", double)
        case .na(let string):
            return string
        }
    }

    var doubleValue: Double? {
        switch self {
        case .value(let double):
            return double
        case .na:
            return nil
        }
    }
}

// MARK: - Complete Workout Log
struct WorkoutLog: Codable {
    let workoutName: String         // 训练名称
    let workoutDate: String         // 训练日期
    let startTime: String           // 开始时间
    let endTime: String             // 结束时间
    let totalDuration: String       // 总训练时长
    let entries: [WorkoutLogEntry]   // 训练条目列表

    // JSON导出方法
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to encode workout log: \(error)")
            return nil
        }
    }
}

// MARK: - Enhanced Workout Log File Manager
class EnhancedWorkoutLogFileManager {
    private let fileManager = FileManager.default

    // 获取Documents目录下的WorkoutLogs文件夹
    var workoutLogsDirectoryURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let workoutLogsFolder = documentsPath.appendingPathComponent("WorkoutLogs")

        // 创建文件夹（如果不存在）
        do {
            try fileManager.createDirectory(at: workoutLogsFolder, withIntermediateDirectories: true)
        } catch {
            print("Failed to create WorkoutLogs directory: \(error)")
        }

        return workoutLogsFolder
    }

    // 生成更友好的文件名
    func generateLogFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dateStr = formatter.string(from: Date())
        return "训练日志_\(dateStr).json"
    }

    // 获取完整的文件路径
    func getLogFileURL() -> URL {
        let fileName = generateLogFileName()
        return workoutLogsDirectoryURL.appendingPathComponent(fileName)
    }

    // 保存日志文件
    func saveWorkoutLog(_ workoutLog: WorkoutLog) -> Bool {
        let fileURL = getLogFileURL()

        guard let jsonString = workoutLog.toJSON() else {
            print("Failed to convert workout log to JSON")
            return false
        }

        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ Workout log saved to: \(fileURL.path)")
            return true
        } catch {
            print("❌ Failed to save workout log: \(error)")
            return false
        }
    }

    // 获取所有日志文件
    func getAllLogFiles() -> [URL] {
        do {
            let logFiles = try fileManager.contentsOfDirectory(
                at: workoutLogsDirectoryURL,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            ).filter { $0.pathExtension == "json" }

            // 按创建时间排序（最新的在前）
            return logFiles.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                return date1 > date2
            }
        } catch {
            print("Failed to get log files: \(error)")
            return []
        }
    }

    // 清理旧日志文件（可选功能）
    func organizeLogFiles() {
        let logFiles = getAllLogFiles()
        let calendar = Calendar.current

        // 按月份分组
        var monthlyGroups: [String: [URL]] = [:]

        for fileURL in logFiles {
            if let creationDate = (try? fileURL.resourceValues(forKeys: [.creationDateKey]))?.creationDate {
                let monthKey = DateFormatter.monthYear.string(from: creationDate)
                if monthlyGroups[monthKey] == nil {
                    monthlyGroups[monthKey] = []
                }
                monthlyGroups[monthKey]?.append(fileURL)
            }
        }

        // 可以在这里创建月份子文件夹并移动文件
        // 目前保持简单，所有文件都在WorkoutLogs根目录
        print("📁 Log files organized by month: \(monthlyGroups.keys.sorted())")
    }
}

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    static let timeDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let dateDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
}
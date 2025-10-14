//
//  WorkoutLogTestHelper.swift
//  Fit
//
//  Created by Jason Lu on 14/10/2025.
//

import Foundation

// MARK: - Workout Log Test Helper
class WorkoutLogTestHelper {

    // 测试文件系统访问性
    static func testFileSystemAccess() {
        print("🧪 开始测试文件系统访问性...")

        let fileManager = EnhancedWorkoutLogFileManager()

        // 1. 测试目录创建
        let directoryURL = fileManager.workoutLogsDirectoryURL
        print("📁 WorkoutLogs 目录: \(directoryURL.path)")

        // 2. 创建测试日志
        let testLog = WorkoutLog(
            workoutName: "测试训练",
            workoutDate: DateFormatter.dateDisplay.string(from: Date()),
            startTime: DateFormatter.timeDisplay.string(from: Date().addingTimeInterval(-3600)),
            endTime: DateFormatter.timeDisplay.string(from: Date()),
            totalDuration: "01:00:00",
            entries: [
                WorkoutLogEntry(
                    exercise: "测试动作",
                    setOrder: 1,
                    targetWeight: 20.0,
                    actualWeight: .value(20.0),
                    targetReps: 10,
                    actualReps: .value(10.0),
                    trainingDuration: .value(45.5),
                    restTime: 90,
                    notes: "测试记录"
                )
            ]
        )

        // 3. 测试文件保存
        let success = fileManager.saveWorkoutLog(testLog)

        if success {
            print("✅ 测试日志文件保存成功")

            // 4. 测试文件读取
            let logFiles = fileManager.getAllLogFiles()
            print("📊 找到 \(logFiles.count) 个日志文件")

            for (index, fileURL) in logFiles.enumerated() {
                print("  \(index + 1). \(fileURL.lastPathComponent)")

                // 读取文件内容验证
                if let data = try? Data(contentsOf: fileURL),
                   let jsonString = String(data: data, encoding: .utf8) {
                    print("    📄 文件大小: \(data.count) bytes")
                    print("    ✅ 文件可读性: 正常")
                } else {
                    print("    ❌ 文件读取失败")
                }
            }

            // 5. 测试文件管理
            fileManager.organizeLogFiles()

        } else {
            print("❌ 测试日志文件保存失败")
        }

        print("🧪 文件系统访问性测试完成")
    }

    // 创建示例训练日志用于演示
    static func createDemoWorkoutLog() -> WorkoutLog {
        return WorkoutLog(
            workoutName: "A组卧推深蹲",
            workoutDate: DateFormatter.dateDisplay.string(from: Date()),
            startTime: "10:31",
            endTime: "11:20",
            totalDuration: "00:49:30",
            entries: [
                WorkoutLogEntry(
                    exercise: "杠铃卧推",
                    setOrder: 1,
                    targetWeight: 45,
                    actualWeight: .value(45.0),
                    targetReps: 5,
                    actualReps: .value(5.0),
                    trainingDuration: .value(35.5),
                    restTime: 90,
                    notes: ""
                ),
                WorkoutLogEntry(
                    exercise: "杠铃卧推",
                    setOrder: 2,
                    targetWeight: 45,
                    actualWeight: .value(45.0),
                    targetReps: 5,
                    actualReps: .value(5.0),
                    trainingDuration: .value(42.3),
                    restTime: 90,
                    notes: ""
                ),
                WorkoutLogEntry(
                    exercise: "杠铃深蹲",
                    setOrder: 1,
                    targetWeight: 62.5,
                    actualWeight: .na("N/A"),
                    targetReps: 5,
                    actualReps: .na("N/A"),
                    trainingDuration: .na("N/A"),
                    restTime: 120,
                    notes: "放弃"
                )
            ]
        )
    }

    // 验证用户是否可以通过文件App访问
    static func verifyFileAppAccess() -> Bool {
        print("🔍 验证文件App访问性...")

        let fileManager = EnhancedWorkoutLogFileManager()
        let demoLog = createDemoWorkoutLog()

        // 保存示例日志
        let success = fileManager.saveWorkoutLog(demoLog)

        if success {
            print("✅ 示例日志已保存到 WorkoutLogs 文件夹")
            print("📱 请打开 '文件' App，浏览到 Fit 应用，查看 WorkoutLogs 文件夹")
            print("📁 文件路径: \(fileManager.workoutLogsDirectoryURL.path)")
            return true
        } else {
            print("❌ 示例日志保存失败")
            return false
        }
    }
}
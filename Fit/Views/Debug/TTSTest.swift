//
//  TTSTest.swift
//  Fit
//
//  Created by Jason Lu on 10/17/2025.
//  TTS功能测试文件
//

import SwiftUI

// MARK: - TTS功能测试视图
struct TTSTestView: View {
    @State private var testResults: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("TTS功能测试")
                .font(.title)
                .padding()

            VStack(spacing: 15) {
                // 测试下一组播报
                Button("测试下一组播报") {
                    testNextSetAnnouncement()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // 测试休息倒计时播报
                Button("测试休息倒计时播报") {
                    testRestCountdownAnnouncement()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                // 测试重量格式化
                Button("测试重量格式化") {
                    testWeightFormatting()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)

                // 清空测试结果
                Button("清空测试结果") {
                    testResults.removeAll()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            // 显示测试结果
            if !testResults.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("测试结果:")
                        .font(.headline)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(testResults, id: \.self) { result in
                                Text("• \(result)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - 测试方法

    private func testNextSetAnnouncement() {
        testResults.append("开始测试下一组播报...")

        // 测试不同重量的格式
        let testCases = [
            ("杠铃卧推", 0.0, 8),
            ("哑铃飞鸟", 15.0, 12),
            ("深蹲", 60.5, 10),
            ("引体向上", 0.0, 6)
        ]

        for (exerciseName, weight, reps) in testCases {
            VoiceManager.shared.announceNextSet(
                exerciseName: exerciseName,
                weight: weight,
                reps: reps
            )

            let weightText = weight == 0 ? "自重" : "\(weight)公斤"
            let result = "播报: '\(exerciseName)', '\(weightText)', '\(reps)次'"
            testResults.append(result)

            // 等待播报完成
            Thread.sleep(forTimeInterval: 3.0)
        }

        testResults.append("下一组播报测试完成!")
    }

    private func testRestCountdownAnnouncement() {
        testResults.append("开始测试休息倒计时播报...")

        // 测试不同的倒计时
        let countdownTimes = [15, 30, 10, 5]

        for seconds in countdownTimes {
            VoiceManager.shared.announceRestCountdown(seconds: seconds)
            let result = "播报: 休息还有\(seconds)秒"
            testResults.append(result)

            // 等待播报完成
            Thread.sleep(forTimeInterval: 2.0)
        }

        testResults.append("休息倒计时播报测试完成!")
    }

    private func testWeightFormatting() {
        testResults.append("开始测试重量格式化...")

        // 这里我们只能通过播报来测试格式化
        let testWeights = [0.0, 10.0, 15.5, 20.0, 22.5]

        for weight in testWeights {
            VoiceManager.shared.announceNextSet(
                exerciseName: "测试动作",
                weight: weight,
                reps: 10
            )

            let expectedText = weight == 0 ? "自重" : "\(weight)公斤"
            let result = "测试重量\(weight)kg -> '\(expectedText)'"
            testResults.append(result)

            // 等待播报完成
            Thread.sleep(forTimeInterval: 2.0)
        }

        testResults.append("重量格式化测试完成!")
    }
}

// MARK: - Preview
#Preview {
    TTSTestView()
}
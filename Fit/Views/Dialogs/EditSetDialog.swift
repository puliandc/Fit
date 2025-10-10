//
//  EditSetDialog.swift
//  Fit
//
//  Created by 陆家贤 on 9/10/2025.
//

import SwiftUI

struct EditSetDialog: View {
    let exercise: Exercise
    let setIndex: Int
    let onDismiss: () -> Void

    @State private var reps: String = ""
    @State private var weight: String = ""
    @State private var notes: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Text("编辑参数")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Content
            VStack(spacing: 16) {
                Text("调整这组训练的参数")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // Reps Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("完成次数")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("0", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                }

                // Weight Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("重量 (kg)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("0.0", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                }

                // Notes Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("备注 (可选)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("添加备注...", text: $notes)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Buttons
                HStack(spacing: 12) {
                    Button("取消") {
                        onDismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("保存") {
                        saveChanges()
                        onDismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 320)
        .onAppear {
            loadCurrentValues()
        }
    }

    private func loadCurrentValues() {
        // Load current values from the exercise or use defaults
        reps = "8"
        weight = "60"
    }

    private func saveChanges() {
        // Save the changes (implementation would depend on your data model)
        print("Saving changes - Reps: \(reps), Weight: \(weight), Notes: \(notes)")
    }
}

// MARK: - Completion Dialog
struct CompletionDialog: View {
    let onDismiss: () -> Void

    @State private var reps: String = ""
    @State private var weight: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Text("完成记录")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Content
            VStack(spacing: 16) {
                Text("请输入您实际完成的次数和重量")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // Reps Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("完成次数")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("0", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                }

                // Weight Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("完成重量 (kg)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("0.0", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                }

                // Buttons
                HStack(spacing: 12) {
                    Button("取消") {
                        onDismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("确认") {
                        saveCompletion()
                        onDismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 320)
        .onAppear {
            loadDefaults()
        }
    }

    private func loadDefaults() {
        reps = "8"
        weight = "60"
    }

    private func saveCompletion() {
        print("Saving completion - Reps: \(reps), Weight: \(weight)")
    }
}

// MARK: - Quit Dialog
struct QuitDialog: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.orange)

                Text("放弃训练")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Content
            VStack(spacing: 16) {
                Text("确定要放弃当前训练吗？")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("您的进度将会丢失")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                // Buttons
                HStack(spacing: 12) {
                    Button("继续训练") {
                        onCancel()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("放弃训练") {
                        onConfirm()
                    }
                    .buttonStyle(DangerButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 300)
    }
}

// MARK: - Workout Complete Dialog
struct WorkoutCompleteDialog: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.green)

                Text("训练完成!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Content
            VStack(spacing: 16) {
                Text("恭喜您完成了今天的训练！")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // Stats
                VStack(spacing: 8) {
                    HStack {
                        Text("总时长:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("45:30")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("消耗卡路里:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("280 kcal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("完成组数:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("12 组")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

                // Button
                Button("完成") {
                    onDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 320)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.pink, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.primary)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    EditSetDialog(
        exercise: MockDataProvider.previewExercise,
        setIndex: 1,
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
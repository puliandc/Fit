//
//  UniversalDialog.swift
//  Fit
//
//  Created by Jason Lu on 22:05:00 10/14/2025.
//

import SwiftUI

// MARK: - Universal Dialog Type
enum UniversalDialogType {
    case input(
        title: String,
        subtitle: String,
        defaultReps: String,
        defaultWeight: String,
        onConfirm: (String, String, String) -> Void
    )
    case confirmation(
        title: String,
        message: String,
        icon: String,
        iconColor: Color,
        onConfirm: () -> Void
    )
    case options(
        title: String,
        message: String,
        options: [DialogOption]
    )
    case completion(
        title: String,
        message: String,
        stats: [(String, String)]
    )
}

// MARK: - Dialog Option
struct DialogOption {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
}

// MARK: - Focus Field Enumeration
extension UniversalDialog {
    enum Field: Hashable {
        case reps
        case weight
        case notes
    }
}

// MARK: - Universal Dialog
struct UniversalDialog: View {
    let type: UniversalDialogType
    let onDismiss: () -> Void

    @State private var reps: String = ""
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var isKeyboardVisible: Bool = false
    @FocusState private var focusedField: Field?

    private var dialogWidth: CGFloat {
        switch type {
        case .input: return 320
        case .confirmation: return 300
        case .options: return 360
        case .completion: return 320
        }
    }

    private var dialogIcon: String? {
        switch type {
        case .input: return nil
        case .confirmation(_, _, let icon, _, _): return icon
        case .options: return "flag.checkered"
        case .completion: return "checkmark.circle.fill"
        }
    }

    private var dialogIconColor: Color {
        switch type {
        case .input: return .clear
        case .confirmation(_, _, _, let color, _): return color
        case .options: return .appPrimary
        case .completion: return .success
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Content
            contentSection

            // Footer (if needed)
            if case .input = type {
                footerSection
            }
        }
        .background(universalBackground)
        .shadow(color: .appBackground.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: dialogWidth)
        .onAppear {
            loadDefaults()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .onTapGesture {
            // 点击背景时关闭键盘
            focusedField = nil
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            if let icon = dialogIcon {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(dialogIconColor)
            }

            Text(dialogTitle)
                .font(.system(size: dialogTitleFont, weight: .semibold))
                .foregroundColor(.appPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Content Section
    private var contentSection: some View {
        VStack(spacing: 16) {
            switch type {
            case .input(_, let subtitle, _, _, _):
                inputContent(subtitle: subtitle)
            case .confirmation(_, let message, _, _, _):
                confirmationContent(message: message)
            case .options(_, let message, let options):
                optionsContent(message: message, options: options)
            case .completion(_, let message, let stats):
                completionContent(message: message, stats: stats)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: 12) {
            Button("取消") {
                onDismiss()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("保存") {
                saveInput()
                onDismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Content Types

    private func inputContent(subtitle: String) -> some View {
        VStack(spacing: 16) {
            Text(subtitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.appTextTertiary)
                .multilineTextAlignment(.center)

            // Reps Input
            inputField(
                title: "完成次数",
                text: $reps,
                placeholder: "0",
                keyboardType: .numberPad,
                color: .success,
                field: .reps
            )

            // Weight Input
            inputField(
                title: "重量 (kg)",
                text: $weight,
                placeholder: "0",
                keyboardType: .decimalPad,
                color: .info,
                field: .weight
            )

            // Notes Input
            inputField(
                title: "备注 (可选)",
                text: $notes,
                placeholder: "添加备注...",
                keyboardType: .default,
                color: .appTextSecondary,
                field: .notes
            )
        }
    }

    private func confirmationContent(message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.appTextTertiary)
                .multilineTextAlignment(.center)

            if case .confirmation(_, let warningMessage, _, _, _) = type {
                Text(warningMessage)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.error)
                    .multilineTextAlignment(.center)
            }

            // Confirmation Buttons
            HStack(spacing: 12) {
                Button("继续训练") {
                    onDismiss()
                }
                .buttonStyle(SecondaryButtonStyle())

                Button("放弃训练") {
                    if case .confirmation(_, _, _, _, let onConfirm) = type {
                        onConfirm()
                    }
                }
                .buttonStyle(DangerButtonStyle())
            }
        }
    }

    private func optionsContent(message: String, options: [DialogOption]) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.appTextTertiary)
                .multilineTextAlignment(.center)

            // Options
            VStack(spacing: 12) {
                ForEach(options, id: \.id) { option in
                    optionCard(option: option)
                }
            }
        }
    }

    private func completionContent(message: String, stats: [(String, String)]) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.appTextTertiary)
                .multilineTextAlignment(.center)

            // Stats
            VStack(spacing: 8) {
                ForEach(stats, id: \.0) { stat in
                    HStack {
                        Text(stat.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appTextTertiary)
                        Spacer()
                        Text(stat.1)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.appTextMuted.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

            // Complete Button
            Button("完成") {
                onDismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    // MARK: - Helper Components

    private func inputField(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType, color: Color, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextTertiary)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.appTextTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: field)
                .onTapGesture {
                    focusedField = field
                }
                .onSubmit {
                    // 提交时移动到下一个输入框或关闭键盘
                    switch field {
                    case .reps:
                        focusedField = .weight
                    case .weight:
                        focusedField = .notes
                    case .notes:
                        focusedField = nil
                    }
                }
        }
    }

    private func optionCard(option: DialogOption) -> some View {
        Button(action: option.action) {
            HStack(spacing: 12) {
                Image(systemName: option.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(option.color)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                        .multilineTextAlignment(.leading)

                    Text(option.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.appTextTertiary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(option.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(option.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Computed Properties

    private var dialogTitle: String {
        switch type {
        case .input(let title, _, _, _, _): return title
        case .confirmation(let title, _, _, _, _): return title
        case .options(let title, _, _): return title
        case .completion(let title, _, _): return title
        }
    }

    private var dialogTitleFont: CGFloat {
        switch type {
        case .completion: return 20 // Completion dialog has larger title
        default: return 18
        }
    }

    private var universalBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.appSurfaceLight.opacity(0.95))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            )
    }

    // MARK: - Methods

    private func loadDefaults() {
        if case .input(_, _, let defaultReps, let defaultWeight, _) = type {
            reps = defaultReps
            weight = defaultWeight
            notes = ""
        }
    }

    private func saveInput() {
        if case .input(_, _, _, _, let onConfirm) = type {
            onConfirm(reps, weight, notes)
        }
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.appText)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.appTextTertiary)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appTextMuted.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appTextMuted.opacity(0.4), lineWidth: 1.5)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.appText)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.error)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Input Dialog Preview
        UniversalDialog(
            type: .input(
                title: "动作完成",
                subtitle: "请输入实际完成次数和重量",
                defaultReps: "8",
                defaultWeight: "60",
                onConfirm: { _, _, _ in }
            ),
            onDismiss: {}
        )

        // Confirmation Dialog Preview
        UniversalDialog(
            type: .confirmation(
                title: "放弃训练",
                message: "确定要放弃当前训练吗？",
                icon: "exclamationmark.triangle",
                iconColor: .warning,
                onConfirm: {}
            ),
            onDismiss: {}
        )

        // Options Dialog Preview
        UniversalDialog(
            type: .options(
                title: "选择结束方式",
                message: "请选择如何结束训练",
                options: [
                    DialogOption(
                        title: "跳过当前动作",
                        description: "跳过当前动作，继续下一个",
                        icon: "forward.end.fill",
                        color: .warning,
                        action: {}
                    ),
                    DialogOption(
                        title: "继续训练",
                        description: "继续当前动作的训练",
                        icon: "play.circle.fill",
                        color: .success,
                        action: {}
                    )
                ]
            ),
            onDismiss: {}
        )
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
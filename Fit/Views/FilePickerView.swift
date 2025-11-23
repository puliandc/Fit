//
//  FilePickerView.swift
//  Fit
//
//  Created by Jason Lu on 10:00:00 10/13/2025.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - File Picker View

struct FilePickerView: UIViewControllerRepresentable
{
    // MARK: - Properties

    @Binding var isPresented: Bool
    let onFileSelected: (URL) -> Void
    let onError: (String) -> Void

    // MARK: - Coordinator

    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController
    {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) { }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIDocumentPickerDelegate
    {
        let parent: FilePickerView

        init(_ parent: FilePickerView)
        {
            self.parent = parent
        }

        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
        {
            guard let url = urls.first else { return }

            // 验证文件安全
            let validator = FileSecurityValidatorStruct()
            let result = validator.validateFile(url)

            switch result
            {
            case .valid:
                parent.onFileSelected(url)
            case .invalidFormat:
                parent.onError("请选择有效的JSON格式文件")
            case .fileTooLarge:
                parent.onError("文件过大，请选择小于10MB的文件")
            case .emptyFile:
                parent.onError("文件为空，请选择有效的训练计划文件")
            case .invalidContent:
                parent.onError("文件内容格式不正确")
            case .inaccessible:
                parent.onError("无法访问文件，请检查文件权限")
            }

            parent.isPresented = false
        }

        func documentPickerWasCancelled(_: UIDocumentPickerViewController)
        {
            parent.isPresented = false
        }
    }
}

// MARK: - File Security Validator

struct FileSecurityValidatorStruct
{
    func validateFile(_ url: URL) -> FileValidationResult
    {
        // 1. 文件扩展名检查
        guard url.pathExtension.lowercased() == "json"
        else
        {
            return .invalidFormat
        }

        // 2. 文件大小检查
        do
        {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            guard let fileSize = resourceValues.fileSize
            else
            {
                return .inaccessible
            }

            if fileSize > 10 * 1024 * 1024
            { // 10MB限制
                return .fileTooLarge
            }

            if fileSize == 0
            {
                return .emptyFile
            }
        }
        catch
        {
            return .inaccessible
        }

        // 3. 文件内容预检查
        do
        {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe, .alwaysMapped])

            // 简单的JSON格式检查
            guard let firstByte = data.first
            else
            {
                return .emptyFile
            }

            if firstByte != UInt8(ascii: "{") && firstByte != UInt8(ascii: "[")
            {
                return .invalidContent
            }

            // 尝试解析JSON头部以验证格式
            if data.count > 1024
            {
                let headData = data.prefix(1024)
                if let _ = try? JSONSerialization.jsonObject(with: Data(headData), options: [.fragmentsAllowed])
                {
                    return .valid
                }
            }
            else
            {
                if let _ = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                {
                    return .valid
                }
            }
        }
        catch
        {
            return .invalidContent
        }

        return .valid
    }
}

// MARK: - File Validation Result

enum FileValidationResult
{
    case valid
    case invalidFormat
    case fileTooLarge
    case emptyFile
    case invalidContent
    case inaccessible
}

// MARK: - Preview

#Preview
{
    @Previewable @State var isPresented = false

    return VStack
    {
        Button("选择文件")
        {
            isPresented = true
        }
        .sheet(isPresented: $isPresented)
        {
            FilePickerView(
                isPresented: $isPresented,
                onFileSelected: { url in
                    print("选择了文件: \(url)")
                },
                onError: { error in
                    print("错误: \(error)")
                }
            )
        }
    }
}

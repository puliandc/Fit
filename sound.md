# 极简化语音播报功能方案

> **创建时间**: 2025年1月15日
> **项目**: Fit健身应用
> **功能**: 应用启动TTS语音播报
> **播报内容**: "今天的燃动开始了"

## 1. 技术方案

### 1.1 方案选择
- **方案**: iOS原生AVFoundation + AVSpeechSynthesizer
- **实现方式**: 纯前端TTS（文字转语音）
- **后端需求**: 完全不需要后端服务

### 1.2 核心特点
- ✅ 极简化设计：约35行核心代码
- ✅ 零配置：无用户界面或设置选项
- ✅ 即插即用：APP启动时自动播放
- ✅ 原生支持：完全依赖iOS系统功能

## 2. 技术实现

### 2.1 VoiceManager.swift

**文件位置**: `/Users/lujiaxian/APP/Fit/Fit/Services/VoiceManager.swift`

```swift
//created by Jason Lu on 09:00:00 10/15/2025
import AVFoundation

class VoiceManager: NSObject, ObservableObject {
    static let shared = VoiceManager()
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

extension VoiceManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 播放完成，无需处理
    }
}
```

### 2.2 FitApp.swift 修改

**文件位置**: `/Users/lujiaxian/APP/Fit/Fit/FitApp.swift`

```swift
//created by Jason Lu on 09:00:00 10/15/2025
import SwiftUI
import AVFoundation

@main
struct FitApp: App {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var dialogManager = DialogManager()
    @StateObject private var workoutSessionManager = WorkoutSessionManager()
    @StateObject private var voiceManager = VoiceManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationManager)
                .environmentObject(dialogManager)
                .environmentObject(workoutSessionManager)
                .onAppear {
                    setupAudioSession()
                    voiceManager.speak("今天的燃动开始了")
                }
        }
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error)")
        }
    }
}
```

### 2.3 Info.plist 权限配置

在 `Info.plist` 文件中添加麦克风权限说明：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>TTS语音播报需要</string>
```

## 3. 文件结构

```
Fit/
├── Services/
│   └── VoiceManager.swift          (新建)
├── FitApp.swift                    (修改)
└── Info.plist                      (修改)
```

## 4. 技术细节

### 4.1 关键配置
- **音频会话**: `.playback` 类别，支持后台播放
- **语音配置**: 中文语音 (`zh-CN`)，语速 `0.5`
- **启动触发**: `ContentView.onAppear` 中自动播放
- **单例模式**: 使用 `shared` 实例

### 4.2 依赖框架
```swift
import AVFoundation
```

### 4.3 实现特点
- **代码量**: 约35行核心代码
- **实现时间**: 10分钟内完成
- **文件修改**: 仅需修改3个文件
- **无用户界面**: 完全隐藏的背景功能
- **固定播报**: 每次启动播放"今天的燃动开始了"

## 5. 使用说明

### 5.1 集成步骤
1. 创建 `Services/VoiceManager.swift` 文件
2. 修改 `FitApp.swift` 添加TTS集成代码
3. 在 `Info.plist` 中添加权限说明
4. 重新编译运行应用

### 5.2 预期效果
- APP冷启动或热启动时会自动播放语音
- 播放内容固定为"今天的燃动开始了"
- 使用系统默认中文语音合成
- 播放时长约2-3秒

## 6. 总结

这个方案实现了最简单的iOS TTS语音播报功能：

- **极简设计**: 无任何额外功能和复杂逻辑
- **零配置**: 不需要任何用户界面或设置
- **即插即用**: 复制粘贴代码即可使用
- **原生支持**: 完全依赖iOS系统功能

适合个人使用的健身应用，提供简单的启动语音激励功能。
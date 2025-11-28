// created by Jason Lu on 09:00:00 10/15/2025
import AVFoundation

class VoiceManager: NSObject
{
    static let shared = VoiceManager()
    private let synthesizer = AVSpeechSynthesizer()
    private let audioSession = AVAudioSession.sharedInstance()
    private var sessionActive = false

    override init()
    {
        super.init()
        synthesizer.delegate = self
    }

    /// 停止当前语音播放并释放资源
    func stopSpeaking()
    {
        if synthesizer.isSpeaking
        {
            synthesizer.stopSpeaking(at: .immediate)
        }
        deactivateSessionIfNeeded()
    }

    deinit
    {
        // 确保释放AVSpeechSynthesizer资源
        stopSpeaking()
    }

    func speak(_ text: String)
    {
        activateSessionIfNeeded()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    // MARK: - 健身播报功能

    /// 播报下一组动作信息
    /// - Parameters:
    ///   - exerciseName: 动作名称
    ///   - weight: 重量（公斤）
    ///   - reps: 次数
    func announceNextSet(exerciseName: String, weight: Double, reps: Int)
    {
        let weightText = formatWeightForSpeech(weight)
        let message = "接下来进行'\(exerciseName)'，'\(weightText)'，'\(reps)次'。"
        speak(message)
    }

    /// 播报休息倒计时
    /// - Parameter seconds: 剩余秒数
    func announceRestCountdown(seconds: Int)
    {
        let message = "休息还有\(seconds)秒"
        speak(message)
    }

    /// 播报休息完成，准备开始训练
    func announceRestComplete()
    {
        let message = "休息完成，开始训练"
        speak(message)
    }

    /// 格式化重量用于语音播报
    /// - Parameter weight: 重量值
    /// - Returns: 格式化后的重量字符串
    private func formatWeightForSpeech(_ weight: Double) -> String
    {
        if weight == 0
        {
            return "自重"
        }
        else if weight.truncatingRemainder(dividingBy: 1) == 0
        {
            return String(format: "%.0f公斤", weight)
        }
        else
        {
            return String(format: "%.1f公斤", weight)
        }
    }

    // MARK: - Audio Session Handling

    private func activateSessionIfNeeded()
    {
        guard !sessionActive else { return }
        do
        {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            sessionActive = true
        }
        catch
        {
            #if DEBUG
                print("音频会话激活失败: \(error)")
            #endif
        }
    }

    private func deactivateSessionIfNeeded()
    {
        guard sessionActive else { return }
        do
        {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
            sessionActive = false
        }
        catch
        {
            #if DEBUG
                print("音频会话停用失败: \(error)")
            #endif
        }
    }
}

extension VoiceManager: AVSpeechSynthesizerDelegate
{
    func speechSynthesizer(_: AVSpeechSynthesizer, didFinish _: AVSpeechUtterance)
    {
        // 播放完成后关闭音频会话，避免长时间占用
        deactivateSessionIfNeeded()
    }

    func speechSynthesizer(_: AVSpeechSynthesizer, didCancel _: AVSpeechUtterance)
    {
        deactivateSessionIfNeeded()
    }
}

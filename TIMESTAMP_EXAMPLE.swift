//created by Jason Lu on 09:15:30 10/10/2025
//
// 全局配置更新示例文件
// 此文件用于演示新的时间戳格式要求
//
// 修改内容：
// - 添加了中文交流全局规则
// - 添加了文件时间戳要求规则
// - 更新了快速参考部分

import Foundation

/// 示例类，演示时间戳格式和中文注释
class GlobalConfigExample {
    /// 配置项名称
    let configName: String

    /// 配置值
    let configValue: Any

    /// 初始化方法
    /// - Parameters:
    ///   - name: 配置项名称
    ///   - value: 配置值
    init(name: String, value: Any) {
        self.configName = name
        self.configValue = value
    }

    /// 获取配置描述
    /// - Returns: 中文配置描述
    func getDescription() -> String {
        return "配置项：\(configName)，值：\(configValue)"
    }
}
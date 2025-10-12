# Fit 应用部署指南

//created by Jason Lu on 09:17:00 10/12/2025

## 📋 部署概述

本指南详细说明了Fit应用的部署流程，包括TestFlight内测、App Store正式发布以及版本管理策略。

## 🎯 部署目标

### 主要目标
- **快速迭代**：支持快速的功能更新和bug修复
- **质量保证**：确保每个版本的稳定性和性能
- **用户体验**：提供流畅的更新和安装体验
- **数据安全**：保护用户数据和隐私

### 部署渠道
1. **TestFlight** - 内测版本分发
2. **App Store** - 正式版本发布
3. **企业分发** - 企业内部部署（未来扩展）

## 🏗️ 环境配置

### 开发环境
```bash
# 环境变量配置
DEVELOPMENT_MODE=true
API_BASE_URL=https://dev-api.fitapp.com/v1
LOG_LEVEL=debug
CRASH_REPORTING=true
ANALYTICS_ENABLED=false
```

### 测试环境
```bash
# 环境变量配置
DEVELOPMENT_MODE=false
API_BASE_URL=https://staging-api.fitapp.com/v1
LOG_LEVEL=info
CRASH_REPORTING=true
ANALYTICS_ENABLED=false
```

### 生产环境
```bash
# 环境变量配置
DEVELOPMENT_MODE=false
API_BASE_URL=https://api.fitapp.com/v1
LOG_LEVEL=error
CRASH_REPORTING=true
ANALYTICS_ENABLED=true
```

## 📱 Xcode项目配置

### 项目设置

#### 基本配置
```swift
// Info.plist 配置
<key>CFBundleDisplayName</key>
<string>Fit</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>mailto</string>
    <string>sms</string>
</array>
```

#### 权限配置
```swift
// Info.plist 权限声明
<key>NSHealthShareUsageDescription</key>
<string>Fit需要访问健康数据来记录您的训练信息</string>

<key>NSMotionUsageDescription</key>
<string>Fit需要访问运动数据来提供准确的训练记录</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Fit需要访问相册来保存训练照片</string>
```

### 构建配置

#### Debug配置
```swift
// Build Settings - Debug
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
SWIFT_OPTIMIZATION_LEVEL = -Onone
ENABLE_TESTABILITY = YES
GCC_PREPROCESSOR_DEFINITIONS = DEBUG=1
```

#### Release配置
```swift
// Build Settings - Release
SWIFT_OPTIMIZATION_LEVEL = -O
ENABLE_TESTABILITY = NO
VALIDATE_PRODUCT = YES
STRIP_INSTALLED_PRODUCT = YES
```

## 🧪 测试策略

### 自动化测试

#### 单元测试
```bash
# 运行单元测试
xcodebuild test \
  -project Fit.xcodeproj \
  -scheme Fit \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:FitTests
```

#### UI测试
```bash
# 运行UI测试
xcodebuild test \
  -project Fit.xcodeproj \
  -scheme Fit \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:FitUITests
```

### 手动测试清单

#### 功能测试
- [ ] 应用启动和界面加载
- [ ] 用户注册和登录流程
- [ ] 训练记录完整流程
- [ ] 数据同步和备份
- [ ] 设置和偏好设置

#### 兼容性测试
- [ ] iOS 15.0 - iOS 17.0
- [ ] iPhone SE (第2代) - iPhone 15 Pro Max
- [ ] iPad 兼容性（如果支持）
- [ ] 暗色模式适配
- [ ] 动态字体大小

#### 性能测试
- [ ] 应用启动时间 < 3秒
- [ ] 界面切换响应 < 300ms
- [ ] 内存使用 < 100MB
- [ ] 电池消耗测试

## 🚀 TestFlight部署

### 准备工作

#### 版本号管理
```bash
# 版本号格式：主版本.次版本.修订版本
# 示例：1.0.0, 1.0.1, 1.1.0

# 构建号：递增数字
# 示例：1, 2, 3, ...
```

#### 测试用户组
- **内部测试组**：开发团队和测试团队
- **外部测试组**：种子用户和反馈用户
- **压力测试组**：大规模用户测试

### 发布流程

#### 1. 构建Archive
```bash
# Xcode构建
Product -> Archive

# 或者命令行构建
xcodebuild archive \
  -project Fit.xcodeproj \
  -scheme Fit \
  -configuration Release \
  -archivePath ./build/Fit.xcarchive
```

#### 2. 验证和上传
```bash
# 验证Archive
xcodebuild -exportArchive \
  -archivePath ./build/Fit.xcarchive \
  -exportPath ./build/ \
  -exportOptionsPlist ExportOptions.plist

# 上传到TestFlight
xcrun altool --upload-app \
  --type ios \
  --file ./build/Fit.ipa \
  --asc-provider <ProviderShortName> \
  --username <AppleID> \
  --password <AppPassword>
```

#### 3. TestFlight配置
- **测试信息**：版本说明和测试重点
- **测试反馈**：配置反馈收集机制
- **测试期限**：设置测试周期

### 测试监控

#### 崩溃监控
```swift
// Crashlytics配置
import FirebaseCrashlytics

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // 设置用户标识符
        Crashlytics.sharedInstance().setUserID("user_id")

        return true
    }
}
```

#### 性能监控
```swift
// 性能指标收集
import UIKit

class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    func trackLaunchTime() {
        let launchTime = CFAbsoluteTimeGetCurrent() - appStartTime
        Analytics.logEvent("app_launch_time", parameters: [
            "duration": launchTime
        ])
    }

    func trackMemoryUsage() {
        let memoryUsage = getMemoryUsage()
        Analytics.logEvent("memory_usage", parameters: [
            "usage_mb": memoryUsage
        ])
    }
}
```

## 🏪 App Store发布

### 发布准备

#### 应用商店信息
- **应用名称**：Fit - 健身训练助手
- **应用描述**：简洁的训练记录应用
- **关键词**：健身,训练,锻炼,记录
- **分类**：健康与健身
- **年龄分级**：4+

#### 截图和预览
- **iPhone截图**：6.7"和5.5"屏幕
- **iPad截图**：12.9"和11"屏幕（如果支持）
- **预览视频**：15-30秒应用演示

#### 隐私政策
- 数据收集说明
- 数据使用目的
- 数据分享政策
- 用户权利说明

### 提交流程

#### 1. 应用审核准备
```swift
// 审核信息配置
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>

// 应用审核备注
应用功能说明：
- 训练记录和管理
- 数据统计和分析
- 个人进度跟踪
```

#### 2. 应用提交
```bash
# 使用Application Loader或Xcode直接提交
# 或者使用Transporter命令行工具

xcrun iTMSTransporter -m upload \
  -f ./build/Fit.itmsp \
  -u <AppleID> \
  -p <AppPassword>
```

#### 3. 审核状态跟踪
- **等待审核**：通常24-48小时
- **审核中**：苹果团队审核
- **被拒绝**：根据反馈修改
- **准备上架**：审核通过等待发布

### 发布后监控

#### 下载量统计
```swift
// 下载量跟踪
class AnalyticsManager {
    static func trackAppInstall() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            Analytics.logEvent("first_launch")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

    static func trackAppUpdate() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let lastVersion = UserDefaults.standard.string(forKey: "lastVersion")

        if currentVersion != lastVersion {
            Analytics.logEvent("app_updated", parameters: [
                "from_version": lastVersion ?? "unknown",
                "to_version": currentVersion ?? "unknown"
            ])
            UserDefaults.standard.set(currentVersion, forKey: "lastVersion")
        }
    }
}
```

#### 用户反馈处理
- **App Store评价**：定期查看和回复
- **用户邮件**：及时回复用户问题
- **社交媒体**：监控用户讨论

## 🔧 CI/CD集成

### GitHub Actions配置

#### 构建和测试
```yaml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

    - name: Build and Test
      run: |
        xcodebuild clean build test \
          -project Fit.xcodeproj \
          -scheme Fit \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -enableCodeCoverage YES

    - name: Upload Coverage
      uses: codecov/codecov-action@v3
```

#### 自动化部署
```yaml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Xcode
      run: |
        sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

    - name: Build Archive
      run: |
        xcodebuild archive \
          -project Fit.xcodeproj \
          -scheme Fit \
          -configuration Release \
          -archivePath ./build/Fit.xcarchive \
          -allowProvisioningUpdates

    - name: Export IPA
      run: |
        xcodebuild -exportArchive \
          -archivePath ./build/Fit.xcarchive \
          -exportPath ./build/ \
          -exportOptionsPlist ExportOptions.plist

    - name: Upload to TestFlight
      run: |
        xcrun altool --upload-app \
          --type ios \
          --file ./build/Fit.ipa \
          --asc-provider ${{ secrets.APPLE_PROVIDER_ID }} \
          --username ${{ secrets.APPLE_ID }} \
          --password ${{ secrets.APPLE_APP_PASSWORD }}
```

## 📊 版本管理策略

### 版本号规则

#### 语义化版本控制
```
主版本.次版本.修订版本 (MAJOR.MINOR.PATCH)

MAJOR: 不兼容的API变更
MINOR: 向后兼容的功能新增
PATCH: 向后兼容的问题修正

示例：
1.0.0 - 首次发布
1.1.0 - 新增功能
1.1.1 - bug修复
2.0.0 - 重大版本更新
```

#### 发布周期
- **主版本**：6-12个月
- **次版本**：1-3个月
- **修订版本**：按需发布（通常1-4周）

### 分支策略

#### Git Flow
```bash
main (生产分支)
├── develop (开发分支)
│   ├── feature/workout-recording
│   ├── feature/data-sync
│   └── feature/ui-redesign
├── release/v1.1.0 (发布分支)
└── hotfix/critical-bug (热修复分支)
```

#### 分支保护规则
- **main分支**：只接受来自release和hotfix的合并
- **develop分支**：需要代码审查和CI通过
- **feature分支**：从develop创建，完成后合并回develop

## 🔍 质量保证

### 代码质量检查

#### SwiftLint集成
```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional

line_length:
  warning: 120
  error: 150
```

#### 静态分析
```bash
# 使用Xcode静态分析
xcodebuild analyze \
  -project Fit.xcodeproj \
  -scheme Fit \
  -configuration Release
```

### 性能测试

#### 启动时间测试
```swift
import XCTest

class LaunchTimeTests: XCTestCase {
    func testAppLaunchTime() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let app = XCUIApplication()
            app.launch()

            // 等待主界面加载完成
            XCTAssertTrue(app.staticTexts["开始训练"].waitForExistence(timeout: 3.0))
        }
    }
}
```

## 🚨 故障排除

### 常见问题

#### 构建失败
```bash
# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean

# 重置模拟器
xcrun simctl erase all

# 重新安装依赖
pod install
```

#### 上传失败
```bash
# 检查应用签名
codesign -dv ./build/Fit.ipa

# 验证应用元数据
xcrun altool --validate-app \
  --type ios \
  --file ./build/Fit.ipa \
  --asc-provider <ProviderShortName> \
  --username <AppleID> \
  --password <AppPassword>
```

#### 审核被拒
1. **仔细阅读审核指南**：确保应用符合所有规定
2. **修改应用**：根据审核反馈进行修改
3. **重新提交**：说明修改内容和原因

### 应急发布流程

#### 热修复
```bash
# 创建热修复分支
git checkout -b hotfix/critical-bug

# 修复问题
# 更新版本号（PATCH版本）
# 测试验证
# 提交审核

# 合并到主分支和开发分支
git checkout main
git merge hotfix/critical-bug
git checkout develop
git merge hotfix/critical-bug
```

#### 回滚策略
- **App Store回滚**：移除问题版本
- **TestFlight回滚**：替换为稳定版本
- **紧急修复**：快速发布修复版本

## 📋 检查清单

### 发布前检查
- [ ] 所有测试通过
- [ ] 代码质量检查通过
- [ ] 性能指标达标
- [ ] 应用元数据完整
- [ ] 截图和预览准备
- [ ] 隐私政策更新
- [ ] 版本号正确
- [ ] 构建号递增

### 发布后检查
- [ ] 应用在App Store可见
- [ ] 下载量正常
- [ ] 崩溃率低
- [ ] 用户反馈积极
- [ ] 监控指标正常

---

这份部署指南为Fit应用提供了完整的部署流程和质量保证策略，确保应用能够稳定、高效地发布和运行。
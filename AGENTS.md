# Repository Guidelines

## 项目结构与模块组织
- 主应用在 `Fit/`，关键子目录：`Views/`、`ViewModels/`、`Models/`、`Services/`、`DesignSystem/`、`Utilities/`、`Integrations/`、`Assets.xcassets`；根目录的 `NavigationManager.swift` 负责导航。
- 测试位于 `FitTests/`（如 `DataValidationTests.swift`、`DebugModeTests.swift`），命名与生产类型对应并以 `Tests` 结尾。
- 自动化脚本在 `scripts/`（`build.sh`、`pre-build-check.sh`、`deploy.sh`），常用别名在 `.dev-aliases`。文档在 `docs/`，AI 提示示例在 `ForAI/`，示例训练计划 `10202028.JSON`、`11222025.json` 可作为测试数据。

## 构建、运行与开发命令
- `source .dev-aliases` 加载别名。
- `fit-check` 调用 `scripts/pre-build-check.sh`，验证 Xcode/SDK 与 Swift 语法。
- `fit-build-debug` / `fit-build-release` 或通用 `fit-build` 执行构建，日志写入 `logs/`。
- `fit-run` 构建后安装到当前已启动的模拟器并启动 App。
- 不用别名示例：`./scripts/build.sh Debug 'platform=iOS Simulator,name=iPhone 17' true` 进行 clean debug 构建。

## 代码风格与命名
- `fit-format` 使用 SwiftFormat：4 空格缩进、Allman 花括号、整理 import、禁用分号。
- `fit-lint` 使用 SwiftLint：120/150 字符阈值，关注强制解包/隐式解包；`fit-format-lint` 一次完成格式化与 lint。
- 类型与文件 PascalCase（如 `WorkoutSessionManager.swift`），变量/函数 camelCase；视图用 `struct ...: View` 且以 `View` 结尾，测试文件以源类型名 + `Tests`。

## 测试指南
- 提交前运行 `fit-test`（scheme `Fit`，iPhone 16e 目标）。
- 新测试放在 `FitTests/`，按领域组织；优先使用确定性数据（示例 JSON）验证 `WorkoutSessionManager` 和计划解析。
- 快速迭代命令示例：`xcodebuild test -project Fit.xcodeproj -scheme Fit -destination 'platform=iOS Simulator,name=iPhone 17'`。

## 提交与 PR 规范
- 沿用历史前缀：`feat:`、`fix:`、`chore:`、`docs:`、`refactor:`、`test:`；用祈使语气、范围清晰。
- PR 包含：简述、关联 issue（如有）、已执行命令/测试、UI 改动的截图或录屏。如本地 Xcode/SDK 不同，请在描述中说明并参考 `scripts/pre-build-check.sh`。

## 安全与配置提示
- 不要提交 DerivedData、构建日志或签名文件；`fit-clean-all` 清理本地产物。
- 示例训练计划仅供本地测试，避免提交用户数据。真机构建前请调整 Bundle ID 和签名到个人团队。

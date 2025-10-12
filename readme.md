# Fit - 健身训练助手

//created by Jason Lu on 09:17:00 10/12/2025

> **一句话描述**：一款专为iOS设计的SwiftUI健身训练应用，提供简洁的训练记录和进度追踪功能。

## 🚀 快速开始

### 系统要求
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### 安装依赖
```bash
# 克隆项目
git clone https://github.com/your-username/Fit.git
cd Fit

# 安装开发工具脚本
./scripts/dev-setup.sh
```

### 快速运行
```bash
# 调试版本构建
./scripts/build.sh debug

# 运行在模拟器
open Fit.xcodeproj
# 或使用命令行
xcodebuild -project Fit.xcodeproj -scheme Fit -destination 'platform=iOS Simulator,name=iPhone 14' build
```

## 📋 项目依赖

### 核心依赖
- **SwiftUI** - 用户界面框架
- **Combine** - 响应式编程
- **Core Data** - 本地数据存储（可选）

### 开发工具
- **SwiftLint** - 代码风格检查
- **SwiftFormat** - 代码格式化
- **Xcode** - 开发环境

### 项目结构
```
Fit/
├── Fit/                    # 主要源代码
│   ├── Components/         # 可复用组件
│   ├── DesignSystem/       # 设计系统
│   ├── Models/            # 数据模型
│   ├── Views/             # 视图组件
│   ├── ViewModels/        # 视图模型
│   └── FitApp.swift       # 应用入口
├── scripts/               # 构建和工具脚本
├── docs/                  # 项目文档
├── .claude/              # AI助手配置
└── claudedocs/           # Claude文档缓存
```

## 🎯 核心功能

- **训练记录** - 记录每组训练的重量和次数
- **进度追踪** - 可视化训练进度和变化
- **简单界面** - 专注训练，减少干扰

## 📚 项目文档体系

### 📋 文档规范

**重要规范**：
- **所有文档必须采用中文编写**（除必要的配置文件外）
- **所有文档更新时必须添加时间戳**，格式：`//created by Jason Lu on HH:MM:SS MM/DD/YYYY`
- **所有回复和沟通必须使用中文**
- **文档内容必须清晰、准确、实用**

### 🗂️ 核心文档目录

#### **项目概览**
- **[UI.md](UI.md)** - 完整的UI架构和组件说明
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - 系统架构地图和设计模式
- **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** - AI业务词典和不变规则

#### **开发规范**
- **[CODING_STANDARDS.md](CODING_STANDARDS.md)** - 编码规范和最佳实践
- **[COMMIT_MSG.md](COMMIT_MSG.md)** - Git提交信息格式规范
- **[CODE_REVIEW.md](CODE_REVIEW.md)** - 代码审查清单和流程

#### **AI助手专用** (.claude目录)
- **[.claude/architecture.md](.claude/architecture.md)** - AI战术手册和模块指南
- **[.claude/api-contracts.md](.claude/api-contracts.md)** - 语义化API契约
- **[.claude/frontend-ux-design-guide.md](.claude/frontend-ux-design-guide.md)** - SwiftUI设计指南
- **[.claude/gen-swiftui-view.md](.claude/gen-swiftui-view.md)** - SwiftUI视图生成模板
- **[.claude/settings.json](.claude/settings.json)** - AI行为配置

#### **详细文档** (docs目录)
- **[docs/features/workout-loop.md](docs/features/workout-loop.md)** - 用户故事和验收标准
- **[docs/features/workout-loop--api-spec.yaml](docs/features/workout-loop--api-spec.yaml)** - OpenAPI规格
- **[deployment-guide.md](deployment-guide.md)** - 完整的部署指南
- **[ci-failure-cookbook.md](ci-failure-cookbook.md)** - CI故障排除手册

### 🎯 文档使用指南

#### 快速定位文档
```
问题类型 → 推荐文档

架构相关问题:
├── 系统整体架构 → ARCHITECTURE.md
├── 模块依赖关系 → .claude/architecture.md
└── 数据流设计 → ARCHITECTURE.md

开发规范问题:
├── 编码风格 → CODING_STANDARDS.md
├── Git提交规范 → COMMIT_MSG.md
├── 代码审查 → CODE_REVIEW.md
└── 命名规范 → CODING_STANDARDS.md

UI/UX设计问题:
├── 界面结构 → UI.md
├── 设计系统 → .claude/frontend-ux-design-guide.md
├── 组件开发 → .claude/gen-swiftui-view.md
└── 样式指南 → .claude/frontend-ux-design-guide.md

API和数据问题:
├── 业务概念 → PROJECT_CONTEXT.md
├── API设计 → .claude/api-contracts.md
├── 数据模型 → ARCHITECTURE.md
└── 功能规范 → docs/features/

部署和运维:
├── 部署流程 → deployment-guide.md
├── CI/CD问题 → ci-failure-cookbook.md
└── 环境配置 → deployment-guide.md
```

#### AI助手使用规范
在向AI助手提问时，可以参考以下示例：
- "请参考[ARCHITECTURE.md]中的数据流设计来解决这个问题"
- "根据[CODING_STANDARDS.md]的编码规范重构这段代码"
- "按照[.claude/gen-swiftui-view.md]的模板生成新的视图组件"

### 📝 文档维护责任

#### 创建新文档
1. **确定文档类型**：选择合适的文档分类
2. **遵循命名规范**：使用清晰、描述性的文件名
3. **添加时间戳**：必须包含创建时间
4. **使用中文编写**：确保内容准确易懂

#### 更新现有文档
1. **检查时间戳**：更新为当前系统时间
2. **保持格式一致**：遵循现有文档的格式规范
3. **验证内容准确性**：确保信息正确无误
4. **更新交叉引用**：检查相关文档的链接是否正确

#### 文档质量标准
- **准确性**：内容必须真实、准确
- **完整性**：信息必须全面、无遗漏
- **可读性**：结构清晰、语言简洁
- **实用性**：提供具体的操作指导

### 🔗 文档交叉引用

所有文档都应包含相关的交叉引用，方便快速导航。当某个文档引用了其他文档的内容时，应在相应位置提供明确的链接。

### 📊 文档更新频率

- **核心文档**（ARCHITECTURE.md、CODING_STANDARDS.md等）：重大变更时更新
- **功能文档**（features/*）：功能开发时更新
- **API文档**：接口变更时更新
- **部署文档**：部署流程变更时更新

## 🛠️ 开发指南

详细的开发指南请参考：
- [架构文档](ARCHITECTURE.md)
- [编码规范](CODING_STANDARDS.md)
- [代码审查清单](CODE_REVIEW.md)

## 📱 部署

支持以下部署方式：
- **TestFlight** - 内测版本分发
- **App Store** - 正式发布
- **模拟器** - 开发调试

详细部署指南请参考 [部署指南](deployment-guide.md)

---

**License**: MIT | **Version**: 1.0.0 | **Last Updated**: 2025-10-12
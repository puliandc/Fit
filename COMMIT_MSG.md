# Fit 项目 Commit Message 规范

//created by Jason Lu on 09:17:00 10/12/2025

## 📝 规范概述

本规范定义了Fit项目使用的Git Commit Message格式，确保提交历史的清晰和一致性。

## 🎯 格式规范

### 基本格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 简化格式（小改动）

```
<type>: <subject>
```

## 📋 类型定义

### 主要类型

**feat**: 新功能
- 添加新的功能特性
- 用户可见的功能变更

**fix**: 修复bug
- 修复程序错误
- 修复功能缺陷

**docs**: 文档更新
- 更新项目文档
- 添加或修改注释

**style**: 代码格式化
- 代码格式调整
- 不影响功能的样式修改

**refactor**: 代码重构
- 代码结构优化
- 不影响功能的代码修改

**test**: 测试相关
- 添加测试用例
- 修改测试代码

**chore**: 构建或工具相关
- 修改构建脚本
- 更新依赖配置

**perf**: 性能优化
- 提升性能的修改
- 优化算法或逻辑

### 特殊类型

**wip**: 工作进行中
- 暂存未完成的工作
- 临时保存进度

**revert**: 撤销更改
- 撤销之前的提交
- 回滚到之前的状态

## 🎯 作用域定义

### 功能模块

**ui**: 用户界面
- SwiftUI视图相关
- 界面布局和样式

**viewModel**: 业务逻辑
- ViewModel相关代码
- 业务逻辑处理

**model**: 数据模型
- 数据结构定义
- 数据模型相关

**navigation**: 导航功能
- 页面导航逻辑
- 路由相关代码

**storage**: 数据存储
- 数据持久化
- 本地存储相关

**build**: 构建配置
- Xcode项目配置
- 构建脚本相关

**ci**: 持续集成
- GitHub Actions配置
- 自动化构建相关

### 示例

```
feat(ui): 添加训练记录界面

feat(viewModel): 实现训练数据管理逻辑

fix(model): 修复训练组数数据验证问题

docs(readme): 更新项目安装说明

style(ui): 调整按钮样式格式

refactor(viewModel): 重构训练状态管理

test(viewModel): 添加训练逻辑单元测试

chore(build): 更新SwiftLint配置

perf(storage): 优化数据加载性能
```

## 📝 主题行规范

### 长度限制

- 不超过50个字符
- 使用简洁、清晰的语言
- 首字母小写
- 不以句号结尾

### 书写规范

**正确示例**：
```
feat(ui): 添加训练开始按钮
fix(viewModel): 修复重量验证逻辑
docs(readme): 更新开发环境配置
```

**错误示例**：
```
feat(ui): Add Workout Start Button
fix(viewModel): Fix weight validation logic.
docs(readme): 更新开发环境配置说明文档
```

## 📄 正文规范

### 格式要求

- 如果有详细说明，需要空一行后开始正文
- 每行不超过72个字符
- 解释"是什么"和"为什么"
- 不要解释"怎么做"

### 内容要求

**必要内容**：
- 当前行为的描述
- 修改的原因
- 解决的问题

**可选内容**：
- 相关的Issue编号
- 实现思路
- 测试说明

### 示例

```
feat(ui): 添加训练完成统计界面

新增训练完成后的统计展示界面，包括：
- 本次训练总组数
- 总重量统计
- 训练时长显示

这个界面帮助用户了解训练效果，
提升用户体验和成就感。

Closes #23
```

## 🔗 页脚规范

### 关联Issue

```
Closes #23
Fixes #45
Resolves #67
```

### 破坏性变更

```
BREAKING CHANGE: 重构训练数据模型，
移除了deprecated的WorkoutEntry结构体
```

### 协作者

```
Co-authored-by: 张三 <zhangsan@example.com>
Reviewed-by: 李四 <lisi@example.com>
```

## 🎯 实际示例

### 新功能示例

```
feat(storage): 实现训练数据本地存储

使用UserDefaults存储训练数据，包括：
- 训练记录列表
- 训练组数详情
- 训练时间统计

为将来的Core Data迁移做准备，
确保数据结构的兼容性。

Closes #15
```

### Bug修复示例

```
fix(ui): 修复训练界面返回按钮不响应问题

问题原因：导航管理器状态更新延迟
解决方案：使用@StateObject确保状态一致性
影响范围：训练界面的所有导航操作

这个修复解决了用户反馈的界面卡死问题
```

### 文档更新示例

```
docs(contributing): 添加代码审查指南

新增代码审查的详细流程和检查清单：
- 代码质量检查项
- 设计原则验证
- 测试覆盖率要求

帮助团队成员提高代码质量，
减少代码审查的时间成本
```

## 🚫 禁止事项

### 格式问题

- ❌ 不使用正确的格式
- ❌ 主题行过长
- ❌ 使用中文标点符号
- ❌ 混合中英文标点

### 内容问题

- ❌ 主题行过于笼统
- ❌ 正文描述不清楚
- ❌ 包含敏感信息
- ❌ 使用不专业的语言

### 示例对比

**好的示例**：
```
feat(ui): 添加训练组数编辑对话框

实现训练组数的实时编辑功能，
支持重量和次数的输入验证。
使用模态对话框展示编辑界面。
```

**不好的示例**：
```
feat: 修改界面
添加了一个对话框，可以编辑训练数据。
```

## 🔧 工具支持

### Git Hook配置

```bash
#!/bin/sh
# commit-msg hook

# 检查commit message格式
commit_regex='^(feat|fix|docs|style|refactor|test|chore|perf|wip|revert)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Commit message格式不符合规范"
    echo "请使用: <type>(<scope>): <subject>"
    exit 1
fi
```

### VSCode插件推荐

- **GitLens**: 增强Git功能
- **Commitizen**: 交互式commit message生成
- **Conventional Commits**: 规范检查

## 📋 检查清单

### 提交前检查

- [ ] 类型选择正确
- [ ] 作用域明确
- [ ] 主题行简洁清晰
- [ ] 长度符合要求
- [ ] 正文描述详细（如果需要）
- [ ] 关联Issue（如果适用）
- [ ] 无拼写错误
- [ ] 使用中文标点符号

### 团队审查标准

- [ ] 提交信息清晰易懂
- [ ] 变更范围明确
- [ ] 原因说明充分
- [ ] 格式符合规范
- [ ] 便于代码审查

---

遵循这个规范将使项目的Git历史更加清晰，便于代码审查和问题追踪。
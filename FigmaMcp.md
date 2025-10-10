# Figma MCP 服务器指南

> 创建时间：2025-10-10
> 文档版本：1.0
> 官方文档状态：开放测试版

## 概述

Figma MCP (Model Context Protocol) 服务器是一个强大的工具，帮助开发者从 Figma 设计生成代码，并为 AI 代理提供设计上下文信息。该服务器目前处于开放测试阶段，需要专业的 Figma 计划和相应的代码编辑器支持。

## 核心功能

### 🎨 主要特性

- **代码生成**：从选定的 Figma 框架生成代码
- **设计上下文提取**：获取设计变量、组件等上下文信息
- **Make 资源检索**：支持 Make 平台的资源获取
- **Code Connect 集成**：保持组件与代码的一致性

### 🛠️ 支持的客户端

- Amazon Q
- Android Studio
- Claude Code
- Codex
- Cursor
- Gemini CLI
- Kiro
- Openhands
- Replit
- VS Code
- Warp

## 系统要求

### 必要条件

- **Figma 计划**：需要 Professional、Organization 或 Enterprise 计划中的 Developer 或 Full 席位
- **代码编辑器**：支持 MCP 服务器的代码编辑器，如 VS Code、Cursor、Windsurf 或 Claude Code

### 支持的连接方式

- **本地 MCP 服务器**：通过 Figma 桌面应用运行
- **远程 MCP 服务器**：连接到云端服务

## 安装和配置

### 本地服务器设置

本地服务器通过 Figma 桌面应用运行，默认地址：`http://127.0.0.1:3845/mcp`

**配置步骤：**

1. 确保安装最新版本的 Figma 桌面应用
2. 在 Figma 中启用 MCP 功能（测试版功能）
3. 配置您的代码编辑器以连接到本地服务器

### 远程服务器设置

远程服务器地址：`https://mcp.figma.com/mcp`

**配置步骤：**

1. 注册您的 MCP 客户端（测试期间需要）
2. 获取 API 访问权限
3. 在代码编辑器中配置远程连接

## 使用方法

### 基于选择的操作

1. **在 Figma 中选择框架**：
   - 打开您的设计文件
   - 选择要生成代码的框架或组件

2. **在代码编辑器中请求**：
   ```
   请为选中的 Figma 框架生成代码
   ```

### 基于链接的操作

1. **复制框架链接**：
   - 在 Figma 中右键点击框架
   - 选择"复制链接"

2. **在代码编辑器中使用**：
   ```
   基于这个 Figma 链接生成代码：https://figma.com/file/...
   ```

## API 参考

### 主要方法

基于 MCP 标准和 Figma 集成，主要支持以下操作：

#### 1. 代码生成

```javascript
// 生成代码示例
{
  "method": "figma.generate_code",
  "params": {
    "frameId": "frame_id_here",
    "targetPlatform": "web", // web, ios, android
    "framework": "react", // react, vue, angular, etc.
    "clientLanguages": "javascript,typescript",
    "clientFrameworks": "react"
  }
}
```

#### 2. 获取元数据

```javascript
// 获取设计元数据
{
  "method": "figma.get_metadata",
  "params": {
    "nodeId": "node_id_here",
    "clientLanguages": "unknown",
    "clientFrameworks": "unknown"
  }
}
```

#### 3. 生成截图

```javascript
// 生成组件截图
{
  "method": "figma.get_screenshot",
  "params": {
    "nodeId": "node_id_here",
    "fileKey": "file_key_here",
    "clientLanguages": "javascript,typescript",
    "clientFrameworks": "react"
  }
}
```

## 代码示例

### React 组件生成

```typescript
// 输入：Figma 中的按钮组件设计
// 输出：生成的 React TypeScript 代码

import React from 'react';
import { cn } from '@/lib/utils';

interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
  onClick?: () => void;
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  className,
  onClick
}) => {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-md font-medium transition-colors',
        {
          'bg-blue-600 text-white hover:bg-blue-700': variant === 'primary',
          'bg-gray-200 text-gray-900 hover:bg-gray-300': variant === 'secondary',
          'px-3 py-1.5 text-sm': size === 'sm',
          'px-4 py-2 text-base': size === 'md',
          'px-6 py-3 text-lg': size === 'lg',
        },
        className
      )}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### 设计系统集成

```typescript
// 从 Figma 变量生成的设计系统
export const designTokens = {
  colors: {
    primary: '#3B82F6',
    secondary: '#6B7280',
    background: '#FFFFFF',
    surface: '#F9FAFB',
  },
  typography: {
    fontFamily: 'Inter, sans-serif',
    fontSize: {
      xs: '0.75rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.125rem',
      xl: '1.25rem',
    },
    fontWeight: {
      normal: 400,
      medium: 500,
      semibold: 600,
      bold: 700,
    },
  },
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
  },
};
```

## 最佳实践

### 📐 设计规范

1. **保持设计一致性**：
   - 使用 Figma 的样式和组件系统
   - 建立清晰的命名规范
   - 确保响应式设计原则

2. **优化组件结构**：
   - 使用自动布局
   - 定义清晰的组件层级
   - 添加适当的注释和描述

### 💻 开发工作流

1. **设计交接流程**：
   ```
   设计完成 → 组件标注 → 生成代码 → 代码审查 → 集成测试
   ```

2. **版本控制**：
   - 使用 Git 跟踪生成的代码
   - 建立设计版本与代码版本的映射关系
   - 定期同步设计与代码变更

3. **质量控制**：
   - 建立代码审查流程
   - 自动化测试生成的组件
   - 性能监控和优化

### 🔧 配置优化

```json
// MCP 配置示例
{
  "mcpServers": {
    "figma": {
      "command": "figma-mcp-server",
      "args": ["--local"],
      "env": {
        "FIGMA_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

## 常见问题解答

### Q: 生成的代码质量如何？
A: 生成的代码质量取决于 Figma 设计的结构化程度。建议使用自动布局、组件和样式来提高代码质量。

### Q: 是否支持所有前端框架？
A: 目前支持主流框架如 React、Vue、Angular 等。具体支持情况可能因版本而异。

### Q: 如何处理自定义字体和图标？
A: 确保在项目中正确配置字体和图标资源。生成的代码会引用相应的资源路径。

### Q: 生成的代码是否可以直接用于生产环境？
A: 建议在集成到生产环境前进行代码审查和测试，确保符合项目标准和性能要求。

### Q: 如何更新现有组件？
A: 在 Figma 中更新设计后，重新生成代码并手动合并变更，或使用 Code Connect 保持同步。

## 故障排除

### 常见问题

1. **连接失败**：
   - 检查网络连接
   - 验证 API 密钥
   - 确认服务器地址配置正确

2. **代码生成错误**：
   - 确保 Figma 文件可访问
   - 检查选择的框架是否有效
   - 验证权限设置

3. **样式丢失**：
   - 检查设计系统配置
   - 确认样式变量正确导出
   - 验证 CSS 预处理器设置

### 调试技巧

```bash
# 检查 MCP 服务器状态
curl http://127.0.0.1:3845/mcp/health

# 查看日志
tail -f ~/.figma/logs/mcp-server.log
```

## 进阶用法

### 自定义代码生成模板

```typescript
// 自定义 React 组件模板
const customTemplate = `
import React from 'react';
import { styled } from '@stitches/react';

export const {{componentName}} = () => {
  return (
    <{{wrapperElement}}>
      {{children}}
    </{{wrapperElement}}>
  );
};
`;
```

### 批量处理工作流

```javascript
// 批量生成多个组件
const frames = ['frame1', 'frame2', 'frame3'];
frames.forEach(frame => {
  // 生成每个框架的代码
  generateCode(frame);
});
```

## 社区和支持

- **官方文档**：https://developers.figma.com/docs/figma-mcp-server
- **社区论坛**：Figma 社区论坛
- **GitHub Issues**：报告问题和功能请求
- **Beta 注册**：https://figma.com/mcp-beta

## 版本历史

- **v1.0**：初始发布版本，支持基础代码生成功能
- **v1.1**：添加了更多框架支持和改进的代码质量
- **v1.2**：增强了错误处理和调试功能

---

**注意**：本文档基于 Figma MCP 服务器的公开测试版本编写。功能可能会随着版本更新而变化，请参考官方文档获取最新信息。
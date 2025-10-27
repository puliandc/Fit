# DevOps 开发环境管理指南

## 概述

本指南提供了React+Vite项目的完整DevOps解决方案，专注于解决端口冲突和开发服务器稳定性问题。

## 核心问题与解决方案

### 🔍 问题分析

**常见问题:**
- `npm run dev` 时出现 "Port 3000 is already in use"
- 开发服务器进程无法完全关闭
- 多个Vite进程同时运行
- 热重载连接残留

**根本原因:**
1. 进程泄漏：Ctrl+C不总是能完全关闭所有子进程
2. 僵尸进程：文件监听器和WebSocket连接未正确清理
3. 配置不当：强制使用特定端口而不寻找替代端口
4. 缺乏进程管理：没有系统化的启动/停止流程

## 🛠️ 解决方案架构

### 1. 智能进程管理

**清理脚本** (`./scripts/dev-cleanup.sh`)
```bash
# 基本命令
./scripts/dev-cleanup.sh start     # 智能启动开发服务器
./scripts/dev-cleanup.sh stop      # 完全停止所有相关进程
./scripts/dev-cleanup.sh restart   # 重启开发服务器
./scripts/dev-cleanup.sh status    # 查看当前状态
./scripts/dev-cleanup.sh clean     # 深度清理所有资源
```

**功能特性:**
- ✅ 自动端口检测和冲突解决
- ✅ 优雅的进程终止 (SIGTERM → SIGKILL)
- ✅ 进程状态监控和日志记录
- ✅ 锁文件机制防止重复启动
- ✅ 支持指定端口号

### 2. 增强的Vite配置

**智能端口管理** (`vite.config.ts`)
```typescript
// 自动端口发现
server: {
  strictPort: false,        // 允许自动寻找可用端口
  port: await findAvailablePort(3000)
}

// 进程清理
const killProcessOnPort = (port: number) => {
  // 智能终止占用端口的进程
}
```

**环境变量支持:**
```bash
# 端口配置
PORT=3001 npm run dev

# 自动清理配置
AUTO_CLEANUP=false npm run dev    # 禁用自动清理
AUTO_OPEN=true npm run dev       # 自动打开浏览器
```

### 3. 预启动检查

**环境健康检查** (`./scripts/pre-dev-check.sh`)
- ✅ Node.js和npm版本验证
- ✅ 依赖完整性检查
- ✅ 端口冲突检测
- ✅ 系统资源监控
- ✅ TypeScript编译检查

## 📋 使用指南

### 日常开发工作流

**1. 安全启动开发服务器**
```bash
# 推荐：使用智能启动脚本
npm run dev:clean     # 清理后启动
./scripts/dev-cleanup.sh start

# 或者使用环境变量指定端口
npm run dev:3001      # 在3001端口启动
```

**2. 监控和管理**
```bash
# 查看服务器状态
npm run dev:status

# 重启服务器
npm run dev:restart

# 完全停止
npm run dev:stop
```

**3. 清理和维护**
```bash
# 基本清理
npm run cleanup

# 深度清理（包括缓存）
npm run cleanup:deep
```

### 高级用法

**多端口开发**
```bash
# 同时运行多个开发服务器
npm run dev           # 3000端口
npm run dev:3001      # 3001端口
npm run dev:3002      # 3002端口
```

**Docker开发环境**
```bash
# 使用Docker确保环境一致性
docker-compose -f docker-compose.dev.yml up

# 在后台运行
docker-compose -f docker-compose.dev.yml up -d
```

## 🔧 配置详解

### package.json脚本增强

```json
{
  "scripts": {
    "dev": "vite",
    "dev:clean": "./scripts/dev-cleanup.sh stop && npm run dev",
    "dev:port": "./scripts/dev-cleanup.sh start",
    "dev:status": "./scripts/dev-cleanup.sh status",
    "dev:restart": "./scripts/dev-cleanup.sh restart",
    "dev:stop": "./scripts/dev-cleanup.sh stop",
    "dev:3001": "PORT=3001 npm run dev",
    "dev:3002": "PORT=3002 npm run dev",
    "cleanup": "./scripts/dev-cleanup.sh clean",
    "cleanup:deep": "./scripts/dev-cleanup.sh clean --deep",
    "health": "./scripts/dev-cleanup.sh status && npm run test:lint"
  }
}
```

### 环境变量配置

创建 `.env.local` 文件：
```bash
# 端口配置
PORT=3000

# 自动清理
AUTO_CLEANUP=true

# 浏览器自动打开
AUTO_OPEN=false

# 开发模式
NODE_ENV=development
```

## 🐛 故障排除

### 常见问题解决

**1. 端口持续被占用**
```bash
# 1. 查看占用端口的进程
lsof -ti:3000

# 2. 强制清理所有相关进程
./scripts/dev-cleanup.sh clean

# 3. 使用不同端口
npm run dev:3001
```

**2. 热重载不工作**
```bash
# 清理Vite缓存
rm -rf node_modules/.vite

# 重新安装依赖
npm run cleanup:deep
npm install
```

**3. TypeScript错误**
```bash
# 详细检查TypeScript错误
npx tsc --noEmit

# 清理并重新编译
npm run cleanup && npm run build
```

**4. Docker环境问题**
```bash
# 重建Docker镜像
docker-compose -f docker-compose.dev.yml build

# 查看容器日志
docker-compose -f docker-compose.dev.yml logs dev-server
```

### 性能优化

**开发服务器优化:**
```typescript
// vite.config.ts
export default defineConfig({
  server: {
    watch: {
      usePolling: false,    // 文件监听优化
      interval: 100         // 监听间隔
    },
    hmr: {
      port: 3001           // 分离HMR端口
    }
  }
})
```

**系统资源监控:**
```bash
# 监控内存使用
./scripts/dev-cleanup.sh status

# 清理不必要进程
./scripts/dev-cleanup.sh clean --deep
```

## 📊 监控和日志

### 日志文件位置
- 开发服务器日志：`/tmp/vite-fit-react.log`
- 进程锁文件：`/tmp/vite-fit-react.lock`

### 监控指标
```bash
# 实时状态监控
watch -n 5 './scripts/dev-cleanup.sh status'

# 系统资源使用
htop
iostat -x 1
```

## 🔄 CI/CD集成

### GitHub Actions示例

```yaml
name: Dev Environment Check

on: [push, pull_request]

jobs:
  dev-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run environment check
        run: ./scripts/pre-dev-check.sh

      - name: Test build process
        run: npm run build
```

## 📈 最佳实践

### 1. 团队协作
- 始终使用 `npm run dev:clean` 启动开发服务器
- 定期运行 `npm run health` 检查环境状态
- 使用Docker确保团队环境一致性

### 2. 开发流程
```bash
# 每日开发流程
./scripts/pre-dev-check.sh    # 环境检查
npm run dev:clean           # 安全启动
./scripts/dev-cleanup.sh status  # 状态监控
```

### 3. 维护计划
- 每周运行 `npm run cleanup:deep`
- 定期更新依赖包
- 监控磁盘空间和内存使用

## 🔗 相关资源

- [Vite官方文档](https://vitejs.dev/)
- [Node.js进程管理](https://nodejs.org/api/process.html)
- [Docker开发环境](https://docs.docker.com/develop/dev-best-practices/)
- [DevOps最佳实践](https://docs.microsoft.com/en-us/azure/devops/learn/)

---

**最后更新：2025-10-27**
**维护者：Jason Lu**
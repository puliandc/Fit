# React+Capacitor 开发环境配置指南
//created by Jason Lu on 18:32:00 10/26/2025

## 🚀 技术栈选择

### 核心技术栈
- **前端框架**: React 18+ with TypeScript
- **构建工具**: Vite 5+ (替代Create React App)
- **UI框架**: Tailwind CSS 3+ (保持与SwiftUI一致的设计语言)
- **状态管理**: Zustand (轻量级，适合训练记录状态)
- **跨平台**: Capacitor 6+ (最新版本，支持iOS 15+)
- **导航**: React Router v6
- **开发工具**: ESLint + Prettier + Husky

### 推荐的项目结构
```
fit-app/
├── src/
│   ├── components/          # React组件
│   │   ├── ui/           # 通用UI组件
│   │   ├── workout/      # 训练相关组件
│   │   └── timer/        # 计时器组件
│   ├── pages/            # 页面组件
│   ├── hooks/            # 自定义Hooks
│   ├── stores/           # Zustand状态管理
│   ├── services/         # 服务层（语音、文件等）
│   ├── types/            # TypeScript类型定义
│   ├── utils/            # 工具函数
│   └── assets/           # 静态资源
├── public/              # 公共资源
├── capacitor.config.ts   # Capacitor配置
├── vite.config.ts       # Vite构建配置
├── tailwind.config.js   # Tailwind配置
├── package.json         # 依赖管理
└── scripts/            # 构建和部署脚本
```

## 🔧 环境配置文件

### package.json 依赖配置
```json
{
  "name": "fit-workout-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "ios:dev": "cap run ios",
    "ios:build": "cap build ios",
    "android:dev": "cap run android",
    "android:build": "cap build android",
    "web:build": "vite build --mode web",
    "test": "vitest",
    "test:e2e": "playwright test",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "lint:fix": "eslint . --ext ts,tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,js,jsx,css,md}\""
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",
    "zustand": "^4.3.6",
    "@capacitor/core": "^6.0.0",
    "@capacitor/cli": "^6.0.0",
    "@capacitor/android": "^6.0.0",
    "@capacitor/ios": "^6.0.0",
    "@capacitor/speech-synthesis": "^6.0.0",
    "@capacitor/filesystem": "^6.0.0",
    "@capacitor/app": "^6.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.28",
    "@types/react-dom": "^18.0.11",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.0.2",
    "vite": "^5.0.0",
    "tailwindcss": "^3.3.0",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.23",
    "eslint": "^8.38.0",
    "@typescript-eslint/eslint-plugin": "^5.57.1",
    "@typescript-eslint/parser": "^5.57.1",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.3.4",
    "prettier": "^2.8.7",
    "husky": "^8.0.3",
    "lint-staged": "^13.2.0",
    "vitest": "^0.30.1",
    "@vitest/ui": "^0.30.1",
    "playwright": "^1.33.0"
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

### Vite 配置 (vite.config.ts)
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@components': resolve(__dirname, 'src/components'),
      '@pages': resolve(__dirname, 'src/pages'),
      '@hooks': resolve(__dirname, 'src/hooks'),
      '@stores': resolve(__dirname, 'src/stores'),
      '@services': resolve(__dirname, 'src/services'),
      '@types': resolve(__dirname, 'src/types'),
      '@utils': resolve(__dirname, 'src/utils')
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          capacitor: ['@capacitor/core']
        }
      }
    }
  },
  server: {
    port: 3000,
    open: true,
    cors: true
  }
})
```

### Capacitor 配置 (capacitor.config.ts)
```typescript
import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.jason.fit',
  appName: 'Fit',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  },
  ios: {
    scheme: 'Fit'
  },
  plugins: {
    SpeechSynthesis: {
      fallback: true // 在iOS上使用原生TTS
    },
    FileSystem: {
      permissions: ['read', 'write']
    }
  }
};

export default config;
```

### TypeScript 配置 (tsconfig.json)
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@pages/*": ["src/pages/*"],
      "@hooks/*": ["src/hooks/*"],
      "@stores/*": ["src/stores/*"],
      "@services/*": ["src/services/*"],
      "@types/*": ["src/types/*"],
      "@utils/*": ["src/utils/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

## 🛠️ 开发工具集成

### Cursor IDE 配置
```json
// .vscode/settings.json
{
  "typescript.preferences.importModuleSpecifier": "relative",
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "emmet.includeLanguages": {
    "typescript": "html",
    "typescriptreact": "html"
  },
  "files.associations": {
    "*.css": "tailwindcss"
  }
}
```

### ESLint 配置 (.eslintrc.cjs)
```javascript
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    'plugin:react-hooks/recommended'
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parser: '@typescript-eslint/parser',
  plugins: ['react-refresh'],
  rules: {
    'react-refresh/only-export-components': [
      'warn',
      { allowConstantExport: true }
    ],
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off'
  }
}
```

### Prettier 配置 (.prettierrc)
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

## 🎨 Tailwind CSS 配置

### tailwind.config.js
```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // 与SwiftUI深色主题匹配的调色板
        primary: {
          50: '#f0f9ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          900: '#1e293b'
        },
        background: '#000000',
        surface: '#1a1a1a',
        card: '#2a2a2a',
        text: '#ffffff',
        'text-secondary': '#9ca3af'
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'sans-serif']
      },
      spacing: {
        'safe-top': '44px', // iPhone安全区域
        'safe-bottom': '34px'
      }
    },
  },
  plugins: [],
  darkMode: 'class'
}
```

## 📱 移动端适配

### 安全区域处理
```css
/* public/styles.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* 安全区域适配 */
.safe-area {
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

/* 防止缩放 */
html {
  -webkit-text-size-adjust: 100%;
  -ms-text-size-adjust: 100%;
}

/* 移动端滚动优化 */
body {
  -webkit-overflow-scrolling: touch;
  overscroll-behavior: contain;
}
```

## 🚀 快速启动脚本

### 开发环境初始化
```bash
#!/bin/bash
# scripts/setup-dev.sh
set -euo pipefail

echo "🚀 Setting up React+Capacitor development environment..."

# 检查Node.js版本
node_version=$(node -v | cut -d'v' -f2)
required_version="18.0.0"
if [ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "❌ Node.js $required_version or higher is required. Current: $node_version"
    exit 1
fi

# 安装依赖
echo "📦 Installing dependencies..."
npm install

# 设置Git hooks
echo "🔧 Setting up Git hooks..."
npx husky install

# 初始化Capacitor
if [ ! -d "ios" ]; then
    echo "📱 Adding iOS platform..."
    npx cap add ios
fi

if [ ! -d "android" ]; then
    echo "🤖 Adding Android platform..."
    npx cap add android
fi

# 同步Web代码到原生平台
echo "🔄 Syncing web code to native platforms..."
npx cap sync

echo "✅ Development environment setup completed!"
echo ""
echo "🎯 Quick start commands:"
echo "  npm run dev          # Start web development server"
echo "  npm run ios:dev      # Run on iOS simulator"
echo "  npm run android:dev  # Run on Android emulator"
```

## 🔍 调试和测试策略

### 开发调试工具
1. **Web调试**: Chrome DevTools
2. **iOS调试**: Safari Web Inspector + Xcode Console
3. **Android调试**: Chrome DevTools + Android Studio Logcat
4. **Capacitor调试**: `npx cap run ios --livereload --external`

### 测试配置
```javascript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    globals: true
  }
})
```

## 📊 性能优化配置

### Vite 构建优化
```typescript
// 继续优化 vite.config.ts
export default defineConfig({
  // ... 之前配置
  build: {
    // ... 之前配置
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    },
    chunkSizeWarningLimit: 1000
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'zustand']
  }
})
```

这个配置为React+Capacitor项目提供了完整的开发环境设置，确保与现有SwiftUI应用的功能和设计语言保持一致。
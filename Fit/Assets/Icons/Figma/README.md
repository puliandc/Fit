# Figma 图标资源

//created by Jason Lu on 12:19:00 10/12/2025

## 📱 图标说明

本目录包含从Figma设计稿导出的SVG矢量图标，用于Fit应用的UI界面。

## 📁 文件列表

### 1. back-icon.svg
- **用途**: 导航返回按钮图标
- **应用**: WorkoutScreen顶部导航栏
- **尺寸**: 16x16pt（推荐显示尺寸）
- **颜色**: 单色SVG，可通过foregroundColor调整

### 2. time-icon.svg
- **用途**: 训练计时功能图标
- **应用**: CompactExerciseInfoCard中的动作时间模块
- **尺寸**: 20x20pt
- **颜色**: 橙色主题

### 3. sets-icon.svg
- **用途**: 组数显示图标
- **应用**: CompactExerciseInfoCard中的当前组数模块
- **尺寸**: 20x20pt
- **颜色**: 蓝色主题

### 4. weight-icon.svg
- **用途**: 重量显示图标
- **应用**: CompactExerciseInfoCard中的重量模块
- **尺寸**: 20x20pt
- **颜色**: 紫色主题

## 🎨 使用方式

在SwiftUI中使用这些SVG图标：

```swift
Image("back-icon")
    .resizable()
    .renderingMode(.template)
    .foregroundColor(.orange)
    .frame(width: 16, height: 16)

Image("time-icon")
    .resizable()
    .frame(width: 20, height: 20)
    .foregroundColor(.orange)

Image("sets-icon")
    .resizable()
    .frame(width: 20, height: 20)
    .foregroundColor(.blue)

Image("weight-icon")
    .resizable()
    .frame(width: 20, height: 20)
    .foregroundColor(.purple)
```

## 📋 集成状态

✅ **已完成**:
- 从Figma导出SVG图标资源
- 创建资源目录结构
- 文档说明和使用指南
- 集成到WorkoutScreen UI组件中

🔄 **特性**:
- SVG矢量格式，支持任意缩放
- 单色设计，可通过foregroundColor动态调整颜色
- iOS 13+原生支持，无需额外转换

---
*最后更新: 2025-10-12*
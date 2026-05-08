# XJTU Toolbox (Flutter 跨平台重构版)

![Flutter](https://img.shields.io/badge/Flutter-3.41.4-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.11.1-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)

本项目是西安交大工具箱（XJTU Toolbox）的 **Flutter 跨平台重构**工作区。本项目的核心策略是在移植具体的 UI 界面和网络实现之前，优先建立跨平台的系统架构和能力边界。

## 📌 当前状态

- 检测到的 Flutter SDK 路径：`D:\learn\code\env\flutter`
- 当前使用的 Flutter 版本为 `3.41.4`，Dart 版本为 `3.11.1`
- 已建立基础的 Dart 应用骨架、迁移待办清单以及核心的架构边界。

## 🚀 快速启动

在开始开发前，请确保您的 Flutter 环境配置正确，然后执行以下命令来初始化并构建项目：

```bash
# 进入项目目录
cd D:\learn\code\final\xjtu_toolbox_flutter

# 获取项目依赖
flutter pub get

# 运行基础单元测试验证环境
flutter test
```

## 📂 项目结构

本项目采用清晰的分层架构设计，便于跨平台功能的扩展和维护：

```text
lib/
  ├── main.dart               # 应用运行入口
  └── src/
      ├── app.dart            # Flutter App 根组件配置
      ├── core/               # 核心逻辑层 (如核心环境配置、会话管理等)
      ├── features/           # 业务功能层 (拆分为各个具体功能模块)
      ├── platform_bridge/    # 平台桥接层 (处理 Android/iOS 原生特性差异)
      ├── navigation/         # 导航和路由中心
      └── ui/                 # 跨平台通用 UI 组件与主题配置
docs/
  ├── migration_plan.md                     # 总体迁移计划
  ├── agent_technical_constraints.zh-CN.md  # 技术约束规范
  ├── agent_function_architecture.zh-CN.md  # 功能架构规范
  └── agent_cross_platform_constraints.zh-CN.md # 跨平台开发规范
```

## 🤖 AI 辅助开发指南 (Agent Context)

如果在开发过程中使用 AI Agent 或辅助编程工具，请务必在开始修改代码前阅读以下核心约束文档：

- `docs/agent_technical_constraints.zh-CN.md` (技术约束规范)
- `docs/agent_function_architecture.zh-CN.md` (功能架构规范)
- `docs/agent_cross_platform_constraints.zh-CN.md` (跨平台约束规范)

> 注：另有英文版规范留存于同目录下备查，并请参考仓库根目录的 `AGENTS.md` 熟悉开发工作流。

## 🚧 核心迁移法则

**⚠️ 非常重要：在开始逐步移植各个界面功能前，请务必先稳固以下基础技术边界：**

1. 身份验证/会话模型设计 (Auth/Session model)
2. Cookie 持久化方案与 WebView Cookie 的同步机制
3. WebVPN URL 统一转换策略
4. 本地缓存与数据库离线存储策略
5. 构建完善的 Android/iOS 软桥接（包含但不限于：原生控件嵌套、文件下载与分享、视频播放、安装更新流程）

---

*致力于为西交大学子打造更流畅的跨平台工具箱应用体验 🚀*

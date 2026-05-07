# XJTU Toolbox 跨平台开发约束

这份文档用于提醒你和其他智能体：本项目不是单纯的 Android Flutter UI 迁移，而是 Android 和 iOS 都要认真支持的跨平台项目。

## 核心原则

- Android 和 iOS 都是一等目标平台。
- 业务页面不得直接绑定某个平台的视觉语言或系统能力。
- Android 默认走 Material 3 风格。
- iOS / macOS 默认走 Cupertino / Liquid Glass-like 风格。
- 平台差异必须集中在 `lib/src/ui` 或 `lib/src/platform_bridge`，不要散落在功能页面里。

## UI 分层要求

功能页面优先使用项目级组件：

- `AppPage`
- `AppSurface`
- `AppListTile`
- `AppSectionHeader`
- `AppButton`
- `AppBadge`
- `AppShell`

不要在功能页面里直接大量使用：

- `Scaffold`
- `NavigationBar`
- `NavigationRail`
- `ListTile`
- `Card`
- `FilledButton`
- `CupertinoButton`
- `BackdropFilter`

如果确实需要使用平台组件，先判断它是否应该进入 `lib/src/ui` 的封装层。

## Android 视觉规则

- Android 以 Material 3 为默认设计语言。
- 主题、圆角、颜色、导航栏、按钮优先通过 `FlexThemeData` 和 `ThemeData` 管理。
- Android 页面应偏工具型应用：信息密度高、结构清晰、可快速扫描。
- 不要为了模拟 iOS 视觉而牺牲 Android 的原生手感。

## iOS 视觉规则

- iOS / macOS 走 Cupertino / Liquid Glass-like 方向。
- 允许使用半透明、blur、轻边框、浮动导航来模拟 iOS 26 风格。
- Liquid Glass-like 只能作为 Flutter 侧模拟，不要假设已经获得系统级 Liquid Glass 能力。
- iOS 上避免过重的 Material 卡片和底部导航外观。
- 任何透明和 blur 效果必须保证文字可读性和对比度。

## 平台能力边界

以下能力不能直接写在 Flutter 功能页面中：

- WebView Cookie 导入 / 导出
- 文件下载、公共 Downloads 目录、文件分享
- 后台任务、通知、前台服务
- Android 桌面小组件
- APK 更新 / 安装
- 视频播放和系统播放器能力
- 安全存储、钥匙串、加密偏好

这些能力必须先定义在 `lib/src/platform_bridge` 或平台服务边界后面，再由 Android / iOS 分别实现或降级。

## 依赖选择规则

- 可以积极使用第三方库简化开发，但必须确认 Android 和 iOS 支持情况。
- 新增 UI 依赖前先判断它是否会强绑定某一种平台风格。
- 新增平台能力依赖前必须确认 iOS 和 Android 的行为差异。
- 如果某个能力只能在 Android 完整支持，必须明确 iOS 降级行为。

## 开发检查清单

每次新增或修改功能前，先检查：

1. 这个页面是否直接使用了平台专属 UI 组件？
2. 是否可以用 `lib/src/ui` 中的 App 组件表达？
3. 是否引入了 Android-only 或 iOS-only 能力？
4. iOS 上是否需要 Cupertino / Liquid Glass-like 替代表现？
5. Android 上是否仍保留 Material 3 原生手感？
6. 是否需要在 `lib/src/platform_bridge` 增加接口？
7. 是否需要测试平台无关的 model、parser、state 逻辑？

## 智能体行为要求

- 改 UI 时，优先改或新增 `lib/src/ui` 的封装，而不是在多个页面复制样式。
- 改功能时，先保持业务逻辑平台无关，再处理平台差异。
- 遇到平台差异不要默认“Flutter 会自动处理”，要明确说明 Android 和 iOS 的行为。
- 不要因为当前主要参考 Android 原项目，就把 Flutter 版本写成 Android-only 体验。


# XJTU Toolbox Flutter 迁移技术约束

这份文档给你和其他智能体参考。任何智能体在为 Flutter 迁移项目添加功能、改架构、接接口之前，都应该先阅读本文，并同时阅读 `docs/agent_cross_platform_constraints.zh-CN.md`。

## 项目位置

- Flutter 迁移项目：`D:\learn\code\final\xjtu_toolbox_flutter`
- 原 Android 项目：`D:\learn\code\final\xjtu-toolbox-android`
- 原 Android 主代码目录：`D:\learn\code\final\xjtu-toolbox-android\app\src\main\java\com\xjtu\toolbox`

## 当前 Flutter 基线

- Flutter 应用包名：`xjtu_toolbox_flutter`
- 入口文件：`lib/main.dart`
- 应用壳：`lib/src/app.dart`
- 当前源码结构：
  - `lib/src/core`：平台无关模型、会话、应用级抽象
  - `lib/src/features`：Flutter 功能页面
  - `lib/src/platform_bridge`：原生能力桥接边界和说明
  - `docs`：迁移文档，供你和智能体阅读
- 已存在 Flutter 生成的平台目录：
  - `android/`
  - `ios/`

当前 Flutter 项目只是迁移工作区和基础骨架。不要假设原 Android 项目的功能已经在 Dart 中实现。

## 工具链注意事项

- 已观察到 Dart SDK 版本：`3.11.1`
- 本地 Flutter SDK 路径：`D:\learn\code\env\flutter`
- 此环境曾出现 `flutter test` / `flutter --version` 卡住，并留下 SDK 锁文件：
  - `D:\learn\code\env\flutter\bin\cache\lockfile`
  - `D:\learn\code\env\flutter\bin\cache\flutter.bat.lock`

如果 Flutter 命令卡住，应该先检查是否有残留的 Flutter/Dart 工具进程，再谨慎重试。不要为了修工具链问题删除项目源码。

本地构建约束：

- 本地只使用 Gradle 做编译检查或错误检查。
- 不要在本地构建、交付或依赖 debug APK 产物。
- debug 版本统一通过 GitHub 远程 workflow 构建和分发。
- 需要验证 Android 代码时，优先运行 Gradle 的 assemble/check 类任务确认编译错误，但不要把 APK 作为交付结果。

## 总体迁移策略

采用增量迁移，不要试图一次性把整个 Android 项目重写成 Flutter。

推荐顺序：

1. 稳定 Flutter 应用壳、路由、主题、通用状态组件和测试。
2. 迁移低风险 UI 或公开数据功能。
3. 迁移平台无关的数据模型和解析器，并补测试。
4. 按模块迁移 HTTP/API 客户端。
5. 等测试体系稳定后，再迁移 CAS 登录、Cookie 持久化、SSO、WebVPN、MFA。
6. Android 专属系统能力保留在原生桥接层。

不要一开始就迁移 CAS 登录、WebVPN、桌面小组件、视频播放、后台下载，除非明确要求。

## 核心技术约束

### 认证

原 Android 项目的登录体系很复杂，包含：

- CAS 统一认证
- RSA 密码加密
- 图形验证码
- MFA / 短信验证码
- 多系统共享 SSO Cookie / Session
- 不同子系统的 Token 提取和自动重认证
- 设备指纹持久化，用于减少重复 MFA

关键 Android 文件：

- `auth/XJTULogin.kt`
- `auth/LoginScreen.kt`
- `auth/AttendanceLogin.kt`
- `auth/JwappLogin.kt`
- `auth/YwtbLogin.kt`
- `auth/CampusCardLogin.kt`
- `auth/LibraryLogin.kt`
- `auth/VenueLogin.kt`
- `auth/DzpzLogin.kt`
- `auth/CouponLogin.kt`
- `MainActivity.kt`，负责全局登录状态编排

迁移要求：

- 不要把所有登录状态塞进 Flutter 全局 Widget 状态。
- 先设计明确的 Session 层。
- 在替换 Android 登录逻辑前，必须有 Cookie、Token、重定向、MFA 等行为的测试或记录样例。

### Cookie 和 WebView

Android 项目依赖持久化 Cookie 和共享 Cookie：

- `util/PersistentCookieJar.kt`
- `util/CredentialStore.kt`
- `browser/BrowserScreen.kt`
- `jiaocai/JiaocaiScreen.kt`

迁移要求：

- Flutter HTTP Cookie 和 WebView Cookie 默认不是同一个东西。
- 如果某功能先用 HTTP 登录，再打开 WebView，必须显式同步 Cookie。
- 不要假设 `webview_flutter` 会自动共享 Dart HTTP 客户端的 Cookie。

### WebVPN

部分服务只能在校内网络或 WebVPN 环境下访问。

关键 Android 文件：

- `util/WebVpnUtil.kt`

迁移要求：

- WebVPN URL 加解密必须先写确定性测试。
- 用 Android 版本的输入/输出样例验证 Dart 版本一致后，再接真实接口。
- 网络模式必须显式保留：自动、直连、VPN。

### 存储和数据迁移

现有 Android 存储方式：

- `EncryptedSharedPreferences`：凭据、Cookie、敏感缓存
- 普通 `SharedPreferences`：应用设置
- Room 数据库：自定义课程、课程回放下载任务
- 本地文件：照片缓存、导出文件

关键 Android 文件：

- `util/CredentialStore.kt`
- `util/PersistentCookieJar.kt`
- `util/DataCache.kt`
- `util/AppDatabase.kt`
- `schedule/CustomCourseEntity.kt`
- `classreplay/DownloadTaskEntity.kt`

迁移要求：

- 不要静默丢弃用户数据。
- 改存储 key 或数据库结构前，先定义迁移行为。
- 凭据必须使用每个平台的安全存储。
- 非敏感设置可以使用简单本地偏好存储。

### 原生平台能力

以下能力不能当成纯 Flutter 功能处理：

- Android 桌面小组件：`widget/*`、`AppWidgetProvider`、`RemoteViews`
- Android 应用内 APK 更新 / 安装
- 公共 Downloads 目录下载
- 文件分享 / 导出
- 与 Media3 / ExoPlayer 等价的视频播放
- WebView Cookie 导入 / 导出
- 通知、前台服务、后台任务

迁移要求：

- 先在 `lib/src/platform_bridge` 定义接口边界。
- Android 端必要时保留或重建 Kotlin 原生桥接代码。
- iOS 端不要盲目追求和 Android 完全一致，需要设计对应替代行为。

### UI 和状态

现有 Android UI 使用 Jetpack Compose + MIUIX / HyperOS 风格组件。

迁移要求：

- Flutter 侧需要建立统一设计风格。
- 不要把每个 Compose 函数逐字翻译成 Dart Widget。
- 优先使用功能级状态对象、控制器或 ViewModel，避免超大 StatefulWidget。
- 初期建议使用 Material 3，除非明确要单独实现一套设计系统。

## 智能体工作规则

添加迁移功能时：

1. 先读本文和 `docs/agent_function_architecture.zh-CN.md`。
2. 找到对应 Android 源文件。
3. 能先迁移模型和解析器，就不要先写 UI。
4. 新增模型、解析器、状态逻辑时补测试。
5. 平台相关逻辑必须放在桥接边界后面。
6. 修改要小、可回滚。

不要做：

- 重写无关功能。
- 把登录、网络、UI、存储混在一个文件里。
- 不说明原因就大量添加第三方包。
- 未经要求删除 Android/iOS 生成文件。
- 把 HarmonyOS 当成 Flutter Android/iOS 迁移已经自然解决的问题。

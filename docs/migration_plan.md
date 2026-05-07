# Flutter Migration Plan

## 目标

为现有 Android/Kotlin/Compose 项目准备一个 Flutter 迁移工作区。第一阶段不追求完整功能，而是先建立清晰边界，避免把现有项目中的登录、网络、缓存、页面状态继续耦合到单个入口文件。

## 推荐路线

1. 保留现有 Android 应用作为生产版本。
2. 在本目录中逐步实现 Flutter 版本。
3. 先迁移无登录或低风险模块，例如设置、校历、空教室、公告列表。
4. 再迁移共享业务能力，例如课表缓存、WebVPN、CAS 登录。
5. 最后处理高风险原生能力，例如桌面小组件、下载管理、视频播放、APK 更新。

## 第一阶段边界

| Boundary | Purpose | Source Android Area |
|---|---|---|
| Session | CAS, SSO, token and cookie state | `auth/`, `AppLoginState` |
| Network | HTTP client, redirects, headers, Brotli, retry | `OkHttpClient`, `XJTULogin` |
| WebVPN | URL encryption/decryption and routing mode | `WebVpnUtil.kt` |
| Storage | settings, credentials, cookies, cache, database | `CredentialStore`, `PersistentCookieJar`, `Room` |
| PlatformBridge | app widgets, WebView cookies, downloads, share, video | `widget/`, `BrowserScreen`, `DownloadManager`, `VideoPlayerScreen` |

## 风险清单

- Flutter CLI currently hangs in this workspace when running `flutter create`.
- Android/iOS folders are intentionally absent until the CLI issue is resolved.
- Existing encrypted preferences and Room data need explicit migration logic.
- WebView cookie sync must be verified per service, not assumed.
- HarmonyOS should not be folded into this Flutter app until the Android/iOS port is stable.

## Flutter CLI Recovery Notes

Observed on 2026-05-07:

- `flutter --version` timed out.
- `flutter create --project-name xjtu_toolbox_flutter --org com.xjtu --platforms android,ios xjtu_toolbox_flutter` timed out.
- Stale SDK lock files were cleared once after confirming no Flutter/Dart process was running, but the command still hung.

Next diagnostic commands:

```powershell
Get-Process | Where-Object { $_.ProcessName -match 'flutter|dart' }
D:\learn\code\env\flutter\bin\dart.bat --version
D:\learn\code\env\flutter\bin\flutter.bat doctor -v
```


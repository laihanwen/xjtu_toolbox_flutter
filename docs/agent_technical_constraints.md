# XJTU Toolbox Flutter Migration Technical Constraints

This document is written for coding agents that will work on the Flutter migration.
Read it before adding features or changing architecture, together with
`docs/agent_cross_platform_constraints.md`.

## Project Locations

- Flutter migration project: `D:\learn\code\final\xjtu_toolbox_flutter`
- Existing Android source project: `D:\learn\code\final\xjtu-toolbox-android`
- Existing Android package root: `D:\learn\code\final\xjtu-toolbox-android\app\src\main\java\com\xjtu\toolbox`

## Current Flutter Baseline

- Flutter app package: `xjtu_toolbox_flutter`
- Entry point: `lib/main.dart`
- App shell: `lib/src/app.dart`
- Current source layout:
  - `lib/src/core`: platform-neutral models and app-level abstractions
  - `lib/src/features`: Flutter feature screens
  - `lib/src/platform_bridge`: interfaces or notes for native/platform-specific behavior
  - `docs`: migration documentation for humans and agents
- Generated platform directories exist:
  - `android/`
  - `ios/`
- The Flutter app is intentionally minimal. Do not assume existing Android features are already implemented in Dart.

## Toolchain Notes

- Dart SDK observed from Flutter cache: `3.11.1`.
- Flutter SDK location observed locally: `D:\learn\code\env\flutter`.
- The environment has previously shown `flutter test`/`flutter --version` hanging and leaving SDK lock files:
  - `D:\learn\code\env\flutter\bin\cache\lockfile`
  - `D:\learn\code\env\flutter\bin\cache\flutter.bat.lock`
- If Flutter commands hang, inspect and stop only stale Flutter/Dart tool processes before retrying. Do not delete project source files to "fix" toolchain issues.

Local build constraints:

- Use Gradle locally only for compile/check validation.
- Do not build, deliver, or depend on local debug APK artifacts.
- Debug APK generation and distribution should happen through the GitHub remote workflow.
- When Android validation is needed, prefer Gradle assemble/check-style tasks to catch compile errors, but do not treat local APK output as the deliverable.

## Migration Strategy

Use incremental migration. Do not try to port the whole Android app at once.

Recommended order:

1. Stabilize Flutter app shell, routing, theme, reusable states, and tests.
2. Port low-risk UI-only or public-data features.
3. Port platform-neutral models and parsers with tests.
4. Port HTTP/API clients feature by feature.
5. Port CAS login, Cookie persistence, SSO, WebVPN, and MFA only after the test harness exists.
6. Keep Android-only system capabilities behind native bridges.

Do not start with CAS login, WebVPN, AppWidget, video, or background downloads unless explicitly requested.

## Core Technical Constraints

### Authentication

The existing Android app has a complex authentication model:

- CAS unified login
- RSA password encryption
- Captcha support
- MFA/SMS verification support
- Shared SSO cookie/session reuse across services
- Per-service token extraction and re-authentication
- Device fingerprint persistence to reduce repeated MFA

Relevant Android files:

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
- `MainActivity.kt` for global login state orchestration

Migration constraint:

- Do not flatten all login state into global Flutter widget state.
- Define an explicit session layer first.
- Cookie and token behavior must be covered by integration-style tests or recorded fixtures before replacing Android logic.

### Cookies and WebView

The Android app depends on persistent and shared cookies:

- `util/PersistentCookieJar.kt`
- `util/CredentialStore.kt`
- `browser/BrowserScreen.kt`
- `jiaocai/JiaocaiScreen.kt`

Migration constraint:

- Flutter HTTP cookies and WebView cookies are separate unless explicitly synced.
- Any feature that opens WebView after OkHttp/Dart HTTP login must implement cookie sync.
- Do not assume `webview_flutter` automatically shares cookies with Dart HTTP clients.

### WebVPN

Some services only work on campus network or through WebVPN.

Relevant Android file:

- `util/WebVpnUtil.kt`

Migration constraint:

- WebVPN URL transformation must be ported with deterministic tests.
- Use known input/output cases from Android before using it in live API calls.
- Network mode must remain explicit: auto/direct/vpn.

### Storage and Data Migration

Existing Android storage:

- `EncryptedSharedPreferences` for credentials, cookies, and sensitive cache
- plain `SharedPreferences` for app settings
- Room database for custom courses and replay download tasks
- local files for cached profile photo and exports

Relevant Android files:

- `util/CredentialStore.kt`
- `util/PersistentCookieJar.kt`
- `util/DataCache.kt`
- `util/AppDatabase.kt`
- `schedule/CustomCourseEntity.kt`
- `classreplay/DownloadTaskEntity.kt`

Migration constraint:

- Do not silently discard user data.
- Define migration behavior before changing storage keys or database schema.
- Credentials must use secure storage on every supported platform.
- Non-sensitive settings can use simpler local preferences.

### Native Platform Capabilities

The following cannot be considered pure Flutter work:

- Android home screen widgets: `widget/*`, AppWidgetProvider, RemoteViews
- Android APK update/install flow: FileProvider and package install Intent
- Downloads into public Downloads folder
- File sharing/export
- Video playback parity with Media3/ExoPlayer
- WebView cookie import/export
- Notifications and foreground/background behavior

Migration constraint:

- Use `lib/src/platform_bridge` to define boundaries before implementation.
- On Android, keep or recreate Kotlin native bridge code where Flutter plugins are insufficient.
- On iOS, design feature parity deliberately; Android-only behavior may need iOS alternatives.

### UI and State

Existing Android UI is Jetpack Compose plus MIUIX/HyperOS-like components.

Migration constraint:

- Flutter UI should use a consistent app-level design system.
- Do not blindly translate every Compose composable into one Dart widget.
- Prefer feature-level state objects, view models, or controllers over large stateful screens.
- Start with Material 3 unless a dedicated custom design system is introduced.

## Agent Working Rules

When adding migration work:

1. Read this document and `docs/agent_function_architecture.md`.
2. Identify the Android source files for the feature.
3. Port models/parsers before UI where possible.
4. Add tests for parsing, state transitions, and URL transformation.
5. Keep platform-specific logic behind interfaces.
6. Keep changes small and reversible.

Do not:

- Rewrite unrelated features.
- Mix login, networking, UI, and storage into one file.
- Add many third-party packages without documenting why.
- Delete generated Android/iOS files unless asked.
- Treat HarmonyOS as solved by the Flutter Android/iOS migration.

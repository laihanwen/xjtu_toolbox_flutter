# XJTU Toolbox Flutter Migration

This directory is a migration workspace for rebuilding XJTU Toolbox with
Flutter. It intentionally starts with platform-neutral boundaries before
porting UI screens or network implementations.

## Current Status

- Flutter SDK detected: `D:\learn\code\env\flutter`
- Flutter version cache reports: `3.41.4`, Dart `3.11.1`
- `flutter create` currently hangs in this environment, so Android/iOS platform
  folders were not generated yet.
- The Dart app skeleton, migration backlog, and architectural boundaries are in
  place.

## Complete Platform Bootstrap

After the Flutter CLI is working again, run:

```powershell
cd D:\learn\code\final\xjtu_toolbox_flutter
flutter create . --project-name xjtu_toolbox_flutter --org com.xjtu --platforms android,ios
flutter pub get
flutter test
```

## Directory Layout

```text
lib/
  main.dart
  src/
    app.dart
    core/
      app_environment.dart
      migration_area.dart
      session/
    features/
      home/
      migration/
    platform_bridge/
docs/
  migration_plan.md
  agent_technical_constraints.md
  agent_function_architecture.md
```

## Agent Context

When using another coding agent, provide these files as context first:

- `docs/agent_technical_constraints.md`
- `docs/agent_function_architecture.md`
- Chinese reference versions:
  - `docs/agent_technical_constraints.zh-CN.md`
  - `docs/agent_function_architecture.zh-CN.md`

## Migration Rule

Do not port screens first. Stabilize these boundaries before feature work:

1. Auth/session model
2. Cookie persistence and WebView cookie sync
3. WebVPN URL transformation
4. Local cache/database strategy
5. Android/iOS platform bridge for widgets, downloads, file sharing, video, and
   install/update flows

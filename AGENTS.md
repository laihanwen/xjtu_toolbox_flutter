# Agent Working Rules

Before making code changes in this repository, read these documents:

1. `docs/agent_technical_constraints.zh-CN.md`
2. `docs/agent_function_architecture.zh-CN.md`
3. `docs/agent_cross_platform_constraints.zh-CN.md`

This is a cross-platform Flutter migration project. Treat Android and iOS as
first-class targets with different UI conventions and platform capabilities.
Do not hard-code Material, Android-only behavior, file-system assumptions,
WebView cookie behavior, notification behavior, or background task behavior
inside feature screens.

Use `lib/src/ui` for app-level UI abstractions and `lib/src/platform_bridge`
for native/platform-specific capabilities.

Local build rule: use Gradle only for compile/check validation. Do not build
or deliver local debug APKs from this workspace. Debug APK generation and
distribution should happen through the GitHub remote workflow.

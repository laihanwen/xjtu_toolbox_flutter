# XJTU Toolbox Cross-Platform Constraints

This project is a cross-platform Flutter migration, not an Android-only UI
port. Android and iOS must both be treated as first-class targets.

## Core Rules

- Android should default to Material 3.
- iOS and macOS should default to Cupertino / Liquid Glass-like presentation.
- Feature screens should not hard-code platform-specific visual language.
- Platform differences must live in `lib/src/ui` or `lib/src/platform_bridge`.

## UI Layering

Feature screens should prefer app-level components:

- `AppPage`
- `AppSurface`
- `AppListTile`
- `AppSectionHeader`
- `AppButton`
- `AppBadge`
- `AppShell`

Avoid spreading direct usage of `Scaffold`, `NavigationBar`,
`NavigationRail`, `ListTile`, `Card`, `FilledButton`, `CupertinoButton`, or
`BackdropFilter` across feature screens. If a platform-specific widget is
needed, consider wrapping it in `lib/src/ui` first.

## Platform Capability Boundaries

Do not implement these directly inside Flutter feature screens:

- WebView cookie import/export
- Downloads, public Downloads access, file sharing/export
- Background tasks, notifications, foreground services
- Android home screen widgets
- APK update/install flows
- Video playback parity with native players
- Secure storage/keychain/encrypted preferences

Define explicit interfaces in `lib/src/platform_bridge` or a platform service
layer before adding implementations.

## Dependency Rules

- Third-party libraries are encouraged when they reduce complexity, but verify
  Android and iOS support before adopting them.
- Avoid UI libraries that lock the app into one platform style unless wrapped
  behind app-level components.
- If a dependency provides full support only on Android, document the iOS
  fallback behavior.

## Development Checklist

Before changing UI or platform behavior:

1. Can this be expressed with existing `lib/src/ui` components?
2. Does the feature still feel native on Android with Material 3?
3. Does iOS need a Cupertino / Liquid Glass-like variant?
4. Is any platform-specific capability hidden behind `platform_bridge`?
5. Are platform-neutral models, parsers, and state transitions covered by tests?


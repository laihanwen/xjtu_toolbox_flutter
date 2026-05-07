import 'package:flutter/material.dart';

enum AppUiStyle {
  material,
  liquidGlass,
}

AppUiStyle resolveAppUiStyle(BuildContext context) {
  final platform = Theme.of(context).platform;
  return switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => AppUiStyle.liquidGlass,
    _ => AppUiStyle.material,
  };
}

bool usesLiquidGlass(BuildContext context) {
  return resolveAppUiStyle(context) == AppUiStyle.liquidGlass;
}

double appSurfaceRadius(BuildContext context) {
  return usesLiquidGlass(context) ? 18 : 8;
}

EdgeInsets appPagePadding(BuildContext context) {
  return usesLiquidGlass(context)
      ? const EdgeInsets.fromLTRB(16, 12, 16, 28)
      : const EdgeInsets.fromLTRB(16, 12, 16, 24);
}

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

enum AppSurfaceTone {
  normal,
  prominent,
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.tone = AppSurfaceTone.normal,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final AppSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    return switch (resolveAppUiStyle(context)) {
      AppUiStyle.material => _MaterialSurface(
          padding: padding,
          onTap: onTap,
          tone: tone,
          child: child,
        ),
      AppUiStyle.liquidGlass => _LiquidGlassSurface(
          padding: padding,
          onTap: onTap,
          tone: tone,
          child: child,
        ),
    };
  }
}

class _MaterialSurface extends StatelessWidget {
  const _MaterialSurface({
    required this.child,
    required this.padding,
    required this.onTap,
    required this.tone,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final AppSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = tone == AppSurfaceTone.prominent
        ? colorScheme.primaryContainer
        : colorScheme.surface;

    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _LiquidGlassSurface extends StatelessWidget {
  const _LiquidGlassSurface({
    required this.child,
    required this.padding,
    required this.onTap,
    required this.tone,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final AppSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    final isDark = brightness == Brightness.dark;
    final grey = CupertinoColors.systemGrey6.resolveFrom(context);
    final teal = CupertinoColors.systemTeal.resolveFrom(context);
    final fill = isDark
        ? grey.withValues(alpha: 0.42)
        : grey.withValues(alpha: 0.66);
    final prominentFill = isDark
        ? teal.withValues(alpha: 0.28)
        : teal.withValues(alpha: 0.22);
    final border = isDark
        ? CupertinoColors.white.withValues(alpha: 0.14)
        : CupertinoColors.white.withValues(alpha: 0.42);

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tone == AppSurfaceTone.prominent ? prominentFill : fill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

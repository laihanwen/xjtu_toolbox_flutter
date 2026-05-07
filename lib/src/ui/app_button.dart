import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      return CupertinoButton(
        minSize: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: CupertinoColors.activeBlue.resolveFrom(context),
        borderRadius: BorderRadius.circular(999),
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

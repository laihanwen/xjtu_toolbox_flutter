import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.activeBlue
              .resolveFrom(context)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: CupertinoColors.activeBlue.resolveFrom(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}

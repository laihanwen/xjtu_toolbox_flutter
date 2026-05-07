import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.action,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          usesLiquidGlass(context)
              ? CupertinoButton(
                  minSize: 32,
                  padding: EdgeInsets.zero,
                  onPressed: onActionPressed,
                  child: Text(action!),
                )
              : TextButton(
                  onPressed: onActionPressed,
                  child: Text(action!),
                ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    if (usesLiquidGlass(context)) {
      final activeColor = CupertinoColors.activeBlue.resolveFrom(context);
      final textColor = selected
          ? CupertinoColors.white
          : CupertinoColors.label.resolveFrom(context);
      final fill = selected
          ? activeColor
          : CupertinoColors.systemGrey6
                .resolveFrom(context)
                .withValues(alpha: 0.72);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelected(!selected),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? activeColor
                  : CupertinoColors.separator.resolveFrom(context),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }
}

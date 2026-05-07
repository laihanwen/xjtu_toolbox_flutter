import 'package:flutter/material.dart';

import '../../core/app_environment.dart';
import '../../core/migration_area.dart';
import '../../ui/app_badge.dart';
import '../../ui/app_page.dart';
import '../../ui/app_surface.dart';
import 'migration_backlog.dart';

class MigrationDashboard extends StatelessWidget {
  const MigrationDashboard({
    required this.environment,
    super.key,
  });

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        Text(
          'Migration Workspace',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Environment: ${environment.name}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        const AppSurface(
          padding: EdgeInsets.all(12),
          child: Text(
            'Start with platform boundaries before porting screens. '
            'Auth, cookies, WebVPN, storage and native bridges are the '
            'critical path for this app.',
          ),
        ),
        const SizedBox(height: 16),
        for (final item in migrationBacklog) ...[
          _BacklogTile(item: item),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _BacklogTile extends StatelessWidget {
  const _BacklogTile({required this.item});

  final MigrationBacklogItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${item.area.label} - ${item.notes}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppBadge(label: item.status.name),
        ],
      ),
    );
  }
}

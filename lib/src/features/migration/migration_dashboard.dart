import 'package:flutter/material.dart';

import '../../core/app_environment.dart';
import '../../core/migration_area.dart';
import 'migration_backlog.dart';

class MigrationDashboard extends StatelessWidget {
  const MigrationDashboard({
    required this.environment,
    super.key,
  });

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
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
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Start with platform boundaries before porting screens. '
              'Auth, cookies, WebVPN, storage and native bridges are the '
              'critical path for this app.',
            ),
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
    final color = switch (item.status) {
      MigrationStatus.done => Colors.green,
      MigrationStatus.inProgress => Colors.blue,
      MigrationStatus.blocked => Colors.red,
      MigrationStatus.planned => Colors.orange,
      MigrationStatus.notStarted => Colors.grey,
    };

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      title: Text(item.title),
      subtitle: Text('${item.area.label} - ${item.notes}'),
      trailing: Chip(
        label: Text(item.status.name),
        side: BorderSide.none,
        backgroundColor: color.withValues(alpha: 0.12),
        labelStyle: TextStyle(color: color),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_environment.dart';
import '../../ui/app_list_tile.dart';
import '../../ui/app_page.dart';
import '../../ui/app_section.dart';
import '../../ui/app_surface.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.environment, super.key});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        _HomeHeader(environment: environment),
        const SizedBox(height: 16),
        const _TodaySummary(),
        const SizedBox(height: 16),
        AppSectionHeader(title: '常用入口', action: '编辑', onActionPressed: () {}),
        const SizedBox(height: 10),
        const _QuickActionGrid(),
        const SizedBox(height: 16),
        AppSectionHeader(title: '待处理', action: '全部', onActionPressed: () {}),
        const SizedBox(height: 10),
        const _NoticeList(),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.all(16),
      tone: AppSurfaceTone.prominent,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XJTU Toolbox',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '迁移版前端 demo · ${environment.name}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.76,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.school,
            size: 36,
            color: colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _InfoPanel(
            icon: LucideIcons.calendarDays,
            title: '今日课表',
            value: '3 门课',
            detail: '下一节 10:10 · 计算机网络',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _InfoPanel(
            icon: LucideIcons.creditCard,
            title: '校园卡',
            value: '¥128.40',
            detail: '午餐后更新',
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 14),
          Text(title, style: textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    const actions = [
      _QuickAction('课表', '周视图', LucideIcons.calendarDays),
      _QuickAction('空教室', '公共查询', LucideIcons.doorOpen),
      _QuickAction('公告', '多来源聚合', LucideIcons.bell),
      _QuickAction('校历', '学期事件', LucideIcons.notebookTabs, route: '/calendar'),
      _QuickAction('图书馆', '座位状态', LucideIcons.libraryBig),
      _QuickAction('成绩', '解析优先', LucideIcons.graduationCap),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;

        return StaggeredGrid.count(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final action in actions)
              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 0.82,
                child: _QuickActionTile(action: action),
              ),
          ],
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.all(12),
      onTap: action.route == null ? null : () => context.push(action.route!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(action.icon, color: colorScheme.primary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action.title, style: textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoticeList extends StatelessWidget {
  const _NoticeList();

  @override
  Widget build(BuildContext context) {
    const notices = [
      _Notice('WebVPN 边界', '先完成确定性 URL 转换测试，再接真实接口。'),
      _Notice('Cookie 同步', 'HTTP 登录后打开 WebView 必须显式同步 Cookie。'),
      _Notice('低风险模块', '校历、空教室、公告适合作为下一批迁移目标。'),
    ];

    return Column(
      children: [
        for (final notice in notices) ...[
          AppListTile(
            icon: LucideIcons.shield,
            title: notice.title,
            subtitle: notice.detail,
            onTap: () {},
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction(this.title, this.subtitle, this.icon, {this.route});

  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;
}

class _Notice {
  const _Notice(this.title, this.detail);

  final String title;
  final String detail;
}

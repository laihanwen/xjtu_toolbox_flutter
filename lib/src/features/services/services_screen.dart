import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../ui/app_badge.dart';
import '../../ui/app_page.dart';
import '../../ui/app_section.dart';
import '../../ui/app_surface.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      children: [
        _PageHeader(),
        SizedBox(height: 16),
        _ServiceGroup(
          title: '早期迁移候选',
          services: [
            _ServiceEntry(
              title: '校历',
              subtitle: '学期、节假日、教学周',
              badge: 'Public API',
              icon: LucideIcons.notebookTabs,
              route: '/calendar',
            ),
            _ServiceEntry(
              title: '空教室',
              subtitle: '校区、楼宇、节次筛选',
              badge: 'Low risk',
              icon: LucideIcons.doorOpen,
            ),
            _ServiceEntry(
              title: '通知公告',
              subtitle: '列表、详情、来源聚合',
              badge: 'Parser first',
              icon: LucideIcons.bell,
            ),
          ],
        ),
        SizedBox(height: 18),
        _ServiceGroup(
          title: '需要核心能力',
          services: [
            _ServiceEntry(
              title: '课表',
              subtitle: '缓存、自定义课程、ICS 导出',
              badge: 'Storage',
              icon: LucideIcons.calendarDays,
            ),
            _ServiceEntry(
              title: '校园卡',
              subtitle: '余额、流水、消费统计',
              badge: 'Auth',
              icon: LucideIcons.creditCard,
            ),
            _ServiceEntry(
              title: '图书馆',
              subtitle: '座位状态、预约、地图',
              badge: 'WebVPN',
              icon: LucideIcons.libraryBig,
            ),
            _ServiceEntry(
              title: '成绩',
              subtitle: 'HTML / 报表解析',
              badge: 'Fixtures',
              icon: LucideIcons.graduationCap,
            ),
          ],
        ),
        SizedBox(height: 18),
        _ServiceGroup(
          title: '原生桥接能力',
          services: [
            _ServiceEntry(
              title: '下载管理',
              subtitle: '后台任务、文件导出',
              badge: 'Bridge',
              icon: LucideIcons.database,
            ),
            _ServiceEntry(
              title: 'WebView',
              subtitle: 'Cookie 导入导出',
              badge: 'Bridge',
              icon: LucideIcons.wifi,
            ),
            _ServiceEntry(
              title: '场馆预约',
              subtitle: '时段、收藏、滑块验证',
              badge: 'Sensitive',
              icon: LucideIcons.mapPinned,
            ),
          ],
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '服务',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '按迁移风险分组，低风险功能先落地，高风险能力放到明确边界后实现。',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ServiceGroup extends StatelessWidget {
  const _ServiceGroup({required this.title, required this.services});

  final String title;
  final List<_ServiceEntry> services;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760
                ? 4
                : constraints.maxWidth >= 520
                ? 3
                : 2;

            return StaggeredGrid.count(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (final service in services)
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1.05,
                    child: _ServiceTile(service: service),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final _ServiceEntry service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.all(12),
      onTap: service.route == null ? null : () => context.push(service.route!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(service.icon, color: colorScheme.primary),
              const Spacer(),
              AppBadge(label: service.badge),
            ],
          ),
          const Spacer(),
          Text(service.title, style: textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            service.subtitle,
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

class _ServiceEntry {
  const _ServiceEntry({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    this.route,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final String? route;
}

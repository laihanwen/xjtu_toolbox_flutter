import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_environment.dart';
import '../../ui/app_button.dart';
import '../../ui/app_list_tile.dart';
import '../../ui/app_page.dart';
import '../../ui/app_section.dart';
import '../../ui/app_surface.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.environment, super.key});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppPage(
      children: [
        AppSurface(
          padding: const EdgeInsets.all(16),
          tone: AppSurfaceTone.prominent,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                child: const Icon(LucideIcons.circleUserRound),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '未登录',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Session 层就绪后接入 CAS / SSO',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              AppButton(label: '登录', onPressed: () {}),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: '应用设置',
          children: [
            _SettingsItem(
              icon: LucideIcons.settings,
              title: '界面偏好',
              subtitle: '主题、首页入口、默认 Tab',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.wifi,
              title: '网络模式',
              subtitle: '自动 / 直连 / WebVPN',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.shield,
              title: '隐私与安全',
              subtitle: '凭据安全存储、敏感缓存边界',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: '开发状态',
          children: [
            _SettingsItem(
              icon: LucideIcons.route,
              title: '迁移环境',
              subtitle: environment.name,
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.database,
              title: '本地数据',
              subtitle: '等待存储迁移策略',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: 8),
        for (final child in children) ...[
          child,
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

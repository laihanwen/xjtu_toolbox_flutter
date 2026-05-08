import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_async_state.dart';
import 'app_button.dart';
import 'app_surface.dart';

typedef AppStateDataBuilder<T> = Widget Function(BuildContext context, T data);

enum AppStateViewMode {
  page,
  section,
}

class AppStateView<T> extends StatelessWidget {
  const AppStateView({
    required this.state,
    required this.builder,
    this.mode = AppStateViewMode.page,
    super.key,
  });

  final AppAsyncState<T> state;
  final AppStateDataBuilder<T> builder;
  final AppStateViewMode mode;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      AppAsyncStatus.loading => AppLoadingState(
          title: state.title ?? '加载中',
          message: state.message ?? '正在获取最新数据。',
          mode: mode,
          actions: state.actions,
        ),
      AppAsyncStatus.data => builder(context, state.data as T),
      AppAsyncStatus.empty => AppEmptyState(
          title: state.title ?? '暂无数据',
          message: state.message ?? '这里还没有可展示的内容。',
          mode: mode,
          actions: state.actions,
        ),
      AppAsyncStatus.error => AppErrorState(
          title: state.title ?? '加载失败',
          message: state.message ?? '请稍后重试。',
          mode: mode,
          actions: state.actions,
        ),
      AppAsyncStatus.loginRequired => AppLoginRequiredState(
          title: state.title ?? '需要登录',
          message: state.message ?? '登录后继续使用该功能。',
          mode: mode,
          actions: state.actions,
        ),
      AppAsyncStatus.offline => _OfflineStateView<T>(
          state: state,
          builder: builder,
          mode: mode,
        ),
      AppAsyncStatus.unavailable => AppUnavailableState(
          title: state.title ?? '暂不可用',
          message: state.message ?? '此功能还在迁移，或当前平台暂不支持。',
          mode: mode,
          actions: state.actions,
        ),
    };
  }
}

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    this.title = '加载中',
    this.message = '正在获取最新数据。',
    this.mode = AppStateViewMode.page,
    this.actions = const <AppStateAction>[],
    super.key,
  });

  final String title;
  final String message;
  final AppStateViewMode mode;
  final List<AppStateAction> actions;

  @override
  Widget build(BuildContext context) {
    return _AppStateContent(
      icon: LucideIcons.loaderCircle,
      title: title,
      message: message,
      mode: mode,
      actions: actions,
      progress: true,
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    this.title = '暂无数据',
    this.message = '这里还没有可展示的内容。',
    this.mode = AppStateViewMode.page,
    this.actions = const <AppStateAction>[],
    super.key,
  });

  final String title;
  final String message;
  final AppStateViewMode mode;
  final List<AppStateAction> actions;

  @override
  Widget build(BuildContext context) {
    return _AppStateContent(
      icon: LucideIcons.inbox,
      title: title,
      message: message,
      mode: mode,
      actions: actions,
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    this.title = '加载失败',
    this.message = '请稍后重试。',
    this.mode = AppStateViewMode.page,
    this.actions = const <AppStateAction>[],
    super.key,
  });

  final String title;
  final String message;
  final AppStateViewMode mode;
  final List<AppStateAction> actions;

  @override
  Widget build(BuildContext context) {
    return _AppStateContent(
      icon: LucideIcons.triangleAlert,
      title: title,
      message: message,
      mode: mode,
      actions: actions,
    );
  }
}

class AppLoginRequiredState extends StatelessWidget {
  const AppLoginRequiredState({
    this.title = '需要登录',
    this.message = '登录后继续使用该功能。',
    this.mode = AppStateViewMode.page,
    this.actions = const <AppStateAction>[],
    super.key,
  });

  final String title;
  final String message;
  final AppStateViewMode mode;
  final List<AppStateAction> actions;

  @override
  Widget build(BuildContext context) {
    return _AppStateContent(
      icon: LucideIcons.logIn,
      title: title,
      message: message,
      mode: mode,
      actions: actions,
    );
  }
}

class AppOfflineState extends StatelessWidget {
  const AppOfflineState({
    this.title = '离线模式',
    this.message = '正在使用本地缓存。',
    this.mode = AppStateViewMode.page,
    this.actions = const <AppStateAction>[],
    super.key,
  });

  final String title;
  final String message;
  final AppStateViewMode mode;
  final List<AppStateAction> actions;

  @override
  Widget build(BuildContext context) {
    return _AppStateContent(
      icon: LucideIcons.cloudOff,
      title: title,
      message: message,
      mode: mode,
      actions: actions,
    );
  }
}

class AppUnavailableState extends StatelessWidget {
  const AppUnavailableState({
    this.title = '暂不可用',
    this.message = '此功能还在迁移，或当前平台暂不支持。',
    this.mode = AppStateViewMode.page,
    this.actions = const <AppStateAction>[],
    super.key,
  });

  final String title;
  final String message;
  final AppStateViewMode mode;
  final List<AppStateAction> actions;

  @override
  Widget build(BuildContext context) {
    return _AppStateContent(
      icon: LucideIcons.circleOff,
      title: title,
      message: message,
      mode: mode,
      actions: actions,
    );
  }
}

class _OfflineStateView<T> extends StatelessWidget {
  const _OfflineStateView({
    required this.state,
    required this.builder,
    required this.mode,
  });

  final AppAsyncState<T> state;
  final AppStateDataBuilder<T> builder;
  final AppStateViewMode mode;

  @override
  Widget build(BuildContext context) {
    final cachedData = state.data;
    final offlineState = AppOfflineState(
      title: state.title ?? '离线模式',
      message: state.message ?? '正在使用本地缓存。',
      mode: AppStateViewMode.section,
      actions: state.actions,
    );

    if (cachedData == null) {
      return AppOfflineState(
        title: state.title ?? '离线模式',
        message: state.message ?? '正在使用本地缓存。',
        mode: mode,
        actions: state.actions,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        offlineState,
        const SizedBox(height: 12),
        builder(context, cachedData),
      ],
    );
  }
}

class _AppStateContent extends StatelessWidget {
  const _AppStateContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.mode,
    required this.actions,
    this.progress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final AppStateViewMode mode;
  final List<AppStateAction> actions;
  final bool progress;

  @override
  Widget build(BuildContext context) {
    final content = _StateBody(
      icon: icon,
      title: title,
      message: message,
      actions: actions,
      progress: progress,
    );

    if (mode == AppStateViewMode.section) {
      return AppSurface(
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: content,
        ),
      ),
    );
  }
}

class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
    required this.progress,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<AppStateAction> actions;
  final bool progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 34,
          color: colorScheme.primary,
        ),
        if (progress) ...[
          const SizedBox(height: 12),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in actions)
                AppButton(
                  label: action.label,
                  onPressed: action.onPressed,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

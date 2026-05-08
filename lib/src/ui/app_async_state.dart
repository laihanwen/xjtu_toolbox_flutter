import 'package:flutter/foundation.dart';

enum AppAsyncStatus {
  loading,
  data,
  empty,
  error,
  loginRequired,
  offline,
  unavailable,
}

@immutable
class AppAsyncState<T> {
  const AppAsyncState._({
    required this.status,
    this.data,
    this.title,
    this.message,
    this.error,
    this.stackTrace,
    this.actions = const <AppStateAction>[],
  });

  const AppAsyncState.loading({
    String title = '加载中',
    String message = '正在获取最新数据。',
    List<AppStateAction> actions = const <AppStateAction>[],
  }) : this._(
          status: AppAsyncStatus.loading,
          title: title,
          message: message,
          actions: actions,
        );

  const AppAsyncState.data(T data)
      : this._(
          status: AppAsyncStatus.data,
          data: data,
        );

  const AppAsyncState.empty({
    String title = '暂无数据',
    String message = '这里还没有可展示的内容。',
    List<AppStateAction> actions = const <AppStateAction>[],
  }) : this._(
          status: AppAsyncStatus.empty,
          title: title,
          message: message,
          actions: actions,
        );

  const AppAsyncState.error({
    String title = '加载失败',
    String message = '请稍后重试。',
    Object? error,
    StackTrace? stackTrace,
    List<AppStateAction> actions = const <AppStateAction>[],
  }) : this._(
          status: AppAsyncStatus.error,
          title: title,
          message: message,
          error: error,
          stackTrace: stackTrace,
          actions: actions,
        );

  const AppAsyncState.loginRequired({
    String title = '需要登录',
    String message = '登录后继续使用该功能。',
    List<AppStateAction> actions = const <AppStateAction>[],
  }) : this._(
          status: AppAsyncStatus.loginRequired,
          title: title,
          message: message,
          actions: actions,
        );

  const AppAsyncState.offline({
    T? cachedData,
    String title = '离线模式',
    String message = '正在使用本地缓存。',
    List<AppStateAction> actions = const <AppStateAction>[],
  }) : this._(
          status: AppAsyncStatus.offline,
          data: cachedData,
          title: title,
          message: message,
          actions: actions,
        );

  const AppAsyncState.unavailable({
    String title = '暂不可用',
    String message = '此功能还在迁移，或当前平台暂不支持。',
    List<AppStateAction> actions = const <AppStateAction>[],
  }) : this._(
          status: AppAsyncStatus.unavailable,
          title: title,
          message: message,
          actions: actions,
        );

  final AppAsyncStatus status;
  final T? data;
  final String? title;
  final String? message;
  final Object? error;
  final StackTrace? stackTrace;
  final List<AppStateAction> actions;

  bool get hasData => data != null;
}

@immutable
class AppStateAction {
  const AppStateAction({
    required this.label,
    required this.onPressed,
  });

  const AppStateAction.retry(VoidCallback onPressed)
      : this(
          label: '重试',
          onPressed: onPressed,
        );

  const AppStateAction.login(VoidCallback onPressed)
      : this(
          label: '登录',
          onPressed: onPressed,
        );

  const AppStateAction.openSettings(VoidCallback onPressed)
      : this(
          label: '打开设置',
          onPressed: onPressed,
        );

  const AppStateAction.viewCache(VoidCallback onPressed)
      : this(
          label: '查看缓存',
          onPressed: onPressed,
        );

  final String label;
  final VoidCallback onPressed;
}

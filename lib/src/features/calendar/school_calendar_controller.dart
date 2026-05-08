import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../ui/app_async_state.dart';
import 'school_calendar_models.dart';
import 'school_calendar_repository.dart';

@immutable
class SchoolCalendarViewData {
  const SchoolCalendarViewData({
    required this.terms,
    required this.selectedIndex,
    required this.fetchedAt,
    required this.source,
  });

  final List<SchoolTerm> terms;
  final int selectedIndex;
  final DateTime fetchedAt;
  final SchoolCalendarDataSource source;

  SchoolTerm get selectedTerm {
    final safeIndex = selectedIndex.clamp(0, terms.length - 1).toInt();
    return terms[safeIndex];
  }

  SchoolCalendarViewData copyWith({
    List<SchoolTerm>? terms,
    int? selectedIndex,
    DateTime? fetchedAt,
    SchoolCalendarDataSource? source,
  }) {
    return SchoolCalendarViewData(
      terms: terms ?? this.terms,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      source: source ?? this.source,
    );
  }
}

class SchoolCalendarController extends ChangeNotifier {
  SchoolCalendarController({
    required SchoolCalendarRepository repository,
    DateTime Function()? now,
  }) : _repository = repository,
       _now = now ?? DateTime.now;

  final SchoolCalendarRepository _repository;
  final DateTime Function() _now;

  AppAsyncState<SchoolCalendarViewData> state = const AppAsyncState.loading(
    title: '正在加载校历',
    message: '正在获取最新学期安排。',
  );

  bool _disposed = false;

  Future<void> load() async {
    _setLoading();

    final cached = await _repository.readCachedTerms();
    if (cached != null) {
      _applyResult(cached);
      unawaited(refresh(silent: true));
      return;
    }

    await refresh(silent: true);
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      _setLoading();
    }

    try {
      final result = await _repository.fetchTerms();
      _applyResult(result);
    } catch (error, stackTrace) {
      final cachedData = state.data;
      if (cachedData != null) {
        _setState(
          AppAsyncState.offline(
            cachedData: cachedData,
            title: '当前显示缓存校历',
            message: '网络刷新失败，正在使用最近一次成功获取的数据。',
            actions: [AppStateAction.retry(() => unawaited(refresh()))],
          ),
        );
        return;
      }

      _setState(
        AppAsyncState.error(
          title: '校历加载失败',
          message: '暂时无法访问校历接口，请稍后重试。',
          error: error,
          stackTrace: stackTrace,
          actions: [AppStateAction.retry(() => unawaited(refresh()))],
        ),
      );
    }
  }

  void selectTerm(int index) {
    final data = state.data;
    if (data == null || index < 0 || index >= data.terms.length) {
      return;
    }
    _setState(AppAsyncState.data(data.copyWith(selectedIndex: index)));
  }

  void _applyResult(SchoolCalendarLoadResult result) {
    if (result.terms.isEmpty) {
      _setState(
        AppAsyncState.empty(
          title: '暂无校历数据',
          message: '接口暂时没有返回可展示的学期安排。',
          actions: [AppStateAction.retry(() => unawaited(refresh()))],
        ),
      );
      return;
    }

    _setState(
      AppAsyncState.data(
        SchoolCalendarViewData(
          terms: result.terms,
          selectedIndex: _selectedIndexFor(result.terms),
          fetchedAt: result.fetchedAt,
          source: result.source,
        ),
      ),
    );
  }

  int _defaultSelectedIndex(List<SchoolTerm> terms) {
    final today = _now();
    final currentIndex = terms.indexWhere(
      (term) => term.currentWeek(today) > 0,
    );
    return currentIndex >= 0 ? currentIndex : 0;
  }

  int _selectedIndexFor(List<SchoolTerm> terms) {
    final selectedTermId = state.data?.selectedTerm.id;
    if (selectedTermId != null) {
      final index = terms.indexWhere((term) => term.id == selectedTermId);
      if (index >= 0) {
        return index;
      }
    }
    return _defaultSelectedIndex(terms);
  }

  void _setLoading() {
    _setState(
      const AppAsyncState.loading(title: '正在加载校历', message: '正在获取最新学期安排。'),
    );
  }

  void _setState(AppAsyncState<SchoolCalendarViewData> nextState) {
    if (_disposed) {
      return;
    }
    state = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../ui/app_async_state.dart';
import 'empty_room_constants.dart';
import 'empty_room_filters.dart';
import 'empty_room_models.dart';
import 'empty_room_repository.dart';

class EmptyRoomController extends ChangeNotifier {
  EmptyRoomController({
    required EmptyRoomRepository repository,
    DateTime Function()? now,
  }) : _repository = repository,
       _now = now ?? DateTime.now;

  final EmptyRoomRepository _repository;
  final DateTime Function() _now;

  AppAsyncState<EmptyRoomViewData> state = const AppAsyncState.loading(
    title: '正在查询空教室',
    message: '正在读取校区和教室数据。',
  );

  EmptyRoomQuery? _query;
  bool _disposed = false;

  List<DateTime> get availableDates {
    final today = emptyRoomDate(_now());
    return [today, today.add(const Duration(days: 1))];
  }

  Future<void> load() async {
    final today = emptyRoomDate(_now());
    _query =
        await _repository.readSavedQuery(
          today: today,
          campusNames: campusBuildings.keys.toList(),
          defaultBuilding: _defaultBuilding,
        ) ??
        _defaultQuery(today);
    await _loadQuery(useCacheFirst: true);
  }

  Future<void> refresh() async {
    await _loadQuery(useCacheFirst: false);
  }

  Future<void> selectCampus(String campus) async {
    if (!campusBuildings.containsKey(campus)) {
      return;
    }

    _query = _currentQuery().copyWith(
      campus: campus,
      buildings: {_defaultBuilding(campus)},
    );
    await _persistAndLoad();
  }

  Future<void> toggleBuilding(String building) async {
    final query = _currentQuery();
    final nextBuildings = {...query.buildings};
    if (nextBuildings.contains(building)) {
      if (nextBuildings.length == 1) {
        return;
      }
      nextBuildings.remove(building);
    } else {
      nextBuildings.add(building);
    }

    _query = query.copyWith(buildings: nextBuildings);
    await _persistAndLoad();
  }

  Future<void> selectAllBuildings() async {
    final query = _currentQuery();
    final buildings = campusBuildings[query.campus] ?? const <String>[];
    if (buildings.isEmpty) {
      return;
    }
    _query = query.copyWith(buildings: buildings.toSet());
    await _persistAndLoad();
  }

  Future<void> selectOnlyDefaultBuilding() async {
    final query = _currentQuery();
    _query = query.copyWith(buildings: {_defaultBuilding(query.campus)});
    await _persistAndLoad();
  }

  Future<void> selectDate(DateTime date) async {
    _query = _currentQuery().copyWith(date: emptyRoomDate(date));
    await _persistAndLoad();
  }

  Future<void> selectStartPeriod(int period) async {
    final query = _currentQuery();
    _query = query.copyWith(
      startPeriod: period,
      endPeriod: query.endPeriod < period ? period : query.endPeriod,
    );
    await _persistAndRecompute();
  }

  Future<void> selectEndPeriod(int period) async {
    _query = _currentQuery().copyWith(endPeriod: period);
    await _persistAndRecompute();
  }

  Future<void> selectQuickFilter(EmptyRoomQuickFilter filter) async {
    _query = _currentQuery().copyWith(quickFilter: filter);
    await _persistAndRecompute();
  }

  Future<void> _persistAndLoad() async {
    await _repository.saveQuery(_currentQuery(), emptyRoomDate(_now()));
    await _loadQuery(useCacheFirst: true);
  }

  Future<void> _persistAndRecompute() async {
    await _repository.saveQuery(_currentQuery(), emptyRoomDate(_now()));
    final data = state.data;
    if (data == null) {
      await _loadQuery(useCacheFirst: true);
      return;
    }
    _applyRooms(
      rooms: data.allRooms,
      fetchedAt: data.fetchedAt,
      source: data.source,
    );
  }

  Future<void> _loadQuery({required bool useCacheFirst}) async {
    final query = _currentQuery();
    if (!useCacheFirst) {
      _setLoading();
    }

    EmptyRoomLoadResult? cached;
    if (useCacheFirst) {
      cached = await _repository.readCachedDay(query.date);
      if (cached != null) {
        _applyResult(cached);
      } else {
        _setLoading();
      }
    }

    try {
      final result = await _repository.fetchDay(query.date);
      _applyResult(result);
    } catch (error, stackTrace) {
      final latestCached =
          cached ?? await _repository.readCachedDay(query.date);
      if (latestCached != null) {
        _applyResult(latestCached, offline: true);
        return;
      }

      final message = error is EmptyRoomNoDataException
          ? error.message
          : '暂时无法访问空教室数据，请稍后重试。';
      _setState(
        AppAsyncState.error(
          title: '空教室查询失败',
          message: message,
          error: error,
          stackTrace: stackTrace,
          actions: [AppStateAction.retry(() => unawaited(refresh()))],
        ),
      );
    }
  }

  void _applyResult(EmptyRoomLoadResult result, {bool offline = false}) {
    try {
      final rooms = result.dayData.roomsFor(
        _currentQuery().campus,
        _currentQuery().buildings,
      );
      _applyRooms(
        rooms: rooms,
        fetchedAt: result.fetchedAt,
        source: result.source,
        offline: offline,
      );
    } catch (error, stackTrace) {
      _setState(
        AppAsyncState.error(
          title: '暂无空教室数据',
          message: error is EmptyRoomNoDataException
              ? error.message
              : '当前筛选条件没有可用数据。',
          error: error,
          stackTrace: stackTrace,
          actions: [AppStateAction.retry(() => unawaited(refresh()))],
        ),
      );
    }
  }

  void _applyRooms({
    required List<RoomInfo> rooms,
    required DateTime fetchedAt,
    required EmptyRoomDataSource source,
    bool offline = false,
  }) {
    final query = _currentQuery();
    final periodIndex = _effectivePeriodIndex(query);
    final data = EmptyRoomViewData(
      query: query,
      allRooms: rooms,
      displayRooms: filterRooms(
        rooms: rooms,
        query: query,
        effectivePeriodIndex: periodIndex,
      ),
      fetchedAt: fetchedAt,
      source: source,
      currentPeriodIndex: periodIndex,
      availableDates: availableDates,
    );

    if (rooms.isEmpty) {
      _setState(
        AppAsyncState.empty(
          title: '暂无空教室数据',
          message: '当前校区和教学楼暂无可展示的教室。',
          actions: [AppStateAction.retry(() => unawaited(refresh()))],
        ),
      );
      return;
    }

    _setState(
      offline
          ? AppAsyncState.offline(
              cachedData: data,
              title: '当前显示缓存空教室',
              message: '网络刷新失败，正在使用最近一次成功获取的数据。',
              actions: [AppStateAction.retry(() => unawaited(refresh()))],
            )
          : AppAsyncState.data(data),
    );
  }

  int _effectivePeriodIndex(EmptyRoomQuery query) {
    if (emptyRoomDate(query.date) != emptyRoomDate(_now())) {
      return -1;
    }
    return currentPeriodIndex(_now());
  }

  EmptyRoomQuery _currentQuery() {
    return _query ?? _defaultQuery(emptyRoomDate(_now()));
  }

  EmptyRoomQuery _defaultQuery(DateTime today) {
    final campus = campusBuildings.keys.first;
    final periodIndex = currentPeriodIndex(_now());
    final initialPeriod = periodIndex >= 0 ? periodIndex + 1 : 1;
    return EmptyRoomQuery(
      campus: campus,
      buildings: {_defaultBuilding(campus)},
      date: today,
      startPeriod: initialPeriod,
      endPeriod: initialPeriod,
      quickFilter: EmptyRoomQuickFilter.freeNow,
    );
  }

  String _defaultBuilding(String campus) {
    return campusBuildings[campus]?.first ?? '';
  }

  void _setLoading() {
    _setState(
      const AppAsyncState.loading(title: '正在查询空教室', message: '正在读取校区和教室数据。'),
    );
  }

  void _setState(AppAsyncState<EmptyRoomViewData> nextState) {
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

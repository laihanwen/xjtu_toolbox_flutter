import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'empty_room_models.dart';
import 'empty_room_parser.dart';

@immutable
class EmptyRoomLoadResult {
  const EmptyRoomLoadResult({
    required this.dayData,
    required this.fetchedAt,
    required this.source,
  });

  final EmptyRoomDayData dayData;
  final DateTime fetchedAt;
  final EmptyRoomDataSource source;
}

class EmptyRoomRepositoryException implements Exception {
  const EmptyRoomRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'EmptyRoomRepositoryException: $message';
}

abstract class EmptyRoomRepository {
  Future<EmptyRoomLoadResult?> readCachedDay(DateTime date);

  Future<EmptyRoomLoadResult> fetchDay(DateTime date);

  Future<EmptyRoomQuery?> readSavedQuery({
    required DateTime today,
    required List<String> campusNames,
    required String Function(String campus) defaultBuilding,
  });

  Future<void> saveQuery(EmptyRoomQuery query, DateTime today);
}

class HttpEmptyRoomRepository implements EmptyRoomRepository {
  HttpEmptyRoomRepository({
    http.Client? client,
    EmptyRoomParser parser = const EmptyRoomParser(),
    EmptyRoomCache? cache,
    Uri? baseUri,
  }) : _client = client ?? http.Client(),
       _parser = parser,
       _cache = cache ?? const EmptyRoomCache(),
       _baseUri = baseUri ?? Uri.parse('https://gh-release.xjtutoolbox.com/');

  final http.Client _client;
  final EmptyRoomParser _parser;
  final EmptyRoomCache _cache;
  final Uri _baseUri;

  @override
  Future<EmptyRoomLoadResult?> readCachedDay(DateTime date) async {
    final payload = await _cache.readDay(date);
    if (payload == null) {
      return null;
    }

    try {
      return EmptyRoomLoadResult(
        dayData: _parser.parseDay(payload.body),
        fetchedAt: payload.fetchedAt,
        source: EmptyRoomDataSource.cache,
      );
    } catch (_) {
      await _cache.clearDay(date);
      return null;
    }
  }

  @override
  Future<EmptyRoomLoadResult> fetchDay(DateTime date) async {
    try {
      final response = await _client.get(_dayUri(date));
      if (response.statusCode == 404) {
        throw const EmptyRoomNoDataException('当天暂无空闲教室数据，请稍后再试');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw EmptyRoomRepositoryException(
          'Empty room request failed with HTTP ${response.statusCode}.',
        );
      }

      final dayData = _parser.parseDay(response.body);
      final fetchedAt = DateTime.now();
      await _cache.writeDay(
        date: date,
        body: response.body,
        fetchedAt: fetchedAt,
      );

      return EmptyRoomLoadResult(
        dayData: dayData,
        fetchedAt: fetchedAt,
        source: EmptyRoomDataSource.network,
      );
    } on EmptyRoomNoDataException {
      rethrow;
    } on EmptyRoomRepositoryException {
      rethrow;
    } catch (error) {
      throw EmptyRoomRepositoryException('Unable to fetch empty rooms.', error);
    }
  }

  @override
  Future<EmptyRoomQuery?> readSavedQuery({
    required DateTime today,
    required List<String> campusNames,
    required String Function(String campus) defaultBuilding,
  }) {
    return _cache.readQuery(
      today: today,
      campusNames: campusNames,
      defaultBuilding: defaultBuilding,
    );
  }

  @override
  Future<void> saveQuery(EmptyRoomQuery query, DateTime today) {
    return _cache.writeQuery(query, today);
  }

  Uri _dayUri(DateTime date) {
    return _baseUri.replace(
      queryParameters: {
        'file': 'static/empty_room/${formatEmptyRoomDate(date)}.json',
      },
    );
  }
}

@immutable
class EmptyRoomCachePayload {
  const EmptyRoomCachePayload({required this.body, required this.fetchedAt});

  final String body;
  final DateTime fetchedAt;
}

class EmptyRoomCache {
  const EmptyRoomCache();

  static const _queryCampusKey = 'empty_room.query.campus';
  static const _queryBuildingsKey = 'empty_room.query.buildings';
  static const _queryDateOffsetKey = 'empty_room.query.date_offset';
  static const _queryStartPeriodKey = 'empty_room.query.start_period';
  static const _queryEndPeriodKey = 'empty_room.query.end_period';
  static const _queryFilterKey = 'empty_room.query.filter';

  Future<EmptyRoomCachePayload?> readDay(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final keySuffix = formatEmptyRoomDate(date);
    final body = prefs.getString('empty_room.day.$keySuffix.body');
    final fetchedAtText = prefs.getString(
      'empty_room.day.$keySuffix.fetched_at',
    );
    if (body == null || fetchedAtText == null) {
      return null;
    }

    final fetchedAt = DateTime.tryParse(fetchedAtText);
    if (fetchedAt == null) {
      await clearDay(date);
      return null;
    }

    return EmptyRoomCachePayload(body: body, fetchedAt: fetchedAt);
  }

  Future<void> writeDay({
    required DateTime date,
    required String body,
    required DateTime fetchedAt,
  }) async {
    jsonDecode(body);
    final prefs = await SharedPreferences.getInstance();
    final keySuffix = formatEmptyRoomDate(date);
    await prefs.setString('empty_room.day.$keySuffix.body', body);
    await prefs.setString(
      'empty_room.day.$keySuffix.fetched_at',
      fetchedAt.toIso8601String(),
    );
  }

  Future<void> clearDay(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final keySuffix = formatEmptyRoomDate(date);
    await prefs.remove('empty_room.day.$keySuffix.body');
    await prefs.remove('empty_room.day.$keySuffix.fetched_at');
  }

  Future<EmptyRoomQuery?> readQuery({
    required DateTime today,
    required List<String> campusNames,
    required String Function(String campus) defaultBuilding,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (campusNames.isEmpty) {
      return null;
    }

    final campus = prefs.getString(_queryCampusKey);
    final selectedCampus = campusNames.contains(campus)
        ? campus!
        : campusNames.first;
    final rawBuildings = prefs.getStringList(_queryBuildingsKey) ?? const [];
    final selectedBuildings = rawBuildings
        .where((building) => building.trim().isNotEmpty)
        .toSet();
    final buildings = selectedBuildings.isEmpty
        ? {defaultBuilding(selectedCampus)}
        : selectedBuildings;
    final dateOffset = (prefs.getInt(_queryDateOffsetKey) ?? 0)
        .clamp(0, 1)
        .toInt();
    final startPeriod = (prefs.getInt(_queryStartPeriodKey) ?? 1)
        .clamp(1, 11)
        .toInt();
    final endPeriod = (prefs.getInt(_queryEndPeriodKey) ?? 11)
        .clamp(startPeriod, 11)
        .toInt();

    return EmptyRoomQuery(
      campus: selectedCampus,
      buildings: buildings,
      date: emptyRoomDate(today).add(Duration(days: dateOffset)),
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      quickFilter: EmptyRoomQuickFilter.fromName(
        prefs.getString(_queryFilterKey),
      ),
    );
  }

  Future<void> writeQuery(EmptyRoomQuery query, DateTime today) async {
    final prefs = await SharedPreferences.getInstance();
    final offset = emptyRoomDate(
      query.date,
    ).difference(emptyRoomDate(today)).inDays;
    await prefs.setString(_queryCampusKey, query.campus);
    await prefs.setStringList(
      _queryBuildingsKey,
      query.buildings.toList()..sort(),
    );
    await prefs.setInt(_queryDateOffsetKey, offset.clamp(0, 1).toInt());
    await prefs.setInt(_queryStartPeriodKey, query.startPeriod);
    await prefs.setInt(_queryEndPeriodKey, query.endPeriod);
    await prefs.setString(_queryFilterKey, query.quickFilter.name);
  }
}

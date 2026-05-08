import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'school_calendar_models.dart';
import 'school_calendar_parser.dart';

enum SchoolCalendarDataSource { network, cache }

@immutable
class SchoolCalendarLoadResult {
  const SchoolCalendarLoadResult({
    required this.terms,
    required this.fetchedAt,
    required this.source,
  });

  final List<SchoolTerm> terms;
  final DateTime fetchedAt;
  final SchoolCalendarDataSource source;
}

class SchoolCalendarRepositoryException implements Exception {
  const SchoolCalendarRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'SchoolCalendarRepositoryException: $message';
}

abstract class SchoolCalendarRepository {
  Future<SchoolCalendarLoadResult?> readCachedTerms();

  Future<SchoolCalendarLoadResult> fetchTerms();
}

class HttpSchoolCalendarRepository implements SchoolCalendarRepository {
  HttpSchoolCalendarRepository({
    http.Client? client,
    SchoolCalendarParser parser = const SchoolCalendarParser(),
    SchoolCalendarCache? cache,
    Uri? baseUri,
  }) : _client = client ?? http.Client(),
       _parser = parser,
       _cache = cache ?? const SchoolCalendarCache(),
       _baseUri = baseUri ?? Uri.parse('http://one2020.xjtu.edu.cn');

  final http.Client _client;
  final SchoolCalendarParser _parser;
  final SchoolCalendarCache _cache;
  final Uri _baseUri;

  @override
  Future<SchoolCalendarLoadResult?> readCachedTerms() async {
    final payload = await _cache.read();
    if (payload == null) {
      return null;
    }

    try {
      return SchoolCalendarLoadResult(
        terms: _parser.parseTerms(payload.body),
        fetchedAt: payload.fetchedAt,
        source: SchoolCalendarDataSource.cache,
      );
    } catch (_) {
      await _cache.clear();
      return null;
    }
  }

  @override
  Future<SchoolCalendarLoadResult> fetchTerms() async {
    try {
      await _bestEffortInitSession();
      final response = await _client.post(
        _termsUri,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Origin': _baseUri.origin,
          'Referer': _showCalendarUri.toString(),
        },
        body: '',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SchoolCalendarRepositoryException(
          'School calendar request failed with HTTP ${response.statusCode}.',
        );
      }

      final terms = _parser.parseTerms(response.body);
      final fetchedAt = DateTime.now();
      await _cache.write(body: response.body, fetchedAt: fetchedAt);

      return SchoolCalendarLoadResult(
        terms: terms,
        fetchedAt: fetchedAt,
        source: SchoolCalendarDataSource.network,
      );
    } on SchoolCalendarRepositoryException {
      rethrow;
    } catch (error) {
      throw SchoolCalendarRepositoryException(
        'Unable to fetch school calendar.',
        error,
      );
    }
  }

  Uri get _showCalendarUri {
    return _baseUri.replace(
      path: '/EIP/edu/education/schoolcalendar/showCalendar.htm',
    );
  }

  Uri get _termsUri {
    return _baseUri.replace(path: '/EIP/schoolcalendar/terms.htm');
  }

  Future<void> _bestEffortInitSession() async {
    try {
      await _client.get(_showCalendarUri);
    } catch (_) {
      return;
    }
  }
}

@immutable
class SchoolCalendarCachePayload {
  const SchoolCalendarCachePayload({
    required this.body,
    required this.fetchedAt,
  });

  final String body;
  final DateTime fetchedAt;
}

class SchoolCalendarCache {
  const SchoolCalendarCache();

  static const _bodyKey = 'school_calendar.cache.body';
  static const _fetchedAtKey = 'school_calendar.cache.fetched_at';

  Future<SchoolCalendarCachePayload?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final body = prefs.getString(_bodyKey);
    final fetchedAtText = prefs.getString(_fetchedAtKey);
    if (body == null || fetchedAtText == null) {
      return null;
    }

    final fetchedAt = DateTime.tryParse(fetchedAtText);
    if (fetchedAt == null) {
      await clear();
      return null;
    }

    return SchoolCalendarCachePayload(body: body, fetchedAt: fetchedAt);
  }

  Future<void> write({
    required String body,
    required DateTime fetchedAt,
  }) async {
    jsonDecode(body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bodyKey, body);
    await prefs.setString(_fetchedAtKey, fetchedAt.toIso8601String());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bodyKey);
    await prefs.remove(_fetchedAtKey);
  }
}

import 'dart:convert';

import 'school_calendar_models.dart';

class SchoolCalendarParseException implements Exception {
  const SchoolCalendarParseException(this.message);

  final String message;

  @override
  String toString() => 'SchoolCalendarParseException: $message';
}

class SchoolCalendarParser {
  const SchoolCalendarParser();

  List<SchoolTerm> parseTerms(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const SchoolCalendarParseException('Response is not an object.');
    }

    final code = _asInt(decoded['code']) ?? -1;
    if (code != 200) {
      final message = _asString(decoded['msg']);
      throw SchoolCalendarParseException(
        'School calendar API returned code=$code: ${message ?? ''}',
      );
    }

    final data = decoded['data'];
    if (data is! List) {
      throw const SchoolCalendarParseException('Response data is not a list.');
    }

    final terms = data.map((item) {
      if (item is! Map<String, Object?>) {
        throw const SchoolCalendarParseException('Term item is not an object.');
      }
      return _parseTerm(item);
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

    return terms;
  }

  SchoolTerm _parseTerm(Map<String, Object?> object) {
    final events = <CalendarEvent>[];
    final holidays = object['holidays'];
    if (holidays is List) {
      for (final item in holidays) {
        if (item is Map<String, Object?>) {
          try {
            events.add(_parseEvent(item));
          } catch (_) {
            continue;
          }
        }
      }
    }
    events.sort((a, b) => a.startDate.compareTo(b.startDate));

    return SchoolTerm(
      id: _asString(object['id']) ?? '',
      startDate: parseCalendarDate(_requiredString(object, 'start_date')),
      endDate: parseCalendarDate(_requiredString(object, 'end_date')),
      termName: _asString(object['term_num']) ?? '',
      yearName: _asString(object['year_num']) ?? '',
      totalWeeks: _asInt(object['week_number']) ?? 0,
      workDays: _asInt(object['work_days']) ?? 0,
      events: events,
    );
  }

  CalendarEvent _parseEvent(Map<String, Object?> object) {
    return CalendarEvent(
      id: _asString(object['id']) ?? '',
      startDate: parseCalendarDate(_requiredString(object, 'start_date')),
      endDate: parseCalendarDate(_requiredString(object, 'end_date')),
      name: _asString(object['holiday_name']) ?? '',
      remark: _asString(object['holiday_remark']) ?? '',
      days: _asInt(object['holiday_days']) ?? 0,
      colorHex: _asString(object['holiday_color']) ?? '#196dd0',
    );
  }

  static String _requiredString(Map<String, Object?> object, String key) {
    final value = _asString(object[key]);
    if (value == null || value.isEmpty) {
      throw SchoolCalendarParseException('Missing required field: $key.');
    }
    return value;
  }

  static String? _asString(Object? value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}

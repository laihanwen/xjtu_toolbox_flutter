import 'package:flutter/foundation.dart';

@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.name,
    required this.remark,
    required this.days,
    required this.colorHex,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String name;
  final String remark;
  final int days;
  final String colorHex;

  bool contains(DateTime date) {
    final day = calendarDate(date);
    return !day.isBefore(startDate) && !day.isAfter(endDate);
  }
}

@immutable
class SchoolTerm {
  const SchoolTerm({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.termName,
    required this.yearName,
    required this.totalWeeks,
    required this.workDays,
    required this.events,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String termName;
  final String yearName;
  final int totalWeeks;
  final int workDays;
  final List<CalendarEvent> events;

  int currentWeek([DateTime? today]) {
    final day = calendarDate(today ?? DateTime.now());
    if (day.isBefore(startDate) || day.isAfter(endDate)) {
      return 0;
    }
    return day.difference(startDate).inDays ~/ 7 + 1;
  }

  int currentDay([DateTime? today]) {
    final day = calendarDate(today ?? DateTime.now());
    if (day.isBefore(startDate)) {
      return 0;
    }
    return day.difference(startDate).inDays + 1;
  }

  int totalDays() {
    return endDate.difference(startDate).inDays + 1;
  }

  int daysRemaining([DateTime? today]) {
    final day = calendarDate(today ?? DateTime.now());
    if (day.isAfter(endDate)) {
      return 0;
    }
    final from = day.isBefore(startDate) ? startDate : day;
    return endDate.difference(from).inDays;
  }

  double progress([DateTime? today]) {
    final day = calendarDate(today ?? DateTime.now());
    if (!day.isAfter(startDate)) {
      return 0;
    }
    if (!day.isBefore(endDate)) {
      return 1;
    }
    final value = currentDay(day) / totalDays();
    return value.clamp(0, 1).toDouble();
  }

  CalendarEvent? todayEvent([DateTime? today]) {
    final day = calendarDate(today ?? DateTime.now());
    for (final event in events) {
      if (event.contains(day)) {
        return event;
      }
    }
    return null;
  }
}

DateTime calendarDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime parseCalendarDate(String value) {
  final parsed = DateTime.parse(value);
  return calendarDate(parsed);
}

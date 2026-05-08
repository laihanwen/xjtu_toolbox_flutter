import 'package:flutter/foundation.dart';

import 'empty_room_constants.dart';

enum EmptyRoomQuickFilter {
  all('全部'),
  freeNow('现在空闲'),
  justReleased('刚解放'),
  largeRoom('大教室');

  const EmptyRoomQuickFilter(this.label);

  final String label;

  static EmptyRoomQuickFilter fromName(String? name) {
    return EmptyRoomQuickFilter.values.firstWhere(
      (filter) => filter.name == name,
      orElse: () => EmptyRoomQuickFilter.freeNow,
    );
  }
}

enum EmptyRoomDataSource { network, cache }

@immutable
class RoomInfo {
  const RoomInfo({
    required this.name,
    required this.size,
    required this.status,
  });

  final String name;
  final int size;
  final List<int> status;

  bool isFreeAt(int periodIndex) {
    return periodIndex >= 0 &&
        periodIndex < status.length &&
        status[periodIndex] == 0;
  }

  bool isFreeInRange(int startPeriod, int endPeriod) {
    final start = (startPeriod - 1).clamp(0, status.length - 1);
    final end = (endPeriod - 1).clamp(start, status.length - 1);
    for (var index = start; index <= end; index++) {
      if (status.elementAtOrNull(index) != 0) {
        return false;
      }
    }
    return true;
  }
}

@immutable
class EmptyRoomQuery {
  const EmptyRoomQuery({
    required this.campus,
    required this.buildings,
    required this.date,
    required this.startPeriod,
    required this.endPeriod,
    required this.quickFilter,
  });

  final String campus;
  final Set<String> buildings;
  final DateTime date;
  final int startPeriod;
  final int endPeriod;
  final EmptyRoomQuickFilter quickFilter;

  EmptyRoomQuery copyWith({
    String? campus,
    Set<String>? buildings,
    DateTime? date,
    int? startPeriod,
    int? endPeriod,
    EmptyRoomQuickFilter? quickFilter,
  }) {
    final nextStart = startPeriod ?? this.startPeriod;
    final nextEnd = endPeriod ?? this.endPeriod;
    return EmptyRoomQuery(
      campus: campus ?? this.campus,
      buildings: buildings ?? this.buildings,
      date: date ?? this.date,
      startPeriod: nextStart.clamp(1, periodTimes.length).toInt(),
      endPeriod: nextEnd.clamp(nextStart, periodTimes.length).toInt(),
      quickFilter: quickFilter ?? this.quickFilter,
    );
  }
}

@immutable
class EmptyRoomDayData {
  const EmptyRoomDayData(this.campuses);

  final Map<String, Map<String, List<RoomInfo>>> campuses;

  List<RoomInfo> roomsFor(String campus, Set<String> buildings) {
    if (buildings.isEmpty) {
      return const [];
    }

    final campusData = campuses[campus];
    if (campusData == null) {
      throw EmptyRoomNoDataException('暂无 $campus 的数据');
    }

    final rooms = <RoomInfo>[];
    for (final building in buildings) {
      final buildingRooms = campusData[building];
      if (buildingRooms == null) {
        throw EmptyRoomNoDataException('暂无 $campus - $building 的数据');
      }
      rooms.addAll(buildingRooms);
    }

    rooms.sort((a, b) => a.name.compareTo(b.name));
    return rooms;
  }
}

@immutable
class EmptyRoomViewData {
  const EmptyRoomViewData({
    required this.query,
    required this.allRooms,
    required this.displayRooms,
    required this.fetchedAt,
    required this.source,
    required this.currentPeriodIndex,
    required this.availableDates,
  });

  final EmptyRoomQuery query;
  final List<RoomInfo> allRooms;
  final List<RoomInfo> displayRooms;
  final DateTime fetchedAt;
  final EmptyRoomDataSource source;
  final int currentPeriodIndex;
  final List<DateTime> availableDates;
}

class EmptyRoomNoDataException implements Exception {
  const EmptyRoomNoDataException(this.message);

  final String message;

  @override
  String toString() => 'EmptyRoomNoDataException: $message';
}

DateTime emptyRoomDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String formatEmptyRoomDate(DateTime value) {
  final date = emptyRoomDate(value);
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String formatMonthDay(DateTime value) {
  final date = emptyRoomDate(value);
  return '${date.month}/${date.day}';
}

import 'empty_room_constants.dart';
import 'empty_room_models.dart';

int currentPeriodIndex(DateTime now) {
  final minutes = now.hour * 60 + now.minute;
  for (var index = 0; index < periodTimes.length; index++) {
    final start = _minutesOf(periodTimes[index].start);
    final end = _minutesOf(periodTimes[index].end);
    if (minutes >= start && minutes <= end) {
      return index;
    }

    if (index < periodTimes.length - 1) {
      final nextStart = _minutesOf(periodTimes[index + 1].start);
      if (minutes >= end && minutes <= nextStart) {
        return index + 1;
      }
    }
  }

  if (minutes < _minutesOf(periodTimes.first.start)) {
    return 0;
  }

  return -1;
}

int consecutiveFreePeriods(RoomInfo room, int startIndex) {
  if (startIndex < 0 || startIndex >= room.status.length) {
    return 0;
  }

  var count = 0;
  for (var index = startIndex; index < room.status.length; index++) {
    if (room.status[index] != 0) {
      break;
    }
    count += 1;
  }
  return count;
}

List<RoomInfo> filterRooms({
  required List<RoomInfo> rooms,
  required EmptyRoomQuery query,
  required int effectivePeriodIndex,
}) {
  final rangeFiltered = rooms
      .where((room) => room.isFreeInRange(query.startPeriod, query.endPeriod))
      .toList();

  final filtered = switch (query.quickFilter) {
    EmptyRoomQuickFilter.all => rangeFiltered,
    EmptyRoomQuickFilter.freeNow =>
      effectivePeriodIndex >= 0
          ? rangeFiltered
                .where((room) => room.isFreeAt(effectivePeriodIndex))
                .toList()
          : rangeFiltered,
    EmptyRoomQuickFilter.justReleased =>
      effectivePeriodIndex > 0
          ? rangeFiltered
                .where(
                  (room) =>
                      room.isFreeAt(effectivePeriodIndex) &&
                      !room.isFreeAt(effectivePeriodIndex - 1),
                )
                .toList()
          : const <RoomInfo>[],
    EmptyRoomQuickFilter.largeRoom =>
      rangeFiltered.where((room) => room.size >= 100).toList(),
  };

  if (effectivePeriodIndex >= 0) {
    filtered.sort(
      (a, b) => consecutiveFreePeriods(
        b,
        effectivePeriodIndex,
      ).compareTo(consecutiveFreePeriods(a, effectivePeriodIndex)),
    );
  } else {
    filtered.sort((a, b) => a.name.compareTo(b.name));
  }
  return filtered;
}

int _minutesOf(String value) {
  final parts = value.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

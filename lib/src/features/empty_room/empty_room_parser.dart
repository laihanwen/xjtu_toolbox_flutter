import 'dart:convert';

import 'empty_room_models.dart';

class EmptyRoomParseException implements Exception {
  const EmptyRoomParseException(this.message);

  final String message;

  @override
  String toString() => 'EmptyRoomParseException: $message';
}

class EmptyRoomParser {
  const EmptyRoomParser();

  EmptyRoomDayData parseDay(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const EmptyRoomParseException('Response is not an object.');
    }

    final campuses = <String, Map<String, List<RoomInfo>>>{};
    for (final campusEntry in decoded.entries) {
      final campusValue = campusEntry.value;
      if (campusValue is! Map<String, Object?>) {
        continue;
      }

      final buildings = <String, List<RoomInfo>>{};
      for (final buildingEntry in campusValue.entries) {
        final buildingValue = buildingEntry.value;
        if (buildingValue is! Map<String, Object?>) {
          continue;
        }

        final rooms = <RoomInfo>[];
        for (final roomEntry in buildingValue.entries) {
          final roomName = roomEntry.key.trim();
          final roomValue = roomEntry.value;
          if (roomName.isEmpty || roomName == 'null' || roomValue == null) {
            continue;
          }
          if (roomValue is! Map<String, Object?>) {
            continue;
          }

          final room = _tryParseRoom(roomName, roomValue);
          if (room != null) {
            rooms.add(room);
          }
        }
        rooms.sort((a, b) => a.name.compareTo(b.name));
        buildings[buildingEntry.key] = rooms;
      }
      campuses[campusEntry.key] = buildings;
    }

    return EmptyRoomDayData(campuses);
  }

  RoomInfo? _tryParseRoom(String name, Map<String, Object?> object) {
    try {
      final rawStatus = object['status'];
      if (rawStatus is! List) {
        return null;
      }

      final status = rawStatus.map(_asInt).whereType<int>().toList();
      if (status.isEmpty) {
        return null;
      }

      return RoomInfo(
        name: name,
        size: _asInt(object['size']) ?? 0,
        status: status,
      );
    } catch (_) {
      return null;
    }
  }

  int? _asInt(Object? value) {
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

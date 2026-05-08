import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/features/empty_room/empty_room_filters.dart';
import 'package:xjtu_toolbox_flutter/src/features/empty_room/empty_room_models.dart';
import 'package:xjtu_toolbox_flutter/src/features/empty_room/empty_room_parser.dart';

void main() {
  const parser = EmptyRoomParser();

  test('parses CDN day data', () {
    final data = parser.parseDay(_emptyRoomJson());
    final rooms = data.roomsFor('兴庆校区', {'主楼A'});

    expect(rooms, hasLength(2));
    expect(rooms.first.name, '101');
    expect(rooms.first.size, 120);
    expect(rooms.first.status, hasLength(11));
  });

  test('skips null, blank and malformed room entries', () {
    final data = parser.parseDay(_emptyRoomJson(includeBadRooms: true));
    final rooms = data.roomsFor('兴庆校区', {'主楼A'});

    expect(rooms.map((room) => room.name), ['101', '102']);
  });

  test('throws no data for missing campus or building', () {
    final data = parser.parseDay(_emptyRoomJson());

    expect(
      () => data.roomsFor('不存在校区', {'主楼A'}),
      throwsA(isA<EmptyRoomNoDataException>()),
    );
    expect(
      () => data.roomsFor('兴庆校区', {'不存在楼'}),
      throwsA(isA<EmptyRoomNoDataException>()),
    );
  });

  test('computes current period with break time semantics', () {
    expect(currentPeriodIndex(DateTime(2025, 9, 15, 7, 30)), 0);
    expect(currentPeriodIndex(DateTime(2025, 9, 15, 8, 20)), 0);
    expect(currentPeriodIndex(DateTime(2025, 9, 15, 8, 55)), 1);
    expect(currentPeriodIndex(DateTime(2025, 9, 15, 22, 0)), -1);
  });

  test('filters and sorts rooms', () {
    final rooms = [
      const RoomInfo(
        name: 'A',
        size: 80,
        status: [1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
      ),
      const RoomInfo(
        name: 'B',
        size: 160,
        status: [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      ),
    ];

    final justReleased = filterRooms(
      rooms: rooms,
      query: EmptyRoomQuery(
        campus: '兴庆校区',
        buildings: const {'主楼A'},
        date: DateTime(2025, 9, 15),
        startPeriod: 2,
        endPeriod: 2,
        quickFilter: EmptyRoomQuickFilter.justReleased,
      ),
      effectivePeriodIndex: 1,
    );
    expect(justReleased.single.name, 'A');

    final largeRooms = filterRooms(
      rooms: rooms,
      query: EmptyRoomQuery(
        campus: '兴庆校区',
        buildings: const {'主楼A'},
        date: DateTime(2025, 9, 15),
        startPeriod: 1,
        endPeriod: 1,
        quickFilter: EmptyRoomQuickFilter.largeRoom,
      ),
      effectivePeriodIndex: 0,
    );
    expect(largeRooms.single.name, 'B');
  });
}

String _emptyRoomJson({bool includeBadRooms = false}) {
  final badRooms = includeBadRooms
      ? '''
        ,
        "": {"size": 10, "status": [0]},
        "null": {"size": 10, "status": [0]},
        "bad": {"size": 10},
        "bad2": null
      '''
      : '';

  return '''
  {
    "兴庆校区": {
      "主楼A": {
        "101": {
          "size": 120,
          "status": [0,0,0,0,1,1,0,0,0,0,0]
        },
        "102": {
          "size": null,
          "status": [1,0,0,0,0,0,0,0,0,0,0]
        }
        $badRooms
      },
      "主楼B": {
        "201": {
          "size": 80,
          "status": [0,1,1,1,1,1,1,1,1,1,1]
        }
      }
    },
    "雁塔校区": {
      "教学楼": {
        "301": {
          "size": 60,
          "status": [0,0,0,0,0,0,0,0,0,0,0]
        }
      }
    }
  }
  ''';
}

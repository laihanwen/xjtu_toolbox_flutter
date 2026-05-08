import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/features/empty_room/empty_room_models.dart';
import 'package:xjtu_toolbox_flutter/src/features/empty_room/empty_room_parser.dart';
import 'package:xjtu_toolbox_flutter/src/features/empty_room/empty_room_repository.dart';
import 'package:xjtu_toolbox_flutter/src/features/empty_room/empty_room_screen.dart';

void main() {
  testWidgets('renders empty room data in Material mode', (tester) async {
    final repository = _FakeEmptyRoomRepository(fetchResults: [_result()]);

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('空教室'), findsOneWidget);
    expect(find.text('查询条件'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
    expect(find.text('120 座'), findsOneWidget);
  });

  testWidgets('renders loading state', (tester) async {
    await tester.pumpWidget(
      _TestApp(repository: _NeverCompleteEmptyRoomRepository()),
    );
    await tester.pump();

    expect(find.text('正在查询空教室'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state and retries', (tester) async {
    final repository = _FakeEmptyRoomRepository(
      fetchErrors: [Exception('network')],
      fetchResults: [_result()],
    );

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('空教室查询失败'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('101'), findsOneWidget);
    expect(repository.fetchCount, 2);
  });

  testWidgets('renders offline state with cached data', (tester) async {
    final repository = _FakeEmptyRoomRepository(
      cachedResult: _result(source: EmptyRoomDataSource.cache),
      fetchErrors: [Exception('network')],
    );

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('当前显示缓存空教室'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
  });

  testWidgets('updates filters from campus, building and quick filter', (
    tester,
  ) async {
    final repository = _FakeEmptyRoomRepository(fetchResults: [_result()]);

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('雁塔'));
    await tester.pumpAndSettle();
    expect(find.text('301'), findsOneWidget);

    await tester.tap(find.text('大教室'));
    await tester.pumpAndSettle();
    expect(find.text('暂无符合条件的教室'), findsOneWidget);
  });

  testWidgets('renders data in Liquid Glass-like mode', (tester) async {
    final repository = _FakeEmptyRoomRepository(fetchResults: [_result()]);

    await tester.pumpWidget(
      _TestApp(repository: repository, platform: TargetPlatform.iOS),
    );
    await tester.pumpAndSettle();

    expect(find.text('空教室'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.repository,
    this.platform = TargetPlatform.android,
  });

  final EmptyRoomRepository repository;
  final TargetPlatform platform;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: platform, useMaterial3: true),
      home: Scaffold(
        body: EmptyRoomScreen(
          repository: repository,
          now: () => DateTime(2025, 9, 15, 8, 20),
        ),
      ),
    );
  }
}

class _FakeEmptyRoomRepository implements EmptyRoomRepository {
  _FakeEmptyRoomRepository({
    this.cachedResult,
    this.fetchResults = const [],
    this.fetchErrors = const [],
  });

  final EmptyRoomLoadResult? cachedResult;
  final List<EmptyRoomLoadResult> fetchResults;
  final List<Object> fetchErrors;

  int fetchCount = 0;
  EmptyRoomQuery? savedQuery;

  @override
  Future<EmptyRoomLoadResult?> readCachedDay(DateTime date) async {
    return cachedResult;
  }

  @override
  Future<EmptyRoomLoadResult> fetchDay(DateTime date) async {
    final index = fetchCount;
    fetchCount += 1;
    if (index < fetchErrors.length) {
      throw fetchErrors[index];
    }
    final resultIndex = (index - fetchErrors.length)
        .clamp(0, fetchResults.length - 1)
        .toInt();
    return fetchResults[resultIndex];
  }

  @override
  Future<EmptyRoomQuery?> readSavedQuery({
    required DateTime today,
    required List<String> campusNames,
    required String Function(String campus) defaultBuilding,
  }) async {
    return savedQuery;
  }

  @override
  Future<void> saveQuery(EmptyRoomQuery query, DateTime today) async {
    savedQuery = query;
  }
}

class _NeverCompleteEmptyRoomRepository implements EmptyRoomRepository {
  final _completer = Completer<EmptyRoomLoadResult>();

  @override
  Future<EmptyRoomLoadResult?> readCachedDay(DateTime date) async {
    return null;
  }

  @override
  Future<EmptyRoomLoadResult> fetchDay(DateTime date) {
    return _completer.future;
  }

  @override
  Future<EmptyRoomQuery?> readSavedQuery({
    required DateTime today,
    required List<String> campusNames,
    required String Function(String campus) defaultBuilding,
  }) async {
    return null;
  }

  @override
  Future<void> saveQuery(EmptyRoomQuery query, DateTime today) async {}
}

EmptyRoomLoadResult _result({
  EmptyRoomDataSource source = EmptyRoomDataSource.network,
}) {
  return EmptyRoomLoadResult(
    dayData: const EmptyRoomParser().parseDay('''
    {
      "兴庆校区": {
        "主楼A": {
          "101": {
            "size": 120,
            "status": [0,0,0,0,1,1,0,0,0,0,0]
          }
        },
        "主楼B": {
          "201": {
            "size": 80,
            "status": [0,1,1,1,1,1,1,1,1,1,1]
          }
        }
      },
      "雁塔校区": {
        "东配楼": {
          "301": {
            "size": 60,
            "status": [0,0,0,0,0,0,0,0,0,0,0]
          }
        }
      }
    }
    '''),
    fetchedAt: DateTime(2025, 9, 15, 8, 30),
    source: source,
  );
}

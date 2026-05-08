import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/features/calendar/school_calendar_models.dart';
import 'package:xjtu_toolbox_flutter/src/features/calendar/school_calendar_repository.dart';
import 'package:xjtu_toolbox_flutter/src/features/calendar/school_calendar_screen.dart';

void main() {
  testWidgets('renders calendar data in Material mode', (tester) async {
    final repository = _FakeCalendarRepository(fetchResults: [_result()]);

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('校历'), findsOneWidget);
    expect(find.text('第 3 学习周'), findsOneWidget);
    expect(find.text('日程安排'), findsOneWidget);
    expect(find.text('国庆节'), findsOneWidget);
  });

  testWidgets('renders loading state', (tester) async {
    final repository = _NeverCompleteCalendarRepository();

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pump();

    expect(find.text('正在加载校历'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state', (tester) async {
    final repository = _FakeCalendarRepository(
      fetchResults: [
        SchoolCalendarLoadResult(
          terms: const [],
          fetchedAt: DateTime(2025, 9, 1),
          source: SchoolCalendarDataSource.network,
        ),
      ],
    );

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('暂无校历数据'), findsOneWidget);
  });

  testWidgets('renders error state and retries', (tester) async {
    final repository = _FakeCalendarRepository(
      fetchResults: [_result()],
      fetchErrors: [Exception('network down')],
    );

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('校历加载失败'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('第 3 学习周'), findsOneWidget);
    expect(repository.fetchCount, 2);
  });

  testWidgets('renders offline state with cached data', (tester) async {
    final repository = _FakeCalendarRepository(
      cachedResult: _result(source: SchoolCalendarDataSource.cache),
      fetchErrors: [Exception('network down')],
    );

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('当前显示缓存校历'), findsOneWidget);
    expect(find.text('第 3 学习周'), findsOneWidget);
  });

  testWidgets('renders data in Liquid Glass-like mode', (tester) async {
    final repository = _FakeCalendarRepository(fetchResults: [_result()]);

    await tester.pumpWidget(
      _TestApp(repository: repository, platform: TargetPlatform.iOS),
    );
    await tester.pumpAndSettle();

    expect(find.text('校历'), findsOneWidget);
    expect(find.text('国庆节'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.repository,
    this.platform = TargetPlatform.android,
  });

  final SchoolCalendarRepository repository;
  final TargetPlatform platform;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: platform, useMaterial3: true),
      home: Scaffold(
        body: SchoolCalendarScreen(
          repository: repository,
          now: () => DateTime(2025, 9, 15),
        ),
      ),
    );
  }
}

class _FakeCalendarRepository implements SchoolCalendarRepository {
  _FakeCalendarRepository({
    this.cachedResult,
    this.fetchResults = const [],
    this.fetchErrors = const [],
  });

  final SchoolCalendarLoadResult? cachedResult;
  final List<SchoolCalendarLoadResult> fetchResults;
  final List<Object> fetchErrors;

  int fetchCount = 0;

  @override
  Future<SchoolCalendarLoadResult?> readCachedTerms() async {
    return cachedResult;
  }

  @override
  Future<SchoolCalendarLoadResult> fetchTerms() async {
    final index = fetchCount;
    fetchCount += 1;
    if (index < fetchErrors.length) {
      throw fetchErrors[index];
    }
    return fetchResults[index - fetchErrors.length];
  }
}

class _NeverCompleteCalendarRepository implements SchoolCalendarRepository {
  final _completer = Completer<SchoolCalendarLoadResult>();

  @override
  Future<SchoolCalendarLoadResult?> readCachedTerms() async {
    return null;
  }

  @override
  Future<SchoolCalendarLoadResult> fetchTerms() {
    return _completer.future;
  }
}

SchoolCalendarLoadResult _result({
  SchoolCalendarDataSource source = SchoolCalendarDataSource.network,
}) {
  return SchoolCalendarLoadResult(
    terms: [
      SchoolTerm(
        id: '2025-1',
        startDate: DateTime(2025, 9, 1),
        endDate: DateTime(2026, 1, 18),
        termName: '2025-2026学年第一学期',
        yearName: '2025-2026',
        totalWeeks: 20,
        workDays: 98,
        events: [
          CalendarEvent(
            id: 'national',
            startDate: DateTime(2025, 10, 1),
            endDate: DateTime(2025, 10, 7),
            name: '国庆节',
            remark: '放假',
            days: 7,
            colorHex: '#ff3355',
          ),
        ],
      ),
    ],
    fetchedAt: DateTime(2025, 9, 15, 8, 30),
    source: source,
  );
}

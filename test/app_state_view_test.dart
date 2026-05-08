import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/ui/app_async_state.dart';
import 'package:xjtu_toolbox_flutter/src/ui/app_page.dart';
import 'package:xjtu_toolbox_flutter/src/ui/app_state_view.dart';

void main() {
  testWidgets('renders loading state', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AppStateView<String>(
          state: const AppAsyncState<String>.loading(),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('加载中'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders data with builder', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AppStateView<String>(
          state: const AppAsyncState<String>.data('校历数据'),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('校历数据'), findsOneWidget);
  });

  testWidgets('renders empty state', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AppStateView<String>(
          state: const AppAsyncState<String>.empty(),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('暂无数据'), findsOneWidget);
  });

  testWidgets('renders error state without raw exception text', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AppStateView<String>(
          state: AppAsyncState<String>.error(
            error: Exception('raw backend token'),
          ),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('加载失败'), findsOneWidget);
    expect(find.textContaining('raw backend token'), findsNothing);
  });

  testWidgets('renders login required state and action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _TestApp(
        child: AppStateView<String>(
          state: AppAsyncState<String>.loginRequired(
            actions: [
              AppStateAction.login(() {
                tapped = true;
              }),
            ],
          ),
          builder: _textBuilder,
        ),
      ),
    );

    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('需要登录'), findsOneWidget);
    expect(tapped, isTrue);
  });

  testWidgets('renders offline state with cached data', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AppStateView<String>(
          state: const AppAsyncState<String>.offline(
            cachedData: '缓存校历',
          ),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('离线模式'), findsOneWidget);
    expect(find.text('缓存校历'), findsOneWidget);
  });

  testWidgets('renders unavailable state', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AppStateView<String>(
          state: const AppAsyncState<String>.unavailable(),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('暂不可用'), findsOneWidget);
  });

  testWidgets('renders section state in Material mode', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        platform: TargetPlatform.android,
        child: AppStateView<String>(
          mode: AppStateViewMode.section,
          state: const AppAsyncState<String>.empty(),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('暂无数据'), findsOneWidget);
  });

  testWidgets('renders section state in Liquid Glass-like mode', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        platform: TargetPlatform.iOS,
        child: AppStateView<String>(
          mode: AppStateViewMode.section,
          state: const AppAsyncState<String>.empty(),
          builder: _textBuilder,
        ),
      ),
    );

    expect(find.text('暂无数据'), findsOneWidget);
  });

  testWidgets('AppPage.state hosts full page states', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AppPage.state(
          state: AppStateView<String>(
            state: const AppAsyncState<String>.loading(),
            builder: _textBuilder,
          ),
        ),
      ),
    );

    expect(find.text('加载中'), findsOneWidget);
  });
}

Widget _textBuilder(BuildContext context, String data) {
  return Text(data);
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.platform = TargetPlatform.android,
  });

  final Widget child;
  final TargetPlatform platform;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        platform: platform,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }
}

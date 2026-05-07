import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/app.dart';
import 'package:xjtu_toolbox_flutter/src/core/app_environment.dart';

void main() {
  testWidgets('demo shell renders primary tabs', (tester) async {
    await tester.pumpWidget(
      const XjtuToolboxApp(environment: AppEnvironment.migration),
    );

    expect(find.text('XJTU Toolbox'), findsOneWidget);
    expect(find.text('今日课表'), findsOneWidget);

    await tester.tap(find.text('服务'));
    await tester.pumpAndSettle();

    expect(find.text('早期迁移候选'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('未登录'), findsOneWidget);
    expect(find.text('迁移环境'), findsOneWidget);
  });
}

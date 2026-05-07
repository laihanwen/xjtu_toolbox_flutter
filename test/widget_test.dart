import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/app.dart';
import 'package:xjtu_toolbox_flutter/src/core/app_environment.dart';

void main() {
  testWidgets('migration dashboard renders', (tester) async {
    await tester.pumpWidget(
      const XjtuToolboxApp(environment: AppEnvironment.migration),
    );

    expect(find.text('XJTU Toolbox'), findsOneWidget);
    expect(find.text('Migration Workspace'), findsOneWidget);
    expect(find.textContaining('Environment: migration'), findsOneWidget);
  });
}

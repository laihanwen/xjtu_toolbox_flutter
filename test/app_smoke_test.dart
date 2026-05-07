import 'package:flutter_test/flutter_test.dart';
import 'package:xjtu_toolbox_flutter/src/core/app_environment.dart';
import 'package:xjtu_toolbox_flutter/src/core/session/login_session.dart';

void main() {
  test('default session is signed out', () {
    const session = LoginSession.signedOut();

    expect(session.state, LoginSessionState.signedOut);
    expect(session.isSignedIn, isFalse);
  });

  test('migration environment exists', () {
    expect(AppEnvironment.migration.name, 'migration');
  });
}

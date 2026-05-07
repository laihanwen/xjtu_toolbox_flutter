import '../migration_area.dart';

enum LoginSessionState {
  signedOut,
  restoring,
  requiresCaptcha,
  requiresMfa,
  signedIn,
  expired,
}

class LoginSession {
  const LoginSession({
    required this.state,
    required this.username,
    required this.availableAreas,
  });

  const LoginSession.signedOut()
      : state = LoginSessionState.signedOut,
        username = '',
        availableAreas = const <MigrationArea>{};

  final LoginSessionState state;
  final String username;
  final Set<MigrationArea> availableAreas;

  bool get isSignedIn => state == LoginSessionState.signedIn;

  LoginSession copyWith({
    LoginSessionState? state,
    String? username,
    Set<MigrationArea>? availableAreas,
  }) {
    return LoginSession(
      state: state ?? this.state,
      username: username ?? this.username,
      availableAreas: availableAreas ?? this.availableAreas,
    );
  }
}

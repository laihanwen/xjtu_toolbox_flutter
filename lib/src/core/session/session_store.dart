import 'login_session.dart';

abstract interface class SessionStore {
  Future<LoginSession> restore();

  Future<void> persist(LoginSession session);

  Future<void> clear();
}

final class MemorySessionStore implements SessionStore {
  LoginSession _session = const LoginSession.signedOut();

  @override
  Future<LoginSession> restore() async => _session;

  @override
  Future<void> persist(LoginSession session) async {
    _session = session;
  }

  @override
  Future<void> clear() async {
    _session = const LoginSession.signedOut();
  }
}

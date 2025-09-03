import 'dart:async';

/// Singleton class to notify about authentication state changes
class AuthStateNotifier {
  static final AuthStateNotifier _instance = AuthStateNotifier._internal();
  factory AuthStateNotifier() => _instance;
  AuthStateNotifier._internal();

  final StreamController<AuthEvent> _controller = StreamController<AuthEvent>.broadcast();
  
  Stream<AuthEvent> get authEvents => _controller.stream;
  
  void notifyTokenExpired() {
    _controller.add(AuthEvent.tokenExpired);
  }
  
  void notifyLogout() {
    _controller.add(AuthEvent.logout);
  }
  
  void dispose() {
    _controller.close();
  }
}

enum AuthEvent {
  tokenExpired,
  logout,
}

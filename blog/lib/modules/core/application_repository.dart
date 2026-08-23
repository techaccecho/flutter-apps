import 'dart:async';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/shared/services/authentication_service.dart';
import 'package:blog/shared/models/user.dart';

class ApplicationRepository {
  final _controller = StreamController<ApplicationEvent>.broadcast();
  final AuthenticationService authenticationService;
  User? _currentUser;

  ApplicationRepository({
    required this.authenticationService,
  });

  Stream<ApplicationEvent> get data async* {
    yield const ApplicationStartupEvent();
    yield* _controller.stream;
  }

  Future<void> initialiseAuth() async {
    final userResponse = await authenticationService.init();
    if (userResponse != null) {
      _currentUser = userResponse;
    } else {
      final authUserId = await authenticationService.getAuthUserId();
      if (authUserId != null && authUserId.isNotEmpty) {
        _currentUser = User(
          id: authUserId,
          authId: authUserId,
          email: '',
          role: 'User',
          isLocked: false,
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
        );
      } else {
        _currentUser = null;
      }
    }
  }

  Future<bool> isLoggedIn() async {
    return await authenticationService.isLoggedIn();
  }

  Future<void> login() async {
    await authenticationService.login();
  }

  Future<void> logout() async {
    await authenticationService.logout();
    _currentUser = null;
  }

  User? get currentUser => _currentUser;

  void updateCurrentUser(User user) {
    _currentUser = user;
  }

  void dispose() {
    _controller.close();
  }
}

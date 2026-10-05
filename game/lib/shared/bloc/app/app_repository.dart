import 'dart:async';
import 'package:game/shared/bloc/app/app_event.dart';
import 'package:game/shared/util/auth/auth_service.dart';
import 'package:game/shared/util/user/user.dart';

class AppRepository {
  final _controller = StreamController<AppEvent>.broadcast();
  final AuthService authenticationService;
  User? _currentUser;

  AppRepository({
    required this.authenticationService,
  });

  Stream<AppEvent> get data async* {
    yield const AppStartupEvent();
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

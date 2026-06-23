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
    _currentUser = userResponse;
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

  void dispose() {
    _controller.close();
  }
}

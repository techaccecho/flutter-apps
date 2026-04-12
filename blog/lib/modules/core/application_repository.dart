import 'dart:async';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/shared/services/authentication_service.dart';

class ApplicationRepository {
  final _controller = StreamController<ApplicationEvent>();
  final AuthenticationService authenticationService;

  ApplicationRepository({required this.authenticationService});

  Stream<ApplicationEvent> get data async* {
    yield const ApplicationStartupEvent();
    yield* _controller.stream;
  }

  Future<void> initialiseAuth() async {
    await authenticationService.init();
  }

  Future<bool> isLoggedIn() async {
    return await authenticationService.isLoggedIn();
  }

  Future<void> login() async {
    await authenticationService.login();
  }

  Future<void> logout() async {
    await authenticationService.logout();
  }
  
  void dispose() => _controller.close();
}

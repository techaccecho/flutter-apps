import 'dart:async';
import 'package:blog/modules/core/application_event.dart';

class ApplicationRepository {
  final _controller = StreamController<ApplicationEvent>();

  ApplicationRepository();

  Stream<ApplicationEvent> get data async* {
    yield const ApplicationStartupEvent();
    yield* _controller.stream;
  }
  
  void dispose() => _controller.close();
}

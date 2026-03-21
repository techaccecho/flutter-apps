import 'dart:async';
import 'package:blog/modules/core/application_event.dart';

class ApplicationRepository {
  final _controller = StreamController<ApplicationEvent>();

  ApplicationRepository();

  Stream<ApplicationEvent> get data async* {
    yield const ApplicationStartupEvent();
    yield* _controller.stream;
  }

  Future<bool> initialiseServices() {
    Future.delayed(const Duration(seconds: 1));
    return Future.value(true);
  }

  Future<dynamic> fetchContent() {
    return Future.delayed(const Duration(seconds: 1), () {
      return {
        'title': 'Example title',
        'description': 'This is an example description, you can replace this with your own content'
      };
    });
  }

  void dispose() => _controller.close();
}

import 'dart:async';
import 'package:flutter_template/bloc/base/base_bloc.dart';
import 'package:flutter_template/bloc/base/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application.dart';

class ApplicationBloc extends AbstractBloc<ApplicationEvent, ApplicationState> {
  final ApplicationRepository _repository;
  late StreamSubscription<ApplicationEvent> _subscription;

  ApplicationBloc({
    required ApplicationRepository repository
  })  : _repository = repository,
        super(const ApplicationInitialState()) {
    on<ApplicationStartupEvent>(_onApplicationStartup);
    on<ApplicationRefreshEvent>(_onApplicationRefresh);

    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _onApplicationStartup(
      ApplicationStartupEvent event, Emitter<ApplicationState> emit) async {
    emit.logCall(ApplicationLoadingState());
    await _repository.initialiseServices();
    await _fetchContent(emit, false);
  }

  Future<void> _onApplicationRefresh(
      ApplicationRefreshEvent event, Emitter<ApplicationState> emit) async {
    emit.logCall(ApplicationLoadingState());
    await _fetchContent(emit, event.forceError);
  }

  Future<void> _fetchContent(Emitter<ApplicationState> emit, bool forceError) async {
    dynamic content = await _repository.fetchContent();
    if (content != null && !forceError) {
      emit.logCall(ApplicationContentLoadedState(title: content['title'], description: content['description']));
    } else {
      emit.logCall(ApplicationContentFailedState(title: "Example error state", description: "This is an example of an error state, you can replace this with your own error handling"));
    }
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    _repository.dispose();
    super.close();
  }
}

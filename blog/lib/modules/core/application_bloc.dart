import 'dart:async';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
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
    on<ApplicationNavigateEvent>(_onApplicationNavigate);
    
    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _onApplicationStartup(
      ApplicationStartupEvent event, Emitter<ApplicationState> emit) async {
      emit.logCall(ApplicationContentLoadedState(route: HomeViewState.blog));
  }

  Future<void> _onApplicationRefresh(
      ApplicationRefreshEvent event, Emitter<ApplicationState> emit) async {
  }

  Future<void> _onApplicationNavigate(
      ApplicationNavigateEvent event, Emitter<ApplicationState> emit) async {
      emit.logCall(ApplicationContentLoadedState(route: event.route));
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    _repository.dispose();
    super.close();
  }
}

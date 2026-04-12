import 'dart:async';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application.dart';

class ApplicationBloc extends AbstractBloc<ApplicationEvent, ApplicationState> {
  final ApplicationRepository _repository;
  late StreamSubscription<ApplicationEvent> _subscription;

  HomeViewState currentRoute = HomeViewState.blog;

  ApplicationBloc({
    required ApplicationRepository repository
  })  : _repository = repository,
        super(const ApplicationInitialState()) {
    on<ApplicationStartupEvent>(_onApplicationStartup);
    on<ApplicationRefreshEvent>(_onApplicationRefresh);
    on<ApplicationNavigateEvent>(_onApplicationNavigate);
    on<ApplicationLoginEvent>(_onApplicationLoginEvent);
    on<ApplicationLogoutEvent>(_onApplicationLogoutEvent);
    
    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _onApplicationStartup(
      ApplicationStartupEvent event, Emitter<ApplicationState> emit) async {
      await _repository.initialiseAuth();
      bool isLoggedIn = await _repository.isLoggedIn();
      emit.logCall(ApplicationContentLoadedState(route: HomeViewState.blog, isLoggedIn: isLoggedIn, timestamp: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> _onApplicationRefresh(
      ApplicationRefreshEvent event, Emitter<ApplicationState> emit) async {
  }

  Future<void> _onApplicationNavigate(
      ApplicationNavigateEvent event, Emitter<ApplicationState> emit) async {
      bool isLoggedIn = await _repository.isLoggedIn();
      currentRoute = event.route;
      emit.logCall(ApplicationContentLoadedState(route: currentRoute, isLoggedIn: isLoggedIn, timestamp: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> _onApplicationLoginEvent(
      ApplicationLoginEvent event, Emitter<ApplicationState> emit) async {
      await _repository.login();
      emit.logCall(ApplicationContentLoadedState(route: currentRoute, isLoggedIn: await _repository.isLoggedIn(), timestamp: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> _onApplicationLogoutEvent(
      ApplicationLogoutEvent event, Emitter<ApplicationState> emit) async {
      await _repository.logout();
      emit.logCall(ApplicationContentLoadedState(route: currentRoute, isLoggedIn: await _repository.isLoggedIn(), timestamp: DateTime.now().millisecondsSinceEpoch));
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    _repository.dispose();
    super.close();
  }
}

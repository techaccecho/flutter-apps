import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game/shared/util/route.dart';
import 'package:game/shared/bloc/base_bloc.dart';
import 'package:game/shared/bloc/base_emitter.dart';

import 'package:game/shared/bloc/app/app_event.dart';
import 'package:game/shared/bloc/app/app_repository.dart';
import 'package:game/shared/bloc/app/app_state.dart';

class AppBloc extends BaseBloc<AppEvent, AppState> {
  final AppRepository _repository;
  late StreamSubscription<AppEvent> _subscription;

  Route currentRoute = Route.home;


  AppBloc({
    required AppRepository repository
  })  : _repository = repository,
        super(const AppInitialState()) {
    on<AppStartupEvent>(_onApplicationStartup);
    on<AppRefreshEvent>(_onApplicationRefresh);
    on<AppNavigateEvent>(_onApplicationNavigate);
    on<AppLoginEvent>(_onApplicationLoginEvent);
    on<AppLogoutEvent>(_onApplicationLogoutEvent);
    on<AppUpdateUserEvent>(_onApplicationUpdateUser);
    
    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _onApplicationStartup(
      AppStartupEvent event, Emitter<AppState> emit) async {
      await _repository.initialiseAuth();
      bool isLoggedIn = await _repository.isLoggedIn();
      final currentUser = _repository.currentUser;
      emit.logCall(AppContentLoadedState(route: Route.home, isLoggedIn: isLoggedIn, timestamp: DateTime.now().millisecondsSinceEpoch, currentUser: currentUser));
  }

  Future<void> _onApplicationRefresh(
      AppRefreshEvent event, Emitter<AppState> emit) async {
  }

  Future<void> _onApplicationNavigate(
      AppNavigateEvent event, Emitter<AppState> emit) async {
      bool isLoggedIn = await _repository.isLoggedIn();
      final currentUser = _repository.currentUser;
      currentRoute = event.route;
      final viewUserId = event.userId ?? (event.route == Route.home ? currentUser?.id : null);
      emit.logCall(AppContentLoadedState(
        route: currentRoute,
        isLoggedIn: isLoggedIn,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        currentUser: currentUser,
        viewUserId: viewUserId,
      ));
  }

  Future<void> _onApplicationLoginEvent(
      AppLoginEvent event, Emitter<AppState> emit) async {
      await _repository.login();
      final currentUser = _repository.currentUser;
      emit.logCall(AppContentLoadedState(route: currentRoute, isLoggedIn: await _repository.isLoggedIn(), timestamp: DateTime.now().millisecondsSinceEpoch, currentUser: currentUser));
  }

  Future<void> _onApplicationLogoutEvent(
      AppLogoutEvent event, Emitter<AppState> emit) async {
      await _repository.logout();
      currentRoute = Route.home;
      final currentUser = _repository.currentUser;
      emit.logCall(AppContentLoadedState(route: currentRoute, isLoggedIn: await _repository.isLoggedIn(), timestamp: DateTime.now().millisecondsSinceEpoch, currentUser: currentUser));
  }

  Future<void> _onApplicationUpdateUser(
      AppUpdateUserEvent event, Emitter<AppState> emit) async {
    _repository.updateCurrentUser(event.user);

    String? viewUserId;
    final currentState = state;
    if (currentState is AppContentLoadedState) {
      viewUserId = currentState.viewUserId;
    }

    emit.logCall(AppContentLoadedState(
      route: currentRoute,
      isLoggedIn: await _repository.isLoggedIn(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      currentUser: event.user,
      viewUserId: viewUserId,
    ));
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    _repository.dispose();
    super.close();
  }
}

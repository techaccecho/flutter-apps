import 'package:game/shared/util/route.dart';
import 'package:game/shared/bloc/base_state.dart';
import 'package:game/shared/util/user/user.dart';

class AppState extends BaseState {
  const AppState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class AppInitialState extends AppState {
  const AppInitialState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class AppCoreLoadedState extends AppState {
  const AppCoreLoadedState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class AppContentLoadedState extends AppState {

  final Route route;
  final bool isLoggedIn;
  final User? currentUser;
  final String? viewUserId;
  final int timestamp;

  const AppContentLoadedState({
    required this.route,
    required this.isLoggedIn,
    required this.timestamp,
    required this.currentUser,
    this.viewUserId,
  });

  @override
  List<Object?> get props => [route, isLoggedIn, timestamp, viewUserId];

  @override
  Map<String, dynamic> get properties => {
    'route': route,
    'isLoggedIn': isLoggedIn,
    'timestamp': timestamp,
    'viewUserId': viewUserId,
  };
}

class AppUnauthorisedState extends AppState {
  const AppUnauthorisedState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationLoadingState extends AppState {
  const ApplicationLoadingState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class AppAuthorisedState extends AppState {
  const AppAuthorisedState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_state.dart';
import 'package:blog/shared/models/user.dart';

class ApplicationState extends BaseState {
  const ApplicationState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationInitialState extends ApplicationState {
  const ApplicationInitialState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationCoreLoadedState extends ApplicationState {
  const ApplicationCoreLoadedState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationContentLoadedState extends ApplicationState {

  final HomeViewState route;
  final bool isLoggedIn;
  final User? currentUser;
  final int timestamp;

  const ApplicationContentLoadedState({
    required this.route,
    required this.isLoggedIn,
    required this.timestamp,
    required this.currentUser
  });

  @override
  List<Object?> get props => [route, isLoggedIn, timestamp];

  @override
  Map<String, dynamic> get properties => {
    'route': route,
    'isLoggedIn': isLoggedIn,
    'timestamp': timestamp
  };
}

class ApplicationUnauthorisedState extends ApplicationState {
  const ApplicationUnauthorisedState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationLoadingState extends ApplicationState {
  const ApplicationLoadingState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationAuthorisedState extends ApplicationState {
  const ApplicationAuthorisedState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

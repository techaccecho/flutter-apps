import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_state.dart';

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

  const ApplicationContentLoadedState({
    required this.route,
  });

  @override
  List<Object?> get props => [route];

  @override
  Map<String, dynamic> get properties => {
    'route': route
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

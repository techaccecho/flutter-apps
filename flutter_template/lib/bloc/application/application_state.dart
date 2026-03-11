import 'package:flutter_template/bloc/base/base_state.dart';

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

  final String title;
  final String description;

  const ApplicationContentLoadedState({
    required this.title,
    required this.description
  });

  @override
  List<Object?> get props => [title, description];

  @override
  Map<String, dynamic> get properties => {
    'title': title,
    'description': description
  };
}

class ApplicationContentFailedState extends ApplicationState {

  final String title;
  final String description;

  const ApplicationContentFailedState({
    required this.title,
    required this.description
  });

  @override
  List<Object?> get props => [title, description];

  @override
  Map<String, dynamic> get properties => {
    'title': title,
    'description': description
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

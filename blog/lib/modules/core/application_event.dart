import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_event.dart';

abstract class ApplicationEvent extends BaseEvent {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties;
}

class ApplicationStartupEvent extends ApplicationEvent {
  const ApplicationStartupEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationRefreshEvent extends ApplicationEvent {

  final bool forceError;
  const ApplicationRefreshEvent({this.forceError = false});

  @override
  List<Object?> get props => [forceError];

  @override
  Map<String, dynamic> get properties => {'forceError': forceError};
}

class ApplicationNavigateEvent extends ApplicationEvent {

  final HomeViewState route;
  const ApplicationNavigateEvent({required this.route});

  @override
  List<Object?> get props => [route];

  @override
  Map<String, dynamic> get properties => {"route": route};
}

class ApplicationLoginEvent extends ApplicationEvent {

  const ApplicationLoginEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ApplicationLogoutEvent extends ApplicationEvent {

  const ApplicationLogoutEvent();

  @override
  List<Object?> get props => [];
  
  @override
  Map<String, dynamic> get properties => {};
}

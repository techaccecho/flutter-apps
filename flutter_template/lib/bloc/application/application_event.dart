import 'package:flutter_template/bloc/base/base_event.dart';

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
import 'package:game/shared/util/route.dart';
import 'package:game/shared/bloc/base_event.dart';
import 'package:game/shared/util/user/user.dart';

abstract class AppEvent extends BaseEvent {
  const AppEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties;
}

class AppStartupEvent extends AppEvent {
  const AppStartupEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class AppRefreshEvent extends AppEvent {

  final bool forceError;
  const AppRefreshEvent({this.forceError = false});

  @override
  List<Object?> get props => [forceError];

  @override
  Map<String, dynamic> get properties => {'forceError': forceError};
}

class AppNavigateEvent extends AppEvent {

  final Route route;
  final String? userId;
  const AppNavigateEvent({required this.route, this.userId});

  @override
  List<Object?> get props => [route, userId];

  @override
  Map<String, dynamic> get properties => {
    "route": route,
    "userId": userId,
  };
}

class AppLoginEvent extends AppEvent {

  const AppLoginEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class AppLogoutEvent extends AppEvent {

  const AppLogoutEvent();

  @override
  List<Object?> get props => [];
  
  @override
  Map<String, dynamic> get properties => {};
}

class AppUpdateUserEvent extends AppEvent {
  final User user;

  const AppUpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];

  @override
  Map<String, dynamic> get properties => {
        "user": user,
      };
}

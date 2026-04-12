import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:flutter/material.dart';

class Auth0Service extends ChangeNotifier {
  static final Auth0Service _instance = Auth0Service._internal();
  late final Auth0Web auth0Web;

  factory Auth0Service() {
    return _instance;
  }

  Auth0Service._internal() {
    auth0Web = Auth0Web(
      AppConfig.domain,
      AppConfig.clientId,
      cacheLocation: CacheLocation.localStorage,
    );
  }
}
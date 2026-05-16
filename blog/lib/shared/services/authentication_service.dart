import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:blog/shared/services/auth0_service.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:flutter/material.dart';

class AuthenticationService extends ChangeNotifier {

  final Auth0Service auth0Service = Auth0Service();

  Future<Credentials?> init() async {
    return await auth0Service.auth0Web.onLoad();
  }

  Future<void> login() async {
    await auth0Service.auth0Web.loginWithRedirect(
      redirectUrl: AppConfig.redirectUrl,
    );
  }

  Future<void> logout() async {
    await auth0Service.auth0Web.logout(
      returnToUrl: AppConfig.redirectUrl,
    );
  }

  Future<bool> isLoggedIn() async {
    return await auth0Service.auth0Web.hasValidCredentials();
  }

  Future<String> getAccessToken() async {
    return (await auth0Service.auth0Web.credentials()).accessToken;
  }
}
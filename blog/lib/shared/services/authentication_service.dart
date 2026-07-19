import 'dart:async';

import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:blog/shared/services/auth0_service.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:flutter/material.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:blog/shared/models/user.dart';

class AuthenticationService extends ChangeNotifier {
  final Auth0Service auth0Service;
  final AuthRepository authRepository;

  AuthenticationService({
    required this.authRepository,
    Auth0Service? auth0Service,
  }) : auth0Service = auth0Service ?? Auth0Service();

  Future<User?> init() async {
    try {
      final Credentials? credentials = await auth0Service.auth0Web.onLoad(
        audience: AppConfig.audience,
        cacheLocation: CacheLocation.localStorage,
      );

      if (credentials != null) {
        return await authRepository.authenticate();
      }

      return null;
    } catch (e) {
      debugPrint(
        "Auth0 initialization status: No active session or user logged out ($e).",
      );
      return null;
    }
  }

  Future<void> login() async {
    try {
      await auth0Service.auth0Web.loginWithRedirect(
        redirectUrl: AppConfig.redirectUrl,
        audience: AppConfig.audience,
      );
    } catch (e) {
      debugPrint("Error initiating login redirect: $e");
    }
  }

  Future<void> logout() async {
    try {
      await auth0Service.auth0Web.logout(returnToUrl: AppConfig.redirectUrl);
    } catch (e) {
      debugPrint("Error initiating logout: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await auth0Service.auth0Web.hasValidCredentials();
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return (await auth0Service.auth0Web.credentials(
        audience: AppConfig.audience,
      )).accessToken;
    } catch (e) {
      debugPrint("Error fetching access token: $e");
      return null;
    }
  }
}

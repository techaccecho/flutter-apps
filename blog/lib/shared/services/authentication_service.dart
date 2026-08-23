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
  String? _authSub;

  String? get authSub => _authSub;

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
        try {
          _authSub = credentials.user.sub;
        } catch (_) {}
        notifyListeners();
        try {
          final user = await authRepository.authenticate();
          return user;
        } catch (authError) {
          debugPrint(
            "Failed to fetch backend user profile for auth0 user ($authError). Falling back to Auth0 credentials.",
          );
          return User(
            id: credentials.user.sub,
            authId: credentials.user.sub,
            email: credentials.user.email ?? '',
            alias: credentials.user.nickname ?? credentials.user.name,
            firstName: credentials.user.givenName,
            lastName: credentials.user.familyName,
            role: 'User',
            isLocked: false,
            createdAt: DateTime.now(),
            lastActivityAt: DateTime.now(),
          );
        }
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
      _authSub = null;
      notifyListeners();
      await auth0Service.auth0Web.logout(returnToUrl: AppConfig.redirectUrl);
    } catch (e) {
      debugPrint("Error initiating logout: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final hasCreds = await auth0Service.auth0Web.hasValidCredentials();
      if (hasCreds && (_authSub == null || _authSub!.isEmpty)) {
        try {
          final creds = await auth0Service.auth0Web.credentials(
            audience: AppConfig.audience,
          );
          final sub = creds.user.sub;
          if (sub.isNotEmpty) {
            _authSub = sub;
          }
        } catch (_) {}
      }
      return hasCreds;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final creds = await auth0Service.auth0Web.credentials(
        audience: AppConfig.audience,
      );
      try {
        final sub = creds.user.sub;
        if (sub.isNotEmpty) {
          _authSub = sub;
        }
      } catch (_) {}
      return creds.accessToken;
    } catch (e) {
      debugPrint("Error fetching access token: $e");
      return null;
    }
  }

  Future<String?> getAuthUserId() async {
    if (_authSub != null && _authSub!.isNotEmpty) {
      return _authSub;
    }
    try {
      final creds = await auth0Service.auth0Web.credentials(
        audience: AppConfig.audience,
      );
      try {
        final sub = creds.user.sub;
        if (sub.isNotEmpty) {
          _authSub = sub;
        }
      } catch (_) {}
      return _authSub;
    } catch (_) {
      return null;
    }
  }
}

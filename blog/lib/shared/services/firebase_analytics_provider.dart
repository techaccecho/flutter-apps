import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

class FirebaseAnalyticsService extends ChangeNotifier {
  late final FirebaseAnalytics _analytics;

  FirebaseAnalyticsService() {
    log('Setup firebase analytics', name: 'FirebaseAnalyticsService.init');
    _analytics = FirebaseAnalytics.instance;
  }

  Future<void> sendEvent(String eventName, dynamic parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  Future<void> logPageViewEvent(String screenName) async {
    await _analytics.logScreenView(screenClass: AnalyticsEvent.pageView.name, screenName: screenName);
  }

  Future<void> logSignUp() async {
    await _analytics.logSignUp(signUpMethod: "UsernameAndPassword");
  }

}

enum AnalyticsEvent {
  pageView,
}

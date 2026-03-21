import 'package:flutter/material.dart';

class RepositoryCache extends ChangeNotifier {
  List<String> _cachedState = [];

  setCachedState(List<String> cachedState) {
    _cachedState = cachedState;
    notifyListeners();
  }

}

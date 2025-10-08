import 'package:flutter/material.dart';

class SessionProvider extends ChangeNotifier {
  String? _session;

  String? get session => _session;

  void setSession(String sessionId) {
    _session = sessionId;
    notifyListeners();
  }

  void deleteSession() {
    _session = null;
    notifyListeners();
  }
}

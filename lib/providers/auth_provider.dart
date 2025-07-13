import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _email;

  String? get email => _email;
  bool get isLoggedIn => _email != null;

  void login(String email) {
    _email = email;
    notifyListeners();
  }

  void logout() {
    _email = null;
    notifyListeners();
  }
}

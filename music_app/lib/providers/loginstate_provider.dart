import 'package:flutter/material.dart';

import '../models/user_model.dart';

class LoginStateProvider extends ChangeNotifier {
  final UserModel _user = UserModel();
  static const String tempUsername = 'user';
  static const String tempPassword = 'password';

  UserModel get user => _user;

  void login(String username, String password) {
    if (username == tempUsername && password == tempPassword) {
      _user.isLoggedIn = true;
      _user.errorMessage = '';
    } else {
      _user.isLoggedIn = false;
      _user.errorMessage = 'Incorrect Username / Password';
    }
    notifyListeners();
  }
}
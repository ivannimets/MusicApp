import 'package:flutter/material.dart';

import '../models/user_model.dart';

class LoginStateProvider extends ChangeNotifier {
  //Creates the instance of the usermodel for this login state
  final UserModel _user = UserModel();
  //Creates a constant username
  static const String tempUsername = 'user';
  //Creates a constant password
  static const String tempPassword = 'password';

  //Encapsulates user to ensure only a getter is present (no setter)
  UserModel get user => _user;

  //Validates the username and password, notifies the provider's listeners to update it
  void login(String username, String password) {
    if (username == tempUsername && password == tempPassword) {
      //Logs user in if password and username are correct
      _user.isLoggedIn = true;
      _user.errorMessage = '';
    } else {
      //Does not log user in, sets the error message instead
      _user.isLoggedIn = false;
      _user.errorMessage = 'Incorrect Username / Password';
    }
    notifyListeners();
  }
}
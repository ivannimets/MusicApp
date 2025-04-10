class UserModel {
  String username;
  String password;
  bool isLoggedIn;
  String errorMessage;

  UserModel({
    this.username = '',
    this.password = '',
    this.isLoggedIn = false,
    this.errorMessage = '',
  });
}
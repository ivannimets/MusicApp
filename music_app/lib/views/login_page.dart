import 'package:flutter/material.dart';
import 'package:music_app/core/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/loginstate_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStateProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 100,
                    color: AppColors.textPrimary,
                  ),
                  Text(
                    "Music App",
                    style: TextStyle(fontSize: 40),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Log in to continue.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "Username",
                  hintStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) => loginState.user.username = value,
              ),
              SizedBox(height: 30),
              Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) => loginState.user.password = value,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    loginState.login(
                      usernameController.text,
                      passwordController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 100.0),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("Login"),
                ),
              ),
              SizedBox(height: 20),
              Center(
                  child: GestureDetector(
                onTap: () {},
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primary,
                    decorationColor: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )),
              Consumer<LoginStateProvider>(
                builder: (context, loginState, child) {
                  if (loginState.user.errorMessage.isEmpty &&
                      loginState.user.isLoggedIn) {
                    Future.microtask(() {
                      Navigator.pushNamed(context, '/playingPage');
                    });
                    return Container();
                  }
                  return loginState.user.errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            loginState.user.errorMessage,
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 20),
                          ),
                        )
                      : Container();
                },
              ),
            ),
            SizedBox(height: 20),
            Consumer<LoginStateProvider>(
              builder: (context, loginState, child) {
                if (loginState.user.errorMessage.isEmpty &&
                    loginState.user.isLoggedIn) {
                  Future.microtask(() {
                    Navigator.pushNamed(context, '/homePage');
                  });
                  return Container();
                }
                return loginState.user.errorMessage.isNotEmpty
                    ? Text(
                      loginState.user.errorMessage,
                      style: TextStyle(color: Colors.red),
                    )
                    : Container();
              },
            ),
          ],
            ],
          ),
        ),
      ),
    );
  }
}

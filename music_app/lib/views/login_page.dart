import 'package:flutter/material.dart';
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
      appBar: AppBar(title: Text("Login")),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter User Name:"),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: "Enter User Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) => loginState.user.username = value,
            ),
            SizedBox(height: 20),
            Text("Enter Password:"),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),
              ),
              onChanged: (value) => loginState.user.password = value,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  loginState.login(
                    usernameController.text,
                    passwordController.text,
                  );
                },
                child: Text("Login"),
              ),
            ),
            SizedBox(height: 20),
            Consumer<LoginStateProvider>(
              builder: (context, loginState, child) {
                if (loginState.user.errorMessage.isEmpty &&
                    loginState.user.isLoggedIn) {
                  Future.microtask(() {
                    Navigator.pushNamed(context, '/playlistsPage');
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
        ),
      ),
    );
  }
}

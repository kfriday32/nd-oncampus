import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'navigation.dart';

class LoginPage extends StatelessWidget {
  final AppNavigator appNavigator = AppNavigator();
  final AuthService authService = AuthService();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  LoginPage({super.key});

  Future<void> _login(BuildContext context) async {
    try {
      final String token = await authService.loginUser(
          studentIdController.text, passwordController.text);

      // Save the token to shared preferences or secure storage

      appNavigator.navigateToHomePage();
    } catch (e) {
      // Handle login error
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid ID or password.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: studentIdController,
              decoration: const InputDecoration(labelText: 'Student Id'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Sign Up'),
                ),
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

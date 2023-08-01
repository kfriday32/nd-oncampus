import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'navigation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'pages.dart';

class LoginPage extends StatelessWidget {
  final AppNavigator appNavigator = AppNavigator();
  final AuthService authService = AuthService();
  final FlutterSecureStorage _Storage = FlutterSecureStorage();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  LoginPage({super.key});

  Future<void> _login(BuildContext context) async {
    try {
      final String token = await authService.loginUser(
          studentIdController.text, passwordController.text);

      // Save the token to shared preferences or secure storage

      //appNavigator.navigateToHomePage();
      // Navigate to the home page after successful login
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Pages(navigator: AppNavigator()),
        ),
      );
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('OnCampus Login'),
        backgroundColor: const Color(0xFF0C2340),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: const Text('Login'),
                ),
                const SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

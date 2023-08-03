import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'navigation.dart';
import 'pages.dart';

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
        title: const Text('Login'),
        backgroundColor: const Color(0xFF0C2340),
        automaticallyImplyLeading: false, // get rid of back arrow
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFF0C2340), // Set the button color here
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    'Click to Sign Up',
                    style: TextStyle(
                      color: Color(0xFF0C2340),
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

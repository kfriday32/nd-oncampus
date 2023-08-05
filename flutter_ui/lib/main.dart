import 'package:flutter/material.dart';
import 'package:flutter_ui/src/login_page.dart';
import 'package:flutter_ui/src/signup_page.dart';
import 'package:flutter_ui/src/navigation.dart';
import 'services/auth_service.dart';
import 'src/app.dart';
import 'src/pages.dart';

void main() {
  runApp(OnCampus());
}

class OnCampus extends StatelessWidget {
  final AuthService _authService = AuthService();
  final AppNavigator appNavigator = AppNavigator();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnCampus',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Check user authentication when the app starts
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute<bool>(
            builder: (context) => FutureBuilder<bool>(
              future: _authService.isAuthenticated(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading screen if authentication status is being checked
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  if (snapshot.data == true) {
                    // If user is authenticated, navigate to home page
                    return Pages(navigator: AppNavigator());
                  } else {
                    // If user is not authenticated, navigate to login page
                    return LoginPage();
                  }
                }
              },
            ),
          );
        }
        // Handle other routes if needed
        return null;
      },
      // Define routes for login, signup, and home pages
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => Pages(navigator: AppNavigator()),
      },
    );
  }
}

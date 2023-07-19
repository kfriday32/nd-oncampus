import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'navigation.dart';

class SignUpPage extends StatelessWidget {
  final AppNavigator appNavigator = AppNavigator();

  final AuthService authService = AuthService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();
  final TextEditingController clubsController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignUpPage({super.key});

  Future<void> _signUp(BuildContext context) async {
    try {
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String studentId = studentIdController.text;
      String email = emailController.text;
      String major = majorController.text;
      String college = collegeController.text;
      String grade = gradeController.text;
      List<String> interests = interestsController.text.split(",");
      List<String> clubs = clubsController.text.split(",");
      List<String> followEvents = [];
      String password = passwordController.text;
      final String token = await authService.signUpUser(
          firstName,
          lastName,
          studentId,
          email,
          major,
          college,
          grade,
          interests,
          clubs,
          followEvents,
          password);

      // Save the token to shared preferences or secure storage

      appNavigator.navigateToHomePage();
    } catch (e) {
      // Handle sign up error
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: const Text('Try signing up again.'),
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
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextFormField(
              controller: studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: majorController,
              decoration: const InputDecoration(labelText: 'Major'),
            ),
            TextFormField(
              controller: collegeController,
              decoration: const InputDecoration(labelText: 'College'),
            ),
            TextFormField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: 'Grade'),
            ),
            TextFormField(
              controller: interestsController,
              decoration: InputDecoration(
                labelText: 'Interests',
                hintText: 'Separate with commas',
              ),
              maxLines: 3, // Adjust the number of visible lines as needed
            ),
            TextFormField(
              controller: clubsController,
              decoration: InputDecoration(
                labelText: 'Clubs',
                hintText: 'Separate with commas',
              ),
              maxLines: 3, // Adjust the number of visible lines as needed
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
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Log In'),
                ),
                ElevatedButton(
                  onPressed: () => _signUp(context),
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

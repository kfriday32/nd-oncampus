import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'navigation.dart';
import 'pages.dart';

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
      // Validate required fields
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          studentId.isEmpty ||
          email.isEmpty ||
          major.isEmpty ||
          college.isEmpty ||
          grade.isEmpty ||
          password.isEmpty) {
        throw Exception('Please fill in all required fields');
      }
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
      print('token created: $token');

      //Save the token to shared preferences or secure storage
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Pages(navigator: AppNavigator()),
        ),
      );
    } catch (e) {
      // Handle sign up error
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: const Text(
              'Fill in all required fields and try signing up again.'),
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
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFF0C2340),
        automaticallyImplyLeading: false, // get rid of back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name *'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'First name must not be blank!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name *'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Last name must not be blank!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID *'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Student ID must not be blank!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email must not be blank!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: majorController,
                decoration: const InputDecoration(labelText: 'Major *'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Major must not be blank!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: collegeController,
                decoration: const InputDecoration(labelText: 'College *'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'College must not be blank!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: gradeController,
                decoration: const InputDecoration(
                    labelText: 'Grade *', hintText: 'Ex. Junior'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Grade must not be blank!';
                  }
                  return null;
                },
              ),
              TextFormField(
                  controller: interestsController,
                  decoration: InputDecoration(
                    labelText: 'Interests',
                    hintText: 'Separate with commas',
                  )),
              TextFormField(
                  controller: clubsController,
                  decoration: InputDecoration(
                    labelText: 'Clubs',
                    hintText: 'Separate with commas',
                  )),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password *'),
                obscureText: true,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _signUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF0C2340), // Set the button color here
                    ),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Click to Login',
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
      ),
    );
  }
}

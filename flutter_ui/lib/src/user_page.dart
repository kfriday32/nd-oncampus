import 'package:flutter/material.dart';
import 'interests_page.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'helpers.dart';
import 'package:flutter_ui/services/auth_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _netIdController = TextEditingController();

  TextEditingController _majorController = TextEditingController();
  TextEditingController _collegeController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();
  List<String> _savedInterests = [];
  List<String> _suggestedInterests = [];

  bool _isUserLoading = false; //true;
  bool _shouldUpdate = false;

  @override
  void initState() {
    super.initState();
    _getUserFromDatabase();
  }

  // Instance of AuthService to handle logout
  final AuthService _authService = AuthService();

  // Method to handle logout
  Future<void> _handleLogout() async {
    try {
      await _authService.logoutUser(); // Call logoutUser to clear the token
      Navigator.pushReplacementNamed(
          context, '/login'); // Navigate to login page
    } catch (e) {
      // Handle any errors that may occur during logout process
      Exception('Logout Error: $e');
    }
  }

  Future<void> _handleDeleteAccount() async {
    try {
      // Get the token from the AuthService
      final token = await _authService.getUserAuthToken();
      String apiUrl = Helpers.getUri();

      final response = await http.post(
        Uri.parse('$apiUrl/deleteaccount'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        await _authService.logoutUser(); // Call logoutUser to clear the token
        Navigator.pushReplacementNamed(
            context, '/login'); // Navigate to login page
      } else {
        // Handle error response
        print('Account deletion failed');
      }
    } catch (e) {
      // Handle any errors that may occur during account deletion process
      print('Delete Account Error: $e');
    }
  }

  Future<void> _getUserFromDatabase() async {
    // Get the token from the AuthService
    final token = await _authService.getUserAuthToken();
    String apiUrl = Helpers.getUri();
    if (mounted) {
      setState(() {
        _isUserLoading = true;
      });
    }
    final response = await http.get(
      Uri.parse('$apiUrl/queryuser'),
      headers: {
        'Authorization': token,
      },
    );
    //final response = await http.get(Uri.parse('${Helpers.getUri()}/user'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      _firstNameController.text = decoded['firstName'];
      _lastNameController.text = decoded['lastName'];

      // for dev purposes, this netid will never be allowed to change
      _netIdController.text = decoded['studentId'];
      _majorController.text = decoded['major'];
      _collegeController.text = decoded['college'];
      _gradeController.text = decoded['grade'];

      _savedInterests = List<String>.from(
          decoded['interests'].map((e) => e.toString()).toList());
      _suggestedInterests = List<String>.from(
          decoded['suggestions'].map((e) => e.toString()).toList());
    } else {
      print("failed");
    }
    if (mounted) {
      setState(() {
        _isUserLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldUpdate) {
      _getUserFromDatabase();
      _shouldUpdate = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color(0xFF0C2340),
        automaticallyImplyLeading: false,
      ),
      body: _isUserLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, left: 15.0, right: 15.0, bottom: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        netID: _netIdController.text,
                                        major: _majorController.text,
                                        college: _collegeController.text,
                                        grade: _gradeController.text)),
                              );
                              if (mounted) {
                                setState(() {
                                  _shouldUpdate = true;
                                });
                              }
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.settings,
                                  size: 24.0,
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Manage Profile',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InterestsPage(
                                      savedInterests: _savedInterests,
                                      suggestedInterests: _suggestedInterests,
                                      isUserLoading: _isUserLoading),
                                ),
                              );
                              if (mounted) {
                                setState(() {
                                  _shouldUpdate = true;
                                });
                              }
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.local_activity,
                                  size: 24.0,
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Update Interests',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey[400],
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              _handleLogout();
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.logout,
                                  size: 24.0,
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Logout Account',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: GestureDetector(
                            onTap: () async {
                              // Show a confirmation dialog before proceeding
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Account Deletion'),
                                    content: Text(
                                        'Are you sure you want to delete your account?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _handleDeleteAccount(); // Call the delete account function
                                          // Navigator.pop(
                                          //     context);
                                          Navigator.pushReplacementNamed(
                                              context,
                                              '/login'); // Close the dialog
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.delete_forever,
                                  size: 24.0,
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Delete Account',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

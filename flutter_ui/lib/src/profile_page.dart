import 'package:flutter/material.dart';
import 'helpers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_ui/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final dynamic firstName;
  final dynamic lastName;
  final dynamic netID;
  final dynamic major;
  final dynamic college;
  final dynamic grade;

  const ProfilePage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.netID,
      required this.major,
      required this.college,
      required this.grade});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _netIdController = TextEditingController();
  TextEditingController _majorController = TextEditingController();
  TextEditingController _collegeController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _netIdController = TextEditingController(text: widget.netID);
    _majorController = TextEditingController(text: widget.major);
    _collegeController = TextEditingController(text: widget.college);
    _gradeController = TextEditingController(text: widget.grade);
  }

  final AuthService _authService = AuthService();

  Future<void> _submitProfile() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    // for dev purposes, this will never be anything but cpreciad
    String netId = _netIdController.text;
    String major = _majorController.text;
    String college = _collegeController.text;
    String grade = _gradeController.text;
    // TODO save the changes to the user profile
    // encode post body data
    String bodyData = jsonEncode(<String, String>{
      'firstName': firstName,
      'lastName': lastName,
      'netId': netId,
      'major': major,
      'college': college,
      'grade': grade,
    });
    final token = await _authService.getUserAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token
    };

    // send post to /user route to server
    final response = await http.post(Uri.parse('${Helpers.getUri()}/queryuser'),
        headers: headers, body: bodyData);

    if (response.statusCode == 200) {
      return;
    }
    // error with post request
    else {
      throw Exception("post interest request failed: ${response}");
    }
    // Do something with the profile data, e.g. save it to a database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Manage Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color(0xFF0C2340),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _netIdController,
                    decoration: const InputDecoration(
                      labelText: 'Net ID',
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _majorController,
                    decoration: const InputDecoration(
                      labelText: 'Major',
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _collegeController,
                    decoration: const InputDecoration(
                      labelText: 'College',
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  _submitProfile();
                  const snackBar = SnackBar(
                    content: Text('Your changes have been saved'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  height: 60.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.5),
                    color: const Color(0xFF0C2340),
                  ),
                  child: const Center(
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18.0,
                        color: Colors.white,
                        letterSpacing: 1.25,
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

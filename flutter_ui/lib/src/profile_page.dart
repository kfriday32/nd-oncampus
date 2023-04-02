import 'package:flutter/material.dart';
import 'helpers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final dynamic firstName;
  final dynamic lastName;
  final dynamic netID;

  const ProfilePage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.netID});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _netIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _netIdController = TextEditingController(text: widget.netID);
  }

  Future<void> _submitProfile() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    // for dev purposes, this will never be anything but cpreciad
    String netId = "cpreciad";
    // TODO save the changes to the user profile
    // encode post body data
    String bodyData = jsonEncode(<String, String>{
      'firstName': firstName,
      'lastName': lastName,
      'netId': netId,
    });
    final headers = {'Content-Type': 'application/json'};

    // send post to /user route to server
    final response = await http.post(Uri.parse('${Helpers.getUri()}/user'),
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _netIdController,
                      decoration: const InputDecoration(
                        labelText: 'Net ID',
                      ),
                    ),
                  ],
                ),
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

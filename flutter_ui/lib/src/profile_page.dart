import 'package:date_format/date_format.dart';
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
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0C2340),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 300.0,
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                ),
              ),
            ),
            SizedBox(
              width: 300.0,
              child: TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
            ),
            SizedBox(
              width: 300.0,
              child: TextField(
                controller: _netIdController,
                decoration: InputDecoration(
                  labelText: 'Net ID',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _submitProfile();
                final snackBar = SnackBar(
                  content: Text('Profile Updated!'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text('Submit'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                Color(0xFFd39F10),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

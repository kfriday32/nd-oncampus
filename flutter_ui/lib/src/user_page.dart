import 'package:flutter/material.dart';
import 'interests_page.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'helpers.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _netIdController = TextEditingController();
  List<String> _interests = [];

  bool _isLoading = true;
  bool _shouldUpdate = false;

  @override
  void initState() {
    super.initState();
    _getUserFromDatabase();
  }

  Future<void> _getUserFromDatabase() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(Uri.parse('${Helpers.getUri()}/user'));
    if (response.statusCode == 200) {
      print(response.body);
      final decoded = jsonDecode(response.body);
      _firstNameController.text = decoded['firstName'];
      _lastNameController.text = decoded['lastName'];
      // for dev purposes, this netid will never be allowed to change
      _netIdController.text = "cprecaid";
      _interests = List<String>.from(
          decoded['interests'].map((e) => e.toString()).toList());
    } else {
      print("failed");
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
      ),
      body: Column(
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
                                  netID: _netIdController.text)),
                        );
                        setState(() {
                          _shouldUpdate = true;
                        });
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
                              builder: (context) =>
                                  InterestsPage(interests: _interests)),
                        );
                        setState(() {
                          _shouldUpdate = true;
                        });
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: GestureDetector(
                      onTap: () {},
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

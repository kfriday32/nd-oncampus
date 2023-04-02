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
        title: const Text('Profile Settings'),
        backgroundColor: const Color(0xFF0C2340),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Center(child: Text('Manage Profile')),
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
          ),
          ListTile(
            title: const Center(child: Text('Update Interests')),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InterestsPage(interests: _interests)),
              );
              setState(() {
                _shouldUpdate = true;
              });
            },
          ),
          ListTile(
            title: const Center(child: Text('Delete Account')),
            onTap: () {
              // This won't do anything right now
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'Helpers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InterestsPage extends StatefulWidget {
  final List<String> interests;
  const InterestsPage({super.key, required this.interests});
  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final _interestController = TextEditingController();

  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _interests = widget.interests;
  }

  Future<void> _saveInterestsToDatabase(List<String> interests) async {
    // save the interests to the database here
    String bodyData = jsonEncode(<String, List<String>>{
      'interests': _interests,
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

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interests'),
        backgroundColor: const Color(0xFF0C2340),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddInterestDialog(context);
            },
          ),
        ],
      ),
      body: _interests.isEmpty
          ? const Center(
              child: Text(
                'Press the plus botton to add interests',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _interests
                  .map((interest) => GestureDetector(
                        onTap: () {
                          _showConfirmDeleteDialog(context, interest);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 10.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.grey[300],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                interest,
                                style: TextStyle(fontSize: 20.0),
                              ),
                              SizedBox(width: 4.0),
                              Icon(
                                Icons.close,
                                size: 16.0,
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }

  void _showAddInterestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add an Interest"),
          content: TextField(
            controller: _interestController,
            decoration: InputDecoration(
              hintText: "Enter interest",
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                Color(0xFF0C2340),
              )),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                Color(0xFFd39F10),
              )),
              onPressed: () {
                // Handle adding the interest here
                setState(() {
                  if (!_interestController.text.trim().isEmpty) {
                    _interests.add(_interestController.text);
                    _saveInterestsToDatabase(_interests);
                    _interestController.text = "";
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDeleteDialog(BuildContext context, String interest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Interest"),
          content: Text("Are you sure you want to remove $interest?"),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color(0xFF0C2340),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color(0xFFd39F10),
                ),
              ),
              onPressed: () {
                setState(() {
                  _interests.remove(interest);
                  _saveInterestsToDatabase(_interests);
                });
                Navigator.of(context).pop();
              },
              child: Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Interests updated"),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color(0xFF0C2340),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

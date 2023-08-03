import 'package:flutter/material.dart';
import 'Helpers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_ui/services/auth_service.dart';

class InterestsPage extends StatefulWidget {
  final List<String> savedInterests;
  final List<String> suggestedInterests;
  final bool isUserLoading;
  const InterestsPage({
    super.key,
    required this.savedInterests,
    required this.suggestedInterests,
    required this.isUserLoading,
  });
  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final _interestController = TextEditingController();

  List<String> _savedInterests = [];
  List<String> _suggestedInterests = [];

  @override
  void initState() {
    super.initState();
    _savedInterests = widget.savedInterests;
    _suggestedInterests = widget.suggestedInterests;
  }

  final AuthService _authService = AuthService();

  Future<void> _saveInterestsToDatabase(List<String> interests) async {
    // save the interests to the database here
    final token = await _authService.getUserAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token
    };

    // send post to /user route to server

    String bodyData = jsonEncode(<String, List<String>>{
      'interests': _savedInterests,
    });

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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
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
      body: _savedInterests.isEmpty
          ? const Center(
              child: Text(
                'Press the plus botton to add interests',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        ...buildSavedInterests(context),
                        ...buildSuggestedInterests(context)
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<GestureDetector> buildSavedInterests(BuildContext context) {
    return _savedInterests
        .map(
          (interest) => GestureDetector(
            onTap: () {
              _showConfirmDeleteDialog(context, interest);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.grey[300],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    interest,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(width: 5.0),
                  const Icon(
                    Icons.close,
                    size: 16.0,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  List<GestureDetector> buildSuggestedInterests(BuildContext context) {
    return _suggestedInterests
        .map(
          (interest) => GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() {
                  _savedInterests.add(interest);
                  _suggestedInterests.remove(interest);
                  _saveInterestsToDatabase(_savedInterests);
                });
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    interest,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.grey[500]!,
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  Icon(
                    Icons.question_mark,
                    size: 16.0,
                    color: Colors.grey[500]!,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
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
                if (mounted) {
                  setState(() {
                    if (!_interestController.text.trim().isEmpty) {
                      _savedInterests.add(_interestController.text);
                      _saveInterestsToDatabase(_savedInterests);
                      _interestController.text = "";
                    }
                  });
                }
                ;
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
                if (mounted) {
                  setState(() {
                    _savedInterests.remove(interest);
                    _saveInterestsToDatabase(_savedInterests);
                  });
                }
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

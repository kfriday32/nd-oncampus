import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsPage extends StatelessWidget {

  const EventsPage({super.key});

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Event Interest'),
        ),
        body: InterestForm()
    );
  }
}

// form to collect user input/interests
class InterestForm extends StatefulWidget {
  @override
  State<InterestForm> createState() => _InterestFormState();
}

class _InterestFormState extends State<InterestForm> {

  // global key to keep track of form id
  final _formKey = GlobalKey<FormState>();
  
  final _serverUri = 'http://127.0.0.1:5000';
  final interestsController = TextEditingController();

  // clean up controller when widget is removed
  @override
  void dispose() {
    interestsController.dispose();
    super.dispose();
  }

  // http request to post interests to backend server
  Future<http.Response> postInterest(String interest) {
    print("post interest: ${interest}");
    return http.post(
      Uri.parse(_serverUri),
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': '18'
      },
      body: <String, String> {
        'interests': interest
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      // centered column
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Event Interest'),
          ),
          TextFormField(
            // validate user input by checking non-empty
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Please enter your interests.";
              }
              return null;
            },
            controller: interestsController
          ),
          ElevatedButton(
            onPressed: () {
              // validate input
              if (_formKey.currentState!.validate()) {
                // process the input if valid
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
                postInterest(interestsController.text);
              }
            },
            child: const Text('Submit')
          ),
        ],
      ),
    );
  }
}
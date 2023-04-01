import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'suggested_page.dart';
import 'helpers.dart' as helpers;


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
	
  final _serverUri = helpers.getUri();
  
  // watch when text input field changes
  final interestsController = TextEditingController();

  // clean up controller when widget is removed
  @override
  void dispose() {
    interestsController.dispose();
    super.dispose();
  }

  // http request to post interests to backend server
  Future<http.Response> postInterest(String interest) async {
 
    // encode post body data
    String bodyData = jsonEncode(<String, String> {
        'interest': interest
    });
    final headers = {'Content-Type': 'application/json'};

    // send post to server
    final response = await http.post(
      Uri.parse(_serverUri),
      headers: headers,
      body: bodyData
    );

    if (response.statusCode == 200) {
      return response;
    }
    // error with post request
    else {
      throw Exception("post interest request failed: ${response}");
    }
  }

  // clean response object to parse event list
  List<String> getEventList(String response) {
    return response.trim().split('\n');
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
            onPressed: () async {
              // validate input
              if (_formKey.currentState!.validate()) {

                // make post request to get events
                final response = await postInterest(interestsController.text);

                // clean the response
                List<String> eventList = getEventList(response.body);
                print("event list: ${eventList}");

                // forward suggested events to next page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuggestedPage(events: eventList)
                  )
                );
              }
            },
            child: const Text('Submit')
          ),
        ],
      ),
    );
  }
}

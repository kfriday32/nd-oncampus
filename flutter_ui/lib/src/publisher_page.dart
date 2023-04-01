import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers.dart' as helpers;

class PublisherPage extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Publisher Page'),
        ),
        body: EventForm()
    );
  }
}

class EventForm extends StatefulWidget {
  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {

  // global key to keep track of form id
  final _formKey = GlobalKey<FormState>();

  // visibility of guest list
  String _time = "";

  // text field controllers
  final titleCont = TextEditingController();
  final descCont = TextEditingController();
  final locCont = TextEditingController();
  final durCont = TextEditingController();
  final regCont = TextEditingController();
  final urlCont = TextEditingController();
  final visCont = TextEditingController();
  final hostCont = TextEditingController();
  final guestCont = TextEditingController();
  final capCont = TextEditingController();

  Future<http.Response> postEvent() async {

    String bodyData = jsonEncode(<String, String> {
        'title': titleCont.text,
        'description': descCont.text,
        'location': locCont.text,
        'time': _time,
        'duration': durCont.text,
        'registrationLink': regCont.text,
        'url': urlCont.text,
        'publicGuestList': visCont.text,
        'host': hostCont.text,
        'numberGuests': guestCont.text,
        'capacity': capCont.text
    });
    
    String uri = "${helpers.getUri()}/publish";
    final headers = {'Content-Type': 'application/json'};

    // send post to server
    final response = await http.post(
      Uri.parse(uri),
      headers: headers,
      body: bodyData
    );

    if (response.statusCode == 200) {
      return response;
    }
    // error with post request
    else {
      throw Exception("post new event request failed: ${response}");
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    // allow scrolling if content exceeds height
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.title),
                    hintText: 'Name of the event',
                    labelText: 'Title *',
                  ),
                  validator: (val) {
                    return (val == null) ? 'Title must not be blank' : null;
                  }
                ),
                TextFormField(
                  controller: descCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.short_text),
                    hintText: 'Short description',
                    labelText: 'Description *',
                  ),
                  validator: (val) {
                    return (val == null) ? 'Description must not be blank' : null;
                  }
                ),
                TextFormField(
                  controller: locCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.pin_drop),
                    hintText: 'On campus location',
                    labelText: 'Location *',
                  ),
                  validator: (val) {
                    return (val == null) ? 'Location must not be blank' : null;
                  }
                ),
                DateTimeFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.event_note),
                    hintStyle: TextStyle(color: Colors.black45),
                    errorStyle: TextStyle(color: Colors.redAccent),
                    labelText: 'Time *',
                  ),
                  validator: (val) {
                    return (val == null) ? 'Please pick a time' : null;
                  },
                  onDateSelected: (DateTime val) {
                    print(val);
                    _time = val.toString();
                  }
                ),
                TextFormField(
                  controller: durCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.schedule),
                    hintText: 'Length of event in hours',
                    labelText: 'Duration (hours) *',
                  ),
                  validator: (val) {
                    return (val == null) ? 'Duration must not be blank' : null;
                  }
                ),
                TextFormField(
                  controller: regCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.how_to_reg),
                    hintText: 'ex: tinyurl.com/',
                    labelText: 'Registration Link',
                  ),
                ),
                TextFormField(
                  controller: urlCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.link),
                    hintText: 'ex: tinyurl.com/',
                    labelText: 'Event Url',
                  ),
                ),
                SelectFormField(
                  controller: visCont,
                  type: SelectFormFieldType.dropdown,
                  icon: Icon(Icons.admin_panel_settings),
                  labelText: 'Visibility',
                  items: [
                    {
                      'value': 'public',
                      'label': 'Public',
                      'icon': Icon(Icons.visibility)
                    },
                    {
                      'value': 'private',
                      'label': 'Private',
                      'icon': Icon(Icons.visibility_off)
                    }
                  ],
                  onSaved: (val) {
                    print(val);
                  }
                ),
                TextFormField(
                  controller: guestCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.group),
                    hintText: 'ex: 50',
                    labelText: 'Number of Guests',
                  ),
                ),
                TextFormField(
                  controller: capCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.groups),
                    hintText: 'ex: 500',
                    labelText: 'Capacity',
                  ),
                ),
                TextFormField(
                  controller: hostCont,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.gite),
                    hintText: 'Event host',
                    labelText: 'Host',
                  ),
                ),
                ElevatedButton(
                  child: const Text('Submit'), 
                  onPressed: () async {
                    // validate input
                    if (_formKey.currentState!.validate()) {
                      // send data to MongoDB
                      final res = await postEvent();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Successfully created new event!')),
                      );

                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data not validated')),
                      );
                    }
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers.dart';

class PublisherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C2340),
          title: const Text(
            'Propose Event',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
        ),
        body: EventForm());
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
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();

  // text field controllers
  final _titleController = TextEditingController();
  final _hostController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _registrationLinkController = TextEditingController();
  final _eventUrlController = TextEditingController();
  final _capacityController = TextEditingController();

  Future<http.Response> postEvent() async {
    String bodyData = jsonEncode(<String, String>{
      'title': _titleController.text,
      'host': _hostController.text,
      'description': _descController.text,
      'location': _locationController.text,
      'startTime': _startTime.toString(),
      'endTime': _endTime.toString(),
      'registrationLink': _registrationLinkController.text,
      'eventUrl': _eventUrlController.text,
      'capacity': _capacityController.text
    });

    String uri = '${Helpers.getUri()}/publish';
    final headers = {'Content-Type': 'application/json'};

    // send post to server
    final response =
        await http.post(Uri.parse(uri), headers: headers, body: bodyData);

    if (response.statusCode == 200) {
      return response;
    }
    // error with post request
    else {
      throw Exception("Failed to propose a new event.");
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    // allow scrolling if content exceeds height
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.title),
                            hintText: 'Name of the event',
                            labelText: 'Title *',
                          ),
                          validator: (val) {
                            return (val == null || val == "")
                                ? 'Title must not be blank'
                                : null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _hostController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.group),
                            hintText: 'Club or organization hosting the event',
                            labelText: 'Host *',
                          ),
                          validator: (val) {
                            return (val == null || val == "")
                                ? 'Host must not be blank'
                                : null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.short_text),
                            hintText: 'Short description',
                            labelText: 'Description *',
                          ),
                          validator: (val) {
                            return (val == null || val == "")
                                ? 'Description must not be blank'
                                : null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.pin_drop),
                            hintText: 'On campus location',
                            labelText: 'Location *',
                          ),
                          validator: (val) {
                            return (val == null || val == "")
                                ? 'Location must not be blank'
                                : null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        DateTimeFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.event_note),
                            hintStyle: TextStyle(color: Colors.black45),
                            errorStyle: TextStyle(color: Colors.redAccent),
                            labelText: 'Start Time *',
                          ),
                          validator: (val) {
                            return (val == null)
                                ? 'Please pick a start time'
                                : null;
                          },
                          onDateSelected: (DateTime val) {
                            _startTime = val;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        DateTimeFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.event_note),
                            hintStyle: TextStyle(color: Colors.black45),
                            errorStyle: TextStyle(color: Colors.redAccent),
                            labelText: 'End Time *',
                          ),
                          validator: (val) {
                            if (val == null) {
                              return 'Please pick an end time';
                            } else if (!_endTime.isAfter(_startTime)) {
                              return 'Ensure that the end time is after the start time';
                            }
                            return null;
                          },
                          onDateSelected: (DateTime val) {
                            _endTime = val;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _registrationLinkController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.how_to_reg),
                            hintText: 'ex: https://und.edu/',
                            labelText: 'Registration Link',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _eventUrlController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.link),
                            hintText: 'ex: https://und.edu/',
                            labelText: 'Event Url',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _capacityController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.groups),
                            hintText: 'ex: 500',
                            labelText: 'Capacity',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // validate input
              if (_formKey.currentState!.validate()) {
                // send data to MongoDB
                await postEvent();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Successfully created new event!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data not validated')),
                );
              }
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
                  'SUBMIT',
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
    );
  }
}

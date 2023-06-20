import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class PublisherPage extends StatelessWidget {
  final Function updateSelectedIndex;

  const PublisherPage({Key? key, required this.updateSelectedIndex})
      : super(key: key);

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
        body: EventForm(updateSelectedIndex: updateSelectedIndex));
  }
}

class EventForm extends StatefulWidget {
  final Function updateSelectedIndex;

  const EventForm({Key? key, required this.updateSelectedIndex})
      : super(key: key);

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  // global key to keep track of form id
  final _formKey = GlobalKey<FormState>();

  // visibility of guest list
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();
  // DateTime? _selectedDateTime;
  // Selected date and time
  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  // text field controllers
  final _titleController = TextEditingController();
  final _hostController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _registrationLinkController = TextEditingController();
  final _eventUrlController = TextEditingController();
  final _capacityController = TextEditingController();

  // Calendar
  final _startCalendarController = CalendarController();
  final _endCalendarController = CalendarController();

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  // Validate date & time
  bool _validateEndDate() {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      return true; // Skip validation if either start or end date is not selected
    }
    return _selectedEndDate!
        .isAfter(_selectedStartDate!); // Validate end date is after start date
  }

  bool _isSubmitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _hostController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _registrationLinkController.dispose();
    _eventUrlController.dispose();
    _capacityController.dispose();

    _startCalendarController.dispose();
    _endCalendarController.dispose();
    super.dispose();
  }

  Future<http.Response> postEvent() async {
    String bodyData = jsonEncode(<String, String>{
      'title': _titleController.text,
      'host': _hostController.text,
      'description': _descController.text,
      'location': _locationController.text,
      'startTime': _startTime.toString(),
      'endTime': _endTime.toString(),
      'startDate': _startTime.toString(),
      'endDate': _endTime.toString(),
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
      child: _isSubmitted
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 250.0,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Your event proposal has been submitted for approval. You will receive a notification if your event is approved.',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      widget.updateSelectedIndex(0);
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
                          'Acknowledge',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18.0,
                            color: Colors.white,
                            letterSpacing: 1.25,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : Column(
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
                                  return (val == null || val.trim().isEmpty)
                                      ? 'Title must not be blank'
                                      : null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                controller: _hostController,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.group),
                                  hintText:
                                      'Club or organization hosting the event',
                                  labelText: 'Host *',
                                ),
                                validator: (val) {
                                  return (val == null || val.trim().isEmpty)
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
                              // Date & Time Selection
                              const SizedBox(
                                height: 20.0,
                              ),

                              SizedBox(
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                        child: Icon(Icons.calendar_today,
                                            color: Colors.grey)),
                                    // Calendar icon
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 182, 186, 188)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 31, 33, 33)),
                                        ),
                                        onPressed: () =>
                                            _selectStartDate(context),
                                        child: Text(_selectedStartDate == null
                                            ? 'Select Start Date'
                                            : 'Start Date: ${_selectedStartDate.toString().split(' ')[0]}'),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 182, 186, 188)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 31, 33, 33)),
                                        ),
                                        onPressed: () =>
                                            _selectStartTime(context),
                                        child: Text(_selectedStartTime == null
                                            ? 'Select Start Time'
                                            : 'Start Time: ${_selectedStartTime!.format(context)}'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20.0),

                              SizedBox(
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                        child: Icon(Icons.calendar_today,
                                            color: Colors.grey)),
                                    // Calendar icon
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 182, 186, 188)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 31, 33, 33)),
                                        ),
                                        onPressed: () =>
                                            _selectEndDate(context),
                                        child: Text(_selectedEndDate == null
                                            ? 'Select End Date'
                                            : _validateEndDate()
                                                ? 'End Date: ${_selectedEndDate.toString().split(' ')[0]}'
                                                : 'Invalid End Date'),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 182, 186, 188)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 31, 33, 33)),
                                        ),
                                        onPressed: () =>
                                            _selectEndTime(context),
                                        child: Text(_selectedEndTime == null
                                            ? 'Select End Time'
                                            : 'Start Time: ${_selectedEndTime!.format(context)}'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // const SizedBox(height: 20.0),
                              // DateTimeFormField(
                              //   decoration: const InputDecoration(
                              //     icon: Icon(Icons.event_note),
                              //     hintStyle: TextStyle(color: Colors.black45),
                              //     errorStyle:
                              //         TextStyle(color: Colors.redAccent),
                              //     labelText: 'Start Time *',
                              //   ),
                              //   validator: (val) {
                              //     return (val == null)
                              //         ? 'Please pick a start time'
                              //         : null;
                              //   },
                              //   onDateSelected: (DateTime val) {
                              //     _startTime = val;
                              //   },
                              // ),
                              // const SizedBox(height: 20.0),
                              // DateTimeFormField(
                              //   decoration: const InputDecoration(
                              //     icon: Icon(Icons.event_note),
                              //     hintStyle: TextStyle(color: Colors.black45),
                              //     errorStyle:
                              //         TextStyle(color: Colors.redAccent),
                              //     labelText: 'End Time *',
                              //   ),
                              //   validator: (val) {
                              //     if (val == null) {
                              //       return 'Please pick an end time';
                              //     } else if (!_endTime.isAfter(_startTime)) {
                              //       return 'Ensure that the end time is after the start time';
                              //     }
                              //     return null;
                              //   },
                              //   onDateSelected: (DateTime val) {
                              //     _endTime = val;
                              //   },
                              // ),
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
                      // await postEvent();

                      if (mounted) {
                        setState(() {
                          _isSubmitted = true;
                        });
                      }
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

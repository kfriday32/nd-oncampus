//import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:bson/bson.dart';

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
  String selectedSeries = '';

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
  final _seriesNameController = TextEditingController();
  // Calendar
  final _startCalendarController = CalendarController();
  final _endCalendarController = CalendarController();

  // Date & Time Selecting
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      // Change color
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF0C2340),
            colorScheme: ColorScheme.light(primary: Color(0xFF0C2340)),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: Color(0xFF0C2340),
            ),
          ),
          child: child!,
        );
      },
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
      // Change color
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF0C2340),
            colorScheme: ColorScheme.light(primary: Color(0xFF0C2340)),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: Color(0xFF0C2340),
            ),
          ),
          child: child!,
        );
      },
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
      // Change color
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF0C2340),
            colorScheme: ColorScheme.light(primary: Color(0xFF0C2340)),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: Color(0xFF0C2340),
            ),
          ),
          child: child!,
        );
      },
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
      // Change color
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF0C2340),
            colorScheme: ColorScheme.light(primary: Color(0xFF0C2340)),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: Color(0xFF0C2340),
            ),
          ),
          child: child!,
        );
      },
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
    if (_selectedStartDate!.isAtSameMomentAs(_selectedEndDate!)) {
      return true;
    }
    return _selectedEndDate!
        .isAfter(_selectedStartDate!); // Validate end date is after start date
  }

  bool _validateEndTime() {
    if (_selectedStartTime == null || _selectedEndTime == null) {
      return true;
    }
    // Start Time is Before End Time
    if (_selectedStartTime!.hour < _selectedEndTime!.hour ||
        (_selectedStartTime!.hour == _selectedEndTime!.hour &&
            _selectedStartTime!.minute < _selectedEndTime!.minute)) {
      return true;
    } else {
      return false;
    }
  }

  bool _isSubmitted = false;
  bool isSeriesEvent = false;

  List<String> _existingSeries = ['ND Softball', 'Series B', 'Series C'];
  TextEditingController _newSeriesController = TextEditingController();
  @override
  void dispose() {
    _titleController.dispose();
    _hostController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _registrationLinkController.dispose();
    _eventUrlController.dispose();
    _capacityController.dispose();
    _seriesNameController.dispose();
    _startCalendarController.dispose();
    _endCalendarController.dispose();
    super.dispose();
  }

  // Get seriesID using seriesName
  Future<String?> fetchSeriesId(String seriesName) async {
    try {
      final response = await http.get(
          Uri.parse('${Helpers.getUri()}/seriesID?seriesName=$seriesName'));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception("Failed to fetch series ID.");
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> generateSeriesId(
    bool isSeriesEvent,
    String value,
    TextEditingController seriesNameController,
  ) async {
    if (isSeriesEvent) {
      if (value == 'new') {
        // User selected "Add New Series"
        final newSeries = seriesNameController.text;
        return ObjectId().toHexString(); // Generate a new ObjectID
      } else {
        // User selected an existing series
        final seriesName = value; // Assuming value is the series name
        final seriesId = await fetchSeriesId(seriesName);
        if (seriesId != null) {
          return seriesId;
        } else {
          throw Exception('Failed to fetch series ID for $seriesName');
        }
      }
    } else {
      return '-1'; // Not a series
    }
  }

  Future<http.Response> postEvent() async {
    Future<String> seriesId =
        generateSeriesId(isSeriesEvent, value, _seriesNameController);
    String series_name = '';
    String bodyData = jsonEncode(<String, dynamic>{
      'title': _titleController.text,
      'host': _hostController.text,
      'description': _descController.text,
      'location': _locationController.text,
      'startTime': DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      ).toString(),
      'endTime': DateTime(
        _selectedEndDate!.year,
        _selectedEndDate!.month,
        _selectedEndDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      ).toString(),
      'registrationLink': _registrationLinkController.text,
      'eventUrl': _eventUrlController.text,
      'capacity': _capacityController.text,
      'series_id': seriesId,
      if (seriesId != '-1') 'series_name': _seriesNameController.text,
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
                              // Date Entry
                              SizedBox(
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.grey),
                                    const SizedBox(width: 15.0),
                                    // Start Date
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 228, 230, 232)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color(0xFF0C2340)),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              side: BorderSide(
                                                color: Color(0xFF0C2340),
                                              ), // Set the desired outline color here
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _selectStartDate(context),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(_selectedStartDate == null
                                              ? 'Start Date'
                                              : 'Starts: ${DateFormat('MMM d').format(_selectedStartDate!)}'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // End Date
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 228, 230, 232)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color(0xFF0C2340)),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              side: const BorderSide(
                                                color: Color(0xFF0C2340),
                                              ), // Set the desired outline color here
                                            ),
                                          ), // shape
                                        ),
                                        onPressed: () =>
                                            _selectEndDate(context),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _selectedEndDate == null
                                                ? 'End Date'
                                                : _validateEndDate()
                                                    ? 'Ends: ${DateFormat('MMM d').format(_selectedStartDate!)}'
                                                    : 'Invalid End Date',
                                            style: TextStyle(
                                              color: _validateEndDate()
                                                  ? Colors.black
                                                  : Colors
                                                      .red, // Set text color based on validity
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              // Time Entry
                              SizedBox(
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.access_time_outlined,
                                        color: Colors.grey),
                                    const SizedBox(width: 15.0),
                                    // Start Time
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 228, 230, 232)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color(0xFF0C2340)),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              side: BorderSide(
                                                color: Color(0xFF0C2340),
                                              ), // Set the desired outline color here
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _selectStartTime(context),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(_selectedStartTime == null
                                              ? 'Start Time'
                                              : 'Starts: ${_selectedStartTime!.format(context)}'),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),
                                    // End Time
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 228, 230, 232)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color(0xFF0C2340)),
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              side: BorderSide(
                                                color: Color(0xFF0C2340),
                                              ), // Set the desired outline color here
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _selectEndTime(context),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _selectedEndTime == null
                                                ? 'End Time'
                                                : _validateEndTime()
                                                    ? 'Ends: ${DateFormat.jm().format(DateTime(2023, 1, 1, _selectedEndTime!.hour, _selectedEndTime!.minute))}'
                                                    : 'Invalid End Time',
                                            style: TextStyle(
                                              color: _validateEndTime()
                                                  ? Colors.black
                                                  : Colors
                                                      .red, // Set text color based on validity
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10.0),
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
                              // Add to Series
                              const SizedBox(height: 20.0),
                              SizedBox(
                                height: 30.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.format_list_bulleted_add,
                                        color: Colors.grey),
                                    const SizedBox(width: 15.0),
                                    SizedBox(width: 10.0),
                                    PopupMenuButton<String>(
                                      child: Text('Add to Series'),
                                      onSelected: (value) {
                                        setState(() {
                                          isSeriesEvent = true;
                                        });
                                        // Handle selected series here
                                        if (value == 'new') {
                                          final newSeries =
                                              _newSeriesController.text;
                                          if (newSeries.isNotEmpty) {
                                            setState(() {
                                              _existingSeries.add(newSeries);
                                              selectedSeries = newSeries;
                                            });
                                          }
                                          _newSeriesController.clear();
                                        } else {
                                          setState(() {
                                            isSeriesEvent = true;
                                            selectedSeries = value;
                                          });
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          ..._existingSeries.map((series) {
                                            return CheckedPopupMenuItem<String>(
                                              value: series,
                                              checked: series == selectedSeries,
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text(series)),
                                                  IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () {
                                                      setState(() {
                                                        _existingSeries
                                                            .remove(series);
                                                        if (selectedSeries ==
                                                            series) {
                                                          selectedSeries =
                                                              ''; // Reset selectedSeries if the deleted series was selected
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                          PopupMenuItem<String>(
                                            value: 'new',
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        _newSeriesController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'New Series Event'),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedSeries = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    final newSeries =
                                                        _newSeriesController
                                                            .text;
                                                    if (newSeries.isNotEmpty) {
                                                      setState(() {
                                                        selectedSeries =
                                                            newSeries;
                                                        _existingSeries
                                                            .add(newSeries);
                                                      });
                                                    }
                                                    _newSeriesController
                                                        .clear();
                                                  },
                                                  icon: Icon(Icons.add),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ];
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              //   child: CheckboxListTile(
                              //       value: _newSeriesController
                              //               .text ==
                              //           series,
                              //       title: Text(series),
                              //       onChanged: (newValue) {
                              //         setState(() {
                              //           _newSeriesController
                              //               .text = series;
                              //           isSeriesEvent =
                              //               newValue ?? false;
                              //         });
                              //       }),
                              // )];

                              //         PopupMenuItem<String>(
                              //           value: 'new',
                              //           child: Row(
                              //             children: [
                              //               Expanded(
                              //                 child: TextFormField(
                              //                   controller:
                              //                       _newSeriesController,
                              //                   decoration: InputDecoration(
                              //                       hintText:
                              //                           'New Series Event'),
                              //                 ),
                              //               ),
                              //               IconButton(
                              //                 onPressed: () {
                              //                   final newSeries =
                              //                       _newSeriesController
                              //                           .text;
                              //                   // Implement logic to add a new series using the newSeries variable
                              //                   //_newSeriesController
                              //                   //.clear(); // Clear the text field after adding the new series
                              //                 },
                              //                 icon: Icon(Icons.add),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ];

                              //       // return [
                              //       //   PopupMenuItem<String>(
                              //       //     value: 'new',
                              //       //     child: Text('Add New Series'),
                              //       //   ),
                              //       // ];
                              //     },
                              //   ),
                              // ]),
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

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

  @override
  void initState() {
    super.initState();
    _seriesNameController.clear();
    // get intial existing series list
    fetchSeriesList().then((list) {
      setState(() {
        seriesList = list;
      });
    }).catchError((error) {
      // Handle error
    });
  }

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

  // Series Input Functions
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

  // Get list of existing series
  Future<List<String>> fetchSeriesList() async {
    try {
      final response =
          await http.get(Uri.parse('${Helpers.getUri()}/existingSeries'));
      if (response.statusCode == 200) {
        final List<dynamic> seriesList = jsonDecode(response.body);
        final List<String> seriesNames = seriesList.cast<String>();
        return seriesNames;
      } else {
        throw Exception("Failed to fetch series names.");
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update series list
  void updateSeriesList() {
    fetchSeriesList().then((list) {
      setState(() {
        seriesList = list;
      });
    }).catchError((error) {
      // Handle error
    });
  }

// Generate seriesId for adding to existing series
  Future<String> generateSeriesId(
    bool isSeriesEvent,
    String value,
    TextEditingController seriesNameController,
  ) async {
    //Map<String, String> seriesData = {};

    if (isSeriesEvent) {
      if (value == 'new') {
        final seriesName = seriesNameController.text;
        if (seriesName.isNotEmpty) {
          final seriesId = await fetchSeriesId(seriesName);
          if (seriesId != null) {
            // check seriesId
            return seriesId;
          } else {
            throw Exception('Failed to fetch series ID for $seriesName');
          }
        }
      }
      // new series selected
      else {
        // retireve existing seriesId
        final seriesName = value; // Assuming value is the series name
        final seriesId = await fetchSeriesId(seriesName);
        if (seriesId != null) {
          // check seriesId
          return seriesId;
        } else {
          throw Exception('Failed to fetch series ID for $seriesName');
        }
      }
    }
    return '-1'; // not part of series
  }
  // if (value == 'new') {
  //   // User selected "Add New Series"
  //   final seriesName = seriesNameController.text;
  //   if (seriesName.isNotEmpty) {
  //     final seriesId = ObjectId().toHexString();
  //     seriesData['seriesName'] = seriesName;
  //     seriesData['seriesId'] = seriesId;
  //     seriesList.add(seriesName);
  //   } else {
  //     throw Exception('Series name cannot be empty.');
  //   }
  // }
  // if {
  //   // User selected an existing series
  //   // keep series name in series collection; just series_id
  //   final seriesName = value; // Assuming value is the series name
  //   final seriesId = await fetchSeriesId(seriesName);
  //   if (seriesId != null) {
  //     seriesData['seriesName'] = seriesName;
  //     seriesData['seriesId'] = seriesId;
  //   } else {
  //     throw Exception('Failed to fetch series ID for $seriesName');
  //   }
  // }

  // Series input widget
  String selectedSeries = ''; // holds the series name
  List<String> seriesList = []; // list of series names to display
  String generatedSeriesId = '';
  String seriesId = '';
  Widget _buildSeriesPopupMenu() {
    return FutureBuilder<List<String>>(
      future: fetchSeriesList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          seriesList = snapshot.data!;
          return PopupMenuButton<String>(
            child: Text(
              selectedSeries.isEmpty ? 'Add to Series' : selectedSeries,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
                fontWeight: FontWeight.normal,
              ),
            ),
            onSelected: (value) async {
              setState(() {
                isSeriesEvent = true;
              });
              // New series
              if (value == 'new') {
                final newSeries = _seriesNameController.text;
                if (newSeries.isNotEmpty) {
                  setState(() {
                    //seriesList.add(newSeries);
                    selectedSeries = newSeries;
                  });
                }

                //_seriesNameController.clear();
                // existing series
              } else {
                setState(() {
                  //isSeriesEvent = true;
                  selectedSeries = value;

                  // Get existing seriesId
                  // final generatedSeriesId = await generateSeriesId(
                  //   isSeriesEvent,
                  //   value,
                  //   _seriesNameController,
                  // ); // dont call generateseriesid here
                  // setState(() {
                  //   seriesId = generatedSeriesId;
                  // });
                });

                // final seriesData = await generateSeriesId(
                //   isSeriesEvent,
                //   value,
                //   _seriesNameController,
                // );
                // setState(() {
                //   seriesId = seriesData['seriesId']!;
                //   selectedSeries = seriesData['seriesName']!;
                // });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                ...seriesList.map((series) {
                  return CheckedPopupMenuItem<String>(
                    value: series,
                    checked: series == selectedSeries,
                    child: Text(series),
                  );
                }),
                PopupMenuItem<String>(
                  value: 'new',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _seriesNameController,
                          decoration: InputDecoration(
                            hintText: 'New Series Event',
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedSeries = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final newSeries = _seriesNameController.text;
                          if (newSeries.isNotEmpty) {
                            setState(() {
                              selectedSeries = newSeries;
                              seriesList.add(newSeries);
                            });
                          }
                          _seriesNameController.clear();
                          updateSeriesList();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ];
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return SizedBox(
            height: 20.0,
            width: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
          );
        }
      },
    );
  }

  Future<Object?> postSeries(bool isSeriesEvent) async {
    // call here not in dropdown series
    // final seriesId = await generateSeriesId(
    //   isSeriesEvent,
    //   selectedSeries,
    //   _seriesNameController,
    // );
    // final seriesData = await generateSeriesId(
    //   isSeriesEvent,
    //   selectedSeries,
    //   _seriesNameController,
    // );
    //String seriesName = seriesData['seriesName']!;
    if (isSeriesEvent) {
      String bodyData = jsonEncode(<String, dynamic>{
        'name': selectedSeries,
        'description': '', // another field if series
      });
      String uri = '${Helpers.getUri()}/publishseries';
      final headers = {'Content-Type': 'application/json'};

      // send series to server
      final response =
          await http.post(Uri.parse(uri), headers: headers, body: bodyData);

      if (response.statusCode == 200) {
        return response; // check response
      }
      // error with post request
      else {
        throw Exception("Failed to add new series.");
      }
    } else {
      return null;
    }
    // try requests
  }

  Future<http.Response> postEvent() async {
    final seriesId = await generateSeriesId(
      isSeriesEvent,
      selectedSeries,
      _seriesNameController,
    );

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
      // if (seriesId != '-1') 'series_name': seriesName, //selectedSeries,
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
                                    _buildSeriesPopupMenu(),
                                  ],
                                ),
                              ),
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

                      await postSeries(isSeriesEvent);

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

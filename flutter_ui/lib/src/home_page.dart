import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'navigation.dart';
import 'events_page.dart';
import 'package:fuzzy/fuzzy.dart';
import 'events_list.dart';

class HomePage extends StatefulWidget {
  final AppNavigator navigator;
  List<dynamic> eventDataToday = [];
  List<dynamic> eventDataThisWeek = [];
  List<dynamic> eventDataUpcoming = [];

  HomePage({Key? key, required this.navigator}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = [
    const Tab(text: 'Upcoming'),
    const Tab(text: 'Suggested'),
  ];

  late TabController _tabController;
  bool displaySearch = false;
  final searchCont = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the number of tabs and this class as the provider
    _tabController = TabController(length: myTabs.length, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Dispose of the controller when the widget is removed from the tree
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2340),
        centerTitle: true,
        title: const Text(
          'OnCampus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                displaySearch = !displaySearch;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EventsPage()));
            }
          )
        ],
        bottom: TabBar(
          controller: _tabController, // Set the controller for the TabBar
          tabs: myTabs,
          indicatorColor: const Color(0xFFd39F10),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              // display search text box if search button is clicked
              displaySearch ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: (
                  TextField(
                    controller: searchCont,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          // reset current lists
                          setState(() {
                            widget.eventDataToday = [];
                            widget.eventDataThisWeek = [];
                            widget.eventDataUpcoming = [];

                            displaySearch = false;
                          });
                          // repopulate events
                          _loadEvents();
                        }
                      ),
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _searchEvents
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  )
                ),
              ) : SizedBox(height: 0),
              Expanded(
                child: TabBarView(
                    controller: _tabController,
                    children: [
                      EventsList(
                        eventDataToday: widget.eventDataToday,
                        eventDataThisWeek: widget.eventDataThisWeek,
                        eventDataUpcoming: widget.eventDataUpcoming,
                      ),
                      EventsList(
                        eventDataToday: widget.eventDataToday,
                        eventDataThisWeek: widget.eventDataThisWeek,
                        eventDataUpcoming: widget.eventDataUpcoming,
                      )
                    ],
                  ),
              ),
            ],
          ),
    );
  }

  void sortData() {
    widget.eventDataToday.sort((a, b) => a['time'].compareTo(b['time']));
    widget.eventDataThisWeek
        .sort((a, b) => a['time'].compareTo(b['time']));
    widget.eventDataUpcoming
        .sort((a, b) => a['time'].compareTo(b['time']));
  }

  void _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/'));

      if (response.statusCode != 200) {
        print('Error: ${response.statusCode}');
      } else {
        setState(() {
          final DateTime now = DateTime.now();
          for (var event in jsonDecode(response.body)) {
            event['time'] = DateTime.parse(event['time']!);

            if (event['time'].isBefore(now)) {
              continue;
            }

            if (isSameDate(now, event['time'])) {
              widget.eventDataToday.add(event);
            } else if (isWithinUpcomingWeek(now, event['time'])) {
              widget.eventDataThisWeek.add(event);
            } else {
              widget.eventDataUpcoming.add(event);
            }
          }

          sortData();
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // method performs search query on events in main page
  void _searchEvents() {
    
    // get user input from search bar
    String searchText = searchCont.text;

    List<List<dynamic>> allEvents = 
      [widget.eventDataToday, widget.eventDataThisWeek, widget.eventDataUpcoming];

    // search all events for anything that matches user's input
    for (var i = 0; i < allEvents.length; i++) {

      List<dynamic> eventList = allEvents[i];
      List<dynamic> matches = [];

      for (var event in eventList) {
        print("event: ${event}");
        var title = event['title'];
        var desc = event['description'];
        var location = event['location'];
        var values = [title.toString(), desc.toString(), location.toString()];
        final textToSearch = Fuzzy(values);
        final result = textToSearch.search(searchText);

        // add to list of search matches if result returns something
        if (result.isNotEmpty) {
          matches.add(event);
        }
      }

      // update event lists with matches
      setState(() {
        if (allEvents[i] == widget.eventDataToday) {
          widget.eventDataToday = matches;
        }
        else if (allEvents[i] == widget.eventDataThisWeek) {
          widget.eventDataThisWeek = matches;
        }
        else {
          widget.eventDataUpcoming = matches;
        }
      });

      sortData();
    }
  }
}

bool isSameDate(DateTime time1, DateTime time2) {
  if (time1.year == time2.year &&
      time1.month == time2.month &&
      time1.day == time2.day) {
    return true;
  }
  return false;
}

bool isWithinUpcomingWeek(DateTime date1, DateTime date2) {
  final now = DateTime.now();
  final upcomingWeekStart =
      now.subtract(Duration(days: now.weekday - 1)).toUtc();
  final upcomingWeekEnd = upcomingWeekStart.add(Duration(days: 7)).toUtc();
  final start = date1.isBefore(date2) ? date1 : date2;
  final end = date1.isBefore(date2) ? date2 : date1;
  return start.isAfter(upcomingWeekStart) && end.isBefore(upcomingWeekEnd);
}

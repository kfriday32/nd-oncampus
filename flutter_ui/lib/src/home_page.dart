import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'navigation.dart';
import 'events_page.dart';
import 'publisher_page.dart';
import 'events_list.dart';
import 'helpers.dart';

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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PublisherPage()));
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
          : TabBarView(
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
    );
  }

  void _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(helpers.getUri()));

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

          widget.eventDataToday.sort((a, b) => a['time'].compareTo(b['time']));
          widget.eventDataThisWeek
              .sort((a, b) => a['time'].compareTo(b['time']));
          widget.eventDataUpcoming
              .sort((a, b) => a['time'].compareTo(b['time']));
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

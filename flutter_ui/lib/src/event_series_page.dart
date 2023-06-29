import 'package:intl/intl.dart';
import 'event_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/src/interests_page.dart';
import 'package:flutter_ui/src/user_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'navigation.dart';
import 'events_page.dart';
import 'package:fuzzy/fuzzy.dart';
import 'events_list.dart';
import 'helpers.dart';
import 'home_page.dart';

class SeriesList extends StatefulWidget {
  //final AppNavigator navigator;
  List<dynamic> eventDataToday = [];
  List<dynamic> eventDataThisWeek = [];
  List<dynamic> eventDataUpcoming = [];

  //SeriesList({Key? key, required this.navigator}) : super(key: key);
  SeriesList({Key? key}) : super(key: key);
  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = [
    const Tab(text: 'Upcoming'),
  ];

  late TabController _tabController;
  bool displaySearch = false;
  final searchCont = TextEditingController();
  bool _isAllLoading = false; //true;
  bool _showErrorScreen = false;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the number of tabs and this class as the provider
    _tabController = TabController(length: myTabs.length, vsync: this);
    // _loadAllEvents();
    // _loadSuggestedEvents();
    // _loadFollowingEvents();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Series',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        bottom: TabBar(
          controller: _tabController, // Set the controller for the TabBar
          tabs: myTabs,
          indicatorColor: const Color(0xFFd39F10),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isAllLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(),
                            EventsList(
                                eventDataToday: widget.eventDataToday,
                                eventDataThisWeek: widget.eventDataThisWeek,
                                eventDataUpcoming: widget.eventDataUpcoming,
                                refreshFollowing: _loadSeriesEvents),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadSeriesEvents() async {
    if (mounted) {
      setState(() {
        _isAllLoading = true;
      });
    }
    try {
      final response = await http.get(Uri.parse('${Helpers.getUri()}/series'));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            // Clear existing data
            widget.eventDataToday = [];
            widget.eventDataThisWeek = [];
            widget.eventDataUpcoming = [];

            final DateTime now = DateTime.now();
            for (var event in jsonDecode(response.body)) {
              event['startTime'] = DateTime.parse(event['startTime']!);
              event['endTime'] = DateTime.parse(event['endTime']!);

              if (event['startTime'].isBefore(now)) {
                continue;
              }

              if (isSameDate(now, event['startTime'])) {
                widget.eventDataToday.add(event);
              } else if (isWithinUpcomingWeek(now, event['startTime'])) {
                widget.eventDataThisWeek.add(event);
              } else {
                widget.eventDataUpcoming.add(event);
              }
            }

            widget.eventDataToday
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
            widget.eventDataThisWeek
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
            widget.eventDataUpcoming
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
          });
        }
      } else {
        throw Exception("Failed to load all events.");
      }
    } catch (e) {
      throw Exception('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAllLoading = false;
        });
      }
    }
  }
}

// Functions
bool isSameDate(DateTime time1, DateTime time2) {
  if (time1.year == time2.year &&
      time1.month == time2.month &&
      time1.day == time2.day) {
    return true;
  }
  return false;
}

bool isWithinUpcomingWeek(DateTime date1, DateTime date2) {
  final nextWeekStart = date1.add(Duration(days: 7 - date1.weekday));
  final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));
  return date2.isAfter(nextWeekStart.subtract(const Duration(days: 1))) &&
      date2.isBefore(nextWeekEnd.add(const Duration(days: 1)));
}

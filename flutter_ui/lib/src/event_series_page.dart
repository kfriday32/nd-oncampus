import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'events_list.dart';
import 'helpers.dart';

class SeriesList extends StatefulWidget {
  //final AppNavigator navigator;
  List<dynamic> eventDataToday = [];
  List<dynamic> eventDataThisWeek = [];
  List<dynamic> eventDataUpcoming = [];
  String seriesId = '';

  SeriesList({Key? key, required this.seriesId}) : super(key: key);
  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {
  bool _isAllLoading = false; //true;
  String? seriesName;
  String? seriesDescription;

  @override
  void initState() {
    super.initState();
    _loadSeriesEvents();
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
        title: FittedBox(
          fit: BoxFit.contain,
          child: Center(
            child: Text(
              seriesName ?? 'Event Series',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isAllLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(children: [
                      Row(
                        children: [
                          const SizedBox(width: 16.0),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              seriesDescription ?? '',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          )),
                          const SizedBox(width: 16.0),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      EventsList(
                          eventDataToday: widget.eventDataToday,
                          eventDataThisWeek: widget.eventDataThisWeek,
                          eventDataUpcoming: widget.eventDataUpcoming,
                          refreshFollowing: () => {}),
                    ]),
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
      // Retrieve seriesinfo
      final seriesInfoResponse = await http.get(Uri.parse(
          '${Helpers.getUri()}/seriesinfo?seriesId=${widget.seriesId}'));
      if (seriesInfoResponse.statusCode == 200) {
        //final seriesInfo = seriesInfoResponse.body;
        final seriesInfo = jsonDecode(seriesInfoResponse.body);
        seriesName = seriesInfo["seriesName"];
        seriesDescription = seriesInfo["seriesDescription"];

        // retrieve series events
        final response = await http.get(Uri.parse(
            '${Helpers.getUri()}/series?seriesId=${widget.seriesId}'));
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
      } else {
        throw Exception("Failed to load series information.");
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
  final thisWeekEnd = date1.add(const Duration(days: 6));
  return date2.isAfter(date1) &&
      date2.isBefore(thisWeekEnd.add(const Duration(days: 1)));
}

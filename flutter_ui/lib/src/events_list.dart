import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_detail_page.dart';

class EventsList extends StatelessWidget {
  List<dynamic> eventDataToday = [];
  List<dynamic> eventDataThisWeek = [];
  List<dynamic> eventDataUpcoming = [];

  EventsList(
      {Key? key,
      required this.eventDataToday,
      required this.eventDataThisWeek,
      required this.eventDataUpcoming})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              EventsListSection(
                title: 'Today',
                events: eventDataToday,
                displayTime: true,
              ),
              const SizedBox(
                height: 20,
              ),
              EventsListSection(
                title: 'This Week',
                events: eventDataThisWeek,
                displayTime: false,
              ),
              const SizedBox(
                height: 20,
              ),
              EventsListSection(
                title: 'Upcoming',
                events: eventDataUpcoming,
                displayTime: false,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class EventsListSection extends StatelessWidget {
  String title = "";
  List<dynamic> events = [];
  bool displayTime = false;

  EventsListSection(
      {Key? key,
      required this.title,
      required this.events,
      required this.displayTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            final event = events[index];
            final String eventTitle = event['title']!;
            final String eventLocation = event['location']!;
            final String eventTime =
                DateFormat('h:mm a').format(event['startTime']!);
            final String eventMonth =
                DateFormat('MMM').format(event['startTime']);
            final String eventDay = event['startTime'].day.toString();

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(event: events[index]),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                ),
                child: Container(
                  height: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.5),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200]!,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7.5),
                              bottomLeft: Radius.circular(7.5),
                            ),
                          ),
                          child: displayTime
                              ? Center(
                                  child: Text(
                                    eventTime,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0,
                                      height: 1.25,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        eventDay,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2.5),
                                      Text(
                                        eventMonth,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  eventTitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2.5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Hosted by ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Colors.grey[500]!,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        event['host'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2.5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Colors.grey[500]!,
                                    ),
                                    const SizedBox(width: 2.5),
                                    Expanded(
                                      child: Text(
                                        eventLocation,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.grey[500]!,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

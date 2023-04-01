import 'package:flutter/material.dart';
import 'navigation.dart';
import 'events_page.dart';
import 'publisher_page.dart';
import 'package:fuzzy/fuzzy.dart';

class HomePage extends StatefulWidget {
  final AppNavigator navigator;
  static const eventData = [
    {
      '_id': '1',
      'title': 'Bingo Night',
      'location': 'Duncan Student Center',
      'time': '5:07 PM',
      'day': '5',
      'month': 'Apr',
    },
    {
      '_id': '2',
      'title': 'Thursday Night at CJs',
      'location': 'CJs Pub',
      'time': '5:07 PM',
      'day': '5',
      'month': 'Apr',
    },
    {
      '_id': '3',
      'title': 'DomerFest',
      'location': 'DeBartolo Quad',
      'time': '5:07 PM',
      'day': '5',
      'month': 'Apr',
    },
  ];

  const HomePage({Key? key, required this.navigator}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = [
    Tab(text: 'Upcoming'),
    Tab(text: 'Suggested'),
  ];

  late TabController _tabController;
  bool displaySearch = false;
  final searchCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the number of tabs and this class as the provider
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Dispose of the controller when the widget is removed from the tree
    super.dispose();
  }

  // method performs search query on events in main page
  List<Map<String,String>> searchEvents() {
    
    // get user input from search bar
    String searchText = searchCont.text;
    print("search text: ${searchText}");

    List<Map<String,String>> matches = [];

    // search events for anything that matches user's input
    for (var event in HomePage.eventData) {
      var values = event.values;
      print("val: ${values}");
      List<dynamic> valList = values.toList() as List<dynamic>;
      final textToSearch = Fuzzy(valList);
      final result = textToSearch.search(searchText);
      print(result);

      // add to list of search matches if result returns something
      if (result.isNotEmpty) {
        matches.add(event);
      }
    }

    print("matches: ${matches}");
    return matches;
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
        ],
        bottom: TabBar(
          controller: _tabController, // Set the controller for the TabBar
          tabs: myTabs,
          indicatorColor: const Color(0xFFd39F10),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // display search text box if search button is clicked
                      displaySearch ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (
                          TextField(
                            controller: searchCont,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              prefixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: searchEvents
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          )
                        ),
                      ) : SizedBox(height: 0),
                      const SizedBox(height: 20),
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: HomePage.eventData.length,
                        itemBuilder: (BuildContext context, int index) {
                          final eventTitle =
                              HomePage.eventData[index]['title']!;
                          final eventLocation =
                              HomePage.eventData[index]['location']!;
                          final eventTime = HomePage.eventData[index]['time']!;
                          final eventDay = HomePage.eventData[index]['day']!;
                          final eventMonth =
                              HomePage.eventData[index]['month']!;

                          return Padding(
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
                                      child: Center(
                                        child: Text(
                                          eventTime,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.0,
                                            height: 1.25,
                                          ),
                                          textAlign: TextAlign.center,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              eventTitle,
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
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    color: Colors.grey[500]!,
                                                  ),
                                                ),
                                                const Text(
                                                  'Student Activities Office',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 7.5),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey[500]!,
                                                ),
                                                const SizedBox(width: 2.5),
                                                Text(
                                                  eventLocation,
                                                  style: TextStyle(
                                                    color: Colors.grey[500]!,
                                                    fontSize: 12,
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
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'This Week',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: HomePage.eventData.length,
                        itemBuilder: (BuildContext context, int index) {
                          final eventTitle =
                              HomePage.eventData[index]['title']!;
                          final eventLocation =
                              HomePage.eventData[index]['location']!;
                          final eventTime = HomePage.eventData[index]['time']!;
                          final eventDay = HomePage.eventData[index]['day']!;
                          final eventMonth =
                              HomePage.eventData[index]['month']!;

                          return Padding(
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
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              eventTitle,
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
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    color: Colors.grey[500]!,
                                                  ),
                                                ),
                                                const Text(
                                                  'Student Activities Office',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 7.5),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey[500]!,
                                                ),
                                                const SizedBox(width: 2.5),
                                                Text(
                                                  eventLocation,
                                                  style: TextStyle(
                                                    color: Colors.grey[500]!,
                                                    fontSize: 12,
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
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Upcoming',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: HomePage.eventData.length,
                        itemBuilder: (BuildContext context, int index) {
                          final eventTitle =
                              HomePage.eventData[index]['title']!;
                          final eventLocation =
                              HomePage.eventData[index]['location']!;
                          final eventTime = HomePage.eventData[index]['time']!;
                          final eventDay = HomePage.eventData[index]['day']!;
                          final eventMonth =
                              HomePage.eventData[index]['month']!;

                          return Padding(
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
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              eventTitle,
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
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    color: Colors.grey[500]!,
                                                  ),
                                                ),
                                                const Text(
                                                  'Student Activities Office',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 7.5),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey[500]!,
                                                ),
                                                const SizedBox(width: 2.5),
                                                Text(
                                                  eventLocation,
                                                  style: TextStyle(
                                                    color: Colors.grey[500]!,
                                                    fontSize: 12,
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
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Suggested',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: HomePage.eventData.length,
                        itemBuilder: (BuildContext context, int index) {
                          final eventTitle =
                              HomePage.eventData[index]['title']!;
                          final eventLocation =
                              HomePage.eventData[index]['location']!;
                          final eventTime = HomePage.eventData[index]['time']!;
                          final eventDay = HomePage.eventData[index]['day']!;
                          final eventMonth =
                              HomePage.eventData[index]['month']!;

                          return Padding(
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
                                      child: Center(
                                        child: Text(
                                          eventTime,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.0,
                                            height: 1.25,
                                          ),
                                          textAlign: TextAlign.center,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              eventTitle,
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
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    color: Colors.grey[500]!,
                                                  ),
                                                ),
                                                const Text(
                                                  'Student Activities Office',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 7.5),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey[500]!,
                                                ),
                                                const SizedBox(width: 2.5),
                                                Text(
                                                  eventLocation,
                                                  style: TextStyle(
                                                    color: Colors.grey[500]!,
                                                    fontSize: 12,
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
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

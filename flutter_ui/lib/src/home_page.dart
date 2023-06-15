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

class HomePage extends StatefulWidget {
  final AppNavigator navigator;
  List<dynamic> eventDataToday = [{"_id":{"oid":"64277de37e591aeb3a0a5d2a"},"title":"Women’s Softball vs. Duke","description":"An upcoming softball game promises to be an exciting and competitive event, featuring two skilled teams ready to battle it out on the field. Fans can expect to see impressive displays of athleticism, teamwork, and strategic thinking as the players utilize their individual strengths to score runs and make game-winning plays. With the energy of the crowd and the high stakes of the match, the atmosphere is sure to be electric as both teams give it their all in pursuit of victory.","location":"Softball Stadium","registrationLink":"https://www.google.com/maps","url":"https://und.com/sports/wbball/","capacity":"500","endTime": DateTime.parse("2023-06-16 19:05:00.000"),"startTime": DateTime.parse("2023-06-16 16:05:00.000"),"host":"Notre Dame Athletics"}, {"_id":{"oid":"6427d0d7752c37a7a61969f9"},"title":"Spring Musical “Anything Goes”","description":"When the S.S. American heads out to sea, etiquette and convention head out the portholes as two unlikely pairs set off on the course to true love","location":"Washington Hall","registrationLink":"","url":"http://pemco.weebly.com/anything-goes.html","capacity":"500","endTime": DateTime.parse("2023-06-16 18:35:00.000"),"host":"PEMCo","startTime": DateTime.parse("2023-06-16 16:05:00.000")}, {"_id":{"oid":"6427d255752c37a7a61969fc"},"title":"“In Viaggio: The Travels of Pope Francis” (2023)","description":"This is a film about Pope Francis","location":"Browning Cinema","registrationLink":"https://performingarts.nd.edu/event/15675/in-viaggio-the-travels-of-pope-francis-2023/?utm_source=The+Week&utm_medium=ND+Newsletter&utm_campaign=The+Week&utm_term=Cinema&utm_content=In+Viaggio","url":"","capacity":"","endTime": DateTime.parse("2023-06-16 15:05:00.000"),"host":"Browning Cinema","startTime": DateTime.parse("2023-06-16 12:05:00.000")}];
  List<dynamic> eventDataThisWeek = [{"_id":{"oid":"6427d2a7752c37a7a61969fd"},"title":"Hesburgh Libraries Hackathon 2023","description":"2023 Hesburgh Libraries Hackathon, where teams of undergrads come together to reimagine solutions to everyday problems","location":"Hesburgh Library","registrationLink":"","url":"hackathon.library.nd.edu","capacity":"75","endTime": DateTime.parse("2023-06-20 04:05:00.000"),"host":"Library Staff","startTime": DateTime.parse("2023-06-20 16:05:00.000")}, {"_id":{"oid":"6427d345752c37a7a61969fe"},"title":"Immigration Week","description":"Join the Student Coalition for Immigration Advocacy to celebrate its annual Immigration Week as it hosts events raising awareness for immigration issues and highlighting our migrant community.","location":"Duncan Student Center","registrationLink":"","url":"","capacity":"","endTime": DateTime.parse("2023-06-20 16:05:00.000"),"startTime": DateTime.parse("2023-06-20 16:05:00.000"),"host":"Student Coalition for Immigration Advocacy"}, {"_id":{"oid":"6427d345752c37a7a61969fe"},"title":"Immigration Week","description":"Join the Student Coalition for Immigration Advocacy to celebrate its annual Immigration Week as it hosts events raising awareness for immigration issues and highlighting our migrant community.","location":"Duncan Student Center","registrationLink":"","url":"","capacity":"","endTime": DateTime.parse("2023-06-20 16:05:00.000"),"startTime": DateTime.parse("2023-06-20 16:05:00.000"),"host":"Student Coalition for Immigration Advocacy"}];
  List<dynamic> eventDataUpcoming = [{"_id":{"oid":"64289010583731839d4abb79"},"title":"Grand Scholars Challenge","description":"Technology challenge","location":"Stinson 143","registrationLink":"","url":"","host":"ND College of Engineering","capacity":"10","endTime": DateTime.parse("2023-07-04 18:11:00.000"),"startTime": DateTime.parse("2023-07-04 16:11:00.000")}, {"_id":{"oid":"64290edb7afcf8c7831c3ecd"},"title":"SILLY GOOFY HOURS","host":"OnCampus Staff","description":"Silly goofy hours for three gamers","location":"Stinson Remick","startTime": DateTime.parse("2023-07-04 03:00:00.000"),"endTime": DateTime.parse("2023-07-04 06:00:00.000"),"registrationLink":"https://tinyurl.com/pleasemakeitstop420","eventUrl":"","capacity":""}, {"_id":{"oid":"64292891fb7695307b61bb4e"},"title":"Beers in the AM","host":"Gavin Uhran","description":"Let's drink beers at 9 AM","location":"Stinson Remick","startTime": DateTime.parse("2023-07-04 09:00:00.000"),"endTime": DateTime.parse("2023-07-04 10:00:00.000"),"registrationLink":"","eventUrl":"","capacity":""}];
  List<dynamic> suggestedEventDataToday = [{"_id":{"oid":"64277de37e591aeb3a0a5d2a"},"title":"Women’s Softball vs. Duke","description":"An upcoming softball game promises to be an exciting and competitive event, featuring two skilled teams ready to battle it out on the field. Fans can expect to see impressive displays of athleticism, teamwork, and strategic thinking as the players utilize their individual strengths to score runs and make game-winning plays. With the energy of the crowd and the high stakes of the match, the atmosphere is sure to be electric as both teams give it their all in pursuit of victory.","location":"Softball Stadium","registrationLink":"https://www.google.com/maps","url":"https://und.com/sports/wbball/","capacity":"500","endTime": DateTime.parse("2023-06-16 19:05:00.000"),"startTime": DateTime.parse("2023-06-16 16:05:00.000"),"host":"Notre Dame Athletics"}, {"_id":{"oid":"6427d0d7752c37a7a61969f9"},"title":"Spring Musical “Anything Goes”","description":"When the S.S. American heads out to sea, etiquette and convention head out the portholes as two unlikely pairs set off on the course to true love","location":"Washington Hall","registrationLink":"","url":"http://pemco.weebly.com/anything-goes.html","capacity":"500","endTime": DateTime.parse("2023-06-16 18:35:00.000"),"host":"PEMCo","startTime": DateTime.parse("2023-06-16 16:05:00.000")}, {"_id":{"oid":"6427d255752c37a7a61969fc"},"title":"“In Viaggio: The Travels of Pope Francis” (2023)","description":"This is a film about Pope Francis","location":"Browning Cinema","registrationLink":"https://performingarts.nd.edu/event/15675/in-viaggio-the-travels-of-pope-francis-2023/?utm_source=The+Week&utm_medium=ND+Newsletter&utm_campaign=The+Week&utm_term=Cinema&utm_content=In+Viaggio","url":"","capacity":"","endTime": DateTime.parse("2023-06-16 15:05:00.000"),"host":"Browning Cinema","startTime": DateTime.parse("2023-06-16 12:05:00.000")}];
  List<dynamic> suggestedEventDataThisWeek = [{"_id":{"oid":"6427d2a7752c37a7a61969fd"},"title":"Hesburgh Libraries Hackathon 2023","description":"2023 Hesburgh Libraries Hackathon, where teams of undergrads come together to reimagine solutions to everyday problems","location":"Hesburgh Library","registrationLink":"","url":"hackathon.library.nd.edu","capacity":"75","endTime": DateTime.parse("2023-06-20 04:05:00.000"),"host":"Library Staff","startTime": DateTime.parse("2023-06-20 16:05:00.000")}, {"_id":{"oid":"6427d345752c37a7a61969fe"},"title":"Immigration Week","description":"Join the Student Coalition for Immigration Advocacy to celebrate its annual Immigration Week as it hosts events raising awareness for immigration issues and highlighting our migrant community.","location":"Duncan Student Center","registrationLink":"","url":"","capacity":"","endTime": DateTime.parse("2023-06-20 16:05:00.000"),"startTime": DateTime.parse("2023-06-20 16:05:00.000"),"host":"Student Coalition for Immigration Advocacy"}, {"_id":{"oid":"6427d345752c37a7a61969fe"},"title":"Immigration Week","description":"Join the Student Coalition for Immigration Advocacy to celebrate its annual Immigration Week as it hosts events raising awareness for immigration issues and highlighting our migrant community.","location":"Duncan Student Center","registrationLink":"","url":"","capacity":"","endTime": DateTime.parse("2023-06-20 16:05:00.000"),"startTime": DateTime.parse("2023-06-20 16:05:00.000"),"host":"Student Coalition for Immigration Advocacy"}];
  List<dynamic> suggestedEventDataUpcoming = [{"_id":{"oid":"64289010583731839d4abb79"},"title":"Grand Scholars Challenge","description":"Technology challenge","location":"Stinson 143","registrationLink":"","url":"","host":"ND College of Engineering","capacity":"10","endTime": DateTime.parse("2023-07-04 18:11:00.000"),"startTime": DateTime.parse("2023-07-04 16:11:00.000")}, {"_id":{"oid":"64290edb7afcf8c7831c3ecd"},"title":"SILLY GOOFY HOURS","host":"OnCampus Staff","description":"Silly goofy hours for three gamers","location":"Stinson Remick","startTime": DateTime.parse("2023-07-04 03:00:00.000"),"endTime": DateTime.parse("2023-07-04 06:00:00.000"),"registrationLink":"https://tinyurl.com/pleasemakeitstop420","eventUrl":"","capacity":""}, {"_id":{"oid":"64292891fb7695307b61bb4e"},"title":"Beers in the AM","host":"Gavin Uhran","description":"Let's drink beers at 9 AM","location":"Stinson Remick","startTime": DateTime.parse("2023-07-04 09:00:00.000"),"endTime": DateTime.parse("2023-07-04 10:00:00.000"),"registrationLink":"","eventUrl":"","capacity":""}];
  List<dynamic> followingEventDataToday = [{"_id":{"oid":"64277de37e591aeb3a0a5d2a"},"title":"Women’s Softball vs. Duke","description":"An upcoming softball game promises to be an exciting and competitive event, featuring two skilled teams ready to battle it out on the field. Fans can expect to see impressive displays of athleticism, teamwork, and strategic thinking as the players utilize their individual strengths to score runs and make game-winning plays. With the energy of the crowd and the high stakes of the match, the atmosphere is sure to be electric as both teams give it their all in pursuit of victory.","location":"Softball Stadium","registrationLink":"https://www.google.com/maps","url":"https://und.com/sports/wbball/","capacity":"500","endTime": DateTime.parse("2023-06-16 19:05:00.000"),"startTime": DateTime.parse("2023-06-16 16:05:00.000"),"host":"Notre Dame Athletics"}, {"_id":{"oid":"6427d0d7752c37a7a61969f9"},"title":"Spring Musical “Anything Goes”","description":"When the S.S. American heads out to sea, etiquette and convention head out the portholes as two unlikely pairs set off on the course to true love","location":"Washington Hall","registrationLink":"","url":"http://pemco.weebly.com/anything-goes.html","capacity":"500","endTime": DateTime.parse("2023-06-16 18:35:00.000"),"host":"PEMCo","startTime": DateTime.parse("2023-06-16 16:05:00.000")}, {"_id":{"oid":"6427d255752c37a7a61969fc"},"title":"“In Viaggio: The Travels of Pope Francis” (2023)","description":"This is a film about Pope Francis","location":"Browning Cinema","registrationLink":"https://performingarts.nd.edu/event/15675/in-viaggio-the-travels-of-pope-francis-2023/?utm_source=The+Week&utm_medium=ND+Newsletter&utm_campaign=The+Week&utm_term=Cinema&utm_content=In+Viaggio","url":"","capacity":"","endTime": DateTime.parse("2023-06-16 15:05:00.000"),"host":"Browning Cinema","startTime": DateTime.parse("2023-06-16 12:05:00.000")}];
  List<dynamic> followingEventDataThisWeek = [{"_id":{"oid":"6427d2a7752c37a7a61969fd"},"title":"Hesburgh Libraries Hackathon 2023","description":"2023 Hesburgh Libraries Hackathon, where teams of undergrads come together to reimagine solutions to everyday problems","location":"Hesburgh Library","registrationLink":"","url":"hackathon.library.nd.edu","capacity":"75","endTime": DateTime.parse("2023-06-20 04:05:00.000"),"host":"Library Staff","startTime": DateTime.parse("2023-06-20 16:05:00.000")}, {"_id":{"oid":"6427d345752c37a7a61969fe"},"title":"Immigration Week","description":"Join the Student Coalition for Immigration Advocacy to celebrate its annual Immigration Week as it hosts events raising awareness for immigration issues and highlighting our migrant community.","location":"Duncan Student Center","registrationLink":"","url":"","capacity":"","endTime": DateTime.parse("2023-06-20 16:05:00.000"),"startTime": DateTime.parse("2023-06-20 16:05:00.000"),"host":"Student Coalition for Immigration Advocacy"}, {"_id":{"oid":"6427d345752c37a7a61969fe"},"title":"Immigration Week","description":"Join the Student Coalition for Immigration Advocacy to celebrate its annual Immigration Week as it hosts events raising awareness for immigration issues and highlighting our migrant community.","location":"Duncan Student Center","registrationLink":"","url":"","capacity":"","endTime": DateTime.parse("2023-06-20 16:05:00.000"),"startTime": DateTime.parse("2023-06-20 16:05:00.000"),"host":"Student Coalition for Immigration Advocacy"}];
  List<dynamic> followingEventDataUpcoming = [{"_id":{"oid":"64289010583731839d4abb79"},"title":"Grand Scholars Challenge","description":"Technology challenge","location":"Stinson 143","registrationLink":"","url":"","host":"ND College of Engineering","capacity":"10","endTime": DateTime.parse("2023-07-04 18:11:00.000"),"startTime": DateTime.parse("2023-07-04 16:11:00.000")}, {"_id":{"oid":"64290edb7afcf8c7831c3ecd"},"title":"SILLY GOOFY HOURS","host":"OnCampus Staff","description":"Silly goofy hours for three gamers","location":"Stinson Remick","startTime": DateTime.parse("2023-07-04 03:00:00.000"),"endTime": DateTime.parse("2023-07-04 06:00:00.000"),"registrationLink":"https://tinyurl.com/pleasemakeitstop420","eventUrl":"","capacity":""}, {"_id":{"oid":"64292891fb7695307b61bb4e"},"title":"Beers in the AM","host":"Gavin Uhran","description":"Let's drink beers at 9 AM","location":"Stinson Remick","startTime": DateTime.parse("2023-07-04 09:00:00.000"),"endTime": DateTime.parse("2023-07-04 10:00:00.000"),"registrationLink":"","eventUrl":"","capacity":""}];

  HomePage({Key? key, required this.navigator}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = [
    const Tab(text: 'Upcoming'),
    const Tab(text: 'Suggested'),
    const Tab(text: 'Following')
  ];

  late TabController _tabController;
  bool displaySearch = false;
  final searchCont = TextEditingController();
  bool _isAllLoading = false; //true;
  bool _isSuggestedLoading = false; //true;
  bool _isFollowingLoading = false; //true;
  bool _showInterestsSuggestion = false;
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
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // _loadAllEvents();
            // _loadSuggestedEvents();
            // _loadFollowingEvents();
          },
        ),
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
              if (mounted) {
                setState(() {
                  displaySearch = !displaySearch;
                });
              }
            },
          ),
        ],
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
                            displaySearch
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: searchCont,
                                      decoration: InputDecoration(
                                        hintText: 'Search',
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            // reset current lists
                                            if (mounted) {
                                              setState(() {
                                                // widget.eventDataToday = [];
                                                // widget.eventDataThisWeek = [];
                                                // widget.eventDataUpcoming = [];

                                                displaySearch = false;
                                              });
                                            }
                                            // repopulate events
                                            // _loadAllEvents();
                                          },
                                        ),
                                        prefixIcon: IconButton(
                                          icon: const Icon(Icons.search),
                                          onPressed: _searchEvents,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey[500]!,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            EventsList(
                                eventDataToday: widget.eventDataToday,
                                eventDataThisWeek: widget.eventDataThisWeek,
                                eventDataUpcoming: widget.eventDataUpcoming,
                                refreshFollowing: () => {},
                                )//_loadFollowingEvents),
                          ],
                        ),
                      ),
                _isSuggestedLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _showErrorScreen
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Center(
                                child: Text(
                                  'AI BROKE\n\nPlease wait a moment and press refresh again.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ],
                          )
                        : _showInterestsSuggestion
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Center(
                                    child: Text(
                                      'You havent saved any interests\n\nClick on the Profile icon and update your Interests!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 40.0,
                                    color: Colors.black,
                                  ),
                                ],
                              )
                            : SingleChildScrollView(
                                child: EventsList(
                                  eventDataToday:
                                      widget.suggestedEventDataToday,
                                  eventDataThisWeek:
                                      widget.suggestedEventDataThisWeek,
                                  eventDataUpcoming:
                                      widget.suggestedEventDataUpcoming,
                                ),
                              ),
                _isFollowingLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: EventsList(
                            eventDataToday: widget.followingEventDataToday,
                            eventDataThisWeek:
                                widget.followingEventDataThisWeek,
                            eventDataUpcoming:
                                widget.followingEventDataUpcoming),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadAllEvents() async {
    if (mounted) {
      setState(() {
        _isAllLoading = true;
      });
    }
    try {
      final response = await http.get(Uri.parse(Helpers.getUri()));

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

  void _loadSuggestedEvents() async {
    if (mounted) {
      setState(() {
        _isSuggestedLoading = true;
      });
    }
    try {
      // call the refresh route
      final response = await http.get(Uri.parse('${Helpers.getUri()}/refresh'));
      if (response.statusCode == 200) {
        _showInterestsSuggestion = false;
        _showErrorScreen = false;
        if (mounted) {
          setState(() {
            // Clear existing data
            widget.suggestedEventDataToday = [];
            widget.suggestedEventDataThisWeek = [];
            widget.suggestedEventDataUpcoming = [];

            final DateTime now = DateTime.now();
            for (var event in jsonDecode(response.body)) {
              event['startTime'] = DateTime.parse(event['startTime']!);
              event['endTime'] = DateTime.parse(event['endTime']!);

              if (event['startTime'].isBefore(now)) {
                continue;
              }

              if (isSameDate(now, event['startTime'])) {
                widget.suggestedEventDataToday.add(event);
              } else if (isWithinUpcomingWeek(now, event['startTime'])) {
                widget.suggestedEventDataThisWeek.add(event);
              } else {
                widget.suggestedEventDataUpcoming.add(event);
              }
            }

            widget.suggestedEventDataToday
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
            widget.suggestedEventDataThisWeek
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
            widget.suggestedEventDataUpcoming
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
          });
        }
      } else if (response.statusCode == 404) {
        // display different things based on the error json
        if (jsonDecode(response.body)['error'] == 'empty') {
          // display a button to go straight to the interests page
          _showInterestsSuggestion = true;
        } else {
          // display a short explaination that the AI is down
          _showErrorScreen = true;
        }
      } else {
        throw Exception("Failed to load suggested events.");
      }
    } catch (e) {
      throw Exception('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSuggestedLoading = false;
        });
      }
    }
  }

  void _loadFollowingEvents() async {
    if (mounted) {
      setState(() {
        _isFollowingLoading = true;
      });
    }
    try {
      String uri = "${Helpers.getUri()}/following";
      final response = await http.get(Uri.parse(uri));

      if (response.statusCode != 200) {
        print('Error: ${response.statusCode}');
      } else {
        if (mounted) {
          setState(() {
            // Clear existing data
            widget.followingEventDataToday = [];
            widget.followingEventDataThisWeek = [];
            widget.followingEventDataUpcoming = [];

            final DateTime now = DateTime.now();
            for (var event in jsonDecode(response.body)) {
              event['startTime'] = DateTime.parse(event['startTime']!);
              event['endTime'] = DateTime.parse(event['endTime']!);

              if (event['startTime'].isBefore(now)) {
                continue;
              }

              if (isSameDate(now, event['startTime'])) {
                widget.followingEventDataToday.add(event);
              } else if (isWithinUpcomingWeek(now, event['startTime'])) {
                widget.followingEventDataThisWeek.add(event);
              } else {
                widget.followingEventDataUpcoming.add(event);
              }
            }

            widget.followingEventDataToday
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
            widget.followingEventDataThisWeek
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
            widget.followingEventDataUpcoming
                .sort((a, b) => a['startTime'].compareTo(b['startTime']));
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFollowingLoading = false;
        });
      }
    }
  }

  // method performs search query on events in main page
  void _searchEvents() {
    // get user input from search bar
    String searchText = searchCont.text;

    List<List<dynamic>> allEvents = [
      widget.eventDataToday,
      widget.eventDataThisWeek,
      widget.eventDataUpcoming
    ];

    // search all events for anything that matches user's input
    for (var i = 0; i < allEvents.length; i++) {
      List<dynamic> eventList = allEvents[i];
      List<dynamic> matches = [];

      for (var event in eventList) {
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
      if (mounted) {
        setState(() {
          if (allEvents[i] == widget.eventDataToday) {
            widget.eventDataToday = matches;
          } else if (allEvents[i] == widget.eventDataThisWeek) {
            widget.eventDataThisWeek = matches;
          } else {
            widget.eventDataUpcoming = matches;
          }
        });
      }

      widget.eventDataToday
          .sort((a, b) => a['startTime'].compareTo(b['startTime']));
      widget.eventDataThisWeek
          .sort((a, b) => a['startTime'].compareTo(b['startTime']));
      widget.eventDataUpcoming
          .sort((a, b) => a['startTime'].compareTo(b['startTime']));
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
  final nextWeekStart = date1.add(Duration(days: 7 - date1.weekday));
  final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));
  return date2.isAfter(nextWeekStart.subtract(const Duration(days: 1))) &&
      date2.isBefore(nextWeekEnd.add(const Duration(days: 1)));
}

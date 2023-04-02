import 'package:flutter/material.dart';
import 'navigation.dart';
import 'pages.dart';
import 'home_page.dart';
import 'events_page.dart';
import 'suggested_page.dart';
import 'publisher_page.dart';
import 'event_detail_page.dart';

class OnCampus extends StatelessWidget {
  OnCampus({super.key});

  final AppNavigator navigator = AppNavigator();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Navigator Example',
      navigatorKey: navigator.navigatorKey,
      routes: {
        '/': (BuildContext context) => Pages(navigator: navigator),
        '/findEvents': (BuildContext context) => EventsPage(),
        '/suggestedEvents': (BuildContext context) => SuggestedPage(events: []),
        '/publishEvents': (BuildContext context) => PublisherPage(),
        '/eventDetails': (BuildContext context) => EventDetailPage()
      },
    );
  }
}

class OnCampusState extends ChangeNotifier {}

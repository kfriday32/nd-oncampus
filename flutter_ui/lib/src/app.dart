import 'package:flutter/material.dart';
import 'navigation.dart';
import 'home_page.dart';
import 'events_page.dart';
import 'suggested_page.dart';
import 'publisher_page.dart';

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
        '/': (BuildContext context) => HomePage(navigator: navigator),
        '/findEvents': (BuildContext context) => EventsPage(),
        '/suggestedEvents': (BuildContext context) => SuggestedPage(events: []),
        '/publishEvents': (BuildContext context) => PublisherPage()
      },
    );
  }
}

class OnCampusState extends ChangeNotifier {}

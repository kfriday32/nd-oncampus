import 'package:flutter/material.dart';
import 'navigation.dart';
import 'home_page.dart';

class OnCampus extends StatelessWidget {
  OnCampus({super.key});

  final AppNavigator navigator = AppNavigator();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigator Example',
      navigatorKey: navigator.navigatorKey,
      routes: {
        '/': (BuildContext context) => HomePage(navigator: navigator),
      },
    );
  }
}

class OnCampusState extends ChangeNotifier {}

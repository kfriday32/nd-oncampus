import 'package:flutter/material.dart';
import 'navigation.dart';
import 'pages.dart';

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
      },
    );
  }
}

class OnCampusState extends ChangeNotifier {}

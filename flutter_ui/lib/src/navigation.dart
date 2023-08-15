import 'package:flutter/material.dart';

class AppNavigator {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  void navigateToHomePage() {
    navigateTo('/home_page');
  }
}

import 'package:flutter/material.dart';

class SuggestedPage extends StatelessWidget {
  // require a list of events
  const SuggestedPage({super.key, required this.events});

  final List<String> events;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Suggested Page'),
        ),
        body: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(events[index]));
          },
        ));
  }
}

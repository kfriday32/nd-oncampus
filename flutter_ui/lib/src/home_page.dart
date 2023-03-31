import 'package:flutter/material.dart';
import 'navigation.dart';

class HomePage extends StatelessWidget {
  final AppNavigator navigator;
  static const eventData = [
    {'title': 'Bingo Night', 'who': 'seniors only'},
    {'title': 'CJs', 'who': 'anyone 21+'},
    {'title': 'domerfest', 'who': 'freshman'},
    {'title': 'Bingo Night', 'who': 'seniors only'},
    {'title': 'CJs', 'who': 'anyone 21+'},
    {'title': 'domerfest', 'who': 'freshman'},
    {'title': 'Bingo Night', 'who': 'seniors only'},
    {'title': 'CJs', 'who': 'anyone 21+'},
    {'title': 'domerfest', 'who': 'freshman'},
    {'title': 'Bingo Night', 'who': 'seniors only'},
    {'title': 'CJs', 'who': 'anyone 21+'},
    {'title': 'domerfest', 'who': 'freshman'},
    {'title': 'Bingo Night', 'who': 'seniors only'},
    {'title': 'CJs', 'who': 'anyone 21+'},
    {'title': 'domerfest', 'who': 'freshman'},
    {'title': 'Bingo Night', 'who': 'seniors only'},
    {'title': 'CJs', 'who': 'anyone 21+'},
    {'title': 'domerfest', 'who': 'freshman'},
    {'title': 'Bingo Night', 'who': 'seniors only'},
    {'title': 'CJs', 'who': 'anyone 21+'},
    {'title': 'domerfest', 'who': 'freshman'},
  ];

  const HomePage({Key? key, required this.navigator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OnCampus'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {},
        ),
      ]),
      body: ListView.builder(
        itemCount: eventData.length,
        itemBuilder: (BuildContext context, int index) {
          final eventTitle = eventData[index]['title']!;
          final eventGuests = eventData[index]['who']!;
          return ListTile(
            title: Text(eventTitle),
            subtitle: Text(eventGuests),
          );
        },
      ),
    );
  }
}

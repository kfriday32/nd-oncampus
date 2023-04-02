import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text('User Profile Page'),
        SizedBox(height: 10),
        Text('Text 2'),
      ],
    );
  }
}

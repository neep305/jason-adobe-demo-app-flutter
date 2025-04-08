import 'package:flutter/material.dart';

class PersonalizationPage extends StatelessWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adobe Demo'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Center(
        child: Column(
          children: [
            Text(
              'Personalization Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
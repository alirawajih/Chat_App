import 'package:flutter/material.dart';

class LodingScreen extends StatelessWidget {
  const LodingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chat App'),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Circular progress indicator',
        ),
      ),
    );
  }
}

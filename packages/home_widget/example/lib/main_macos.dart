import 'package:flutter/material.dart';

void main() => runApp(const MacOSExample());

class MacOSExample extends StatelessWidget {
  const MacOSExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Home Widget',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.widgets_outlined, size: 48),
              SizedBox(height: 16),
              Text('Home Widget', style: TextStyle(fontSize: 24)),
              SizedBox(height: 8),
              Text('Add HomeWidget macOS from your Mac’s widget gallery.'),
            ],
          ),
        ),
      ),
    );
  }
}

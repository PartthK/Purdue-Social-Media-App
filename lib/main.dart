import 'package:flutter/material.dart';
import 'navigation.dart';  // Add this import
import 'theme.dart';  // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: BoilerVibeTheme.theme,  // Use BoilerVibeTheme here
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'BoilerVibe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: NavigationPage(),  // Use NavigationPage here
      ),
    );
  }
}

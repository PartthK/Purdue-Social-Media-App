import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:purdue_social/home_screen.dart';
import 'firebase_options.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoilerVibe',
      theme: BoilerVibeTheme.theme,
      home: HomeScreen(),  // Set NavigationPage as the home page
    );
  }
}

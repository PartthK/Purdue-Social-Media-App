import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:purdue_social/home_screen.dart';
import 'package:purdue_social/auth_screen.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'firebase_options.dart';
import 'interests_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

//Gaur useless

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'BoilerVibe',
            theme: BoilerVibeTheme.lightTheme, // Light theme
            darkTheme: BoilerVibeTheme.darkTheme, // Dark theme
            themeMode: authProvider.themeMode, // Use theme mode from AuthProvider
            home: _getInitialScreen(authProvider),
            routes: {
              '/home': (context) => HomeScreen(),
              '/auth': (context) => AuthScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/interests') {
                final args = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) {
                    return InterestsScreen(name: args);
                  },
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }

  Widget _getInitialScreen(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      return HomeScreen();
    } else {
      return AuthScreen();
    }
  }
}

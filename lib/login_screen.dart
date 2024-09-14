
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as custom_auth;
import 'signup_screen.dart';
import 'forgot_password_screen.dart';  // Import the ForgotPasswordScreen
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _validationMessage = '';
  bool _isDarkMode = true;

  void _validateAndLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (!email.endsWith('@purdue.edu')) {
      setState(() {
        _validationMessage = 'Only @purdue.edu emails are allowed';
      });
    } else {
      setState(() {
        _validationMessage = '';
      });
      try {
        await Provider.of<custom_auth.AuthProvider>(context, listen: false).login(email, password);

      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'invalid-credential') {
            _validationMessage = 'The supplied auth credential is incorrect, malformed or has expired.';
          } else if (e.code == 'user-not-found') {
            _validationMessage = 'No user found for that email.';
          } else if (e.code == 'wrong-password') {
            _validationMessage = 'Wrong password provided for that user.';
          } else {
            _validationMessage = 'An unexpected error occurred. Please try again.';
          }
        });
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Color(0xFF0D1114) : Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: _toggleTheme,
          child: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
          mini: true,
          backgroundColor: _isDarkMode ? Colors.white : Colors.black,
          foregroundColor: _isDarkMode ? Colors.black : Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BoilerVibe',
              style: GoogleFonts.outfit(
                fontSize: 42.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                filled: true,
                fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.person, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                filled: true,
                fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _validateAndLogin,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isDarkMode ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.montserrat(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text(
                'Don\'t have an account? Sign up',
                style: GoogleFonts.montserrat(
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),  // Navigate to ForgotPasswordScreen
                );
              },
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.montserrat(
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (_validationMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _validationMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

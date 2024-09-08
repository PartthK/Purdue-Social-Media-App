import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isDarkMode = true; // To match with the Sign-Up screen

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent! Please check your inbox.')),
      );
      _emailController.clear();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'user-not-found':
          message = 'There is no user corresponding to this email address.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(),
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
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Forgot Password',
              style: GoogleFonts.montserrat(
                fontSize: 42.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Enter your email address to receive a password reset link.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16.0,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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
                prefixIcon: Icon(Icons.email, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isDarkMode ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                'Send Reset Link',
                style: GoogleFonts.montserrat(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
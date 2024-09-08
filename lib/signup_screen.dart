import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'interests_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _validationMessage = '';
  bool _isDarkMode = true;

  void _validateAndSignup() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (!email.endsWith('@purdue.edu')) {
      setState(() {
        _validationMessage = 'Only @purdue.edu emails are allowed';
      });
    } else if (password.length < 6) {
      setState(() {
        _validationMessage = 'Password must be at least 6 characters long';
      });
    } else {
      setState(() {
        _validationMessage = '';
      });
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signup(name, email, password);

        // Navigate to InterestsScreen and pass the name
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InterestsScreen(name: name)),
        );
      } catch (e) {
        setState(() {
          _validationMessage = 'Sign-up failed: ${e.toString()}';
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
    return WillPopScope(
      onWillPop: () async {
        // Prevent the back button from doing anything
        return false;
      },
      child: Scaffold(
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
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: Padding(
          padding: EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign Up',
                style: GoogleFonts.montserrat(
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _nameController,
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Name',
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
                  prefixIcon: Icon(Icons.email, color: Colors.grey),
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
                onPressed: _validateAndSignup,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _isDarkMode ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                ),
                child: Text(
                  'Sign Up',
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
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Login',
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
      ),
    );
  }
}
